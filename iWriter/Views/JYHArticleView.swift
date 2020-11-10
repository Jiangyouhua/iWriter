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
    var search: Search?
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    func format() {
        views = Dictionary<Int, NSScrollView>()
        layout()
    }
    
    func updateSearchAttributes(data: [Search], onlyRemove: Bool) {
        guard let view = editing?.documentView as? JYHTextView else {
            return
        }
        guard let article = view.textStorage else {
            return
        }
        guard let item = data.filter({
            return $0.chapter.creation == view.chapter?.creation
        }).first else {
            return
        }
        
        if search != nil {
            article.removeAttribute(NSAttributedString.Key.backgroundColor, range: NSRange(location: 0, length: article.string.count))
//            search?.marks.forEach({ mark in
//                article.removeAttribute(NSAttributedString.Key.backgroundColor, range: NSRange(mark.articleRange, in: article.string))
//            })
            if onlyRemove {
                return
            }
        }
        item.marks.forEach({ mark in
            article.setAttributes([NSAttributedString.Key.backgroundColor: NSColor.red], range: NSRange(mark.articleRange, in: article.string))
        })
        search = item
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
        textView.textStorage?.append(chapter.article)
        textView.delegate = self
        textView.textStorage!.delegate = self
        textView.chapter = chapter
        views[chapter.creation] = scrollView
        return scrollView
    }
    
    /// 实现每一个文本编辑器有一个独立的Undo。
    func undoManager(for view: NSTextView) -> UndoManager? {
        guard let v = view as? JYHTextView else {
            return nil
        }
        var manager = managers[v.chapter!.creation]
        if manager != nil {
            return manager
        }
        manager = UndoManager()
        managers[v.chapter!.creation] = manager
        return manager
    }
    
    func textDidChange(_ notification: Notification) {
        guard let view = (editing?.documentView as? JYHTextView) else {
            return
        }
        view.chapter!.article = view.textStorage!
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
        guard let title = v.chapter?.content else {
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
        paragraphStyle.lineSpacing = 3.0
        paragraphStyle.lineHeightMultiple = 1.2
//        paragraphStyle.firstLineHeadIndent = 0
//        paragraphStyle.paragraphSpacing = 1.0
        textStorage.addAttributes([NSAttributedString.Key.paragraphStyle : paragraphStyle], range: editedRange)
    }
}
