//
//  AppDelegate.swift
//  iWriter
//
//  Created by Jiangyouhua on 2019/7/9.
//  Copyright © 2019 Jiangyouhua. All rights reserved.
//

import Cocoa

@NSApplicationMain

class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var recentFilesMenu: NSMenu!
    
    var works: Works = Works()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        // 打开当前缓存文件。
        if FileManager.default.fileExists(atPath: CACHE_PATH) {
            do {
                // 从缓存读取。
                try works.openFilesFromCache()
                NSApp.mainWindow?.title = works.info.file
                formatRecentOpenMenu()
            } catch let error as WorksError {
                // 显示提示窗。
                let alert = NSAlert()
                alert.addButton(withTitle: "OK")
                alert.messageText = "Open File From Cache Error"
                switch error {
                case .operateError(let code, let function,  let info) :
                    print(code, function)
                    alert.informativeText = info
                }
                alert.runModal()
            } catch {
                print(error)
            }
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    /// 事件：新建文件。
    /// - parameter sender 事件发送者。
    @IBAction func newFile(_ sender: Any) {
        guard let path = saveFilePanel(title: "New File") else {
            return
        }
        do {
            // 新建。
            try works.newFile(path: path)
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
    }
    
    /// 事件：打开文件。
    /// - parameter sender 事件发送者。
    @IBAction func openFile(_ sender: Any) {
        guard let path = openFilePanel(title: "Open File") else{
            return
        }
        do {
            // 打开。
            try works.openFile(path: path)
        } catch let error as WorksError{
            let alert = NSAlert()
            alert.addButton(withTitle: "OK")
            alert.messageText = "Open File Error"
            switch error {
            case .operateError(let code, let function,  let info) :
                print(code, function)
                alert.informativeText = info
            }
            alert.runModal()
        } catch {
            print(error)
        }
    }
    
    /// 事件：保存文件。
    /// - parameter sender 事件发送者。
    @IBAction func saveFile(_ sender: Any) {
        do {
            // 保存。
            try works.saveFile()
        } catch let error as WorksError{
            let alert = NSAlert()
            alert.addButton(withTitle: "OK")
            alert.messageText = "Save File Error"
            switch error {
            case .operateError(let code, let function,  let info) :
                print(code, function)
                alert.informativeText = info
            }
            alert.runModal()
        } catch {
            print(error)
        }
    }
    
    /// 事件：另存文件。
    /// - parameter sender 事件发送者。
    @IBAction func saveAsFile(_ sender: Any) {
        guard let path = saveFilePanel(title: "Save as File") else {
            return
        }
        do {
            // 另存。
            try works.saveAsFile(path: path)
            // TODO
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
    }

    func formatRecentOpenMenu() {
        // 清除当前
        for i in 0..<(recentFilesMenu.numberOfItems - 2) {
            recentFilesMenu.removeItem(at: i)
        }
        // 获取数据
        guard let array = cache.getOpenedFiles() else {
            return
        }
        // 实例菜单项
        for (j, file) in array.enumerated() {
            // 判断文件是否存在，不存在则移除。
            if !FileManager.default.fileExists(atPath: file) {
                _ = cache.deleteOpenedFile(file: file)
                continue
            }
            let item = NSMenuItem.init(title: file.fileName(), action: #selector(works.openRecentFile(sender:)), keyEquivalent: "")
            item.toolTip = file
            recentFilesMenu.insertItem(item, at: j)
        }
    }
}

// MARK: - File Browser。
extension AppDelegate {
    /// 文件流览器，打开文件。
    /// - parameter title 显示的标题。
    func openFilePanel(title: String)->String?{
        let dialog = NSOpenPanel()
        dialog.title                   = title
        dialog.showsResizeIndicator    = true
        dialog.canChooseDirectories    = true
        dialog.canCreateDirectories    = true
        dialog.allowsMultipleSelection = false
        dialog.allowedFileTypes        = ["iw"]
        
        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            let result = dialog.url // Pathname of the file
            if (result != nil) {
                return result!.path
            }
        }
        return nil
    }
    
    /// 文件流览器，保存文件。
    /// - parameter title 显示的标题。
    func saveFilePanel(title: String)->String?{
        let dialog = NSSavePanel()
        dialog.title                   = title
        dialog.showsResizeIndicator    = true
        dialog.showsHiddenFiles        = false
        dialog.canCreateDirectories    = true
        dialog.allowedFileTypes        = ["iw"]
        
        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            let result = dialog.url // Pathname of the file
            if (result != nil) {
                return result!.path
            }
        }
        return nil
    }
}
