//
//  JYHSymbolView.swift
//  iWriter
//
//  Created by 姜友华 on 2020/5/6.
//  Copyright © 2020 Jiangyouhua. All rights reserved.
//

import Cocoa

class JYHSymbolView: JYHBlockView , NSTextFieldDelegate {
    
    override func format(){
        // 状态。
        data = works.symbols
        contentOutlineView.reloadData()
        expandedChildren(items: data)
    }
    
    override func interface() {
        // 初始界面。
        leftAddButtonState = false
        rightAddButtonState = false
        leftAddButton.isHidden = leftAddButtonState
        rightAddButton.isHidden = rightAddButtonState

        self.titleIconButton.image = NSImage(named: NSImage.Name("Symbol"))
        self.titleTextButton.title = "Symbol"
        self.leftAddButton.image = NSImage(named: NSImage.Name("AddSymbol"))
        self.rightAddButton.image = NSImage(named: NSImage.Name("AddSymbolInfo"))
        self.titleIconButton.toolTip = "Show or Hide the Symbol Block"
        
        contextMenu()
    }
    
    // MARK: Action - Title Icon.
    override func leftButtonClicked(isSelect: Bool) {
        let node = Symbol()
        node.content = "New Symbol"
        data.append(node)
        works.symbols = data as! [Symbol]
        writeAndReloadList()
    }
    
    override func rightButtonClicked(isSelect: Bool) {
        let index = contentOutlineView.selectedRow
        guard let symbol = contentOutlineView.item(atRow: index) as? Symbol else {
            return
        }
        let node = Symbol()
        node.content = "New Symbol Tag"
        // 非顶级。
        if symbol.parent != nil {
            node.parent = symbol.parent
            symbol.parent?.children.insert(node, at: index)
            symbol.parent?.expanded = true
            writeAndReloadList(symbol.parent)
            return
        }
        node.parent = symbol
        symbol.children.append(node)
        symbol.expanded = true
        writeAndReloadList(symbol)
    }
    
    // MARK: Context Menu.
    /// 添加私有项。
    private func contextMenu(){
        // 菜单
        let addNode = NSMenuItem(title: "Add Symbol", action: #selector(addNodeMenuClick(_:)), keyEquivalent: "")
        let addText = NSMenuItem(title: "New Symbol Tag", action: #selector(addTextMenuClick(_:)), keyEquivalent: "")
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
        guard let symbol = contentOutlineView.item(atRow: contentOutlineView.clickedRow) as? Symbol else {
            return
        }
        
        for item in menu.items {
            item.isEnabled = true
        }

        if symbol.parent != nil {
            menu.item(at: 1)?.isEnabled = false
        }
    }
    
    // MARK: - NSOutlineView
    /// 显示内容。
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView?{
        // 数据未传入。
        guard let symbol = item as? Symbol else {
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
            cell.textField!.stringValue = symbol.content
            cell.textField!.isEditable = true
            cell.textField!.delegate = self
            cell.textField!.font = NSFont.systemFont(ofSize: 11)
//            cell.imageView!.image = NSImage(named: NSImage.Name(symbol.gender))!
            return cell
        }
        return nil
    }
    
    /// 行被点。
    override func rowDoubleClicked(_ sender: Any) {
        guard let outlineView = sender as? NSOutlineView else {
                    return
                }
                
        guard let symbol = outlineView.item(atRow: outlineView.selectedRow) as? Symbol else {
            return
        }
        
        // TODO
    }
    
    /// 支节点被展开。
    func outlineViewItemDidExpand(_ notification: Notification){
        guard let symbol = notification.userInfo?["NSObject"] as? Symbol else {
            return
        }
        symbol.expanded = true
        try? works.writeSymbolFile()
    }
    
    /// 支节点被关闭。
    func outlineViewItemWillCollapse(_ notification: Notification){
        guard let symbol = notification.userInfo?["NSObject"] as? Symbol else {
            return
        }
        symbol.expanded = false
        try? works.writeSymbolFile()
    }

    /// 改。
    func controlTextDidEndEditing(_ obj: Notification) {
        guard let symbol = contentOutlineView.item(atRow: contentOutlineView.selectedRow) as? Symbol  else {
            return
        }
        guard let textField = obj.object as? NSTextField else {
            return
        }
        symbol.naming = false
        if textField.stringValue.isEmpty {
            textField.stringValue = symbol.content
            return
        }
        symbol.content = textField.stringValue
        
        writeAndReloadList()
    }
    
    /// 写入缓存并更新视图。
    override func writeAndReloadList(_ item: Model? = nil){
        // 保存数据。
        do {
            try works.writeSymbolFile()
            contentOutlineView.reloadData()
            contentOutlineView.expandItem(item)
        } catch {
            print(error)
        }
    }
}
