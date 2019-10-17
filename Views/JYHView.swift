//
//  JYHView.swift
//  iWriter
//
//  Created by 姜友华 on 2019/9/29.
//  Copyright © 2019 Jiangyouhua. All rights reserved.
//

import Cocoa

class JYHView: NSView {

    override func draw(_ dirtyRect: NSRect) {
        NSColor.init(calibratedWhite: 0.85, alpha: 1).setFill()
        dirtyRect.fill();
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
}
