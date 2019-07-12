//
//  ViewController.swift
//  iWriter
//
//  Created by Jiangyouhua on 2019/7/9.
//  Copyright © 2019 Jiangyouhua. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    @IBOutlet weak var leftRightSplitView: NSSplitView!
    @IBOutlet weak var leftAreaView: NSView!
    @IBOutlet weak var centerAreaView: NSView!
    @IBOutlet weak var rightAreaView: NSView!
    @IBOutlet weak var leftAreaSplitView: NSSplitView!
    @IBOutlet weak var centerAreaSplitView: NSSplitView!
    @IBOutlet weak var rightAreaSplitView: NSSplitView!
    
    @IBOutlet weak var catalogBlockView: NSView!
    @IBOutlet weak var noteBlockView: NSView!
    @IBOutlet weak var searchBlockView: NSView!
    @IBOutlet weak var ideaBlockView: NSView!
    @IBOutlet weak var contentBlockView: NSView!
    @IBOutlet weak var outlineBlockView: NSView!
    @IBOutlet weak var roleBlockView: NSView!
    @IBOutlet weak var symbolBlockView: NSView!
    @IBOutlet weak var dictionaryBlockView: NSView!
    
    @IBOutlet weak var tabsBarView: NSView!
    
    @IBOutlet weak var catalogIconButton: NSButton!
    @IBOutlet weak var noteIconButton: NSButton!
    @IBOutlet weak var searchIconButton: NSButton!
    @IBOutlet weak var ideaIconButton: NSButton!
    @IBOutlet weak var outlineIconButton: NSButton!
    @IBOutlet weak var roleIocnButton: NSButton!
    @IBOutlet weak var symbolIconButton: NSButton!
    @IBOutlet weak var dictionaryIconButton: NSButton!
    
    @IBOutlet weak var catalogAddButton: NSButton!
    @IBOutlet weak var noteAddButton: NSButton!
    @IBOutlet weak var roleAddIcon: NSButton!
    @IBOutlet weak var symbolAddButton: NSButton!
    
    @IBOutlet weak var catalogTitleView: NSView!
    @IBOutlet weak var noteTitleView: NSView!
    @IBOutlet weak var searchTitleView: NSView!
    @IBOutlet weak var outlineTitleView: NSView!
    @IBOutlet weak var roleTitleView: NSView!
    @IBOutlet weak var symbolTitleView: NSView!
    @IBOutlet weak var dictionaryTitleView: NSView!
    
    @IBOutlet weak var catalogScrollView: NSScrollView!
    @IBOutlet weak var noteScrollView: NSScrollView!
    @IBOutlet weak var searchScrollView: NSScrollView!
    @IBOutlet weak var ideaScrollView: NSScrollView!
    @IBOutlet weak var contentScrollView: NSScrollView!
    @IBOutlet weak var roleScrollView: NSScrollView!
    @IBOutlet weak var symbolScrollView: NSScrollView!
    @IBOutlet weak var dictionaryScrollView: NSScrollView!
    
    @IBOutlet weak var catalogOutlineView: NSOutlineView!
    @IBOutlet weak var noteOutlineView: NSOutlineView!
    @IBOutlet weak var searchOutlineView: NSOutlineView!
    @IBOutlet weak var roleOutlineView: NSOutlineView!
    @IBOutlet weak var symbolOutlineView: NSOutlineView!
    @IBOutlet weak var dictionaryOutlineView: NSOutlineView!
    
    @IBOutlet var ideaTextView: NSTextView!
    @IBOutlet var contentTextView: NSTextView!
    
    let threshold:CGFloat = 130
    let thickness:CGFloat = 30
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        leftRightSplitView.delegate = self
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
}

/// MARK: - Block Toggle
extension ViewController: NSSplitViewDelegate {
    
    // 显示隐藏目录内容
    @IBAction func catalogIconClick(_ sender: Any) {
        // 判断AreaView是否隐藏
        if catalogTitleView.isHidden {
            // 如隐藏则显示
            return leftAreaShow()
        }
        // 切换本BlockView的显示与隐藏的状态
        if catalogBlockView.frame.height == thickness {
            leftAreaSplitView.setPosition(threshold + thickness, ofDividerAt: 0)
        } else {
            leftAreaSplitView.setPosition( thickness, ofDividerAt: 0)
        }
    }
    
    // 显示隐藏备注内容， 同上
    @IBAction func noteIconClick(_ sender: Any) {
        if noteTitleView.isHidden {
            return leftAreaShow()
        }
        if noteBlockView.frame.height == thickness {
            leftAreaSplitView.setPosition(noteBlockView.frame.origin.y + threshold + thickness, ofDividerAt: 1)
        } else {
            leftAreaSplitView.setPosition(noteBlockView.frame.origin.y + thickness, ofDividerAt: 1)
        }
    }
    
    // 显示隐藏搜索内容， 同上
    @IBAction func searchIconClick(_ sender: Any) {
        if searchTitleView.isHidden {
            return leftAreaShow()
        }
        if searchBlockView.frame.height == thickness {
            leftAreaSplitView.setPosition(leftAreaSplitView.frame.height - threshold - thickness, ofDividerAt: 1)
        } else {
            leftAreaSplitView.setPosition(leftAreaSplitView.frame.height - thickness, ofDividerAt: 1)
        }
    }
    
    // 显示隐藏角色内容，同上
    @IBAction func roleIconClick(_ sender: Any) {
        if roleTitleView.isHidden {
            return rightAreaShow()
        }
        if roleBlockView.frame.height == thickness {
            rightAreaSplitView.setPosition(threshold + thickness, ofDividerAt: 0)
        } else {
            rightAreaSplitView.setPosition( thickness, ofDividerAt: 0)
        }
    }
    
    // 显示隐藏符号内容， 同上
    @IBAction func symbolIconClick(_ sender: Any) {
        if symbolTitleView.isHidden {
            return rightAreaShow()
        }
        if symbolBlockView.frame.height == thickness {
            rightAreaSplitView.setPosition(symbolBlockView.frame.origin.y + threshold + thickness, ofDividerAt: 1)
        } else {
            rightAreaSplitView.setPosition(symbolBlockView.frame.origin.y + thickness, ofDividerAt: 1)
        }
    }
    
    // 显示隐藏字典内容， 同上
    @IBAction func dictionaryIconClick(_ sender: Any) {
        if dictionaryTitleView.isHidden {
            return rightAreaShow()
        }
        if dictionaryBlockView.frame.height == thickness {
            rightAreaSplitView.setPosition(rightAreaSplitView.frame.height - threshold - thickness, ofDividerAt: 1)
        } else {
            rightAreaSplitView.setPosition(rightAreaSplitView.frame.height - thickness, ofDividerAt: 1)
        }
    }
    
    // 显示隐藏想法内容，同上，无AreaView判断
    @IBAction func ideaIconClick(_ sender: Any) {
        if ideaBlockView.frame.height == 0 {
            centerAreaSplitView.setPosition(threshold + thickness, ofDividerAt: 0)
        } else {
            centerAreaSplitView.setPosition( 0, ofDividerAt: 0)
        }
    }
    
    // 显示隐藏大纲内容，同上
    @IBAction func outlineIconClick(_ sender: Any) {
        if outlineBlockView.frame.height == thickness {
            centerAreaSplitView.setPosition(centerAreaSplitView.frame.height - threshold - thickness, ofDividerAt: 1)
        } else {
            centerAreaSplitView.setPosition(centerAreaSplitView.frame.height - thickness, ofDividerAt: 1)
        }
    }
}

/// MARK: - Area Toggle
extension ViewController {
    // 知道各个分划线的位置值，并设置新的位置值
    func splitView(_ splitView: NSSplitView, constrainSplitPosition proposedPosition: CGFloat, ofSubviewAt dividerIndex: Int) -> CGFloat{
        // 左边分割线
        if dividerIndex == 0 {
            // 小于阈值
            if proposedPosition < threshold {
                // 隐藏Left Area View的内容，只保留IconButton
                leftAreaSubviewsIsHidden(true)
                // 并保留30的宽
                return thickness
            }
            leftAreaSubviewsIsHidden(false)
            return proposedPosition
        }
        
        // 右边分割线，如上
        if dividerIndex == 1 {
            if proposedPosition > splitView.frame.size.width - threshold {
                rightAreaSubviewsIsHidden(true)
                return splitView.frame.size.width - thickness
            }
            rightAreaSubviewsIsHidden(false)
            return proposedPosition
        }
        return proposedPosition
    }
    
    // 显示左Left Area View的内容
    func leftAreaShow(){
        let postion = threshold + thickness
        leftRightSplitView.setPosition(postion, ofDividerAt: 0)
        leftAreaSubviewsIsHidden(false)
    }
    
    // 显示左Right Area View的内容
    func rightAreaShow() {
        let postion = leftRightSplitView.frame.size.width - threshold - thickness
        leftRightSplitView.setPosition(postion, ofDividerAt: 1)
        leftAreaSubviewsIsHidden(false)
    }
    
    // 隐藏或显示Left Area View的内容，除IconButton外
    func leftAreaSubviewsIsHidden(_ bool: Bool){
        catalogTitleView.isHidden = bool
        catalogScrollView.isHidden = bool
        noteTitleView.isHidden = bool
        noteScrollView.isHidden = bool
        searchTitleView.isHidden = bool
        searchScrollView.isHidden = bool
    }
    
    // 隐藏或显示Right Area View的内容，除IconButton外
    func rightAreaSubviewsIsHidden(_ bool: Bool){
        roleTitleView.isHidden = bool
        roleScrollView.isHidden = bool
        symbolTitleView.isHidden = bool
        symbolScrollView.isHidden = bool
        dictionaryTitleView.isHidden = bool
        dictionaryScrollView.isHidden = bool
    }
}

