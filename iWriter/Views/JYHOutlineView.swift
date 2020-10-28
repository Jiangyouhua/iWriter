//
//  JYHOutlineView.swift
//  iWriter
//
//  Created by 姜友华 on 2020/4/29.
//  Copyright © 2020 Jiangyouhua. All rights reserved.
//

import Cocoa

protocol JYHOutlineViewDelegate {
    func outlineTitleClicked(_ target: JYHOutlineView)
}


class JYHOutlineView: NSView {

    @IBOutlet var view: NSView!
    @IBOutlet weak var titleIconButton: NSButton!
    @IBOutlet weak var titleTextButton: NSButton!
    @IBOutlet weak var leftAddButton: NSButton!
    @IBOutlet weak var centerAddButton: NSButton!
    @IBOutlet weak var rightAddButton: NSButton!
    @IBOutlet weak var horizontalLineView: JYHView!
    @IBOutlet weak var contentMainView: NSView!
    
    var delegate: JYHOutlineViewDelegate?

    @IBAction func titleIconButtonClick(_ sender: Any) {
        self.delegate?.outlineTitleClicked(self)
    }
    
    @IBAction func titleTextButtonClick(_ sender: Any) {
        self.delegate?.outlineTitleClicked(self)
    }
    
    @IBAction func leftAddButtonClick(_ sender: Any) {
        
    }
    
    @IBAction func centerAddButtonClick(_ sender: Any) {
        
    }
    
    @IBAction func rightAddButtonClick(_ sender: Any) {
        
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        loadXib()
    }

    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        loadXib()
    }
    
    // 加载对应的视图。
    private func loadXib() {
        // 从图获取NSView。
        Bundle.main.loadNibNamed("JYHOutlineView", owner: self, topLevelObjects: nil)
        self.addSubview(self.view)
        self.heightAnchor.constraint(greaterThanOrEqualToConstant: iconWidth).isActive = true
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        // 及时更新视图的大小。
        self.view.frame = self.bounds
    }
}
