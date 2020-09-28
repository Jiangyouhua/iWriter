//
//  JYHView.swift
//  iWriter
//
//  Created by 姜友华 on 2019/9/29.
//  Copyright © 2019 Jiangyouhua. All rights reserved.
//

import Cocoa

class JYHLineView: NSView {
    // 作水平分割线用。
    override func draw(_ dirtyRect: NSRect) {
        // 使用10%不透明度的黑色。
        NSColor.init(calibratedWhite: 0.5, alpha: 0.1).setFill()
        dirtyRect.fill();
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
}
