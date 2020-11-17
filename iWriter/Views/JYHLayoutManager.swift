//
//  JYHLayoutManager.swift
//  iWriter
//
//  Created by 姜友华 on 2020/11/16.
//  Copyright © 2020 Jiangyouhua. All rights reserved.
//

import Cocoa

class JYHLayoutManager: NSLayoutManager {
    // 改下划线为实现圆角背景。
    override func drawUnderline(forGlyphRange glyphRange: NSRange,
        underlineType underlineVal: NSUnderlineStyle,
        baselineOffset: CGFloat,
        lineFragmentRect lineRect: CGRect,
        lineFragmentGlyphRange lineGlyphRange: NSRange,
        containerOrigin: CGPoint
    ) {
        let firstPosition  = location(forGlyphAt: glyphRange.location).x
        let lastPosition: CGFloat
        if NSMaxRange(glyphRange) < NSMaxRange(lineGlyphRange) {
            lastPosition = location(forGlyphAt: NSMaxRange(glyphRange)).x
        } else {
            lastPosition = lineFragmentUsedRect(
                forGlyphAt: NSMaxRange(glyphRange) - 1,
                effectiveRange: nil).size.width
        }

        var lineRect = lineRect
        let height = lineRect.size.height // replace your under line height
        lineRect.origin.x += firstPosition
        lineRect.size.width = lastPosition - firstPosition
        lineRect.size.height = height
        lineRect.origin.x += containerOrigin.x
        lineRect.origin.y += containerOrigin.y
        lineRect = lineRect.integral.insetBy(dx: 0.5, dy: 0.5)
        let path = NSBezierPath(roundedRect: lineRect, xRadius: 3.0, yRadius: 3.0)
        path.fill()
    }
}
