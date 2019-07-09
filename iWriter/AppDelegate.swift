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

    static let works = Works()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}

// MARK: - Menu Action
extension AppDelegate{
    
    /// 事件：新建文件
    /// - parameter sender 事件发送者
    @IBAction func newFile(_ sender: Any) {
        guard let path = saveFilePanel(title: "New File") else {
            return
        }
        do {
            try AppDelegate.works.newFile(path: path)
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
    
    /// 事件：打开文件
    /// - parameter sender 事件发送者
    @IBAction func openFile(_ sender: Any) {
        guard let path = openFilePanel(title: "Open File") else{
            return
        }
        do {
            try AppDelegate.works.openFile(path: path)
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
    
    /// 事件：保存文件
    /// - parameter sender 事件发送者
    @IBAction func saveFile(_ sender: Any) {
        do {
            try AppDelegate.works.saveFile()
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
    
    // 事件：另存文件
    /// - parameter sender 事件发送者
    @IBAction func saveAsFile(_ sender: Any) {
        guard let path = saveFilePanel(title: "Save as File") else {
            return
        }
        do {
            try AppDelegate.works.saveAsFile(path: path)
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
}

// MARK: - File Browser
extension AppDelegate{
    
    /// 文件流览器，打开文件
    /// - parameter title 显示的标题
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
    
    /// 文件流览器，保存文件
    /// - parameter title 显示的标题
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

