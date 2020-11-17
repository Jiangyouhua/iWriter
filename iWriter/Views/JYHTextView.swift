//
//  JYHTextView.swift
//  iWriter
//
//  Created by 姜友华 on 2020/10/13.
//  Copyright © 2020 Jiangyouhua. All rights reserved.
//

import Cocoa

class JYHTextView: NSTextView {
    
    var placeHolder: String = "Please enter ..."
    
    var chapter: Chapter?
//    internal override var layoutManager: JYHLayoutManager?
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        if string.isEmpty {
            let m = [NSAttributedString.Key.foregroundColor: NSColor.gray]
            let s = NSAttributedString(string: placeHolder, attributes: m)
            s.draw(at: NSMakePoint(10, 10))
        }
    }
}
