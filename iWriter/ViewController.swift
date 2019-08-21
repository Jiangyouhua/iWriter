//
//  ViewController.swift
//  iWriter
//
//  Created by Jiangyouhua on 2019/7/9.
//  Copyright © 2019 Jiangyouhua. All rights reserved.
//

import Cocoa

/**
 ## 目录项移动前原位置数据。
 */
struct DragItem {
    var at: Int = -1          // 在父项的位置。
    var item: Any? = nil      // 移动的项目。
    var inParent: Any? = nil  // 父项。
}

/**
 ## 各目录项移动前原位置数据。
 */
struct DragItems {
    var catalog: DragItem = DragItem()
    var note: DragItem = DragItem()
    var search: DragItem = DragItem()
    var role: DragItem = DragItem()
    var symbol: DragItem = DragItem()
    var dictionary: DragItem = DragItem()
}

class ViewController: NSViewController, WorksDelegate {
    
    /// 布局的组件Outlet。
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
    
    @IBOutlet weak var tabsBarView: TabsBarView!
    
    @IBOutlet weak var catalogIconButton: NSButton!
    @IBOutlet weak var noteIconButton: NSButton!
    @IBOutlet weak var searchIconButton: NSButton!
    @IBOutlet weak var ideaIconButton: NSButton!
    @IBOutlet weak var outlineIconButton: NSButton!
    @IBOutlet weak var roleIconButton: NSButton!
    @IBOutlet weak var symbolIconButton: NSButton!
    @IBOutlet weak var dictionaryIconButton: NSButton!
    
    @IBOutlet weak var catalogAddButton: NSButton!
    @IBOutlet weak var noteAddButton: NSButton!
    @IBOutlet weak var roleAddButton: NSButton!
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
    
    @IBOutlet weak var catalogLine: JYHView!
    @IBOutlet weak var noteLine: JYHView!
    @IBOutlet weak var searchLine: JYHView!
    @IBOutlet weak var roleLine: JYHView!
    @IBOutlet weak var symbolLine: JYHView!
    @IBOutlet weak var dictionaryLine: JYHView!
    
    @IBOutlet var ideaTextView: NSTextView!
    @IBOutlet var contentTextView: NSTextView!
    
    @IBOutlet var catalogMenu: NSMenu!
    
    // 新建目录项对话窗口。
    var catalogWindowController: CatalogWindowController?
    
    // 引用Works，用来处理保存内容。
    let works: Works = AppDelegate.works          // Works，唯一实例。
    
    // 布局格式保存与控制。
    let defaults = UserDefaults.standard
    let threshold: CGFloat = 130                  // Left Area View、 Right Area View 宽度最小值。
    let thickness: CGFloat = 30                   // 标题栏厚度。
    var dividers: [String: CGFloat] = [:]         // 各divider位置。
    var loaded = false                            // 加载完成。
    
    // 拖动相关。
    var dragItems = DragItems()                   // 起点位置。
    
    // Left Area View 处于隐藏状态。
    var leftAreaState: Bool {
        get {
            return leftAreaView.frame.width == thickness
        }
    }
    
    // Right Area View 处于隐藏状态。
    var rightAreaState: Bool {
        get {
            return rightAreaView.frame.width == thickness
        }
    }
    
    // Catalog Block View 处于隐藏状态。
    var catalogState: Bool {
        get {
            return catalogBlockView.frame.height == thickness
        }
    }
    
    // Note Block View 处于隐藏状态。
    var noteState: Bool {
        get {
            return noteBlockView.frame.height == thickness
        }
    }
    
    // Search Block View 处于隐藏状态。
    var searchState: Bool {
        get {
            return searchBlockView.frame.height == thickness
        }
    }
    
    // Search Block View 处于隐藏状态。
    var outlineState: Bool {
        get {
            return outlineBlockView.frame.height == thickness
        }
    }
    
    // Role Block View 处于隐藏状态。
    var roleState: Bool {
        get {
            return roleBlockView.frame.height == thickness
        }
    }
    
    /**
     ## Func Start。
     */
    
    // Symbol Block View 处于隐藏状态。
    var symbolState: Bool {
        get {
            return symbolBlockView.frame.height == thickness
        }
    }
    
    // Dictionary Block View 处于隐藏状态。
    var dictionaryState: Bool {
        get {
            return dictionaryBlockView.frame.height == thickness
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        works.delegate = self
        addButtonIsHidden(bool: true)
        
        // NSOutliveView的委托。
        outlineViewDelegate()
        //        catalogBox.frame = CGRect.init(x:30, y: 0, width: 100, height: 1)
        //  catalogBox.fillColor = NSColor.red
        
        // 布局。
        buttonToolTips()     // Image Button的提示语。
        splitViewDelegate()  // NSSplitView的委托。
        loadLayoutConfig()   // 继承上一次的格式。
        loaded = true        // 判断加载是否完成 ，用来区分Window.Resize。
    }
    
    override func viewDidDisappear() {
        saveLayoutConfig()
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
            saveLayoutConfig()
        }
    }
    
    /// 显示与隐藏Add Button，没有打开文件时隐藏。
    func addButtonIsHidden(bool: Bool){
        catalogAddButton.isHidden = bool
        noteAddButton.isHidden = bool
        roleAddButton.isHidden = bool
        symbolAddButton.isHidden = bool
    }
    
    /// Split View Delegate，控制区块大小。
    func splitViewDelegate(){
        leftRightSplitView.delegate = self
        leftAreaSplitView.delegate = self
        centerAreaSplitView.delegate = self
        rightAreaSplitView.delegate = self
    }
    
    /// Outline View Delegate，各区块显示的数据及编辑。
    func outlineViewDelegate(){
        catalogOutlineView.delegate = self
        catalogOutlineView.dataSource = self
        catalogOutlineView.registerForDraggedTypes([NSPasteboard.PasteboardType.string])
        tabsBarView.delegate = self
    }
    
    /// 各Image Button的提示。
    func buttonToolTips(){
        catalogIconButton.toolTip = "Hide or show the Catalog block"
        noteIconButton.toolTip = "Hide or show the Note block"
        searchIconButton.toolTip = "Hide or show the Search block"
        ideaIconButton.toolTip = "Hide or show the Idea block"
        outlineIconButton.toolTip = "Hide or show the Outline block"
        roleIconButton.toolTip = "Hide or show the Role block"
        symbolIconButton.toolTip = "Hide or show the Symbol block"
        dictionaryIconButton.toolTip = "Hide or show the Dictionary block"
        catalogAddButton.toolTip = "Add content"
        noteAddButton.toolTip = "Add Note"
        roleAddButton.toolTip = "Add Role"
        symbolAddButton.toolTip = "Add Symbol"
    }
    
    func loadedFile(file: String) {
        _ = AppDelegate.recent.lastFiles(file)
        catalogUpdatedItem()
        addButtonIsHidden(bool: false)
    }
}

// MARK: - Block Toggle。

/**
 ## 各BlockView显示与隐藏。
 显示：原则上向下展开。
 隐藏：原则上向上收拢。
 1. 所有BlockView隐藏，则隐藏其AreaView；
 2. 通IconButton显示其AreaView时，同时显示其BlockView。
 */
extension ViewController {
    
    /* IconButton Action。 */
    
    /// 显示隐藏目录内容。
    @IBAction func catalogIconClick(_ sender: Any) {
        // 判断AreaView是否隐藏。
        if catalogTitleView.isHidden {
            // 如隐藏则显示。
            leftAreaIsHidden(false)
            return catalogBlockShow()
        }
        
        // 显示。
        if catalogState {
            return catalogBlockShow()
        }
        // 隐藏。
        return catalogBlockHidden()
    }
    
    
    
    /// 显示隐藏备注内容， 同上。
    @IBAction func noteIconClick(_ sender: Any) {
        if noteTitleView.isHidden {
            leftAreaIsHidden(false)
            return noteBlockShow()
        }
        if noteState {
            return noteBlockShow()
        }
        return noteBlockHidden()
        
    }
    
    /// 显示隐藏搜索内容， 同上。
    @IBAction func searchIconClick(_ sender: Any) {
        if searchTitleView.isHidden {
            leftAreaIsHidden(false)
            return searchBlockShow()
        }
        if searchState {
            return searchBlockShow()
        }
        return searchBlockHidden()
    }
    
    
    /// 显示隐藏角色内容，同上。
    @IBAction func roleIconClick(_ sender: Any) {
        if roleTitleView.isHidden {
            rightAreaIsHidden(false)
            return roleBlockShow()
        }
        if roleState {
            return roleBlockShow()
        }
        return roleBlockHidden()
    }
    
    /// 显示隐藏符号内容， 同上。
    @IBAction func symbolIconClick(_ sender: Any) {
        if symbolTitleView.isHidden {
            rightAreaIsHidden(false)
            return symbolBlockShow()
        }
        if symbolState {
            return symbolBlockShow()
        }
        return symbolBlockHidden()
    }
    
    /// 显示隐藏字典内容， 同上。
    @IBAction func dictionaryIconClick(_ sender: Any) {
        if dictionaryTitleView.isHidden {
            rightAreaIsHidden(false)
            return dictionaryBlockShow()
        }
        if dictionaryState {
            return dictionaryBlockShow()
        }
        return dictionaryBlockHidden()
    }
    
    /// 显示隐藏想法内容，同上，无AreaView判断。
    @IBAction func ideaIconClick(_ sender: Any) {
        if ideaBlockView.frame.height == 0 {
            centerAreaSplitView.setPosition(threshold + thickness, ofDividerAt: 0)
        } else {
            centerAreaSplitView.setPosition( 0, ofDividerAt: 0)
        }
    }
    
    /// 显示隐藏大纲内容，同上。
    @IBAction func outlineIconClick(_ sender: Any) {
        if outlineBlockView.frame.height == thickness {
            centerAreaSplitView.setPosition(centerAreaSplitView.frame.height - threshold - thickness, ofDividerAt: 1)
        } else {
            centerAreaSplitView.setPosition(centerAreaSplitView.frame.height - thickness, ofDividerAt: 1)
        }
    }
    
    /* BlockView Show Or Hidden。 */
    
    /// 显示Catalog Block View。
    func catalogBlockShow(){
        // 1. 已显示，直接返回；
        if !catalogState {
            return
        }
        
        // 2. 中显示，向下移动第一个Divider，移一半；
        if !noteState {
            leftAreaSplitView.setPosition(searchBlockView.frame.origin.y / 2, ofDividerAt: 0)
        } else {
            // 3. 向下移动第一个Divider。
            leftAreaSplitView.setPosition(threshold + thickness, ofDividerAt: 0)
        }
        saveLayoutConfig()
        
    }
    
    /// 隐藏Catalog Block View。
    func catalogBlockHidden(){
        // 1. 中下隐藏，直接隐藏左区；
        if noteState && searchState {
            return leftAreaIsHidden(true)
        }
        
        // 2. 中隐藏，向上移动第二个Divider；
        if noteState {
            return leftAreaSplitView.setPosition(thickness * 2, ofDividerAt: 1)
        } else {
            // 3. 向上移动第一个Divider。
            leftAreaSplitView.setPosition(thickness, ofDividerAt: 0)
        }
        saveLayoutConfig()
    }
    
    /// 显示Note Block View。
    func noteBlockShow(){
        // 1. 已显示，直接返回；
        if !noteState {
            return
        }
        // 2. 下隐藏，向上移动第一个Divider；
        if searchState {
            return leftAreaSplitView.setPosition(searchBlockView.frame.origin.y / 2, ofDividerAt: 0)
        } else {
            // 3. 向下移动第二个Divider，移一半。
            leftAreaSplitView.setPosition(leftAreaView.frame.height - searchBlockView.frame.height / 2, ofDividerAt: 1)
        }
        saveLayoutConfig()
    }
    
    /// 隐藏Note Block View。
    func noteBlockHidden(){
        // 1. 中下隐藏，直接隐藏左区；
        if catalogState && searchState {
            return leftAreaIsHidden(true)
        }
        // 2. 下隐藏，向下移动第一个Divider；
        if searchState {
            return leftAreaSplitView.setPosition(leftAreaView.frame.height - thickness * 2, ofDividerAt: 0)
        } else {
            // 3. 向上移动第二个Divider。
            let number = noteBlockView.frame.origin.y
            leftAreaSplitView.setPosition(number + thickness, ofDividerAt: 1)
        }
        saveLayoutConfig()
    }
    
    /// 显示Search Block View。
    func searchBlockShow(){
        // 1. 已显示，直接返回；
        if !searchState {
            return
        }
        
        // 2. 中显示，向上移动第二个Divider，移一半；
        if !noteState {
            return leftAreaSplitView.setPosition((noteBlockView.frame.origin.y + leftAreaView.frame.height) / 2, ofDividerAt: 1)
        } else {
            // 3. 向上移动第二个Divider。
            leftAreaSplitView.setPosition(leftAreaView.frame.height - threshold - thickness, ofDividerAt: 1)
        }
        saveLayoutConfig()
    }
    
    /// 隐藏Search Block View。
    func searchBlockHidden(){
        // 1. 中下隐藏，直接隐藏左区；
        if catalogState && noteState {
            return leftAreaIsHidden(true)
        }
        // 2. 中隐藏，向下移动第一个Divider；
        if noteState {
            return leftAreaSplitView.setPosition(leftAreaView.frame.height - thickness * 2, ofDividerAt: 0)
        } else {
            // 3. 向下移动第二个Divider。
            leftAreaSplitView.setPosition(leftAreaView.frame.height - thickness, ofDividerAt: 1)
        }
        saveLayoutConfig()
    }
    
    /// 显示Role Block View。
    func roleBlockShow(){
        // 1. 已显示，直接返回；
        if !roleState {
            return
        }
        
        // 2. 中显示，向下移动第一个Divider，移一半；
        if !symbolState {
            return rightAreaSplitView.setPosition(dictionaryBlockView.frame.origin.y / 2, ofDividerAt: 0)
        } else {
            // 3. 向下移动第一个Divider。
            rightAreaSplitView.setPosition(threshold + thickness, ofDividerAt: 0)
        }
        saveLayoutConfig()
    }
    
    /// 隐藏Catalog Block View。
    func roleBlockHidden(){
        // 1. 中下隐藏，直接隐藏左区；
        if symbolState && dictionaryState {
            return rightAreaIsHidden(true)
        }
        
        // 2. 中隐藏，向上移动第二个Divider；
        if symbolState {
            return rightAreaSplitView.setPosition(thickness * 2, ofDividerAt: 1)
        } else {
            // 3. 向上移动第一个Divider。
            rightAreaSplitView.setPosition(thickness, ofDividerAt: 0)
        }
        saveLayoutConfig()
    }
    
    /// 显示Note Block View。
    func symbolBlockShow(){
        // 1. 已显示，直接返回；
        if !symbolState {
            return
        }
        // 2. 下隐藏，向上移动第一个Divider；
        if dictionaryState {
            return rightAreaSplitView.setPosition(dictionaryBlockView.frame.origin.y / 2, ofDividerAt: 0)
        } else {
            // 3. 向下移动第二个Divider，移一半。
            rightAreaSplitView.setPosition(rightAreaView.frame.height - dictionaryBlockView.frame.height / 2, ofDividerAt: 1)
        }
        saveLayoutConfig()
    }
    
    /// 隐藏Note Block View。
    func symbolBlockHidden(){
        // 1. 中下隐藏，直接隐藏左区；
        if roleState && dictionaryState {
            return rightAreaIsHidden(true)
        }
        // 2. 下隐藏，向下移动第一个Divider；
        if dictionaryState {
            return rightAreaSplitView.setPosition(rightAreaView.frame.height - thickness * 2, ofDividerAt: 0)
        } else {
            // 3. 向上移动第二个Divider。
            rightAreaSplitView.setPosition(symbolBlockView.frame.origin.y + thickness, ofDividerAt: 1)
        }
    }
    
    /// 显示Search Block View。
    func dictionaryBlockShow(){
        // 1. 已显示，直接返回；
        if !dictionaryState {
            return
        }
        
        // 2. 中显示，向上移动第二个Divider，移一半；
        if !symbolState {
            return rightAreaSplitView.setPosition((symbolBlockView.frame.origin.y + rightAreaView.frame.height) / 2, ofDividerAt: 1)
        } else {
            // 3. 向上移动第二个Divider。
            rightAreaSplitView.setPosition(rightAreaView.frame.height - threshold - thickness, ofDividerAt: 1)
        }
        saveLayoutConfig()
    }
    
    /// 隐藏Search Block View。
    func dictionaryBlockHidden(){
        // 1. 中下隐藏，直接隐藏左区；
        if roleState && symbolState {
            return rightAreaIsHidden(true)
        }
        // 2. 中隐藏，向下移动第一个Divider；
        if symbolState {
            return rightAreaSplitView.setPosition(rightAreaView.frame.height - thickness * 2, ofDividerAt: 0)
        } else {
            // 3. 向下移动第二个Divider。
            rightAreaSplitView.setPosition(rightAreaView.frame.height - thickness, ofDividerAt: 1)
        }
    }
    
}

// MARK: - Area Toggle。
/**
 ## 通过分隔线控制AreaView、BlockView。
 1. 各AreaView、BlockView隐藏状态（最小状态）时保留标题栏；
 2. AreaView左右区，在阈值范围内自动隐藏。
 */
extension ViewController: NSSplitViewDelegate {
    /// 完成子视图的变化。
    func splitViewDidResizeSubviews(_ notification: Notification){
        // 加载完成了没。
        guard loaded else {
            return
        }
        // 是外部改变大小吗？
        guard notification.userInfo == nil else {
            return
        }
        // 改变了内容大布局了吗？
        guard let view = notification.object as? NSView else {
            return
        }
        // 保持左右AreaView不变，保存Ccenter Area View上下BlockView不变。
        switch view {
        case leftRightSplitView:
            if let value = dividers["leftRight0"] {
                leftRightSplitView.setPosition(value, ofDividerAt: 0)
            }
            if let value = dividers["leftRight1"] {
                leftRightSplitView.setPosition(leftRightSplitView.frame.width - value, ofDividerAt: 1)
            }
        case leftAreaSplitView:
            if let value = dividers["leftArea0"] {
                leftAreaSplitView.setPosition(value, ofDividerAt: 0)
            }
            if let value = dividers["leftArea1"] {
                leftAreaSplitView.setPosition(leftAreaSplitView.frame.height - value, ofDividerAt: 1)
            }
        case centerAreaSplitView:
            if let value = dividers["centerArea0"] {
                centerAreaSplitView.setPosition(value, ofDividerAt: 0)
            }
            if let value = dividers["centerArea1"] {
                centerAreaSplitView.setPosition(centerAreaSplitView.frame.height - value, ofDividerAt: 1)
            }
        case rightAreaSplitView:
            if let value = dividers["rightArea0"] {
                rightAreaSplitView.setPosition(value, ofDividerAt: 0)
            }
            if let value = dividers["rightArea1"] {
                rightAreaSplitView.setPosition(rightAreaSplitView.frame.height - value, ofDividerAt: 1)
            }
        default:
            return
        }
    }
    
    /// 分隔线位置发生了变化。
    func splitView(_ splitView: NSSplitView, constrainSplitPosition proposedPosition: CGFloat, ofSubviewAt dividerIndex: Int) -> CGFloat{
        guard loaded else {
            return proposedPosition
        }
        switch splitView {
        case leftRightSplitView:
            return leftRightSplitViewResize(position: proposedPosition, index: dividerIndex)
        case leftAreaSplitView:
            return leftAreaSplitViewResize(position: proposedPosition, index: dividerIndex)
        case centerAreaSplitView:
            return centerAreaSplitViewResize(position: proposedPosition, index: dividerIndex)
        case rightAreaSplitView:
            return rightAreaSplitViewResize(position: proposedPosition, index: dividerIndex)
        default:
            return proposedPosition
        }
    }
    
    /// Left Right Splite View。
    func leftRightSplitViewResize(position: CGFloat, index: Int) ->CGFloat {
        // 左边分割线。
        let key = "leftRight\(index)"
        if index == 0 {
            dividers[key] = position
            // 小于阈值。
            if position < threshold {
                // 隐藏Left Area View的内容，只保留IconButton。
                leftAreaSubviewsIsHidden(true)
                // 并保留30的宽。
                dividers[key] = thickness
                return thickness
            }
            leftAreaSubviewsIsHidden(false)
            return position
        }
        
        // 右边分割线，如上。
        
        if position > leftRightSplitView.frame.size.width - threshold {
            rightAreaSubviewsIsHidden(true)
            let number = leftRightSplitView.frame.size.width - thickness
            dividers[key] = thickness
            return number
        }
        rightAreaSubviewsIsHidden(false)
        dividers[key] = leftRightSplitView.frame.size.width - position
        return position
        
    }
    
    /// Left Area Split View。
    func leftAreaSplitViewResize(position: CGFloat, index: Int) ->CGFloat {
        dividers["leftArea\(index)"] = index == 0 ? position : leftAreaSplitView.frame.height - position
        return position
    }
    
    /// Center Area Split View。
    func centerAreaSplitViewResize(position: CGFloat, index: Int) ->CGFloat {
        dividers["centerArea\(index)"] = index == 0 ? position : centerAreaSplitView.frame.height - position
        return position
    }
    
    /// Right Area Split View。
    func rightAreaSplitViewResize(position: CGFloat, index: Int) ->CGFloat {
        dividers["rightArea\(index)"] = index == 0 ? position : rightAreaSplitView.frame.height - position
        return position
    }
    
    /// 显示左Left Area View的内容。
    func leftAreaIsHidden(_ bool: Bool){
        let postion = bool ? thickness : threshold + thickness
        leftRightSplitView.setPosition(postion, ofDividerAt: 0)
        leftAreaSubviewsIsHidden(bool)
    }
    
    /// 显示左Right Area View的内容。
    func rightAreaIsHidden(_ bool: Bool) {
        let number = bool ? thickness : threshold + thickness
        let postion = leftRightSplitView.frame.size.width - number
        leftRightSplitView.setPosition(postion, ofDividerAt: 1)
        leftAreaSubviewsIsHidden(bool)
    }
    
    /// 隐藏或显示Left Area View的内容，除IconButton外。
    func leftAreaSubviewsIsHidden(_ bool: Bool){
        catalogTitleView.isHidden = bool
        catalogScrollView.isHidden = bool
        catalogLine.isHidden = bool
        noteTitleView.isHidden = bool
        noteScrollView.isHidden = bool
        noteLine.isHidden = bool
        searchTitleView.isHidden = bool
        searchScrollView.isHidden = bool
        searchLine.isHidden = bool
    }
    
    /// 隐藏或显示Right Area View的内容，除IconButton外。
    func rightAreaSubviewsIsHidden(_ bool: Bool){
        roleTitleView.isHidden = bool
        roleScrollView.isHidden = bool
        roleLine.isHidden = bool
        symbolTitleView.isHidden = bool
        symbolScrollView.isHidden = bool
        symbolLine.isHidden = bool
        dictionaryTitleView.isHidden = bool
        dictionaryScrollView.isHidden = bool
        dictionaryLine.isHidden = bool
    }
}

// MARK: - Layout Config。
extension ViewController {
    /// 加载板块规格。
    func loadLayoutConfig() {
        // Left Right Split View。
        if let value: CGFloat = defaults.value(forKey: "leftRight0") as? CGFloat {
            leftRightSplitView.setPosition(value, ofDividerAt: 0)
            dividers["leftRight0"] = value
        } else {
            dividers["leftRight0"] = leftAreaView.frame.width
        }
        if let value: CGFloat = defaults.value(forKey: "leftRight1") as? CGFloat {
            leftRightSplitView.setPosition(leftRightSplitView.frame.width - value, ofDividerAt: 1)
            dividers["leftRight1"] = value
        } else {
            dividers["leftRight1"] = leftRightSplitView.frame.width - rightAreaView.frame.width
        }
        
        // Left Area Split View。
        if let value: CGFloat = defaults.value(forKey: "leftArea0") as? CGFloat {
            leftAreaSplitView.setPosition(value, ofDividerAt: 0)
            dividers["leftArea0"] = value
        } else {
            dividers["leftArea0"] = catalogBlockView.frame.height
        }
        if let value: CGFloat = defaults.value(forKey: "leftArea1") as? CGFloat {
            leftAreaSplitView.setPosition(leftAreaSplitView.frame.height - value, ofDividerAt: 1)
            dividers["leftArea1"] = value
        } else {
            dividers["leftArea1"] = leftAreaSplitView.frame.height - searchBlockView.frame.height
        }
        
        // Center Area Split View。
        if let value: CGFloat = defaults.value(forKey: "centerArea0") as? CGFloat {
            centerAreaSplitView.setPosition(value, ofDividerAt: 0)
            dividers["centerArea0"] = value
        } else {
            dividers["centerArea0"] = ideaBlockView.frame.height
        }
        if let value: CGFloat = defaults.value(forKey: "centerArea1") as? CGFloat {
            centerAreaSplitView.setPosition(centerAreaSplitView.frame.height - value, ofDividerAt: 1)
            dividers["centerArea1"] = value
        } else {
            dividers["centerArea1"] = centerAreaSplitView.frame.height - outlineBlockView.frame.height
        }
        
        // Right Area Split View。
        if let value: CGFloat = defaults.value(forKey: "rightArea0") as? CGFloat {
            rightAreaSplitView.setPosition(value, ofDividerAt: 0)
            dividers["rightArea0"] = value
        } else {
            dividers["rightArea0"] = roleBlockView.frame.height
        }
        if let value: CGFloat = defaults.value(forKey: "rightArea1") as? CGFloat {
            rightAreaSplitView.setPosition(rightAreaSplitView.frame.height - value, ofDividerAt: 1)
            dividers["rightArea1"] = value
        } else {
            dividers["rightArea1"] = rightAreaSplitView.frame.height - dictionaryBlockView.frame.height
        }
    }
    
    /// 保存板块规格。
    func saveLayoutConfig() {
        
        // Left Right Split View。
        defaults.set(dividers["leftRight0"], forKey: "leftRight0")
        defaults.set(dividers["leftRight1"], forKey: "leftRight1")
        
        
        // Left Area Split View。
        defaults.set(dividers["leftArea0"], forKey: "leftArea0")
        defaults.set(dividers["leftArea1"], forKey: "leftArea1")
        
        // Center Area Split View。
        defaults.set(dividers["centerArea0"], forKey: "centerArea0")
        defaults.set(dividers["centerArea1"], forKey: "centerArea1")
        
        // Right Area Split View。
        defaults.set(dividers["rightArea0"], forKey: "rightArea0")
        defaults.set(dividers["rightArea1"], forKey: "rightArea1")
    }
}

// MARK: - OutlineView: Based。

/**
 ## 实现OutlineView委托。
 1. Cell Based，4个必须实现的委托;
 2. View Based, 只需要实现非Colmun数据的3个，使用NSView来替换。
 */
extension ViewController: NSOutlineViewDataSource {
    
    // 各级的Row数量。
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        switch outlineView {
        case catalogOutlineView:
            return catalogOutlineViewRowNumber(item: item)
        case noteOutlineView:
            return noteOutlineViewRowNumber(item: item)
        case searchOutlineView:
            return searchOutlineViewRowNumber(item: item)
        case roleOutlineView:
            return roleOutlineViewRowNumber(item: item)
        case symbolOutlineView:
            return symbolOutlineViewRowNumber(item: item)
        case dictionaryOutlineView:
            return dictionaryOutlineViewRowNumber(item: item)
        default:
            return 0
        }
    }
    
    // 各级的Row数据。
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any{
        switch outlineView {
        case catalogOutlineView:
            return catalogOutlineRowData(index: index, item: item)
        case noteOutlineView:
            return noteOutlineRowData(index: index, item: item)
        case searchOutlineView:
            return searchOutlineRowData(index: index, item: item)
        case roleOutlineView:
            return roleOutlineRowData(index: index, item: item)
        case symbolOutlineView:
            return symbolOutlineRowData(index: index, item: item)
        case dictionaryOutlineView:
            return dictionaryOutlineRowData(index: index, item: item)
        default:
            return ""
        }
    }
    
    // 各级的Row是否为子集显示展开与收拢功能。
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool{
        switch outlineView {
        case catalogOutlineView:
            return catalogOutlineViewItemHasToggle(item: item)
        case noteOutlineView:
            return noteOutlineViewItemHasToggle(item: item)
        case searchOutlineView:
            return searchOutlineViewItemHasToggle(item: item)
        case roleOutlineView:
            return roleOutlineViewItemHasToggle(item: item)
        case symbolOutlineView:
            return symbolOutlineViewItemHasToggle(item: item)
        case dictionaryOutlineView:
            return dictionaryOutlineViewItemHasToggle(item: item)
        default:
            return false
        }
    }
    
    /// 拖动的接收方，index = -1时表示放在某项中，在这里不处理
    func outlineView(_ outlineView: NSOutlineView, acceptDrop info: NSDraggingInfo, item: Any?, childIndex index: Int) -> Bool {
        switch outlineView {
        case catalogOutlineView:
            return catalogOutlineViewEndDrag(info: info, item: item, index: index)
        case noteOutlineView:
            return noteOutlineViewEndDrag(info: info, item: item, index: index)
        case searchOutlineView:
            return searchOutlineViewEndDrag(info: info, item: item, index: index)
        case roleOutlineView:
            return roleOutlineViewEndDrag(info: info, item: item, index: index)
        case symbolOutlineView:
            return symbolOutlineViewEndDrag(info: info, item: item, index: index)
        case dictionaryOutlineView:
            return dictionaryOutlineViewEndDrag(info: info, item: item, index: index)
        default:
            return false
        }
    }
    
    /// 拖动的发起方与经过方，index = -1时表示拖某项
    func outlineView(_ outlineView: NSOutlineView, validateDrop info: NSDraggingInfo, proposedItem item: Any?, proposedChildIndex index: Int) ->
        NSDragOperation {
            switch outlineView {
            case catalogOutlineView:
                return catalogOutlineViewStartDrag(info: info, item: item, index: index)
            case noteOutlineView:
                return noteOutlineViewStartDrag(info: info, item: item, index: index)
            case searchOutlineView:
                return searchOutlineViewStartDrag(info: info, item: item, index: index)
            case roleOutlineView:
                return roleOutlineViewStartDrag(info: info, item: item, index: index)
            case symbolOutlineView:
                return symbolOutlineViewStartDrag(info: info, item: item, index: index)
            case dictionaryOutlineView:
                return dictionaryOutlineViewStartDrag(info: info, item: item, index: index)
            default:
                return NSDragOperation()
            }
    }
    
    /// 是否可拖移
    func outlineView(_ outlineView: NSOutlineView, pasteboardWriterForItem item: Any) -> NSPasteboardWriting? {
        switch outlineView {
        case catalogOutlineView:
            return catalogOutlineViewIsDrag(item: item)
        case noteOutlineView:
            return noteOutlineViewIsDrag(item: item)
        case searchOutlineView:
            return searchOutlineViewIsDrag(item: item)
        case roleOutlineView:
            return roleOutlineViewIsDrag(item: item)
        case symbolOutlineView:
            return symbolOutlineViewIsDrag(item: item)
        case dictionaryOutlineView:
            return dictionaryOutlineViewIsDrag(item: item)
        default:
            return nil
        }
    }
    
    /// 各级的Row数量。
    func catalogOutlineViewRowNumber(item: Any?) -> Int {
        if let catalog = item as? Catalog {
            return catalog.sub.count
        }
        return works.catalogData.count
    }
    
    func noteOutlineViewRowNumber(item: Any?) -> Int {
        // TODO
        return 0
    }
    
    func searchOutlineViewRowNumber(item: Any?) -> Int {
        // TODO
        return 0
    }
    
    func roleOutlineViewRowNumber(item: Any?) -> Int {
        // TODO
        return 0
    }
    
    func symbolOutlineViewRowNumber(item: Any?) -> Int {
        // TODO
        return 0
    }
    
    func dictionaryOutlineViewRowNumber(item: Any?) -> Int {
        // TODO
        return 0
    }
    
    /// Catalog各Row的数据。
    func catalogOutlineRowData(index: Int, item: Any?) -> Any{
        if let catalog = item as? Catalog {
            return catalog.sub[index]
        }
        return works.catalogData[index]
    }
    
    func noteOutlineRowData(index: Int, item: Any?) -> Any{
        // TODO
        return "Jiang Youhua"
    }
    
    func searchOutlineRowData(index: Int, item: Any?) -> Any{
        // TODO
        return "Jiang Youhua"
    }
    
    func roleOutlineRowData(index: Int, item: Any?) -> Any{
        // TODO
        return "Jiang Youhua"
    }
    
    func symbolOutlineRowData(index: Int, item: Any?) -> Any{
        // TODO
        return "Jiang Youhua"
    }
    
    func dictionaryOutlineRowData(index: Int, item: Any?) -> Any{
        // TODO
        return "Jiang Youhua"
    }
    
    /// 各Row是否显示展开与收拢功能。
    func catalogOutlineViewItemHasToggle(item: Any) -> Bool{
        if let catalog = item as? Catalog {
            return catalog.sub.count > 0
        }
        return false
    }
    
    func noteOutlineViewItemHasToggle(item: Any) -> Bool{
        // TODO
        return false
    }
    
    func searchOutlineViewItemHasToggle(item: Any) -> Bool{
        // TODO
        return false
    }
    
    func roleOutlineViewItemHasToggle(item: Any) -> Bool{
        // TODO
        return false
    }
    
    func symbolOutlineViewItemHasToggle(item: Any) -> Bool{
        // TODO
        return false
    }
    
    func dictionaryOutlineViewItemHasToggle(item: Any) -> Bool{
        // TODO
        return false
    }
    
    /// 结束拖移，章在章间移动、节在节间移动
    func catalogOutlineViewEndDrag(info: NSDraggingInfo, item: Any?, index: Int) -> Bool {
        guard let toParent = item as? Catalog else {
            return false
        }
        
        guard let atParent =  dragItems.catalog.inParent as? Catalog else {
            return false
        }
        
        // 如果是章，不能移到节的级别中
        if works.catalogData[0] === atParent && works.catalogData[0] !== toParent {
            return false
        }
        
        // 如果是节，不能移到章的级别中，可以意的子集尾
        if works.catalogData[0] !== atParent && works.catalogData[0] === toParent && index > -1{
            return false
        }
        
        // 移到其前
        var to = index
        if index < 0 {
            // 节，移为另一章的节
            to = toParent.sub.count
        } else if to > dragItems.catalog.at && to > 0 && atParent === toParent{
            // 同级向下
            to -= 1
        }
        AppDelegate.works.moveCatalog(at: dragItems.catalog.at, atParent: atParent, to: to, toParent: toParent)
        dragItems.catalog.at = -1
        dragItems.catalog.item = nil
        dragItems.catalog.inParent = nil
        catalogOutlineView.reloadData()
        catalogOutlineView.expandItem(item, expandChildren: true)
        return true
    }
    
    func noteOutlineViewEndDrag(info: NSDraggingInfo, item: Any?, index: Int) -> Bool {
        // TODO
        return true
    }
    
    func searchOutlineViewEndDrag(info: NSDraggingInfo, item: Any?, index: Int) -> Bool {
        // TODO
        return true
    }
    
    func roleOutlineViewEndDrag(info: NSDraggingInfo, item: Any?, index: Int) -> Bool {
        // TODO
        return true
    }
    
    func symbolOutlineViewEndDrag(info: NSDraggingInfo, item: Any?, index: Int) -> Bool {
        // TODO
        return true
    }
    
    func dictionaryOutlineViewEndDrag(info: NSDraggingInfo, item: Any?, index: Int) -> Bool {
        // TODO
        return true
    }
    
    /// 开始拖移
    func catalogOutlineViewStartDrag(info: NSDraggingInfo, item: Any?, index: Int) -> NSDragOperation {
        // 开始的节点
        if index < 0 && dragItems.catalog.at < 0{
            dragItems.catalog.at = catalogOutlineView.childIndex(forItem: item!)
            dragItems.catalog.item = item
            dragItems.catalog.inParent = catalogOutlineView.parent(forItem: item!)
            return NSDragOperation.move
        }
        let dragOperation: NSDragOperation = []
        // 过程节点
        guard let atParent = dragItems.catalog.inParent as? Catalog else {
            return dragOperation
        }
        guard let toParent = item as? Catalog else {
            return dragOperation
        }
        // 如果是章，不能移到节的级别中
        if works.catalogData[0] === atParent && works.catalogData[0] !== toParent {
            return dragOperation
        }
        // 如果是节，不能移到章的级别中，可以意的子集尾
        if works.catalogData[0] !== atParent && works.catalogData[0] === toParent && index > -1{
            return dragOperation
        }
        // 显示可插入标志
        return NSDragOperation.generic
    }
    
    func noteOutlineViewStartDrag(info: NSDraggingInfo, item: Any?, index: Int) -> NSDragOperation {
        // TODO
        return NSDragOperation()
    }
    func searchOutlineViewStartDrag(info: NSDraggingInfo, item: Any?, index: Int) -> NSDragOperation {
        // TODO
        return NSDragOperation()
    }
    func roleOutlineViewStartDrag(info: NSDraggingInfo, item: Any?, index: Int) -> NSDragOperation {
        // TODO
        return NSDragOperation()
    }
    func symbolOutlineViewStartDrag(info: NSDraggingInfo, item: Any?, index: Int) -> NSDragOperation {
        // TODO
        return NSDragOperation()
    }
    func dictionaryOutlineViewStartDrag(info: NSDraggingInfo, item: Any?, index: Int) -> NSDragOperation {
        // TODO
        return NSDragOperation()
    }
    
    /// 是否可拖移，拖多，返回空不可拖
    func catalogOutlineViewIsDrag(item: Any) -> NSPasteboardWriting? {
        guard let catalog = item as? Catalog else {
            return nil
        }
        let  pb = NSPasteboardItem.init()
        pb.setString(catalog.title, forType: NSPasteboard.PasteboardType.string)
        return pb
    }
    
    func noteOutlineViewIsDrag(item: Any) -> NSPasteboardWriting? {
        // TODO
        return nil
    }
    func searchOutlineViewIsDrag(item: Any) -> NSPasteboardWriting? {
        // TODO
        return nil
    }
    func roleOutlineViewIsDrag(item: Any) -> NSPasteboardWriting? {
        // TODO
        return nil
    }
    func symbolOutlineViewIsDrag(item: Any) -> NSPasteboardWriting? {
        // TODO
        return nil
    }
    func dictionaryOutlineViewIsDrag(item: Any) -> NSPasteboardWriting? {
        // TODO
        return nil
    }
}

// MARK: - OutlineView Edit。

/**
 # 实现对OutlineView的增删改与右键菜单。
 1. 实现ICON与View可编辑；
 */
extension ViewController:  NSOutlineViewDelegate {
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView?{
        switch outlineView {
        case catalogOutlineView:
            return catalogOutlineViewItemView(column: tableColumn, item: item)
        case noteOutlineView:
            return noteOutlineViewItemView(column: tableColumn, item: item)
        case searchOutlineView:
            return searchOutlineViewItemView(column: tableColumn, item: item)
        case roleOutlineView:
            return roleOutlineViewItemView(column: tableColumn, item: item)
        case symbolOutlineView:
            return symbolOutlineViewItemView(column: tableColumn, item: item)
        case dictionaryOutlineView:
            return dictionaryOutlineViewItemView(column: tableColumn, item: item)
        default:
            return nil
        }
    }
    
    /// 点击各行。
    func outlineViewSelectionDidChange(_ notification: Notification){
        let outlineView = notification.object as! NSOutlineView
        let index = outlineView.selectedRow
        switch outlineView {
        case catalogOutlineView:
            return catalogOutlineViewOpenItem(index: index)
        case noteOutlineView:
            return
        case searchOutlineView:
            return
        case roleOutlineView:
            return
        case symbolOutlineView:
            return
        case dictionaryOutlineView:
            return
        default:
            return
        }
    }
    
    
    func catalogOutlineViewItemView(column: NSTableColumn?, item: Any) -> NSView?{
        // 数据未传入。
        guard let catalog = item as? Catalog else {
            return nil
        }
        // 没有Identifier为“catalogTableCellView”的视图。
        guard let view = catalogOutlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier.init("catalogTableCellView"), owner: self) else {
            return nil
        }
        // 未设置Catalog的Table Cell View的Identifier为“catalogTableCellView”。
        guard let tableCellView = view as? NSTableCellView else {
            return nil
        }
        // 为Table Cell View设置Title与Icon。
        tableCellView.textField!.stringValue = catalog.title
        tableCellView.textField!.isEditable = true
        tableCellView.textField!.delegate = self
        tableCellView.textField!.tag = 1
        tableCellView.textField!.font = NSFont.systemFont(ofSize: 11)
        tableCellView.imageView!.image =  NSImage.init(named: NSImage.Name("catalogLevel\(catalog.level)"))
        return tableCellView
    }
    
    func noteOutlineViewItemView(column: NSTableColumn?, item: Any) -> NSView?{
        // TODO
        return nil
    }
    
    func searchOutlineViewItemView(column: NSTableColumn?, item: Any) -> NSView?{
        // TODO
        return nil
    }
    
    func roleOutlineViewItemView(column: NSTableColumn?, item: Any) -> NSView?{
        // TODO
        return nil
    }
    
    func symbolOutlineViewItemView(column: NSTableColumn?, item: Any) -> NSView?{
        // TODO
        return nil
    }
    
    func dictionaryOutlineViewItemView(column: NSTableColumn?, item: Any) -> NSView?{
        // TODO
        return nil
    }
}

// MARK: - Add Button。

/**
 ## 为Catalog、Note、Role、Symbol添加子项。
 */
extension ViewController {
    @IBAction func catalogAddButtonClick(_ sender: Any) {
        catalogOutlineViewAddItem()
    }
    
    @IBAction func noetAddButtonClick(_ sender: Any) {
        /// TODO
    }
    
    @IBAction func roleAddButtonClick(_ sender: Any) {
        /// TODO
    }
    
    @IBAction func symbolAddButtonClick(_ sender: Any) {
        /// TODO
    }
}

/// MARK: - Right Menu。

/**
 ## OutlineView Item的操作。
 1. 增、删、改；
 2. 位移、排序；
 3. 打开章节内容。
 */
extension ViewController: NSTextFieldDelegate {
    // Catalog Outline View。
    
    /// 完成编辑。
    func controlTextDidEndEditing(_ obj: Notification) {
        let textField = obj.object as! NSTextField
        switch textField.tag {
        case 1:
            return catalogOutlineViewUpdateItem(textField: textField, index: catalogOutlineView.selectedRow)
        case 2:
            return
        case 3:
            return
        case 4:
            return
        case 5:
            return
        case 6:
            return
        default:
            return
        }
    }
}

// MARK: - Catalog。

/**
 ## 编辑Catalog。
 */
extension ViewController {
    // 增加。
    @IBAction func catalogMenuAddItemClick(_ sender: Any) {
        catalogOutlineViewAddItem()
    }
    
    // 上移。
    @IBAction func catalogMenuMoveUpItemClick(_ sender: Any) {
        // 获取父节点，及在父节点的位置。
        guard let catalog = catalogOutlineView.item(atRow: catalogOutlineView.selectedRow) as? Catalog else {
            return
        }
        let (item, index) = works.parentCatalog(inSub: works.catalogData[0], catalog: catalog)
        if item == nil || index <= 0 {
            return
        }
        
        // 向上移一节点。
        works.moveCatalog(at: index, atParent: item!, to: index - 1, toParent: item!)
        catalogOutlineView.reloadData()
    }
    
    // 下移。
    @IBAction func catalogMenuMoveDownItemClick(_ sender: Any) {
        // 获取父节点，及在父节点的位置。
        guard let catalog = catalogOutlineView.item(atRow: catalogOutlineView.selectedRow) as? Catalog else {
            return
        }
        let (item, index) = works.parentCatalog(inSub: works.catalogData[0], catalog: catalog)
        if item == nil {
            return
        }
        if index >= item!.sub.count - 1 {
            return
        }
        // 向下移一节点。
        works.moveCatalog(at: index, atParent: item!, to: index + 1, toParent: item!)
        catalogOutlineView.reloadData()
    }
    
    // 移为首。
    @IBAction func catalogMenuMoveToFirstItemClick(_ sender: Any) {
        // 获取父节点，及在父节点的位置。
        // 获取父节点，及在父节点的位置。
        guard let catalog = catalogOutlineView.item(atRow: catalogOutlineView.selectedRow) as? Catalog else {
            return
        }
        let (item, index) = works.parentCatalog(inSub: works.catalogData[0], catalog: catalog)
        if item == nil {
            return
        }
        // 向上移一节点。
        works.moveCatalog(at: index, atParent: item!, to: 0 , toParent: item!)
        catalogOutlineView.reloadData()
    }
    
    // 移为尾
    @IBAction func catalogMenuMoveToLastItemClick(_ sender: Any) {
        // 获取父节点，及在父节点的位置。
        guard let catalog = catalogOutlineView.item(atRow: catalogOutlineView.selectedRow) as? Catalog else {
            return
        }
        let (item, index) = works.parentCatalog(inSub: works.catalogData[0], catalog: catalog)
        if item == nil {
            return
        }
        // 向上移一节点。
        works.moveCatalog(at: index, atParent: item!, to: item!.sub.count - 1, toParent: item!)
        catalogOutlineView.reloadData()
    }
    
    // 删除。
    @IBAction func catalogMenuDeleteItemClick(_ sender: Any) {
        let index = catalogOutlineView.selectedRow
        catalogOutlineViewDelItem(index: index)
    }
    
    // 增，TitleTabsVeiw、ContentText。
    func catalogOutlineViewAddItem(){
        // 打开设置窗口，添加完成后调用又catalogWindowAddedData。
        catalogWindowController = CatalogWindowController()
        catalogWindowController?.index = catalogOutlineView.selectedRow
        catalogWindowController?.showWindow(nil)
    }
    
    // 删。
    func catalogOutlineViewDelItem(index: Int){
        _ = works.catalogDataRomoveItem(index: index)
        catalogOutlineView.reloadData()
    }
    
    /// 改。
    func catalogOutlineViewUpdateItem(textField: NSTextField, index: Int){
        guard let catalog = catalogOutlineView.item(atRow: index) as? Catalog else {
            return
        }
        catalog.title = textField.stringValue
        tabsBarView.updateCatalogs(catalogs: works.infoData.contentTitleOnBar)
    }
    
    /// 打开。
    func catalogOutlineViewOpenItem(index: Int){
        if index < 1 {
            return
        }
        let catalog = catalogOutlineView.item(atRow: index) as! Catalog
        // 当前的。
        works.currentContent = catalog
        // 标题标签栏上。
        tabsBarView.addCatalog(catalog)
        catalogCurrentItem()
    }
    
    /// 完成新加或更新。
    func catalogWindowAddedData(catalog: Catalog) {
        // 新加。
        
        // 加入到当前。
        works.currentContent = catalog
        do {
            // 建立当前章节文件。
            try works.writeCurrentContentFile()
        } catch let error as WorksError{
            let alert = NSAlert()
            alert.addButton(withTitle: "OK")
            alert.messageText = "New File Error"
            switch error {
            case .operateError(let code, let function,  let info) :
                print(code, function)
                alert.informativeText = info
            }
            alert.runModal()
        } catch {
            print(error)
        }
        
        // 重建标签栏。
        catalogCurrentItem()
    }
    
    // 添加目录节点后，更新Layout。
    func catalogUpdatedItem() {
        catalogOutlineView.reloadData()
        tabsBarView.dataSource(catalogs: works.infoData.contentTitleOnBar, active: works.currentContent)
        catalogCurrentItem()
    }
    
    // 节点移动后，更新Layout。
    func catalogMovedItem() {
        catalogOutlineView.reloadData()
    }
    
    func catalogCurrentItem(){
        // 展天节点。
        catalogOutlineView.expandItem(nil, expandChildren: true)
        // 选择对应项。
        let (i, b) = works.indexCatalog(catalogs: works.catalogData, catalog: works.currentContent)
        if b {
            catalogOutlineView.selectRowIndexes(IndexSet.init(integer: i), byExtendingSelection: false)
        }
        // 读取内容。
        try? works.readCurrentChapterFile()
        ideaTextView.string = works.currentContent.info
        contentTextView.string = works.currentContentData
    }
}

/// MARK: 标签栏事件。
extension ViewController: TabsBarDelegate {
    func tabDidClicked(catalog: Catalog) {
        works.currentContent = catalog
        catalogCurrentItem()
    }
    
    func tabDidClosed(catalogs: [Catalog], current: Catalog) {
        works.currentContent = current
        works.infoData.contentTitleOnBar = catalogs
        catalogCurrentItem()
    }
}
