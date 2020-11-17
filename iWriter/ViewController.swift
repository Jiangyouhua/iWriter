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

class ViewController: NSViewController, WorksDelegate, JYHSearchViewDelegate {
    
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
    @IBOutlet weak var articleBlockView: JYHArticleView!
    

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
        
        articleBlockView.delegate = self
        outlineBlockView.delegate = self
        
        works.delegate = self
        titlesBarView.target = self
        
        windowDidResize()                                        // 继承上一次的格式。
    }
    
    /// 实现方法。WorksDelegate
    func loadedCatalog() {
        
        // 1. 界面更新;
        catalogBlockView.format()
        
        // 2. 展开节点。
        titlesBarView.format()
        infoBlockView.format()
        articleBlockView.format()
        
        // 3. 更新最近打开菜单。
        app.formatRecentOpenMenu()
    }
    
    func loadedNote(){
        noteBlockView.format()
    }
    func loadedRole(){
        roleBlockView.format()
    }
    func loadedSymbol(){
        symbolBlockView.format()
    }
    
    func selectedLeaf(chapter: Chapter) {
        titlesBarView.opened(chapter: chapter)
        infoBlockView.opened(chapter: chapter)
        articleBlockView.opened(chapter: chapter)
    }
    
    func namedLeaf(chapter: Chapter) {
        titlesBarView.opened(chapter: chapter)
        infoBlockView.opened(chapter: chapter)
        articleBlockView.opened(chapter: chapter)
    }
    
    func deletedLeaf(chapter: Chapter) {
        guard let index = works.info.chapterOpened.firstIndex(where: {return $0.creation == chapter.creation}) else {
            return
        }
        titlesBarView.deleted(index: index)
        infoBlockView.deleted(chapter: chapter)
        articleBlockView.deleted(chapter: chapter)
    }
}

// MARK: - Area Toggle。
/**
 ## 通过分隔线控制AreaView、BlockView。
 1. 各AreaView、BlockView隐藏状态（最小状态）时保留标题栏；
 2. AreaView左右区，在阈值范围内自动隐藏。
 */
extension ViewController: NSSplitViewDelegate, JYHBlockViewDelegate, JYHDictionaryViewDelegate, JYHOutlineViewDelegate {
    
    func blockTitleClicked(_ target: JYHBlockView) {
        switch target {
        case catalogBlockView:
            toggleCatalogBlockState()
        case noteBlockView:
            toggleNoteBlockState()
        case roleBlockView:
            toggleRoleBlockState()
        default:
            toggleSymbolBlockState()
        }
    }
    
    func blockTitleClicked(_ target: JYHSearchView) {
        toggleSearchBlockState()
    }
    
    func blockTitleClicked(_ target: JYHDictionaryView) {
        toggleDictionaryBlockState()
    }
    
    
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
        leftRightSplitView.setPosition(rightWidth, ofDividerAt: 1)
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
            return leftBlockState(position: proposedPosition)
        case centerAreaSplitView:
            return dividerIndex == 0 ? centerTopAreaState(position: proposedPosition) : centerBottomAreaState(position: proposedPosition)
        case rightAreaSplitView:
            return  rightBlockState(position: proposedPosition)
        default:
            return proposedPosition
        }
    }

    /// 左区状态，有两种：隐藏、显示。
    func leftAreaState(position: CGFloat) -> CGFloat {
        // 左侧小于阈值的一半，则隐藏。
        if position < minAreaWidth / 2 {
            cache.setStateWithBlock(block: .left, value: true)
            return iconWidth
        }
        
        // 左侧大于阈值的一半，则显示。
        cache.setStateWithBlock(block: .left, value: false)
        if position < minAreaWidth {
            // 显示的最小尺寸为阈值。
            cache.setPositionWithSplitView(position: .leftOfHorizontal, value:minAreaWidth)
            return minAreaWidth
        }
        
        // 左侧不能影响右侧，右侧显示时不能小于阈值。
        let v = cache.getStateWithBlock(block: .right) ? iconWidth : minAreaWidth
        if windowSize.width - position < v + minAreaWidth {
            let p = windowSize.width - v - minAreaWidth
            cache.setPositionWithSplitView(position: .leftOfHorizontal, value:p)
            return p
        }
        
        cache.setPositionWithSplitView(position: .leftOfHorizontal, value:position)
        return position
    }
    
    /// 左区状态，有两种：隐藏、显示。
    func rightAreaState(position: CGFloat) -> CGFloat {
        // 右侧小于阈值的一半，则隐藏。
        if windowSize.width - position < minAreaWidth / 2 {
            cache.setStateWithBlock(block: .right, value: true)
            return windowSize.width - iconWidth
        }
        
        // 右侧大于阈值的一半，则显示。
        cache.setStateWithBlock(block: .right, value: false)
        if windowSize.width - position < minAreaWidth {
            // 显示的最小尺寸为阈值
            let p = windowSize.width - minAreaWidth
            cache.setPositionWithSplitView(position: .rightOfHorizontal, value: p)
            return p
        }
        
        // 右侧不能影响左侧，左侧显示时不能小于阈值。
        // 注意：因为约束了centerAreaView的宽不小于200，所以设置右侧是最小宽度才有用。
        let v = cache.getStateWithBlock(block: .left) ? iconWidth : minAreaWidth
        if position < v + minAreaWidth {
            let p =  v + minAreaWidth
            cache.setPositionWithSplitView(position: .rightOfHorizontal, value: p)
            return p
        }
        
        cache.setPositionWithSplitView(position: .rightOfHorizontal, value: position)
        return position
    }
    
    func leftBlockState(position: CGFloat) -> CGFloat {
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
    
    func rightBlockState(position: CGFloat) -> CGFloat {
        return position
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
        if articleBlockView.frame.height < minBlockHeight {
            centerAreaSplitView.setPosition(minBlockHeight * 2, ofDividerAt: 1)
        }
        centerAreaSplitView.setPosition(minBlockHeight, ofDividerAt: 0)
    }
    
    /**
     三个都是隐藏状态，则隐藏当前侧。
     */
    func toggleCatalogBlockState(){
        // 1. 左则展开状态，则隐藏。
        if !cache.getStateWithBlock(block: .left) {
            leftRightSplitView.setPosition(iconWidth, ofDividerAt: 0)
            return
        }
        // 2. 左则隐藏状态，则展开。
        let p = cache.getPositionWithSplitView(position: .leftOfHorizontal)
        leftRightSplitView.setPosition(p, ofDividerAt: 0)
        // 3. 当前展开状态，则不变。
        if catalogBlockView.frame.height > minBlockHeight {
            return
        }
        // 4. 调高于最小值的其它项，使之为最小值。
        if searchBlockView.frame.height > minBlockHeight {
            leftAreaSplitView.setPosition(windowSize.height - minBlockHeight, ofDividerAt: 1)
        }
        var h = roleBlockView.frame.height
        if h > minBlockHeight {
            h = minBlockHeight
        }
        leftAreaSplitView.setPosition(windowSize.height - minBlockHeight - h, ofDividerAt: 0)
    }
    
    func toggleNoteBlockState(){
        if !cache.getStateWithBlock(block: .right) {
            leftRightSplitView.setPosition(windowSize.width - iconWidth, ofDividerAt: 1)
            return
        }
        let p = cache.getPositionWithSplitView(position: .rightOfHorizontal)
        leftRightSplitView.setPosition(p, ofDividerAt: 1)
        if noteBlockView.frame.height > minBlockHeight {
            return
        }
        // 4. 调高于最小值的其它项，使之为最小值。
        if dictionaryBlockView.frame.height > minBlockHeight {
            rightAreaSplitView.setPosition(windowSize.height - minBlockHeight, ofDividerAt: 1)
        }
        var h = symbolBlockView.frame.height
        if h > minBlockHeight {
            h = minBlockHeight
        }
        rightAreaSplitView.setPosition(windowSize.height - minBlockHeight - h, ofDividerAt: 0)
    }
    
    func toggleRoleBlockState(){
        if !cache.getStateWithBlock(block: .left) {
            leftRightSplitView.setPosition(iconWidth, ofDividerAt: 0)
            return
        }
        let p = cache.getPositionWithSplitView(position: .leftOfHorizontal)
        leftRightSplitView.setPosition(p, ofDividerAt: 0)
        if roleBlockView.frame.height > minBlockHeight {
            return
        }
        if searchBlockView.frame.height > minBlockHeight {
            leftAreaSplitView.setPosition(windowSize.height - minBlockHeight, ofDividerAt: 1)
        }
        if catalogBlockView.frame.height > minBlockHeight {
            leftAreaSplitView.setPosition(minBlockHeight, ofDividerAt: 0)
        }
    }
    
    func toggleSymbolBlockState(){
        if !cache.getStateWithBlock(block: .right) {
            leftRightSplitView.setPosition(windowSize.width - iconWidth, ofDividerAt: 1)
            return
        }
        let p = cache.getPositionWithSplitView(position: .rightOfHorizontal)
        leftRightSplitView.setPosition(p, ofDividerAt: 1)
        if symbolBlockView.frame.height > minBlockHeight  {
            return
        }
        if dictionaryBlockView.frame.height > minBlockHeight {
            rightAreaSplitView.setPosition(windowSize.height - minBlockHeight, ofDividerAt: 1)
        }
        if noteBlockView.frame.height > minBlockHeight {
            rightAreaSplitView.setPosition(minBlockHeight, ofDividerAt: 0)
        }
    }
    
    func toggleSearchBlockState(){
        if !cache.getStateWithBlock(block: .left) {
            leftRightSplitView.setPosition(iconWidth, ofDividerAt: 0)
            return
        }
        let p = cache.getPositionWithSplitView(position: .leftOfHorizontal)
        leftRightSplitView.setPosition(p, ofDividerAt: 0)
        if searchBlockView.frame.height > minBlockHeight {
            return
        }
        if catalogBlockView.frame.height > minBlockHeight {
            leftAreaSplitView.setPosition(minBlockHeight, ofDividerAt: 0)
        }
        var h = roleBlockView.frame.height
        if h > minBlockHeight {
            h = minBlockHeight
        }
        leftAreaSplitView.setPosition(windowSize.height - minBlockHeight - h, ofDividerAt: 1)
    }
    
    func toggleDictionaryBlockState(){
        if !cache.getStateWithBlock(block: .right) {
            leftRightSplitView.setPosition(windowSize.width - iconWidth, ofDividerAt: 1)
            return
        }
        let p = cache.getPositionWithSplitView(position: .rightOfHorizontal)
        leftRightSplitView.setPosition(p, ofDividerAt: 1)
        if dictionaryBlockView.frame.height > minBlockHeight{
            return
        }
        if noteBlockView.frame.height > minBlockHeight {
            rightAreaSplitView.setPosition(minBlockHeight, ofDividerAt: 0)
        }
        var h = symbolBlockView.frame.height
        if h > minBlockHeight {
            h = minBlockHeight
        }
        rightAreaSplitView.setPosition(windowSize.height - minBlockHeight - h, ofDividerAt: 1)
    }
}


extension ViewController: JYHTitlesBarViewDelegate {
    
    func clickedTabItem(chapter: Chapter) {
        catalogBlockView.contentOutlineView.reloadData()
        infoBlockView.action(chapter: chapter)
        articleBlockView.action(chapter: chapter)
    }
    
    func closedTabItem(chapter: Chapter) {
        catalogBlockView.contentOutlineView.reloadData()
        infoBlockView.action(chapter: chapter)
        articleBlockView.action(chapter: chapter)
    }
    
    // search
    func searchWord(_ word: String) {
        guard let chapter = catalogBlockView.contentOutlineView.item(atRow: catalogBlockView.contentOutlineView.selectedRow) as? Chapter else {
            return
        }
        let data = chapter.search(word)
        searchBlockView.data = data
        articleBlockView.updateSearchAttributes(data: data, onlyRemove: false)
    }
    
    func currentSearch(chapter: Chapter, mark: Mark) {
        // 更换章节。
        if works.info.chapterEditingId != chapter.creation {
            works.info.chapterEditingId = chapter.creation
            works.info.chapterSelection = chapter
            works.opened(chapter: chapter)
            selectedLeaf(chapter: chapter)
        }
        
        DispatchQueue.main.async {
            self.articleBlockView.currentSearch(currentMark: mark)
        }
    }

}

extension ViewController : JYHContentViewDelegate {
    func contentDidChange(chapter: Chapter) {
        catalogBlockView.contentOutlineView.reloadItem(chapter)
    }
}
