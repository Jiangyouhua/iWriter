//
//  JYHRoleView.swift
//  iWriter
//
//  Created by 姜友华 on 2020/5/6.
//  Copyright © 2020 Jiangyouhua. All rights reserved.
//

import Cocoa

class JYHRoleView: JYHBlockView {
    
    override func format(){
        
    }
    
    override func interface() {
        rightAddButtonState = false
        rightAddButton.isHidden = false
        self.titleIconButton.image = NSImage(named: NSImage.Name("Role"))
        self.titleTextButton.title = "Role"
        self.rightAddButton.image = NSImage(named: NSImage.Name("AddRole"))
        self.titleIconButton.toolTip = "Show or Hide the Role Block"
        self.titleTextButton.toolTip = "Show or Hide the Role Block"
    }
}
