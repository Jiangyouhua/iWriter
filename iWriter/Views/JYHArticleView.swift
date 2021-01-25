//
//  JYHContentView.swift
//  iWriter
//
//  Created by 姜友华 on 2020/10/9.
//  Copyright © 2020 Jiangyouhua. All rights reserved.
//

import Cocoa

protocol JYHContentViewDelegate {
    func contentDidChange(chapter: Chapter)
}

class JYHArticleView: NSView, NSTextViewDelegate, NSTextStorageDelegate {
    
    var delegate: JYHContentViewDelegate?
    
    let works = (NSApp.delegate as! AppDelegate).works
    var count = 0
    var editing: NSScrollView?
    var active = false
    var views: Dictionary<Int, NSScrollView> = Dictionary<Int, NSScrollView>()
    var managers: Dictionary<Int, UndoManager> = Dictionary<Int, UndoManager>()
    var search: Search?  // 当前搜索。
    var mark: Mark?  // 当前选择。
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    func format() {
        views = Dictionary<Int, NSScrollView>()
        layout()
    }
    
    override func layout(){
        if works.info.chapterOpened.count == 0 {
            self.subviews.forEach{$0.removeFromSuperview()}
            return
        }
        if works.info.chapterEditingId == 0 {
            return
        }
        // 各章节对应一个编辑器，有则拿来用，没有则新建。
        var view = views[works.info.chapterEditingId]
        if view == nil {
            view = item(chapter: works.chapterEditing())
        }
        view!.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: self.frame.size)
        placeHolder(view: view!)
        if view == editing {
            return
        }
        
        // 移除旧的添加当前的。
        editing?.removeFromSuperview()
        self.addSubview(view!)
        
        // 点击tab时，编辑器自动获取焦点。
        if (active){
            view?.becomeFirstResponder()
        }
        active = false
        editing = view
    }
    
    func opened(chapter: Chapter) {
        self.needsLayout = true
    }
    
    func action(chapter: Chapter){
        active = true
        self.needsLayout = true
    }
    
    func deleted(chapter: Chapter) {
        active = true
        self.needsLayout = true
    }
    
    func item(chapter: Chapter) -> NSScrollView {
        // 读取内容。
        do {
            try chapter.readArticleFile()
        } catch {
            print(error)
        }
        
        // 实例化。
        let scrollView = JYHTextView.scrollableTextView()
        scrollView.hasHorizontalScroller = true
        
        let textView = scrollView.documentView as! JYHTextView
        textView.allowsUndo = true
        textView.textContainerInset = NSSize(width: 10, height: 10)
        textView.textStorage?.setAttributedString(NSAttributedString(string: chapter.value))
        textView.delegate = self
        textView.textStorage!.delegate = self
        textView.chapter = chapter
        views[chapter.id] = scrollView
        return scrollView
    }
    
    /// 实现每一个文本编辑器有一个独立的Undo。
    func undoManager(for view: NSTextView) -> UndoManager? {
        guard let v = view as? JYHTextView else {
            return nil
        }
        var manager = managers[v.chapter!.id]
        if manager != nil {
            return manager
        }
        manager = UndoManager()
        managers[v.chapter!.id] = manager
        return manager
    }
    
    func textDidChange(_ notification: Notification) {
        guard let view = (editing?.documentView as? JYHTextView) else {
            return
        }
        textDidChangeFrom(view: view)
    }
    
    func textDidChangeFrom(view: JYHTextView) {
        view.chapter!.article = view.string
        view.chapter!.count = view.string.count
        works.saved = false
        self.delegate?.contentDidChange(chapter: view.chapter!)
        do {
            try works.writeOutlineFile()
            try view.chapter?.writeArticleFile()
        } catch {
            print(error)
        }
    }
    
    func placeHolder(view: NSScrollView) {
        guard let v = view.documentView as? JYHTextView else {
            return
        }
        guard let title = v.chapter?.value else {
            return
        }
        let s = "Content: " + title
        if v.placeHolder == s {
            return
        }
        v.placeHolder = s
        v.needsDisplay = true
    }
    
    func textStorage(_ textStorage: NSTextStorage, didProcessEditing editedMask: NSTextStorageEditActions, range editedRange: NSRange, changeInLength delta: Int) {
        let paragraphStyle = NSMutableParagraphStyle()
        // 两个都赋值才能让光标与文字垂直居中对齐。
//        paragraphStyle.lineSpacing = 3.0
//        paragraphStyle.lineHeightMultiple = 1.2
//        paragraphStyle.firstLineHeadIndent = 0
//        paragraphStyle.paragraphSpacing = 1.0
        textStorage.addAttributes([.paragraphStyle : paragraphStyle], range: editedRange)
    }
    
    func updateSearchAttributes(data: [Search], onlyRemove: Bool) {
        guard let view = editing?.documentView as? JYHTextView else {
            return
        }
        guard let article = view.textStorage else {
            return
        }
        guard let item = data.filter({
            return $0.chapter.id == view.chapter?.id
        }).first else {
            return
        }
        
        if search != nil {
            // 移除搜索结果。
            search?.marks.forEach({ mark in
                article.removeAttribute(.backgroundColor, range: NSRange(mark.articleRange, in: article.string))
            })
            if onlyRemove {
                return
            }
        }
        item.marks.forEach({ mark in
            article.setAttributes([.backgroundColor: NSColor.gray], range: NSRange(mark.articleRange, in: article.string))
        })
        search = item
    }
    
    func replaceWordWithSelected(from: String, to: String, item: Any){
        guard let view = editing?.documentView as? JYHTextView else {
            return
        }
        guard let article = view.textStorage else {
            return
        }
        guard let manager = self.undoManager(for: view) else {
            return
        }
        
        // 实现Undo\Redo功能。
        manager.registerUndo(withTarget: self) { target in
            target.replaceWordWithSelected(from: to, to: from, item: item)
        }
        switch item {
        case is Search:
            let search = item as! Search
            var i = 0
                search.marks.forEach({ mark in
                    var r = NSRange(mark.articleRange, in: article.string)
                    r.location += i
                    r.length = from.count
                    article.replaceCharacters(in: r, with: to)
                    i += (to.count - search.word.count)
                })
        case is Mark:
            let mark = item as! Mark
            var r = NSRange(mark.articleRange, in: article.string)
            r.length = from.count
            article.replaceCharacters(in: r, with: to)
        default:
            return
        }
        self.textDidChangeFrom(view: view)
    }
    
    
    func currentSearch(currentMark: Mark){
        // 选择当前。
        guard let view = self.editing?.documentView as? JYHTextView else {
            return
        }
        guard let article = view.textStorage else {
            return
        }
        if mark != nil {
            // 移除前一个，标志现在的。
            let r = NSRange(mark!.articleRange, in: article.string)
            article.removeAttribute(.underlineStyle, range: r)
            article.setAttributes([.backgroundColor: NSColor.gray, .foregroundColor: NSColor.textColor], range: r)
        }
        // 显示当前。
        let r = NSRange(currentMark.articleRange, in: article.string)
        useCustomBackground(range: r, article: article, view: view)
        mark = currentMark
        
        // 定位。
        guard let rect = view.layoutManager?.boundingRect(forGlyphRange: r, in: view.textContainer!) else { return
        }
        view.scrollToVisible(CGRect(x: rect.origin.x - 100, y: rect.origin.y - 100, width: rect.size.width + 200, height: rect.size.height + 200))
    }
    
    // 使用自定义的下线改的圆角背景。
    private func useCustomBackground(range: NSRange, article: NSTextStorage, view: NSTextView) {
        article.setAttributes([.underlineStyle:NSUnderlineStyle.single.rawValue, .underlineColor: NSColor.yellow, .foregroundColor: NSColor.black], range: range)
        let layout = JYHLayoutManager()
        article.addLayoutManager(layout)
        layout.addTextContainer(view.textContainer!)
    }
}
