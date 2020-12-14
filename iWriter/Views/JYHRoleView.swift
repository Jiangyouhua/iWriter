//
//  JYHRoleView.swift
//  iWriter
//
//  Created by 姜友华 on 2020/5/6.
//  Copyright © 2020 Jiangyouhua. All rights reserved.
//

import Cocoa

class JYHRoleView: JYHBlockView, NSTextFieldDelegate {
    
    override func format(){
        // 状态。
        data = works.roles
        contentOutlineView.reloadData()
        expandedChildren(items: data)
    }
    
    override func interface() {
        // 初始界面。
        leftAddButtonState = false
        rightAddButtonState = false
        leftAddButton.isHidden = leftAddButtonState
        rightAddButton.isHidden = rightAddButtonState

        self.titleIconButton.image = NSImage(named: NSImage.Name("Role"))
        self.titleTextButton.title = "Role"
        self.leftAddButton.image = NSImage(named: NSImage.Name("AddRole"))
        self.rightAddButton.image = NSImage(named: NSImage.Name("AddRoleInfo"))
        self.titleIconButton.toolTip = "Show or Hide the Role Block"
        
        contextMenu()
    }
    
    // MARK: Action - Title Icon.
    override func leftButtonClicked(isSelect: Bool) {
        let node = Role(id: creationTime(), value: "New Role")
        data.append(node)
        works.roles = data as! [Role]
        writeAndReloadList()
    }
    
    override func rightButtonClicked(isSelect: Bool) {
        let index = contentOutlineView.selectedRow
        guard let role = contentOutlineView.item(atRow: index) as? Role else {
            return
        }
        let node = Role(id: creationTime(), value: "New Role Tag")
        // 非顶级。
        if role.parent != nil {
            role.parent?.add(child: node)
            if let item = role.parent as? Model {
                item.expanded = true
                writeAndReloadList(item )
            }
            return
        }
        role.add(child: node)
        role.expanded = true
        writeAndReloadList(role)
    }
    
    // MARK: Context Menu.
    /// 添加私有项。
    private func contextMenu(){
        // 菜单
        let addNode = NSMenuItem(title: "Add Role", action: #selector(addNodeMenuClick(_:)), keyEquivalent: "")
        let addText = NSMenuItem(title: "New Role Tag", action: #selector(addTextMenuClick(_:)), keyEquivalent: "")
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
        guard let role = contentOutlineView.item(atRow: contentOutlineView.clickedRow) as? Role else {
            return
        }
        
        for item in menu.items {
            item.isEnabled = true
        }

        if role.parent != nil {
            menu.item(at: 1)?.isEnabled = false
        }
    }
    
    // MARK: - NSOutlineView
    /// 显示内容。
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView?{
        // 数据未传入。
        guard let role = item as? Role else {
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
            cell.textField!.stringValue = role.value
            cell.textField!.isEditable = true
            cell.textField!.delegate = self
//            cell.imageView!.image = NSImage(named: NSImage.Name(role.gender))!
            return cell
        }
        return nil
    }
    
    /// 行被点。
    override func rowDoubleClicked(_ sender: Any) {
        guard let outlineView = sender as? NSOutlineView else {
                    return
                }
                
        guard let role = outlineView.item(atRow: outlineView.selectedRow) as? Role else {
            return
        }
        
        // TODO
    }
    
    /// 支节点被展开。
    func outlineViewItemDidExpand(_ notification: Notification){
        guard let role = notification.userInfo?["NSObject"] as? Role else {
            return
        }
        role.expanded = true
        try? works.writeRoleFile()
    }
    
    /// 支节点被关闭。
    func outlineViewItemWillCollapse(_ notification: Notification){
        guard let role = notification.userInfo?["NSObject"] as? Role else {
            return
        }
        role.expanded = false
        try? works.writeRoleFile()
    }

    /// 改。
    func controlTextDidEndEditing(_ obj: Notification) {
        guard let role = contentOutlineView.item(atRow: contentOutlineView.selectedRow) as? Role  else {
            return
        }
        guard let textField = obj.object as? NSTextField else {
            return
        }
        role.naming = false
        if textField.stringValue.isEmpty {
            textField.stringValue = role.value
            return
        }
        role.value = textField.stringValue
        
        writeAndReloadList()
    }
    
    /// 写入缓存并更新视图。
    override func writeAndReloadList(_ item: Node? = nil){
        // 保存数据。
        do {
            try works.writeRoleFile()
            contentOutlineView.reloadData()
            contentOutlineView.expandItem(item)
        } catch {
            print(error)
        }
    }
}
