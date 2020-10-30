//
//  JYHSymbolView.swift
//  iWriter
//
//  Created by 姜友华 on 2020/5/6.
//  Copyright © 2020 Jiangyouhua. All rights reserved.
//

import Cocoa

class JYHSymbolView: JYHBlockView {
    
    override func format(){
        
    }
    
    override func interface() {
        rightAddButtonState = false
        rightAddButton.isHidden = false
        self.titleIconButton.image = NSImage(named: NSImage.Name("Symbol"))
        self.titleTextButton.title = "Symbol"
        self.rightAddButton.image = NSImage(named: NSImage.Name("AddSymbol"))
        self.titleIconButton.toolTip = "Show or Hide the Symbol Block"
        self.titleTextButton.toolTip = "Show or Hide the Symbol Block"
    }
}
