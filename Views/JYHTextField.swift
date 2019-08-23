//
//  JYHTextField.swift
//  iWriter
//
//  Created by Jiangyouhua on 2019/7/22.
//  Copyright © 2019 Jiangyouhua. All rights reserved.
//

import Cocoa

/**
 ## 自定义TextField
 1. 实现获取焦点后全选文本。
 */
class JYHTextField: NSTextField {
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        // Drawing code here。
    }
    
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        self.currentEditor()?.selectAll(self)
    }
}
