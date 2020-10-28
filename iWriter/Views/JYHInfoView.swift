//
//  JYHContentView.swift
//  iWriter
//
//  Created by 姜友华 on 2020/10/9.
//  Copyright © 2020 Jiangyouhua. All rights reserved.
//  多个
//

import Cocoa

class JYHInfoView: NSView, NSTextViewDelegate {
    
    let works = (NSApp.delegate as! AppDelegate).works
    var editing: NSScrollView?
    var active = false
    var views: Dictionary<Int, NSScrollView> = Dictionary<Int, NSScrollView>()
    var managers: Dictionary<Int, UndoManager> = Dictionary<Int, UndoManager>()
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    func format() {
        self.autoresizesSubviews = true
        layout()
    }
    
    override func layout(){
        if works.info.chapterEditing.creation == 0 {
            return
        }
        if works.info.chapterOpened.count == 0 {
            editing?.removeFromSuperview()
            return
        }
        // 各章节对应一个编辑器，有则拿来用，没有则新建。
        var view = views[works.info.chapterEditing.creation]
        if view == nil {
            view = item(chapter: works.info.chapterEditing)
        }
        view!.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: self.frame.size)
        if view == editing {
            return
        }
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
            try works.readContentFile(chapter: chapter)
        } catch {
            print(error)
        }
        
        // 实例化。
        let scrollView = JYHTextView.scrollableTextView()
        
        scrollView.hasHorizontalScroller = true
//        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        let textView = scrollView.documentView as! JYHTextView
        textView.allowsUndo = true
        textView.string = chapter.info
        textView.delegate = self
        textView.chapter = chapter
        textView.placeHolder = chapter.title + "：提要"
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
        view.chapter!.info = view.string
        do {
            try works.writeContentFile(chapter: view.chapter!)
        } catch {
            print(error)
        }
    }
}
