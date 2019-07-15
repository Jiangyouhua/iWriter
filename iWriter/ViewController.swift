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
    
    // 内容相关
    let works = AppDelegate.works
    var catalogs = [Catalog]()
    
    // 布局相关
    let defaults = UserDefaults.standard
    let threshold: CGFloat = 130                  // Left Area View、 Right Area View 宽度最小值
    let thickness: CGFloat = 30                   // 标题栏厚度
    var dividers: [String: CGFloat] = [:]         // 各divider位置
    var loaded = false                            // 加载完成
    
    // Left Area View 处于隐藏状态
    var leftAreaState: Bool {
        get {
            return leftAreaView.frame.width == thickness
        }
    }
    
    // Right Area View 处于隐藏状态
    var rightAreaState: Bool {
        get {
            return rightAreaView.frame.width == thickness
        }
    }
    
    // Catalog Block View 处于隐藏状态
    var catalogState: Bool {
        get {
            return catalogBlockView.frame.height == thickness
        }
    }
    
    // Note Block View 处于隐藏状态
    var noteState: Bool {
        get {
            return noteBlockView.frame.height == thickness
        }
    }
    
    // Search Block View 处于隐藏状态
    var searchState: Bool {
        get {
            return searchBlockView.frame.height == thickness
        }
    }
    
    // Search Block View 处于隐藏状态
    var outlineState: Bool {
        get {
            return outlineBlockView.frame.height == thickness
        }
    }
    
    // Role Block View 处于隐藏状态
    var roleState: Bool {
        get {
            return roleBlockView.frame.height == thickness
        }
    }
    
    /**
     ## Func Start
    */
    
    // Symbol Block View 处于隐藏状态
    var symbolState: Bool {
        get {
            return symbolBlockView.frame.height == thickness
        }
    }
    
    // Dictionary Block View 处于隐藏状态
    var dictionaryState: Bool {
        get {
            return dictionaryBlockView.frame.height == thickness
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 布局的委托
        leftRightSplitView.delegate = self
        leftAreaSplitView.delegate = self
        centerAreaSplitView.delegate = self
        rightAreaSplitView.delegate = self
        
        
        // 数据的委托
        var catalog = Catalog()
        catalog.title = "第一章，第一节"
        catalog.creation = works.creationTime()
        catalogs = [catalog]
        catalogOutlineView.delegate = self
        catalogOutlineView.dataSource = self
        
        // 加载布局配置
        loadLayoutConfig()
        loaded = true
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
}

/// MARK: - Block Toggle

/**
 ## 各BlockView显示与隐藏
 显示：原则上向下展开。
 隐藏：原则上向上收拢。
 1. 所有BlockView隐藏，则隐藏其AreaView；
 2. 通IconButton显示其AreaView时，同时显示其BlockView。
 */
extension ViewController {
    
    /* IconButton Action*/
    
    /// 显示隐藏目录内容
    @IBAction func catalogIconClick(_ sender: Any) {
        // 判断AreaView是否隐藏
        if catalogTitleView.isHidden {
            // 如隐藏则显示
            leftAreaIsHidden(false)
            return catalogBlockShow()
        }
        
        // 显示
        if catalogState {
            return catalogBlockShow()
        }
        // 隐藏
        return catalogBlockHidden()
    }
    
    
    
    /// 显示隐藏备注内容， 同上
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
    
    /// 显示隐藏搜索内容， 同上
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
    
    
    /// 显示隐藏角色内容，同上
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
    
    /// 显示隐藏符号内容， 同上
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
    
    /// 显示隐藏字典内容， 同上
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
    
    /// 显示隐藏想法内容，同上，无AreaView判断
    @IBAction func ideaIconClick(_ sender: Any) {
        if ideaBlockView.frame.height == 0 {
            centerAreaSplitView.setPosition(threshold + thickness, ofDividerAt: 0)
        } else {
            centerAreaSplitView.setPosition( 0, ofDividerAt: 0)
        }
    }
    
    /// 显示隐藏大纲内容，同上
    @IBAction func outlineIconClick(_ sender: Any) {
        if outlineBlockView.frame.height == thickness {
            centerAreaSplitView.setPosition(centerAreaSplitView.frame.height - threshold - thickness, ofDividerAt: 1)
        } else {
            centerAreaSplitView.setPosition(centerAreaSplitView.frame.height - thickness, ofDividerAt: 1)
        }
    }
    
    /* BlockView Show Or Hidden */
    
    /// 显示Catalog Block View
    func catalogBlockShow(){
        // 1. 已显示，直接返回
        if !catalogState {
            return
        }
        
        // 2. 中显示，向下移动第一个Divider，移一半
        if !noteState {
            return leftAreaSplitView.setPosition(searchBlockView.frame.origin.y / 2, ofDividerAt: 0)
        }
        
        // 3. 向下移动第一个Divider
        leftAreaSplitView.setPosition(threshold + thickness, ofDividerAt: 0)
    }
    
    /// 隐藏Catalog Block View
    func catalogBlockHidden(){
        // 1. 中下隐藏，直接隐藏左区
        if noteState && searchState {
            return leftAreaIsHidden(true)
        }
        
        // 2. 中隐藏，向上移动第二个Divider
        if noteState {
            return leftAreaSplitView.setPosition(thickness * 2, ofDividerAt: 1)
        }
        
        // 3. 向上移动第一个Divider
        leftAreaSplitView.setPosition(thickness, ofDividerAt: 0)
    }
    
    /// 显示Note Block View
    func noteBlockShow(){
        // 1. 已显示，直接返回
        if !noteState {
            return
        }
        // 2. 下隐藏，向上移动第一个Divider
        if searchState {
            return leftAreaSplitView.setPosition(searchBlockView.frame.origin.y / 2, ofDividerAt: 0)
        }
        // 3. 向下移动第二个Divider，移一半
        leftAreaSplitView.setPosition(leftAreaView.frame.height - searchBlockView.frame.height / 2, ofDividerAt: 1)
    }
    
    /// 隐藏Note Block View
    func noteBlockHidden(){
        // 1. 中下隐藏，直接隐藏左区
        if catalogState && searchState {
            return leftAreaIsHidden(true)
        }
        // 2. 下隐藏，向下移动第一个Divider
        if searchState {
            return leftAreaSplitView.setPosition(leftAreaView.frame.height - thickness * 2, ofDividerAt: 0)
        }
        // 3. 向上移动第二个Divider
        let number = noteBlockView.frame.origin.y
        leftAreaSplitView.setPosition(number + thickness, ofDividerAt: 1)
    }
    
    /// 显示Search Block View
    func searchBlockShow(){
        // 1. 已显示，直接返回
        if !searchState {
            return
        }
        
        // 2. 中显示，向上移动第二个Divider，移一半
        if !noteState {
            return leftAreaSplitView.setPosition((noteBlockView.frame.origin.y + leftAreaView.frame.height) / 2, ofDividerAt: 1)
        }
        
        // 3. 向上移动第二个Divider
        leftAreaSplitView.setPosition(leftAreaView.frame.height - threshold - thickness, ofDividerAt: 1)
    }
    
    /// 隐藏Search Block View
    func searchBlockHidden(){
        // 1. 中下隐藏，直接隐藏左区
        if catalogState && noteState {
            return leftAreaIsHidden(true)
        }
        // 2. 中隐藏，向下移动第一个Divider
        if noteState {
            return leftAreaSplitView.setPosition(leftAreaView.frame.height - thickness * 2, ofDividerAt: 0)
        }
        // 3. 向下移动第二个Divider
        leftAreaSplitView.setPosition(leftAreaView.frame.height - thickness, ofDividerAt: 1)
    }
    
    /// 显示Role Block View
    func roleBlockShow(){
        // 1. 已显示，直接返回
        if !roleState {
            return
        }
        
        // 2. 中显示，向下移动第一个Divider，移一半
        if !symbolState {
            return rightAreaSplitView.setPosition(dictionaryBlockView.frame.origin.y / 2, ofDividerAt: 0)
        }
        
        // 3. 向下移动第一个Divider
        rightAreaSplitView.setPosition(threshold + thickness, ofDividerAt: 0)
    }
    
    /// 隐藏Catalog Block View
    func roleBlockHidden(){
        // 1. 中下隐藏，直接隐藏左区
        if symbolState && dictionaryState {
            return rightAreaIsHidden(true)
        }
        
        // 2. 中隐藏，向上移动第二个Divider
        if symbolState {
            return rightAreaSplitView.setPosition(thickness * 2, ofDividerAt: 1)
        }
        
        // 3. 向上移动第一个Divider
        rightAreaSplitView.setPosition(thickness, ofDividerAt: 0)
    }
    
    /// 显示Note Block View
    func symbolBlockShow(){
        // 1. 已显示，直接返回
        if !symbolState {
            return
        }
        // 2. 下隐藏，向上移动第一个Divider
        if dictionaryState {
            return rightAreaSplitView.setPosition(dictionaryBlockView.frame.origin.y / 2, ofDividerAt: 0)
        }
        // 3. 向下移动第二个Divider，移一半
        rightAreaSplitView.setPosition(rightAreaView.frame.height - dictionaryBlockView.frame.height / 2, ofDividerAt: 1)
    }
    
    /// 隐藏Note Block View
    func symbolBlockHidden(){
        // 1. 中下隐藏，直接隐藏左区
        if roleState && dictionaryState {
            return rightAreaIsHidden(true)
        }
        // 2. 下隐藏，向下移动第一个Divider
        if dictionaryState {
            return rightAreaSplitView.setPosition(rightAreaView.frame.height - thickness * 2, ofDividerAt: 0)
        }
        // 3. 向上移动第二个Divider
        rightAreaSplitView.setPosition(symbolBlockView.frame.origin.y + thickness, ofDividerAt: 1)
    }
    
    /// 显示Search Block View
    func dictionaryBlockShow(){
        // 1. 已显示，直接返回
        if !dictionaryState {
            return
        }
        
        // 2. 中显示，向上移动第二个Divider，移一半
        if !symbolState {
            return rightAreaSplitView.setPosition((symbolBlockView.frame.origin.y + rightAreaView.frame.height) / 2, ofDividerAt: 1)
        }
        
        // 3. 向上移动第二个Divider
        rightAreaSplitView.setPosition(rightAreaView.frame.height - threshold - thickness, ofDividerAt: 1)
    }
    
    /// 隐藏Search Block View
    func dictionaryBlockHidden(){
        // 1. 中下隐藏，直接隐藏左区
        if roleState && symbolState {
            return rightAreaIsHidden(true)
        }
        // 2. 中隐藏，向下移动第一个Divider
        if symbolState {
            return rightAreaSplitView.setPosition(rightAreaView.frame.height - thickness * 2, ofDividerAt: 0)
        }
        // 3. 向下移动第二个Divider
        rightAreaSplitView.setPosition(rightAreaView.frame.height - thickness, ofDividerAt: 1)
    }
    
}

/// MARK: - Area Toggle
/**
 ## 通过分隔线控制AreaView、BlockView
 1. 各AreaView、BlockView隐藏状态（最小状态）时保留标题栏；
 2. AreaView左右区，在阈值范围内自动隐藏。
 */
extension ViewController: NSSplitViewDelegate {
    /// 完成子视图的变化
    func splitViewDidResizeSubviews(_ notification: Notification){
        // 加载完成了没
        guard loaded else {
            return
        }
        // 是外部改变大小吗
        guard notification.userInfo == nil else {
            return
        }
        // 改变了内容大布局了吗
        guard let view = notification.object as? NSView else {
            return
        }
        // 保持左右AreaView不变，保存Ccenter Area View上下BlockView不变
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
    
    /// 分隔线位置发生了变化
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
    
    /// Left Right Splite View
    func leftRightSplitViewResize(position: CGFloat, index: Int) ->CGFloat {
        // 左边分割线
        let key = "leftRight\(index)"
        if index == 0 {
            dividers[key] = position
            // 小于阈值
            if position < threshold {
                // 隐藏Left Area View的内容，只保留IconButton
                leftAreaSubviewsIsHidden(true)
                // 并保留30的宽
                dividers[key] = thickness
                return thickness
            }
            leftAreaSubviewsIsHidden(false)
            return position
        }
        
        // 右边分割线，如上
        
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
    
    /// Left Area Split View
    func leftAreaSplitViewResize(position: CGFloat, index: Int) ->CGFloat {
        dividers["leftArea\(index)"] = index == 0 ? position : leftAreaSplitView.frame.height - position
        return position
    }
    
    /// Center Area Split View
    func centerAreaSplitViewResize(position: CGFloat, index: Int) ->CGFloat {
        dividers["centerArea\(index)"] = index == 0 ? position : centerAreaSplitView.frame.height - position
        return position
    }
    
    /// Right Area Split View
    func rightAreaSplitViewResize(position: CGFloat, index: Int) ->CGFloat {
        dividers["rightArea\(index)"] = index == 0 ? position : rightAreaSplitView.frame.height - position
        return position
    }
    
    /// 显示左Left Area View的内容
    func leftAreaIsHidden(_ bool: Bool){
        let postion = bool ? thickness : threshold + thickness
        leftRightSplitView.setPosition(postion, ofDividerAt: 0)
        leftAreaSubviewsIsHidden(bool)
    }
    
    /// 显示左Right Area View的内容
    func rightAreaIsHidden(_ bool: Bool) {
        let number = bool ? thickness : threshold + thickness
        let postion = leftRightSplitView.frame.size.width - number
        leftRightSplitView.setPosition(postion, ofDividerAt: 1)
        leftAreaSubviewsIsHidden(bool)
    }
    
    /// 隐藏或显示Left Area View的内容，除IconButton外
    func leftAreaSubviewsIsHidden(_ bool: Bool){
        catalogTitleView.isHidden = bool
        catalogScrollView.isHidden = bool
        noteTitleView.isHidden = bool
        noteScrollView.isHidden = bool
        searchTitleView.isHidden = bool
        searchScrollView.isHidden = bool
    }
    
    /// 隐藏或显示Right Area View的内容，除IconButton外
    func rightAreaSubviewsIsHidden(_ bool: Bool){
        roleTitleView.isHidden = bool
        roleScrollView.isHidden = bool
        symbolTitleView.isHidden = bool
        symbolScrollView.isHidden = bool
        dictionaryTitleView.isHidden = bool
        dictionaryScrollView.isHidden = bool
    }
}

/// MARK: - Layout Config
extension ViewController {
    /// 加载板块规格
    func loadLayoutConfig() {
        // Left Right Split View
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
        
        // Left Area Split View
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
        
        // Center Area Split View
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
        
        // Right Area Split View
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
    
    /// 保存板块规格
    func saveLayoutConfig() {
        
        // Left Right Split View
        defaults.set(dividers["leftRight0"], forKey: "leftRight0")
        defaults.set(dividers["leftRight1"], forKey: "leftRight1")
        
        
        // Left Area Split View
        defaults.set(dividers["leftArea0"], forKey: "leftArea0")
        defaults.set(dividers["leftArea1"], forKey: "leftArea1")
        
        // Center Area Split View
        defaults.set(dividers["centerArea0"], forKey: "centerArea0")
        defaults.set(dividers["centerArea1"], forKey: "centerArea1")
        
        // Right Area Split View
        defaults.set(dividers["rightArea0"], forKey: "rightArea0")
        defaults.set(dividers["rightArea1"], forKey: "rightArea1")
    }
}

/// MARK: - catalog
extension ViewController: NSOutlineViewDataSource, NSOutlineViewDelegate {
    // 顶级元素或子元素数量。
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if let catalog = item as? Catalog {
            return catalog.sub.count
        }
        return catalogs.count
    }
    
    // 顶级元素或子元素数据。
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any{
        if let catalog = item as? Catalog {
            return catalog.sub[index]
        }
        return catalogs[index]
    }
    
    // 是否有子元素。
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool{
        if let catalog = item as? Catalog {
            return catalog.sub.count > 0
        }
        return false
    }
    
    // 为各Cell添加数据，需要区别各列，所以在Storyboard中需要为各列及Cell添加Identifier。
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView?{
        let view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("catalogCell"), owner: self) as?  NSTableCellView
        if let catalog = item as? Catalog {
            if let textField = view?.textField {
                textField.stringValue = catalog.title
            }
        }
        return view
    }
    
    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat{
        return thickness
    }
    
    func formatCatalog() -> [Catalog]{
        var array = [Catalog]()
        var temp = Dictionary<Int, Catalog>()
        for catalog in AppDelegate.works.catalogData{
            if catalog.level == 0 {
                array.append(catalog)
            }else{
                if var c = temp[catalog.level - 1] {
                    c.sub.append(catalog)
                }
            }
            temp[catalog.level] = catalog
        }
        return array
    }
}
