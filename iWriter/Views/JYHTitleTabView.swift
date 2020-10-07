//
//  TitleTabView.swift
//  iWriter
//
//  Created by Jiangyouhua on 2019/7/20.
//  Copyright © 2019 Jiangyouhua. All rights reserved.
//

import Cocoa

protocol JYHTitleTabViewDelegate {
    func tabClicked(tab: JYHTitleTabView, dragged: Bool)
    func tabClosed(tab: JYHTitleTabView)
}

/**
 ## 标题标签类。
 1. 不能放在Layout设计格式，因为实现比较靠后，无法在Bar中有效排列；
 2. 不能使用init?(coder decoder: NSCoder)，初始化。
 */
class JYHTitleTabView: NSView {
    
    // file's Owner 绑定该类后再建立Outlet。
    @IBOutlet var view: NSView!
    @IBOutlet weak var label: NSTextField!
    @IBOutlet weak var button: NSButton!
    @IBOutlet weak var splitLine: JYHLineView!
    
    var delegate: JYHTitleTabViewDelegate?
    var oldPoint: NSPoint?
    var dragTab: JYHTitleTabView?
    var dragged: Int = 0            // 是否被拖移。
    
    var chapter: Chapter
    var active: Bool
    var index: Int = 0
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
        label.stringValue = chapter.title
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
        self.layer?.backgroundColor = b ? tabBackgroundColorOfActiveState() : tabBackgroundColorOfNormalState()
    }
    
    func copyItem() -> JYHTitleTabView {
        let item = JYHTitleTabView(chapter: self.chapter, active: self.active)
        item.frame = self.frame
        item.layer?.backgroundColor = self.layer?.backgroundColor?.copy(alpha: 0.5)
        item.label.textColor = NSColor(cgColor: self.label.textColor?.cgColor.copy(alpha: 0.5) ?? CGColor.white)
        item.splitLine.isHidden = true
        // 添加到上级会失去焦点，而无法拖动，所以加两层。
        self.superview?.superview?.addSubview(item)
        return item
    }
    
    override func draw(_ dirtyRect: NSRect) {
        /// 改变底图颜色。
//        NSColor.white.setFill()
//        dirtyRect.fill()
        super.draw(dirtyRect)
    
    }
    
    override func mouseDragged(with event: NSEvent) {
        print("mouseDragged")
        if oldPoint == nil || dragTab == nil {
            return
        }
        dragged += 1
        // 计算偏移量，移动到新位置。
        let newPoint = (self.window?.contentView?.convert(event.locationInWindow, to: dragTab!))!
        let x = newPoint.x - oldPoint!.x + dragTab!.frame.origin.x
        let y = dragTab!.frame.origin.y
        dragTab!.frame = NSRect(x: x, y: y, width: dragTab!.frame.width, height: dragTab!.frame.height)
//        dragTab!.translateOrigin(to: NSPoint(x: x, y: y))
    }
    
    
    override func mouseUp(with event: NSEvent) {
        // 完成移动。
        print("mouseUp")
        delegate?.tabClicked(tab: dragTab!, dragged: dragged > 1)
        dragTab?.removeFromSuperview()
        oldPoint = nil
        dragTab = nil
    }
    
    override func mouseDown(with event: NSEvent) {
        print("mouseDown")
        // 原位置。
        dragTab = self.copyItem()
        oldPoint = (self.window?.contentView?
            .convert(event.locationInWindow, to: dragTab))!
        dragged = 0
    }
    
    /// 关闭Tab。
    @IBAction func buttonClick(_ sender: Any) {
        delegate?.tabClosed(tab: self)
    }
}
