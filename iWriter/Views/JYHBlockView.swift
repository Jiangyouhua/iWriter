//
//  JYHBlockView.swift
//  iWriter
//
//  Created by 姜友华 on 2020/4/29.
//  Copyright © 2020 Jiangyouhua. All rights reserved.
//

import Cocoa

protocol JYHBlockViewDelegate {
    func blockTitleClicked(_ target: JYHBlockView)
}

class JYHBlockView: NSView, NSOutlineViewDelegate, NSOutlineViewDataSource, NSMenuDelegate{
    
    @IBOutlet var view: NSView!
    @IBOutlet weak var titleIconButton: NSButton!
    @IBOutlet weak var titleTextButton: NSButton!
    @IBOutlet weak var leftAddButton: NSButton!
    @IBOutlet weak var rightAddButton: NSButton!
    @IBOutlet weak var horizontalLineView: JYHView!
    @IBOutlet weak var contentScrollView: NSScrollView!
    @IBOutlet weak var contentOutlineView: NSOutlineView!
    @IBOutlet weak var titleColumn: NSTableColumn!
    @IBOutlet weak var otherColumn: NSTableColumn!
    
    // Menu
    @IBOutlet var rightClickMenu: NSMenu!
    
    // 跟区域大小相关的分割线，点击标题栏时需要改变其位置。
    let works = (NSApp.delegate as! AppDelegate).works
    var delegate: JYHBlockViewDelegate?
    
    // 添加按钮的状态， true为隐藏。
    var leftAddButtonState = true
    var rightAddButtonState = true
    
    // icon 被点击。
    @IBAction func titleIconButtonClick(_ sender: Any) {
        self.delegate?.blockTitleClicked(self)
    }
    
    // title 被点击。
    @IBAction func titleTextButtonClick(_ sender: Any) {
        self.delegate?.blockTitleClicked(self)
    }
    
    @IBAction func leftAddButtonClick(_ sender: Any) {
        leftButtonClicked(isSelect: true)
    }
    
    @IBAction func rightAddButtonClick(_ sender: Any) {
        rightButtonClicked(isSelect: true)
    }
    
    // MARK:  - Menu Action
    @IBAction func moveUpMenuClicked(_ sender: Any) {
        moveUpItemClicked()
    }
    
    @IBAction func moveDownMenuClicked(_ sender: Any) {
        moveDownItemClicked()
    }
    
    @IBAction func renameMenuClicked(_ sender: Any) {
        renameItemClicked()
    }
    
    @IBAction func deleteMenuClicked(_ sender: Any) {
        deleteItemClicked()
    }
    
    @objc func doubleClicked(_ sender: Any){
        print(#function)
    }
    
    @objc func rowClicked(_ sender: Any){
        print(#function)
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
        Bundle.main.loadNibNamed("JYHBlockView", owner: self, topLevelObjects: nil)
        self.addSubview(self.view)
        
        // 表格处理。
        contentOutlineView.delegate = self
        contentOutlineView.dataSource = self
        contentOutlineView.target = self
        contentOutlineView.action = #selector(outlineViewDidClick(_:))
        contentOutlineView.doubleAction = #selector(doubleClicked(_:))
        
        // 右键菜单。
        rightClickMenu.autoenablesItems = false       // 可自己设置菜单项的可用状态。
        rightClickMenu.delegate = self
        
        interface()
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        // 及时更新视图的大小。
        self.view.frame = self.bounds
        titleColumn.width = self.bounds.width - otherColumn.width
        
        // LeftArea进入隐藏状态。
        if self.frame.size.width <= iconWidth {
            titleTextButton.isHidden = true
            leftAddButton.isHidden = true
            rightAddButton.isHidden = true
            contentScrollView.isHidden = true
            horizontalLineView.isHidden = true
            return
        }
        
        // title上元素的显示。
        titleTextButton.isHidden = false
        contentScrollView.isHidden = false
        horizontalLineView.isHidden = false
        leftAddButton.isHidden = leftAddButtonState
        rightAddButton.isHidden = rightAddButtonState
    }
    
    /// NSOutlineViewDataSource
    // 各级的Row数量。
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        return 0
    }
    
    // 各级的Row数据。
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any{
        return (Any).self
    }
    
    // 各级的Row是否为子集显示展开与收拢功能。
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool{
        return false
    }
    
    func menuWillOpen(_ menu: NSMenu){
        print(#function)
    }
    
    func interface(){
        print(#function)
    }
    
    // 处理各子类的结构。
    func format(){
        print(#function)
    }
    
    func leftButtonClicked(isSelect: Bool){
        print(#function)
    }
    
    func rightButtonClicked(isSelect: Bool){
        print(#function)
    }
       
    func moveUpItemClicked(){
        print(#function)
    }
    
    func moveDownItemClicked(){
        print(#function)
    }
    
    func renameItemClicked(){
        print(#function)
    }
    
    func deleteItemClicked(){
        print(#function)
    }
    
    @objc func outlineViewDidClick(_ event: NSEvent){
        let row = contentOutlineView.clickedRow
        let column = contentOutlineView.clickedColumn
        let onTitleImage = onImageViewWithCell(row: row, column: column)
        let unselected = -1

        if row == unselected && column == unselected{
            tableViewDidDeselectRow()
            return
        }else if row != unselected && column != unselected{
            tableViewDidSelectRow(row, column, onTitleImage)
            return
        }else if column != unselected && row == unselected{
            tableviewDidSelectHeader(column)
        }
    }
    
    // 判断是否在图片上点击。、
    private func onImageViewWithCell(row: Int, column: Int) -> Bool{
        guard let titleCell: NSTableCellView = contentOutlineView.view(atColumn: column, row: row, makeIfNecessary: true) as? NSTableCellView else {
            return false
        }
        guard let view = titleCell.imageView else {
            return false
        }
        guard let point = view.window?.mouseLocationOutsideOfEventStream else {
            return false
        }
        let p = (self.window?.contentView?.convert(point, to: view.superview))!
        return view.isMousePoint(p, in: view.frame)
    }
    
    func tableViewDidDeselectRow() {
        print(#function)
    }

    func tableViewDidSelectRow(_ row : Int, _ column: Int, _ onTitleImage: Bool){
        print(#function)
    }

    func tableviewDidSelectHeader(_ column : Int){
        print(#function)
    }
    
    func reloadDataWithRow(_ row: Int) {
        contentOutlineView.removeItems(at: IndexSet(integer: row), inParent: nil, withAnimation: .effectFade)
        contentOutlineView.insertItems(at: IndexSet(integer: row), inParent: nil, withAnimation: .effectFade)
    }
}
