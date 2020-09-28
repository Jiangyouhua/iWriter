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
class MainWindowController: NSWindowController, NSWindowDelegate {

    @IBOutlet weak var lastFilesSelect: NSPopUpButton!
    
    override func windowDidLoad() {
        super.windowDidLoad()
        self.window?.delegate = self
    }
    
    func windowDidResize(_ notification: Notification) {
        windowSize = self.window!.contentViewController!.view.frame.size
        guard let root = self.window?.contentViewController as? ViewController else {
            return
        }
        root.windowDidResize()
    }
}
