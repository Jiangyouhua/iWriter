//
//  JYHNoteView.swift
//  iWriter
//
//  Created by 姜友华 on 2020/5/6.
//  Copyright © 2020 Jiangyouhua. All rights reserved.
//

import Cocoa

class JYHNoteView: JYHBlockView {
    
    override func format(){
        
    }
    
    override func interface() {
        rightAddButtonState = false
        rightAddButton.isHidden = false
        self.titleIconButton.image = NSImage(named: NSImage.Name("Note"))
        self.titleTextButton.title = "Note"
        self.rightAddButton.image = NSImage(named: NSImage.Name("AddNote"))
        self.titleIconButton.toolTip = "Show or Hide the Note Block"
        self.titleTextButton.toolTip = "Show or Hide the Note Block"
    }
}
