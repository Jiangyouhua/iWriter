//
//  TitleTabView.swift
//  iWriter
//
//  Created by Jiangyouhua on 2019/7/20.
//  Copyright © 2019 Jiangyouhua. All rights reserved.
//

import Cocoa

protocol JYHTitleTabViewDelegate {
    func tabClicked(tab: JYHTitleTabView)
    func tabClosed(tab: JYHTitleTabView)
    func tabDragStart(tab: JYHTitleTabView, x: CGFloat)
    func tabDragEnd(tab: JYHTitleTabView, x: CGFloat)
}

/**
 ## 标题标签类。
 1. 不能放在Layout设计格式，因为实现比较靠后，无法在Bar中有效排列；
 2. 不能使用init?(coder decoder: NSCoder)，初始化。
 */
class JYHTitleTabView: NSView {
    
    // file's Owner 绑定该类后再建立Outlet。
    @IBOutlet var view: NSView!
    @IBOutlet weak var backView: JYHView!
    @IBOutlet weak var label: NSTextField!
    @IBOutlet weak var button: NSButton!
    
    var delegate: JYHTitleTabViewDelegate?
    var position: NSPoint?
    
    var chapter: Chapter
    var active: Bool
    var index: Int = 0                      // 在数据中的顺序。
    var sort: Int = 0                       // 在视图中的顺序。
    var isInit: Bool = true
    
    init(chapter: Chapter, active: Bool) {
        self.chapter = chapter
        self.active = active
        super.init(frame: CGRect.zero)
        
        // 从图获取NSView。
        if Bundle.main.loadNibNamed("JYHTitleTabView", owner: self, topLevelObjects: nil) {
            self.addSubview(self.view)
            self.wantsLayer = true
        }
        format()                     // 需要在初始化中格式内容，这样在TabsBarView才会先形成图
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layout() {
        if isInit {
            return
        }
        format()
    }
    
    /// 独立出来，方便动态更新。
    func format(){
        // 设置Label。
        backView.backgroundColor = NSColor.selectedControlColor
        label.stringValue = chapter.content
        label.sizeToFit()
        
        // 设置尺寸适匹内容。
        var width = 40 + label.frame.width
        if width > 200 {
            width = 200
        }
        var frame = self.view.frame
        frame.size.width = width
        self.view.frame = CGRect.init(x: 0, y: 0, width: frame.width, height: frame.height)
        frame.origin.y = 0
        self.frame = frame
        
//        self.wantsLayer = true;
        self.isActive(b: active)
    }
    
    /// 添加动态更新方法。
    func update(chapter: Chapter, active: Bool) {
        self.chapter = chapter
        self.active = active
        self.isInit = false
    }
    
    /// 独立出底色修改。
    func isActive(b: Bool){
        backView.isHidden =  !b
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }
    
    /// 鼠标点击。
    override func mouseDown(with event: NSEvent) {
        // 原位置。
        position = (self.window?.contentView?
                        .convert(event.locationInWindow, to: self.superview))!
        delegate?.tabDragStart(tab: self, x: position!.x)
    }
    
    /// 鼠标释放。
    override func mouseUp(with event: NSEvent) {
        if position == nil {
            return
        }
        // 完成移动。
        let point = (self.window?.contentView?.convert(event.locationInWindow, to: self.superview))!
        if abs(point.x - position!.x) > 1 || abs(point.y - position!.y) > 1 {
            delegate?.tabDragEnd(tab: self, x: point.x)
        } else {
            delegate?.tabClicked(tab: self)
        }
        position = nil
    }
    
    /// 关闭Tab。
    @IBAction func buttonClick(_ sender: Any) {
        delegate?.tabClosed(tab: self)
    }
}
