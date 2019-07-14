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
    
    let defaults = UserDefaults.standard
    let threshold:CGFloat = 130          // Left Area View、 Right Area View 宽度最小值
    let thickness:CGFloat = 30           // 标题栏厚度
    
    // Catalog Block View 处于隐藏状态
    var catalogState:Bool{
        get{
            return catalogBlockView.frame.height == thickness
        }
    }
    
    // Note Block View 处于隐藏状态
    var noteState:Bool{
        get{
            return noteBlockView.frame.height == thickness
        }
    }
    
    // Search Block View 处于隐藏状态
    var searchState:Bool{
        get{
            return searchBlockView.frame.height == thickness
        }
    }
    
    // Role Block View 处于隐藏状态
    var roleState:Bool{
        get{
            return roleBlockView.frame.height == thickness
        }
    }
    
    // Symbol Block View 处于隐藏状态
    var symbolState:Bool{
        get{
            return symbolBlockView.frame.height == thickness
        }
    }
    
    // Dictionary Block View 处于隐藏状态
    var dictionaryState:Bool{
        get{
            return dictionaryBlockView.frame.height == thickness
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Split View的委托
        leftRightSplitView.delegate = self
        
        // 加载布局配置
        loadLayoutConfig()
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
    /// 分隔线位置发生了变化
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
            if proposedPosition > leftRightSplitView.frame.size.width - threshold {
                rightAreaSubviewsIsHidden(true)
                let number = leftRightSplitView.frame.size.width - thickness
                return number
            }
            rightAreaSubviewsIsHidden(false)
            return proposedPosition
        }
        return proposedPosition
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
        for i in [1, 0] {
            // Left Right Split View
            if let leftRightValue: CGFloat = defaults.value(forKey: Divider.leftRightSplitView(at: i)) as? CGFloat {
                leftRightSplitView.setPosition(leftRightValue, ofDividerAt: i)
            }
            
            
            // Left Area Split View
            if let leftAreaValue: CGFloat = defaults.value(forKey: Divider.leftAreaSplitView(at: i)) as? CGFloat {
                print("leftAreaValue", leftAreaValue, i)
                leftAreaSplitView.setPosition(leftAreaValue, ofDividerAt: i)
            }
            
            // Center Area Split View
            if let centerAreaValue: CGFloat = defaults.value(forKey: Divider.centerAreaSplitView(at: i)) as? CGFloat {
                centerAreaSplitView.setPosition(centerAreaValue, ofDividerAt: i)
            }
            
            // Right Area Split View
            if let rightAreaValue: CGFloat = defaults.value(forKey: Divider.rightAreaSplitView(at: i)) as? CGFloat {
                rightAreaSplitView.setPosition(rightAreaValue, ofDividerAt: i)
            }
        }
    }
    
    /// 保存板块规格
    func saveLayoutConfig() {
        
        // Left Right Split View
        let leftRightValue0 = leftAreaView.frame.width
        defaults.set(leftRightValue0, forKey: Divider.leftRightSplitView(at: 0))
        let leftRightValue1 = centerAreaView.frame.origin.x + centerAreaSplitView.frame.width
        defaults.set(leftRightValue1, forKey: Divider.leftRightSplitView(at: 1))
        
        
        // Left Area Split View
        let leftAreaValue0 = catalogBlockView.frame.height
        defaults.set(leftAreaValue0, forKey: Divider.leftAreaSplitView(at: 0))
        let leftAreaValue1 = noteBlockView.frame.origin.y + noteBlockView.frame.height
        defaults.set(leftAreaValue1, forKey: Divider.leftAreaSplitView(at: 1))
        
        // Center Area Split View
        let centerAreaValue0 = ideaBlockView.frame.height + thickness
        defaults.set(centerAreaValue0, forKey: Divider.centerAreaSplitView(at: 0))
        let centerAreaValue1 = contentBlockView.frame.origin.y + contentBlockView.frame.height
        defaults.set(centerAreaValue1, forKey: Divider.centerAreaSplitView(at: 1))
        
        // Right Area Split View
        let rightAreaValue0 = roleBlockView.frame.height
        defaults.set(rightAreaValue0, forKey: Divider.rightAreaSplitView(at: 0))
        let rightAreaValue1 = symbolBlockView.frame.origin.y + symbolBlockView.frame.height
        defaults.set(rightAreaValue1, forKey: Divider.rightAreaSplitView(at: 1))
    }
}
