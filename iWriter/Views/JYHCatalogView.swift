//
//  JYHCatalogView.swift
//  iWriter
//
//  Created by 姜友华 on 2020/5/6.
//  Copyright © 2020 Jiangyouhua. All rights reserved.
//

import Cocoa

class JYHCatalogView: JYHBlockView {
    
    // MARK: - View.
    override func format(){
        // 状态。
        data = [works.outlines[0]]
        contentOutlineView.reloadData()
        expandedChildren(items: data)
    }
    
    override func interface(){
        // 初始界面。
        leftAddButtonState = false
        rightAddButtonState = false
        leftAddButton.isHidden = leftAddButtonState
        rightAddButton.isHidden = rightAddButtonState

        self.titleIconButton.image = NSImage(named: NSImage.Name("Catalog"))
        self.titleTextButton.title = "Catalog"
        self.leftAddButton.image = NSImage(named: NSImage.Name("AddChapter"))
        self.rightAddButton.image = NSImage(named: NSImage.Name("AddSection"))
        self.titleIconButton.toolTip = "Show or Hide the Catalog Block"
        
        contextMenu()
    }
    
    // MARK: Action - Title Icon.
    override func leftButtonClicked(isSelect: Bool) {
        let node = addNode(title:"New Node", leaf: false, isSelect: isSelect)
        works.info.chapterSelection = node
        writeAndReloadList()
    }
    
    override func rightButtonClicked(isSelect: Bool) {
        let node = addNode(title:"New Text", leaf: true, isSelect: isSelect)
        works.info.chapterSelection = node
        works.info.chapterEditingId = node.creation
        works.opened(chapter: node)
        writeAndReloadList()
        
        // 添加并打开对应的文本。
        do {
            try node.readArticleFile()
        } catch {
            print(error)
        }
    }
    
    // MARK: Context Menu.
    /// 添加私有项。
    private func contextMenu(){
        // 菜单
        let addNode = NSMenuItem(title: "Add Node", action: #selector(addNodeMenuClick(_:)), keyEquivalent: "")
        let addText = NSMenuItem(title: "Add Text", action: #selector(addTextMenuClick(_:)), keyEquivalent: "")
        let importText = NSMenuItem(title: "Import Text", action: #selector(importTextMenuClick(_:)), keyEquivalent: "")
        let exportText = NSMenuItem(title: "Export Text", action: #selector(exportTextMenuClick(_:)), keyEquivalent: "")
        rightClickMenu.insertItem(addNode, at: 0)
        rightClickMenu.insertItem(addText, at: 1)
        rightClickMenu.insertItem(importText, at: 2)
        rightClickMenu.insertItem(exportText, at: 3)
        contentOutlineView.menu = rightClickMenu
    }
    
    /// 私有项的处理。
    @objc func addNodeMenuClick(_ sender: Any?) {
        leftButtonClicked(isSelect: false)
    }
    
    @objc func addTextMenuClick(_ sender: Any?) {
        rightButtonClicked(isSelect: false)
    }
    
    @objc func importTextMenuClick(_ sender: Any?) {
        // TODO
    }
    
    @objc func exportTextMenuClick(_ sender: Any?) {
        // TODO
    }
    
    /// 根据当前项显示菜单项的有效性。
    func menuWillOpen(_ menu: NSMenu){
        guard let chapter = contentOutlineView.item(atRow: contentOutlineView.clickedRow) as? Chapter else {
            return
        }
        
        for item in menu.items {
            item.isEnabled = true
        }
        
        if chapter.leaf {
            return
        }
        
        // 分支节点。
        menu.item(at: 2)?.isEnabled = false
        menu.item(at: 3)?.isEnabled = false
        if chapter.parent != nil {
            return
        }
        
        // 根节点。
        menu.item(at: 5)?.isEnabled = false
        menu.item(at: 6)?.isEnabled = false
        menu.item(at: 8)?.isEnabled = false
        menu.item(at: 9)?.isEnabled = false
    }
    
    /// 公有项的处理。
    override func moveUpItemClicked() {
        itemUpOrDown(isUp: true)
    }
    
    override func moveDownItemClicked() {
        itemUpOrDown(isUp: false)
    }
    
    override func renameItemClicked() {
        guard let chapter = contentOutlineView.item(atRow: contentOutlineView.clickedRow) as? Chapter else {
            return
        }
        chapter.naming = true
        contentOutlineView.reloadItem(chapter)
    }
    
    override func deleteItemClicked() {
        guard let chapter = contentOutlineView.item(atRow: contentOutlineView.clickedRow) as? Chapter else {
            return
        }
        
        if chapter.parent == nil {
            return
        }
        
        let i = chapter.countChildren()
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
        
        chapter.deleteFiles()
        _ = chapter.removeFromParent()
        writeAndReloadList()
    }
    
    // MARK: - NSOutlineView
    /// 各级的Row数量。
    override func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        guard let chapter = item as? Chapter else {
            return data.count
        }
        return chapter.children.count
    }
    
    /// 各级的Row数据。
    override func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any{
        guard let chapter = item as? Chapter else {
            return data[index]
        }
        return chapter.children[index]
    }
    
    /// 各级的Row是否为子集显示展开与收拢功能。
    override func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool{
        guard let chapter = item as? Chapter else {
            return false
        }
        return !chapter.leaf
    }
    
    /// 显示内容。
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView?{
        // 数据未传入。
        guard let chapter = item as? Chapter else {
            return nil
        }
        
        guard let columnIdentifier = tableColumn?.identifier else {
            return nil
        }
        
        // 标题。
        if columnIdentifier == NSUserInterfaceItemIdentifier(rawValue: "title") {
            let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "titleCellView")
            guard let cell = outlineView.makeView(withIdentifier: cellIdentifier, owner: nil) as? NSTableCellView else {
                return nil
            }
            
            // 为Table Cell View设置Title与Icon。
            cell.textField!.stringValue = chapter.content
            cell.textField!.isEditable = true
            cell.textField!.delegate = self
            cell.imageView!.image = outlineNodeImage(top: chapter.parent == nil, leaf: chapter.leaf)
            return cell
        }
        return nil
    }
    
    /// 行添加后的方法了处理当前项。
    override func outlineView(_ outlineView: NSOutlineView, didAdd rowView: NSTableRowView, forRow row: Int) {
        // 当前项。没有当前项，则选择根目录，有则选择其为当前项。
        if works.info.chapterSelection.content.isEmpty && row == 0 {
            outlineView.selectRowIndexes(IndexSet(integer: row), byExtendingSelection: false)
            return
        }
        guard let chapter = outlineView.item(atRow: row) as? Chapter else {
            return
        }
        
        // 如果与编辑项相同，则为当前选择项。
        if chapter.creation == works.info.chapterSelection.creation {
            outlineView.selectRowIndexes(IndexSet(integer: row), byExtendingSelection: false)
        }
        
        // 命名项。只有新建项为命名项，失去编辑模则naming = false.
        if chapter.naming {
            guard let cell = rowView.view(atColumn: 0) as? NSTableCellView else {
                return
            }
            // 命名项一定是当前项。
            outlineView.selectRowIndexes(IndexSet(integer: row), byExtendingSelection: false)
            outlineView.scrollRowToVisible(row)
            // 命名项一定为可见，所以必然展开上一级。
            outlineView.expandItem(chapter.parent)
            // 命名项设置为第一响应者，即进入命名状态。
            cell.textField?.becomeFirstResponder()
        }
    }
    
    // MARK: Drag
    /// 开始拖曳。将指定内容写入剪切板，这样可能实现通过拖曳将其内容拖至到文本域等。
    func outlineView(_ outlineView: NSOutlineView, pasteboardWriterForItem item: Any) -> NSPasteboardWriting? {
        guard let chapter = item as? Chapter else {
            return nil
        }
        
        node = chapter  // 更新拖曳的对象。
        let  pastBoard = NSPasteboardItem.init()
        pastBoard.setString(chapter.content, forType: NSPasteboard.PasteboardType.string)
        return pastBoard
    }

    /// 拖曳中。
    func outlineView(_ outlineView: NSOutlineView, validateDrop info: NSDraggingInfo, proposedItem item: Any?, proposedChildIndex index: Int) ->
        NSDragOperation {
            let dragNullOperation: NSDragOperation = []
        
            // 根节点，不能拖曳。
            guard let chapter = item as? Chapter else {
                return dragNullOperation
            }
            
            // 无效接收节点、无效拖曳节点，不能拖曳。
            if node?.parent == nil {
                return dragNullOperation
            }
            
            // 内部方法，确定不是拖曳到自己或子类的内部。
            func lap(_ n: Model?) -> Bool{
                if n?.parent == nil {
                    return false
                }
                if n?.creation == node?.creation {
                    return true
                }
                return lap(n?.parent)
             }
            
            if lap(chapter) {
                return dragNullOperation
            }
        
            return NSDragOperation.generic
    }
    
    /// 结束拖曳。
    func outlineView(_ outlineView: NSOutlineView, acceptDrop info: NSDraggingInfo, item: Any?, childIndex index: Int) -> Bool {
        // 接收的对象为空。
        guard let chapter = item as? Chapter else {
            return false
        }
        
        // 叶节点不接收拖移。
        if chapter.leaf{
            return false
        }
        
        // 从自身的父节点中移除自己。
        let i = node!.removeFromParent()
        if i < 0 {
            return false
        }
        
        // 判断移至内或移至某位置。
        var x = index
        // 移至某支叶节里。
        if index < 0 {
            x = chapter.children.count
        }
        // 同子集里下移。
        if node?.parent?.creation == chapter.creation && i < x {
            x -= 1
        }
        outlineView.moveItem(at: i, inParent: node?.parent, to: x, inParent: chapter)
        
        // 同步更新数据。
        chapter.children.insert(node!, at: x)       // 添加到新的里面；
        node?.parent = chapter                      // 更新其父节点。
        try? works.writeOutlineFile()
        
        // 节点清空。
        node = nil
        return true
    }
    
    /// 支节点被展开。
    func outlineViewItemDidExpand(_ notification: Notification){
        guard let chapter = notification.userInfo?["NSObject"] as? Chapter else {
            return
        }
        chapter.expanded = true
        try? works.writeOutlineFile()
    }
    
    /// 支节点被关闭。
    func outlineViewItemWillCollapse(_ notification: Notification){
        guard let chapter = notification.userInfo?["NSObject"] as? Chapter else {
            return
        }
        chapter.expanded = false
        try? works.writeOutlineFile()
    }
    
    /// 叶节点的选择发生变化。
    override func tableViewDidSelectRow(_ row : Int, _ column: Int, _ onTitleImage: Bool) {
        guard let chapter = contentOutlineView.item(atRow: row) as? Chapter else {
            return
        }
        if !chapter.leaf {
            return
        }

        works.info.chapterEditingId = chapter.creation
        works.info.chapterSelection = chapter
        works.opened(chapter: chapter)
        works.delegate?.selectedLeaf(chapter: chapter)
        do {
            try works.writeInfoFile()
            try works.writeOutlineFile()
        } catch {
            print(error)
        }
    }
    
    /// 行被点。
    override func rowDoubleClicked(_ sender: Any) {
        guard let outlineView = sender as? NSOutlineView else {
                    return
                }
                
        guard let chapter = outlineView.item(atRow: outlineView.selectedRow) as? Chapter else {
            return
        }
        
        // 展开或关闭子项。
        if chapter.leaf {
            return
        }
        chapter.expanded = !outlineView.isItemExpanded(chapter)
        try? works.writeOutlineFile()
        if chapter.expanded {
            return outlineView.expandItem(chapter)
        }
        return outlineView.collapseItem(chapter)
    }
    
    // MARK: - 数据处理
    /// 增。
    func addNode(title:String, leaf: Bool, isSelect: Bool) -> Chapter {
        let row = isSelect ? contentOutlineView.selectedRow : contentOutlineView.clickedRow
        let chapter: Chapter = contentOutlineView.item(atRow: row) as? Chapter ?? data[0] as! Chapter
        let node = Chapter()
        node.content = title
        node.leaf = leaf
        
        // 当前节点为支节点，添加到其子集的未尾。
        if !chapter.leaf {
            node.parent = chapter
            node.expanded = true
            contentOutlineView.expandItem(chapter)
            chapter.children.append(node)
            return node
        }
        
        // 当前节点为叶节点，添加到其后，为同级。
        node.parent = chapter.parent
        let index = chapter.indexParent()
        if index < 0 {
            return node
        }
        chapter.parent?.children.insert(node, at: index + 1)
        return node
    }
    
    /// 位移。
    override func itemUpOrDown(isUp: Bool){
        guard let chapter = contentOutlineView.item(atRow: contentOutlineView.clickedRow) as? Chapter else {
            return
        }
        
        // 确定兄弟的个数
        guard let count = chapter.parent?.children.count else {
            return
        }
        if count < 2 {
            return
        }
        
        // 确定当前节点在兄弟节点中的位置。
        let index = chapter.indexParent()
        if index < 0 {
            return
        }
        
        if isUp {
            if index == 0 {
                return
            }
            contentOutlineView.moveItem(at: index, inParent: chapter.parent, to: index - 1, inParent: chapter.parent)
            chapter.parent?.children.remove(at: index)
            chapter.parent?.children.insert(chapter, at: index - 1)
            return
        }
        if index == count - 1 {
            return
        }
        contentOutlineView.moveItem(at: index, inParent: chapter.parent, to: index + 1, inParent: chapter.parent)
        chapter.parent?.children.remove(at: index)
        chapter.parent?.children.insert(chapter, at: index + 1)
    }
    
    func outlineNodeImage(top: Bool, leaf: Bool) -> NSImage {
        var imageName = "CatalogLeaf"
        if !leaf {
            imageName = "CatalogBranch"
        }
        if top {
            imageName = "CatalogBook"
        }
        return NSImage(named: NSImage.Name(imageName))!
    }
    
    /// 按Chapter.children标志展开下一级。
    override func expandedChildren(items: [Model]){
        for item in items {
            guard let it = item as? Chapter else {
                return
            }
            if it.expanded {
                contentOutlineView.expandItem(item)
            }
            // 同步标题栏
            if it.leaf && it.opened {
                works.opened(chapter: it)
                works.delegate?.selectedLeaf(chapter: it)
            }
            if item.children.isEmpty {
                continue
            }
            expandedChildren(items: item.children)
        }
    }
}

// MARK: 文本的处理。
extension JYHCatalogView: NSTextFieldDelegate {
    /// 改。
    func controlTextDidEndEditing(_ obj: Notification) {
        guard let chapter = contentOutlineView.item(atRow: contentOutlineView.selectedRow) as? Chapter  else {
            return
        }
        guard let textField = obj.object as? NSTextField else {
            return
        }
        chapter.naming = false
        if textField.stringValue.isEmpty {
            textField.stringValue = chapter.content
            return
        }
        chapter.content = textField.stringValue
        works.delegate?.namedLeaf(chapter: chapter)
        writeAndReloadList()
    }
    
    /// 写入缓存并更新视图。
    private func writeAndReloadList(){
        // 保存数据。
        do {
            try works.writeOutlineFile()
            contentOutlineView.reloadData()

        } catch {
            print(error)
        }
    }
}
