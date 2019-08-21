//
//  TabsBarView.swift
//  iWriter
//
//  Created by Jiangyouhua on 2019/7/20.
//  Copyright © 2019 Jiangyouhua. All rights reserved.
//

import Cocoa

protocol TabsBarDelegate {
    func tabDidClicked(catalog: Catalog)
    func tabDidClosed(catalogs: [Catalog], current: Catalog)
}

/**
 ## 标题栏类。
 1. 多个章节在这里切换显示；
 2. 最少显示一个；
 3. 最多显示的宽度不超过自身宽度。
 */
class TabsBarView: NSView {
    
    var delegate: TabsBarDelegate?
    
    var catalogs: [Catalog] = [Catalog]()   // 显示的章节标题
    var active: Catalog = Catalog()         // 激活的章节
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
        // 添加感应区。
        let trackingArea = NSTrackingArea.init(rect: dirtyRect, options: [NSTrackingArea.Options.mouseEnteredAndExited, NSTrackingArea.Options.activeAlways], owner: self, userInfo: nil)
        self.addTrackingArea(trackingArea)
        self.becomeFirstResponder()
    }
    
    /**
     ## 布局设计，排成一排。
     1. 最少一个；
     2. 最多不能超过TabsBar的宽度；
     3. 需要保留当前的。
    */
    override func layout() {
        self.subviews.forEach { $0.removeFromSuperview() }
        if catalogs.isEmpty {
            return
        }
        var x: CGFloat = 0
        let activeView = TitleTabView(catalog: active, active: true)
        var activeContain = false     // 判断active包含到TabsBarView里了没有
        // 添加Tab
        for (i, catalog) in catalogs.enumerated() {
            // 实例一个TitelTab。
            var view: TitleTabView
            if active.creation == catalog.creation {
                view = activeView
                activeContain = true
            } else {
                view = TitleTabView(catalog: catalog, active: false)
            }
            
            view.index = i
            // 为了排序改变横向位置。
            var frame = view.frame
            frame.origin.x = x - 1
            view.frame = frame
            
            // 已添加当前章节标签，判断超出则结束
            if activeContain && x + view.frame.width > self.frame.width {
                break
            }
            
            // 未添加当前章节标签，判断添加当前章节标签后超出则结束
            if !activeContain && x + view.frame.width + activeView.frame.width > self.frame.width {
                frame.size.width = activeView.frame.width
                activeView.frame = frame
                self.addSubview(view)
                break
            }
            self.addSubview(view)
            x += frame.width

        }
        
        // 添加Stand in
        let sub = self.subviews
        for view in sub {
            if let v =  view as? TitleTabView {
                let standIn = StandInTabView.init(catalog: v.catalog, active: v.catalog.creation == active.creation)
                standIn.index = v.index
                standIn.frame = v.frame
                standIn.delegate = self
                self.addSubview(standIn, positioned: NSWindow.OrderingMode.above, relativeTo: nil)
            }
        }
    }
    
    /// 添加数据。
    func dataSource( catalogs: [Catalog], active: Catalog) {
        self.catalogs = catalogs
        self.active = active
        self.needsLayout = true
    }
    
    /// 改变活跃标签。
    func updateActive( active: Catalog){
        self.active = active
        for view in self.subviews {
            if let v = view as? TitleTabView {
                v.isActive(b: v.catalog.creation == active.creation)
            }
        }
    }
    
    /// 添加标签。
    func addCatalog(_ catalog: Catalog){
        if self.catalogs.contains(where: {$0.creation == catalog.creation}) {
            return updateActive(active: catalog)
        }
        self.active = catalog
        catalogs.insert(catalog, at: 0)
        self.needsLayout = true
    }
    
    /// 删除标签。
    func delCatalog(index: Int) -> ([Catalog], Catalog) {
        if catalogIsEmpty() {
            return ([Catalog](), Catalog())
        }
        let catalog = catalogs.remove(at: index)
        if catalogIsEmpty() {
            return ([Catalog](), Catalog())
        }
        if catalog.creation != active.creation {
            self.needsLayout = true
            return (self.catalogs, Catalog())
        }
        active = catalogs[0]
        self.needsLayout = true
        return (self.catalogs, self.catalogs[0])
    }
    
    func catalogIsEmpty() -> Bool{
        if catalogs.count == 0 {
            self.subviews.forEach { $0.removeFromSuperview() }
            return true
        }
        return false
    }
}

/// 实现标签的委托方法。
extension TabsBarView: StandInTabDelegate {
    // 激活
    func tabClick(view: TitleTabView, catalog: Catalog, index: Int) {
        // 改变激活标签
        updateActive(active: catalog)
        for view in self.subviews {
            if let v = view as? StandInTabView {
                v.isHidden = v.catalog.creation != active.creation
            }
        }
        delegate?.tabDidClicked(catalog: catalog)
    }
    
    // 关闭
    func tabClose(catalog: Catalog, index: Int) {
        let (catalogs, catalog) = delCatalog(index: index)
        delegate?.tabDidClosed(catalogs: catalogs, current: catalog)
    }
    
    // 排序
    func standInDragEnded(standIn: StandInTabView) {
        let point = standIn.frame.origin
        var isInset = false    // 是否被插入
        var array = [Catalog]()
        for view in self.subviews {
            if let v = view as? TitleTabView {
                // 除替身外和自身外的所有标签
                if  v is StandInTabView || v.catalog.creation == standIn.catalog.creation {
                    continue
                }
                // 排序位置前的
                if v.frame.origin.x < point.x {
                    array.append(v.catalog)
                } else {
                    // 插入到当前位置
                    if !isInset {
                        array.append(standIn.catalog)
                        isInset = true
                    }
                    // 排序位置后的
                    array.append(v.catalog)
                }
            }
        }
        if !isInset {
            array.append(standIn.catalog)
        }
        self.catalogs = array
        self.needsLayout = true
    }
}
