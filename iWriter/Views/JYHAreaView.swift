//
//  JYHAreaView.swift
//  iWriter
//
//  Created by 姜友华 on 2020/4/29.
//  Copyright © 2020 Jiangyouhua. All rights reserved.
//

import Cocoa


class JYHBlockView: NSView, NSOutlineViewDelegate, NSOutlineViewDataSource {
    
    @IBOutlet var view: NSView!
    @IBOutlet weak var titleIconButton: NSButton!
    @IBOutlet weak var titleTextButton: NSButton!
    @IBOutlet weak var leftAddButton: NSButton!
    @IBOutlet weak var rightAddButton: NSButton!
    @IBOutlet weak var horizontalLineView: JYHLineView!
    @IBOutlet weak var contentScrollView: NSScrollView!
    @IBOutlet weak var contentOutlineView: NSOutlineView!
    @IBOutlet weak var titleColumn: NSTableColumn!
    @IBOutlet weak var otherColumn: NSTableColumn!
    
    // 跟区域大小相关的分割线，点击标题栏时需要改变其位置。
    let app = NSApp.delegate as! AppDelegate
    var leftAddButtonHidden = true            // 左添加隐藏。
    var rightAddButtonHidden = true           // 右添加隐藏。
    var onlyTitle: Bool = false               // 只有标题。
    var block: AreaBlock = .catalog       // 所在区块。
    var verticalSplitView: NSSplitView?       // 在哪具分割图内。
    var horizontalSplitView: NSSplitView?       // 在哪具分割图内。
    var anchor: NSLayoutConstraint!           // 改变其约束。
    
    // icon 被点击。
    @IBAction func titleIconButtonClick(_ sender: Any) {
        changeBlockState()
    }
    
    // title 被点击。
    @IBAction func titleTextButtonClick(_ sender: Any) {
        changeBlockState()
    }
    
    @IBAction func leftAddButtonClick(_ sender: Any) {
        
    }
    
    @IBAction func rightAddButtonClick(_ sender: Any) {
        
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        loadXib()
    }

    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        loadXib()
    }
    
    // 加载对应的视图。
    private func loadXib() {
        // 从图获取NSView。
        Bundle.main.loadNibNamed("JYHAreaView", owner: self, topLevelObjects: nil)
        self.addSubview(self.view)
        // 让高约束可以修改。
        self.anchor = self.heightAnchor.constraint(greaterThanOrEqualToConstant: iconSize)
        self.anchor.isActive = true
        
        // 表格处理。
        contentOutlineView.delegate = self
        contentOutlineView.dataSource = self
        format()
    }
    
    //  改变块状态。
    func changeBlockState() {
        // 优先展开左右区。
        switch block {
        case .catalog, .role, .search:
            if cache.getStateWithBlock(block: .left) {
                horizontalSplitView?.setPosition(minAreaWidth, ofDividerAt: 0)
                return
            }
        default:
            if cache.getStateWithBlock(block: .right) {
                horizontalSplitView?.setPosition(windowSize.width - minAreaWidth, ofDividerAt: 1)
                return
            }
        }
        
        // 改变状态。
        onlyTitle = !onlyTitle
        // 改变高度的约束。
        setAnchor()
        cache.setStateWithBlock(block: block, value: onlyTitle)
        areaViewTitleClicked = true
        // 各个块自己处理分割线位置。
        positionSplitLine()
        areaViewTitleClicked = false
    }
    
    func initBlock(){
        onlyTitle = cache.getStateWithBlock(block: block)
        setAnchor()
        // 不处理分割线移动事件。
        areaViewTitleClicked = true
        positionSplitLine()
        areaViewTitleClicked = false
    }
    
    func setAnchor(){
        // 修改约束值。
        if onlyTitle {
            self.anchor.constant = iconSize
        } else {
            self.anchor.constant = minBlockHeight
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        // 及时更新视图的大小。
        self.view.frame = self.bounds
        titleColumn.width = self.bounds.width - otherColumn.width
        
        // LeftArea进入隐藏状态。
        if self.frame.size.width <= iconSize {
            titleTextButton.isHidden = true
            leftAddButton.isHidden = true
            rightAddButton.isHidden = true
            contentScrollView.isHidden = true
            horizontalLineView.isHidden = true
            return
        }
        
        // title上元素的显示。
        titleTextButton.isHidden = false
        leftAddButton.isHidden = leftAddButtonHidden ? true : false
        rightAddButton.isHidden = rightAddButtonHidden ? true : false
        
        // 自身的状态。
        horizontalLineView.isHidden = onlyTitle
        if block == .search || block == .dictionary {
            contentOutlineView.isHidden = onlyTitle
            return
        }
        contentScrollView.isHidden = onlyTitle
    }
    
    // 处理各子类的结构。
    func format(){
        print("format")
    }
    
    func positionSplitLine(){
        print("positionSplitLine")
    }
}
