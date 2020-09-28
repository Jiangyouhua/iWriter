//
//  StandInTabView.swift
//  iWriter
//
//  Created by Jiangyouhua on 2019/8/16.
//  Copyright © 2019 Jiangyouhua. All rights reserved.
//

import Cocoa

protocol JYHStuntmanOfTitleTabViewDelegate {
    func tabClose(chapter: Chapter, index: Int)
    func tabClick(view: JYHTitleTabView, chapter: Chapter, index: Int)
    func standInDragEnded(stuntman: JYHStuntmanOfTitleTabView)
}

/**
 ## 替身类，实现移动的标签在最上面。
 */
class JYHStuntmanOfTitleTabView: JYHTitleTabView {
    
    var delegate: JYHStuntmanOfTitleTabViewDelegate?
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        // Drawing code here.
    }
    
    override func mouseDragged(with event: NSEvent) {
        // 计算偏移量，移动到新位置。
        let point = (self.window?.contentView?.convert(event.locationInWindow, to: self))!
        let offset = NSPoint(x: point.x - firstMouseDownPoint.x, y: point.y - firstMouseDownPoint.y)
        let origin = self.frame.origin
        let size = self.frame.size
        self.frame = NSRect(x: origin.x + offset.x, y: origin.y, width: size.width, height: size.height)
        self.layer?.backgroundColor = CGColor.init(gray: 1, alpha: 0.9)
        self.label.textColor = NSColor.init(white: 0, alpha: 0.9)
    }
    
    override func mouseUp(with event: NSEvent) {
        // 完成移动。
        delegate?.standInDragEnded(stuntman: self)
    }
    
    override func mouseDown(with event: NSEvent) {
        // 原位置。
        firstMouseDownPoint = (self.window?.contentView?
            .convert(event.locationInWindow, to: self))!
        delegate?.tabClick(view:self, chapter: chapter, index: index)
    }
    
    /// 关闭Tab。
    @IBAction func buttonClick(_ sender: Any) {
        delegate?.tabClose(chapter: chapter, index: index)
    }
}
