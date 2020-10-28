//
//  JYHView.swift
//  iWriter
//
//  Created by 姜友华 on 2019/9/29.
//  Copyright © 2019 Jiangyouhua. All rights reserved.
//

import Cocoa

class JYHView: NSView {
    // 使用10%不透明度的黑色。
    var backgroundColor: NSColor = NSColor.init(calibratedWhite: 0.5, alpha: 0.1) {
        didSet{
            self.needsLayout = true
        }
    }
    // 作水平分割线用。
    override func draw(_ dirtyRect: NSRect) {
        backgroundColor.setFill()
        dirtyRect.fill();
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    
}
