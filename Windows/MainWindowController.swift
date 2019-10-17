//
//  MainWindowController.swift
//  iWriter
//
//  Created by Jiangyouhua on 2019/7/21.
//  Copyright © 2019 Jiangyouhua. All rights reserved.
//

import Cocoa

/**
 ## 接收标题栏的Action。
 */
class MainWindowController: NSWindowController {

    @IBOutlet weak var lastFilesSelect: NSPopUpButton!
    override func windowDidLoad() {
        super.windowDidLoad()
        AppDelegate.works.reeentSelect = lastFilesSelect
        AppDelegate.works.formatRecentSelect()
    }
}

/// MARK: - Window Title。
extension MainWindowController {
    /// 最近打开文件，选择下拉项。
    @IBAction func lastFilesSelected(_ sender: Any) {
        let i  = (sender as! NSPopUpButton).objectValue as! Int
        guard let file = lastFilesSelect.item(at: i)?.toolTip else {
            return
        }
        AppDelegate.works.openLastFile(file: file, index: i)
    }
}
