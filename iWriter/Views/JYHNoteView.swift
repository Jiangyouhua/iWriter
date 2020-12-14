//
//  JYHNoteView.swift
//  iWriter
//
//  Created by 姜友华 on 2020/5/6.
//  Copyright © 2020 Jiangyouhua. All rights reserved.
//

import Cocoa

class JYHNoteView: JYHBlockView, NSTextFieldDelegate {
    
    // MARK: - View.
    override func format(){
        // 状态。
        data = works.notes
        contentOutlineView.reloadData()
        expandedChildren(items: data)
    }
    
    override func interface(){
        // 初始界面。
        leftAddButtonState = false
        rightAddButtonState = false
        leftAddButton.isHidden = leftAddButtonState
        rightAddButton.isHidden = rightAddButtonState

        self.titleIconButton.image = NSImage(named: NSImage.Name("Note"))
        self.titleTextButton.title = "Note"
        self.leftAddButton.image = NSImage(named: NSImage.Name("AddNote"))
        self.rightAddButton.image = NSImage(named: NSImage.Name("AddReply"))
        self.titleIconButton.toolTip = "Show or Hide the Note Block"
        
        contextMenu()
    }
    
    // MARK: Action - Title Icon.
    /// 添加事项。
    override func leftButtonClicked(isSelect: Bool) {
        let node = Note(id: creationTime(), value: "New Note")
        data.append(node)
        works.notes = data as! [Note]
        writeAndReloadList()
    }
    
    /// 添加回复。
    override func rightButtonClicked(isSelect: Bool) {
        let index = contentOutlineView.selectedRow
        guard let note = contentOutlineView.item(atRow: index) as? Note else {
            return
        }
        let node = Note(id: creationTime(), value: "New Replay")
        
        // 非顶级。
        if note.parent != nil {
            note.parent?.add(child: node)
            if let item = note.parent as? Model {
                item.expanded = true
                writeAndReloadList(item )
            }
            return
        }
        note.add(child: node)
        note.expanded = true
        writeAndReloadList(note)
    }
    
    // MARK: Context Menu.
    /// 添加私有项。
    private func contextMenu(){
        // 菜单
        let addNode = NSMenuItem(title: "Add Note", action: #selector(addNodeMenuClick(_:)), keyEquivalent: "")
        let addText = NSMenuItem(title: "Add Reply", action: #selector(addTextMenuClick(_:)), keyEquivalent: "")
        rightClickMenu.insertItem(addNode, at: 0)
        rightClickMenu.insertItem(addText, at: 1)
        contentOutlineView.menu = rightClickMenu
    }
    
    /// 私有项的处理。
    @objc func addNodeMenuClick(_ sender: Any?) {
        leftButtonClicked(isSelect: false)
    }
    
    @objc func addTextMenuClick(_ sender: Any?) {
        rightButtonClicked(isSelect: false)
    }
    
    /// 根据当前项显示菜单项的有效性。
    func menuWillOpen(_ menu: NSMenu){
        guard let note = contentOutlineView.item(atRow: contentOutlineView.clickedRow) as? Note else {
            return
        }
        
        for item in menu.items {
            item.isEnabled = true
        }

        if note.parent != nil {
            menu.item(at: 1)?.isEnabled = false
        }
    }
    
    // MARK: - NSOutlineView
    
    /// 显示内容。
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView?{
        // 数据未传入。
        guard let note = item as? Note else {
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
            cell.textField!.stringValue = note.value
            cell.textField!.isEditable = true
            cell.textField!.delegate = self
            cell.imageView!.image = outlineNodeImage(top: note.parent == nil, checked: note.checked)
            return cell
        }
        return nil
    }
    
    /// 叶节点的选择发生变化。
    override func tableViewDidSelectRow(_ row : Int, _ column: Int, _ onTitleImage: Bool) {
        guard let note = contentOutlineView.item(atRow: row) as? Note else {
            return
        }
        if !onTitleImage {
            return
        }
        note.checked = !note.checked
        try? works.writeNoteFile()
        contentOutlineView.reloadItem(note)
    }
    
    /// 行被点。
    override func rowDoubleClicked(_ sender: Any) {
        guard let outlineView = sender as? NSOutlineView else {
                    return
                }
        guard let note = outlineView.item(atRow: outlineView.selectedRow) as? Note else {
            return
        }
        
        // TODO
    }
    
    /// 支节点被展开。
    func outlineViewItemDidExpand(_ notification: Notification){
        guard let note = notification.userInfo?["NSObject"] as? Note else {
            return
        }
        note.expanded = true
        try? works.writeNoteFile()
    }
    
    /// 支节点被关闭。
    func outlineViewItemWillCollapse(_ notification: Notification){
        guard let note = notification.userInfo?["NSObject"] as? Note else {
            return
        }
        note.expanded = false
        try? works.writeNoteFile()
    }
    
    // MARK: - 数据处理
    func outlineNodeImage(top: Bool, checked: Bool) -> NSImage {
        var imageName = "NoteChecked"
        if !checked {
            imageName = "NoteUnchecked"
        }
        if !top {
            imageName = "NoteReply"
        }
        return NSImage(named: NSImage.Name(imageName))!
    }
    
    /// 写入缓存并更新视图。
    override func writeAndReloadList(_ item: Model? = nil){
        // 保存数据。
        do {
            try works.writeNoteFile()
            contentOutlineView.reloadData()
            contentOutlineView.expandItem(item)
        } catch {
            print(error)
        }
    }

    /// 内容文字改完。
    func controlTextDidEndEditing(_ obj: Notification) {
        guard let note = contentOutlineView.item(atRow: contentOutlineView.selectedRow) as? Note  else {
            return
        }
        guard let textField = obj.object as? NSTextField else {
            return
        }
        note.naming = false
        if textField.stringValue.isEmpty {
            textField.stringValue = note.value
            return
        }
        note.value = textField.stringValue
        
        writeAndReloadList()
    }
    
    override func removeItemFromData(_ data: [Model]){
        works.notes = data as! [Note]
        writeAndReloadList()
    }
}
