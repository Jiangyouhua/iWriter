//
//  ViewController.swift
//  iWriter
//
//  Created by Jiangyouhua on 2019/7/9.
//  Copyright © 2019 Jiangyouhua. All rights reserved.
//

import Cocoa
/**
 ## 各目录项移动前原位置数据。
 */

class ViewController: NSViewController, WorksDelegate {
    
    let app = NSApp.delegate as! AppDelegate
    let works = (NSApp.delegate as! AppDelegate).works
    
    /// 分割视图。
    @IBOutlet weak var leftRightSplitView: NSSplitView!       // 左右分割的视图。
    @IBOutlet weak var leftAreaSplitView: NSSplitView!        // 左侧上下分割的视图。
    @IBOutlet weak var centerAreaSplitView: NSSplitView!      // 中侧上下分割的视图。
    @IBOutlet weak var rightAreaSplitView: NSSplitView!       // 右侧上下分割的视图。
    
    /// 水平分割后左中右视图。
    @IBOutlet weak var leftAreaView: NSView!
    @IBOutlet weak var centerAreaView: NSView!
    @IBOutlet weak var rightAreaView: NSView!
    
    /// 左视图垂直分割后的上中下视图：目录、角色、搜索。
    @IBOutlet weak var catalogBlockView: JYHCatalogView!
    @IBOutlet weak var roleBlockView: JYHRoleView!
    @IBOutlet weak var searchBlockView: JYHSearchView!
    
    /// 中视图顶部留出标签栏 + 按钮。
    @IBOutlet weak var titlesBarView: JYHTitlesBarView!
    
    
    /// 中视图余下部分垂直分割为上中下视图：想法、内容、大纲。
    /// 想法。
    @IBOutlet weak var infoBlockView: JYHInfoView!
    
    /// 内容。
    @IBOutlet weak var contentBlockView: JYHContentView!
    

    /// 大纲。
    @IBOutlet weak var outlineBlockView: JYHOutlineView!
    
    /// 右视图垂直分割后的上中下视图：便条、符号、字典。
    @IBOutlet weak var noteBlockView: JYHNoteView!
    @IBOutlet weak var symbolBlockView: JYHSymbolView!
    @IBOutlet weak var dictionaryBlockView: JYHDictionaryView!
    
    // 不作类变量会随着方法的结束而结束。
    // TODO 浮动窗口
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 在各视图中处理分割线。
        leftRightSplitView.delegate = self
        leftAreaSplitView.delegate = self
        centerAreaSplitView.delegate = self
        rightAreaSplitView.delegate = self
        
        catalogBlockView.delegate = self
        noteBlockView.delegate = self
        roleBlockView.delegate = self
        symbolBlockView.delegate = self
        searchBlockView.delegate = self
        dictionaryBlockView.delegate = self
        outlineBlockView.delegate = self
        
        works.delegate = self
        titlesBarView.target = self
        
        windowDidResize()                                        // 继承上一次的格式。
    }
    
    /// 实现方法。WorksDelegate
    func loadedFile(file: String) {
        // 1. 缓存更新；
        cache.addOpenedFile(file: file)
        
        // 2. 更新最近打开菜单。
        app.formatRecentOpenMenu()
        
        // 3. 界面更新;
        catalogBlockView.format()
        noteBlockView.format()
        roleBlockView.format()
        symbolBlockView.format()
        infoBlockView.format()
        contentBlockView.format()
        
        // 4. 展开节点。
        titlesBarView.needsLayout = true
    }
    
    func selectedLeaf(chapter: Chapter) {
        titlesBarView.opened(chapter: chapter)
        infoBlockView.opened(chapter: chapter)
        contentBlockView.opened(chapter: chapter)
    }
    
    func namedLeaf(chapter: Chapter) {
        titlesBarView.needsLayout = true
    }
    
    func deletedLeaf(chapter: Chapter) {
        guard let index = works.info.chapterOpened.firstIndex(where: {return $0.creation == chapter.creation}) else {
            return
        }
        titlesBarView.deleted(index: index)
        infoBlockView.deleted(chapter: chapter)
        contentBlockView.deleted(chapter: chapter)
    }
}

// MARK: - Area Toggle。
/**
 ## 通过分隔线控制AreaView、BlockView。
 1. 各AreaView、BlockView隐藏状态（最小状态）时保留标题栏；
 2. AreaView左右区，在阈值范围内自动隐藏。
 */
extension ViewController: NSSplitViewDelegate, JYHBlockViewDelegate, JYHOutlineViewDelegate {
    
    override func viewWillAppear() {
        //
    }
    
    /// 窗口改变时，左右区域宽度不变，外部调用。
    func windowDidResize() {
        // 如果左区为隐藏状态，则向左留一个ICON的宽度。
        let leftWidth = cache.getStateWithBlock(block: .left) ? iconWidth : cache.getPositionWithSplitView(position: .leftOfHorizontal)
        leftRightSplitView.setPosition(leftWidth, ofDividerAt: 0)
        
        // 如果右区为隐藏状态，则向右留一个ICON的宽度。
        let rightWidth = cache.getStateWithBlock(block: .right) ? iconWidth : cache.getPositionWithSplitView(position: .rightOfHorizontal)
        leftRightSplitView.setPosition(windowSize.width - rightWidth, ofDividerAt: 1)
    }
    
    /// 分隔线位置发生了变化。
    func splitView(_ splitView: NSSplitView, constrainSplitPosition proposedPosition: CGFloat, ofSubviewAt dividerIndex: Int) -> CGFloat {
        
        // 如查布局未加载完成，则不处理。
        if !self.isViewLoaded {
            return proposedPosition
        }
        
        
        switch splitView {
        case leftRightSplitView:
            return dividerIndex == 0 ? leftAreaState(position: proposedPosition) : rightAreaState(position: proposedPosition)
        case leftAreaSplitView:
            return dividerIndex == 0 ? leftTopAreaState(position: proposedPosition) : leftBottomAreaState(position: proposedPosition)
        case centerAreaSplitView:
            return dividerIndex == 0 ? centerTopAreaState(position: proposedPosition) : centerBottomAreaState(position: proposedPosition)
        case rightAreaSplitView:
            return dividerIndex == 0 ? rightTopAreaState(position: proposedPosition) : rightBottomAreaState(position: proposedPosition)
        default:
            return proposedPosition
        }
    }

    /// 左区状态，有两种：隐藏、显示。
    func leftAreaState(position: CGFloat) -> CGFloat {
        // 左侧小于阈值的一半，则隐藏。
        var p = position
        if p < minAreaWidth / 2 {
            cache.setStateWithBlock(block: .left, value: true)
            return iconWidth
        }
        
        // 左侧大于阈值的一半，则显示。
        cache.setStateWithBlock(block: .left, value: false)
        if p < minAreaWidth {
            // 显示的最小尺寸为阈值。
            p = minAreaWidth
        }
        
        // 左侧不能影响右侧，右侧显示时不能小于阈值。
        let v = cache.getStateWithBlock(block: .right) ? iconWidth : minAreaWidth
        if windowSize.width - p < v + minAreaWidth {
            p = windowSize.width - v - minAreaWidth
        }
        
        cache.setPositionWithSplitView(position: .leftOfHorizontal, value:p)
        return p
    }
    
    /// 左区状态，有两种：隐藏、显示。
    func rightAreaState(position: CGFloat) -> CGFloat {
        // 右侧小于阈值的一半，则隐藏。
        var p = position
        if windowSize.width - p < minAreaWidth / 2 {
            cache.setStateWithBlock(block: .right, value: true)
            return windowSize.width - iconWidth
        }
        
        // 右侧大于阈值的一半，则显示。
        cache.setStateWithBlock(block: .right, value: false)
        if windowSize.width - p < minAreaWidth {
            // 显示的最小尺寸为阈值
            p = windowSize.width - minAreaWidth
        }
        
        // 右侧不能影响左侧，左侧显示时不能小于阈值。
        // 注意：因为约束了centerAreaView的宽不小于200，所以设置右侧是最小宽度才有用。
        let v = cache.getStateWithBlock(block: .left) ? iconWidth : minAreaWidth
        if p < v + minAreaWidth {
            p =  v + minAreaWidth
        }
        
        cache.setPositionWithSplitView(position: .rightOfHorizontal, value: p)
        return p
    }
    
    func leftTopAreaState(position: CGFloat) -> CGFloat {
        return position
    }
    
    func leftBottomAreaState(position: CGFloat) -> CGFloat {
        return position
    }
    
    func centerTopAreaState(position: CGFloat) -> CGFloat {
        return position
    }
    
    func centerBottomAreaState(position: CGFloat) -> CGFloat {
        var p = position
        let h = windowSize.height - iconWidth - 1
        if h - p  < minBlockHeight / 2 {
            return h - iconWidth
        }
        if h - p < minBlockHeight {
            p = h - minBlockHeight
        }
        cache.setPositionWithSplitView(position: .centerBottomOfVertical, value: p)
        return p
    }
    
    func rightTopAreaState(position: CGFloat) -> CGFloat {
        return position
    }
    
    func rightBottomAreaState(position: CGFloat) -> CGFloat {
        return position
    }
    
    func blockTitleClicked(_ target: JYHBlockView) {
        switch target {
        case catalogBlockView:
            toggleCatalogBlockState()
        case noteBlockView:
            toggleNoteBlockState()
        case roleBlockView:
            toggleRoleBlockState()
        case symbolBlockView:
            toggleSymbolBlockState()
        case searchBlockView:
            toggleSearchBlockState()
        default:
            toggleDictionaryBlockState()
        }
    }
    
    func outlineTitleClicked(_ target: JYHOutlineView) {
        if target.frame.height > iconWidth + 3 {
            return centerAreaSplitView.setPosition(windowSize.height - iconWidth * 2, ofDividerAt: 1)
        }
        let h = cache.getPositionWithSplitView(position: .centerBottomOfVertical)
        centerAreaSplitView.setPosition(h, ofDividerAt: 1)
    }
    
    @IBAction func ideaButtonClick(_ sender: Any) {
        // 关闭。
        if infoBlockView.frame.height > iconWidth {
            return centerAreaSplitView.setPosition(0, ofDividerAt: 0)
        }
        if contentBlockView.frame.height < minBlockHeight {
            centerAreaSplitView.setPosition(minBlockHeight * 2, ofDividerAt: 1)
        }
        centerAreaSplitView.setPosition(minBlockHeight, ofDividerAt: 0)
    }
    
    func toggleCatalogBlockState(){
        let b = catalogBlockView.frame.height > minBlockHeight
        let s = cache.getStateWithBlock(block: .left)
        var p = cache.getPositionWithSplitView(position: .leftOfHorizontal)
        leftAreaSplitView.setPosition(windowSize.height - iconWidth * 2, ofDividerAt: 0)
        if !s && b{
            p = iconWidth
        }
        leftRightSplitView.setPosition(p, ofDividerAt: 0)
    }
    
    func toggleNoteBlockState(){
        let b = noteBlockView.frame.height > minBlockHeight
        let s = cache.getStateWithBlock(block: .right)
        var p = cache.getPositionWithSplitView(position: .rightOfHorizontal)
        rightAreaSplitView.setPosition(windowSize.height - iconWidth * 2, ofDividerAt: 0)
        if !s && b{
            p = iconWidth
        }
        leftRightSplitView.setPosition(windowSize.width - p, ofDividerAt: 1)
    }
    
    func toggleRoleBlockState(){
        let b = roleBlockView.frame.height > minBlockHeight
        let s = cache.getStateWithBlock(block: .left)
        var p = cache.getPositionWithSplitView(position: .leftOfHorizontal)
        leftAreaSplitView.setPosition(iconWidth, ofDividerAt: 0)
        leftAreaSplitView.setPosition(windowSize.height - iconWidth, ofDividerAt: 1)
        if !s && b{
            p = iconWidth
        }
        leftRightSplitView.setPosition(p, ofDividerAt: 0)
    }
    
    func toggleSymbolBlockState(){
        let b = symbolBlockView.frame.height > minBlockHeight
        let s = cache.getStateWithBlock(block: .right)
        var p = cache.getPositionWithSplitView(position: .rightOfHorizontal)
        rightAreaSplitView.setPosition(iconWidth, ofDividerAt: 0)
        rightAreaSplitView.setPosition(windowSize.height - iconWidth, ofDividerAt: 1)
        if !s && b{
            p = iconWidth
        }
        leftRightSplitView.setPosition(windowSize.width - p, ofDividerAt: 1)
    }
    
    func toggleSearchBlockState(){
        let b = searchBlockView.frame.height > minBlockHeight
        let s = cache.getStateWithBlock(block: .left)
        var p = cache.getPositionWithSplitView(position: .leftOfHorizontal)
        leftAreaSplitView.setPosition(iconWidth * 2, ofDividerAt: 1)
        if !s && b{
            p = iconWidth
        }
        leftRightSplitView.setPosition(p, ofDividerAt: 0)
    }
    
    func toggleDictionaryBlockState(){
        let b = dictionaryBlockView.frame.height > minBlockHeight
        let s = cache.getStateWithBlock(block: .right)
        var p = cache.getPositionWithSplitView(position: .rightOfHorizontal)
        rightAreaSplitView.setPosition(iconWidth, ofDividerAt: 0)
        rightAreaSplitView.setPosition(iconWidth * 2, ofDividerAt: 1)
        if !s && b{
            p = iconWidth
        }
        leftRightSplitView.setPosition(windowSize.width - p, ofDividerAt: 1)
    }
}


extension ViewController: JYHTitlesBarViewDelegate {
    
    func clickedTabItem(chapter: Chapter) {
        catalogBlockView.contentOutlineView.reloadData()
        infoBlockView.action(chapter: chapter)
        contentBlockView.action(chapter: chapter)
    }
    
    func closedTabItem(chapter: Chapter) {
        catalogBlockView.contentOutlineView.reloadData()
        infoBlockView.action(chapter: chapter)
        contentBlockView.action(chapter: chapter)
    }
}
