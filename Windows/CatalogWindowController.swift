//
//  CatalogWindowController.swift
//  iWriter
//
//  Created by Jiangyouhua on 2019/7/20.
//  Copyright © 2019 Jiangyouhua. All rights reserved.
//

import Cocoa

/**
 ## 新建章节跳出的对话框，让用户选择新建章还是节。
 */
class CatalogWindowController: NSWindowController, NSWindowDelegate {

    @IBOutlet weak var cancenButton: NSButton!
    @IBOutlet weak var sectionButton: NSButton!
    @IBOutlet weak var chapterButton: NSButton!
    @IBOutlet weak var titleTextField: NSTextField!
    
    var index = -1;
    let works = AppDelegate.works
    
    override var windowNibName: NSNib.Name?{
        return "CatalogWindowController"
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
    }
    
    /// 失去焦点，则关闭
    func windowDidResignKey(_ notification: Notification){
        self.close()
    }
    
    /// 关闭窗口
    @IBAction func canterButtonClick(_ sender: Any) {
        self.close()
    }
    
    /// 添加节
    @IBAction func sectionButtonClick(_ sender: Any) {
        guard titleTextField.stringValue.count > 0 else {
            return
        }

        let catalog = Catalog()
        catalog.title = titleTextField!.stringValue
        catalog.level = 2
        catalog.creation = works.creationTime()
        works.addCatalog(item: catalog, inParent: works.catalogData[0].sub.last!)
        works.addOtherItem(catalog: catalog)
        self.close()
    }
    
    /// 添加章
    @IBAction func chapterButtonClick(_ sender: Any) {
        guard titleTextField.stringValue.count > 0 else {
            return
        }
        
        let catalog = Catalog()
        catalog.title = titleTextField!.stringValue
        catalog.level = 1
        catalog.creation = works.creationTime()
        
        works.addCatalog(item: catalog, inParent: works.catalogData[0])
        works.addOtherItem(catalog: catalog)
        self.close()
    }
}
