//
//  JYHSearchView.swift
//  iWriter
//
//  Created by 姜友华 on 2020/5/6.
//  Copyright © 2020 Jiangyouhua. All rights reserved.
//

import Cocoa

class JYHSearchView: JYHBlockView {
    
    override func format(){
        
    }
    
    override func interface() {
        self.titleIconButton.image = NSImage(named: NSImage.Name("Search"))
        self.titleTextButton.title = "Search"
        self.rightAddButton.isHidden = true
        self.titleIconButton.toolTip = "Show or Hide the Search Block"
        self.titleTextButton.toolTip = "Show or Hide the Search Block"
    }
}
