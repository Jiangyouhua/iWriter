//
//  TitleTabView.swift
//  iWriter
//
//  Created by Jiangyouhua on 2019/7/20.
//  Copyright © 2019 Jiangyouhua. All rights reserved.
//

import Cocoa

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
    
    var firstMouseDownPoint: NSPoint = NSZeroPoint
    var trackingArea: NSTrackingArea?
    
    var chapter: Chapter
    var active: Bool
    var index: Int = 0
    var isInit: Bool = true
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(chapter: Chapter, active: Bool) {
        self.chapter = chapter
        self.active = active
        super.init(frame: CGRect.zero)
        // 从图获取NSView。
        Bundle.main.loadNibNamed("JYHTitleTabView", owner: self, topLevelObjects: nil)
        self.addSubview(self.view)
        format()                     // 需要在初始化中格式内容，这样在TabsBarView才会先形成图
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
        var width = 35 + label.frame.width
        if width > 200 {
            width = 200
        }
        var frame = self.view.frame
        frame.size.width = width
        self.view.frame = CGRect.init(x: 0, y: 0, width: frame.width, height: frame.height)
        frame.origin.y = -4
        self.frame = frame
        
        self.wantsLayer = true;
        self.isActive(b: active)
        self.layer?.borderColor = tabBorderColor()
        self.layer?.borderWidth = 0.5;
        self.layer?.cornerRadius = 4;
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
    
    override func draw(_ dirtyRect: NSRect) {
        /// 改变底图颜色。
//        NSColor.white.setFill()
//        dirtyRect.fill()
        super.draw(dirtyRect)
    
    }
}
