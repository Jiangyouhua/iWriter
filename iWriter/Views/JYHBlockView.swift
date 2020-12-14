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
    
    /// Context Menu
    @IBOutlet var rightClickMenu: NSMenu!
    
    /// 跟区域大小相关的分割线，点击标题栏时需要改变其位置。
    let works = (NSApp.delegate as! AppDelegate).works
    var data: [Model] = []
    var heights = [Int: CGFloat]()
    var node: Model?
    var delegate: JYHBlockViewDelegate?
    
    /// 添加按钮的状态， true为隐藏。
    var leftAddButtonState = true
    var rightAddButtonState = true
    
    // MARK: Action - Title Clicked
    /// Title Icon clicked
    @IBAction func titleIconButtonClick(_ sender: Any) {
        self.delegate?.blockTitleClicked(self)
    }
    
    /// Title Text clicked.
    @IBAction func titleTextButtonClick(_ sender: Any) {
        self.delegate?.blockTitleClicked(self)
    }
    
    /// left Icon clicked.
    @IBAction func leftAddButtonClick(_ sender: Any) {
        leftButtonClicked(isSelect: true)
    }
    
    /// right Icon clicked.
    @IBAction func rightAddButtonClick(_ sender: Any) {
        rightButtonClicked(isSelect: true)
    }
    
    func leftButtonClicked(isSelect: Bool){
        print(#function)
    }
    
    func rightButtonClicked(isSelect: Bool){
        print(#function)
    }
    
    // MARK:  Action - Context Clicked
    /// Move Up Item.
    @IBAction func moveUpMenuClicked(_ sender: Any) {
        moveUpItemClicked()
    }
    
    /// Move Down Item.
    @IBAction func moveDownMenuClicked(_ sender: Any) {
        moveDownItemClicked()
    }
    
    /// Remane Item.
    @IBAction func renameMenuClicked(_ sender: Any) {
        renameItemClicked()
    }
    
    /// Delete Item.
    @IBAction func deleteMenuClicked(_ sender: Any) {
        deleteItemClicked()
    }
       
    func moveUpItemClicked() {
        itemUpOrDown(isUp: true)
    }
    
    func moveDownItemClicked() {
        itemUpOrDown(isUp: false)
    }
    
    func renameItemClicked() {
        guard let model = contentOutlineView.item(atRow: contentOutlineView.clickedRow) as? Model else {
            return
        }
        model.naming = true
        contentOutlineView.reloadData()
    }
    
    func deleteItemClicked() {
        guard let model = contentOutlineView.item(atRow: contentOutlineView.clickedRow) as? Model else {
            return
        }
        
        let i = model.countChildren()
        let alert = NSAlert()
        alert.addButton(withTitle: "Delete")
        alert.addButton(withTitle: "Cancel")
        alert.messageText = "Do you want to delete the \(i) selected items?"
        alert.informativeText = "This operation cannot be undone."
        let code = alert.runModal()
        
        //  用户取消了
        if code == NSApplication.ModalResponse.alertSecondButtonReturn {
            return
        }
        
        if model.parent != nil {
            _ = model.removeFromParent()
            writeAndReloadList()
            return
        }
        _ = model.removeFromArray(&data)
        removeItemFromData(data)
    }
    
    func writeAndReloadList(_ item: Model? = nil){
        print(#function)
    }
    
    func removeItemFromData(_ data: [Model]){
        print(#function)
    }
    
    // MARK: View
    /// Init Subclass.
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
        contentOutlineView.doubleAction = #selector(rowDoubleClicked(_:))
        contentOutlineView.registerForDraggedTypes([NSPasteboard.PasteboardType.string])
        
        // 右键菜单。
        rightClickMenu.autoenablesItems = false       // 可自己设置菜单项的可用状态。
        rightClickMenu.delegate = self
        
        interface()
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        // 及时更新视图的大小。
        self.view.frame = self.bounds
        titleColumn.width = self.bounds.width - 10
        
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
    
    /// 界面处理。
    func interface(){
        print(#function)
    }
    
    /// 显示处理。
    func format(){
        print(#function)
    }
    
    // MARK: NSOutlineView
    /// 各级的Row数量。
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        guard let model = item as? Model else {
            return data.count
        }
        return model.children.count
    }
    
    /// 各级的Row数据。
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any{
        guard let model = item as? Model else {
            return data[index]
        }
        return model.children[index]
    }
    
    /// 各级的Row是否为子集显示展开与收拢功能。
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool{
        guard let model = item as? Model else {
            return false
        }
        return model.children.count > 0
    }
    
    /// 行添加后的方法了处理当前项。
    func outlineView(_ outlineView: NSOutlineView, didAdd rowView: NSTableRowView, forRow row: Int) {
        guard let model = outlineView.item(atRow: row) as? Model else {
            return
        }
        
        // 命名项。只有新建项为命名项，失去编辑模则naming = false.
        if model.naming {
            guard let cell = rowView.view(atColumn: 0) as? NSTableCellView else {
                return
            }
            // 命名项一定是当前项。
            outlineView.selectRowIndexes(IndexSet(integer: row), byExtendingSelection: false)
            outlineView.scrollRowToVisible(row)
            // 命名项一定为可见，所以必然展开上一级。
            outlineView.expandItem(model.parent)
            // 命名项设置为第一响应者，即进入命名状态。
            cell.textField?.becomeFirstResponder()
        }
    }
    
    // MARK: Drag
    /// 开始拖曳。将指定内容写入剪切板，这样可能实现通过拖曳将其内容拖至到文本域等。
    func outlineView(_ outlineView: NSOutlineView, pasteboardWriterForItem item: Any) -> NSPasteboardWriting? {
        guard let model = item as? Model else {
            return nil
        }
        
        node = model  // 更新拖曳的对象。
        let  pastBoard = NSPasteboardItem.init()
        pastBoard.setString(model.value, forType: NSPasteboard.PasteboardType.string)
        return pastBoard
    }

    /// 拖曳中。
    func outlineView(_ outlineView: NSOutlineView, validateDrop info: NSDraggingInfo, proposedItem item: Any?, proposedChildIndex index: Int) ->
        NSDragOperation {
        let dragNullOperation: NSDragOperation = []
        
        // 非同父节点的兄弟节点间，不能拖曳。
        if (item == nil && node?.parent == nil) || (item as? Model)?.id == node?.parent?.id {
            return NSDragOperation.generic
        }
        return dragNullOperation
    }
    
    /// 结束拖曳。
    func outlineView(_ outlineView: NSOutlineView, acceptDrop info: NSDraggingInfo, item: Any?, childIndex index: Int) -> Bool {
        
        // 非同父节点的兄弟节点间，不能拖曳。
        if (item == nil && node?.parent == nil) || (item as? Model)?.id == node?.parent?.id {
            let parent = node?.parent

            // 从自身的父节点中移除自己。
            let i = item == nil ? node!.removeFromArray(&data) : node!.removeFromParent()
            if i < 0 {
                return false
            }
            var x = index
            // 同子集里下移。
            if i < index {
                x -= 1
            }
            
            outlineView.moveItem(at: i, inParent: parent, to: x, inParent: parent)
            
            // 同步更新数据。
            if parent == nil {
                data.insert(node!, at: x)
            } else {
                parent!.children.insert(node!, at: x)       // 添加到新的里面；
            }
            try? works.writeOutlineFile()
            
            // 节点清空。
            node = nil
            return true
        }
        return false
    }
    
    // MARK: Action - Row Clicked
    /// Row点击事件。
    @objc func outlineViewDidClick(_ event: NSEvent){
        let row = contentOutlineView.clickedRow
        if row < 0 {
            return 
        }
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
    
    /// 判断是否在图片上点击。、
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
    
    /// 取消行选择。
    func tableViewDidDeselectRow() {
        print(#function)
    }

    /// 选择行。
    func tableViewDidSelectRow(_ row : Int, _ column: Int, _ onTitleImage: Bool){
        print(#function)
    }

    /// 选择了表头。
    func tableviewDidSelectHeader(_ column : Int){
        print(#function)
    }
    
    /// 更新当前行数据。
    func reloadDataWithRow(_ row: Int) {
        contentOutlineView.removeItems(at: IndexSet(integer: row), inParent: nil, withAnimation: .effectFade)
        contentOutlineView.insertItems(at: IndexSet(integer: row), inParent: nil, withAnimation: .effectFade)
    }

    /// 双击当前行。
    @objc func rowDoubleClicked(_ sender: Any){
        print(#function)
    }
    
    func itemUpOrDown(isUp: Bool){
        let at = contentOutlineView.clickedRow
        guard let n = contentOutlineView.item(atRow: at) as? Model else {
            return
        }
        
        // 确定当前节点在兄弟节点中的位置。
        node = n
        var to = at + 2
        
        if isUp {
            if at == 0 {
                return
            }
            to = at - 1
        }
        changePosition(at: at, to: to, inParent: n.parent)
    }
    
    func changePosition(at: Int, to: Int, inParent: Node?) {
        // 判断移至内或移至某位置。
        var x = to
        // 同子集里下移。
        if at < x {
            x -= 1
        }
        if  to == at {
            return
        }
        contentOutlineView.moveItem(at: at, inParent: inParent, to: x, inParent: inParent)
        
        // 同步更新数据。
        if inParent == nil {
            data.remove(at: at)
            data.insert(node!, at: x)
        } else {
            inParent?.children.remove(at: at)
            inParent?.children.insert(node!, at: x)       // 添加到新的里面；
        }
        try? works.writeNoteFile()
        node = nil
    }
    
    /// 按Note.children标志展开下一级。
    func expandedChildren(items: [Model]){
        for item in items {
            if item.expanded {
                contentOutlineView.expandItem(item)
            }
            guard let array = item.children as? [Model] else {
                return
            }
            expandedChildren(items: array)
        }
    }
}
