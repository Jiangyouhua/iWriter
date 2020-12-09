//
//  JYHBlockView.swift
//  iWriter
//
//  Created by 姜友华 on 2020/4/29.
//  Copyright © 2020 Jiangyouhua. All rights reserved.
//

import Cocoa

protocol JYHDictionaryViewDelegate {
    func blockTitleClicked(_ target: JYHDictionaryView)
    func dictionaryWord(_ word: String)
}

class JYHDictionaryView: NSView, NSOutlineViewDelegate, NSOutlineViewDataSource, NSMenuDelegate{
    

    @IBOutlet var view: NSView!
    @IBOutlet weak var titleIconButton: NSButton!
    @IBOutlet weak var horizontalLineView: JYHView!
    @IBOutlet weak var dictionaryTextField: NSTextField!
    @IBOutlet weak var contentScrollView: NSScrollView!
    @IBOutlet weak var previousButton: NSButton!
    @IBOutlet weak var nextButton: NSButton!
    
    
    @IBOutlet weak var contentOutlineView: NSOutlineView!
    @IBOutlet weak var titleColumn: NSTableColumn!
    
    @IBOutlet var rightClickMenu: NSMenu!
    /// Context Menu
    
    /// 跟区域大小相关的分割线，点击标题栏时需要改变其位置。
    var data: [Paraphrase] = []{
        didSet{
            contentOutlineView.reloadData()
            contentOutlineView.expandItem(nil, expandChildren: true)
            previousButton.isEnabled = data.count > 0
            nextButton.isEnabled = data.count > 0
        }
    }
    var heights = [Int: CGFloat]()
    var delegate: JYHDictionaryViewDelegate?
    
    // MARK: Action - Title Clicked
    /// Title Icon clicked
    @IBAction func titleIconButtonClick(_ sender: Any) {
        self.delegate?.blockTitleClicked(self)
    }
    @IBAction func dictionaryTextFieldSend(_ sender: Any) {
        guard let word = (sender as? NSTextField)?.stringValue else {
            return
        }
        self.delegate?.dictionaryWord(word)
    }
    
    @IBAction func previousButtonClicked(_ sender: Any) {
    }
    
    @IBAction func nextButtonClicked(_ sender: Any) {
    }
    // MARK: View
    /// Init Subclass.
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
        Bundle.main.loadNibNamed("JYHDictionaryView", owner: self, topLevelObjects: nil)
        self.addSubview(self.view)
        
        // 表格处理。
        contentOutlineView.delegate = self
        contentOutlineView.dataSource = self
        contentOutlineView.target = self
        contentOutlineView.action = #selector(outlineViewDidClick(_:))
        contentOutlineView.doubleAction = #selector(rowDoubleClicked(_:))
        contentOutlineView.registerForDraggedTypes([NSPasteboard.PasteboardType.string])
        
        interface()
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        // 及时更新视图的大小。
        self.view.frame = self.bounds
        titleColumn.width = self.bounds.width - 10
        
        // LeftArea进入隐藏状态。
        if self.frame.size.width <= iconWidth {
            dictionaryTextField.isHidden = true
            previousButton.isHidden = true
            nextButton.isHidden = true
            contentScrollView.isHidden = true
            horizontalLineView.isHidden = true
            return
        }
        
        // title上元素的显示。
        dictionaryTextField.isHidden = false
        previousButton.isHidden = false
        nextButton.isHidden = false
        contentScrollView.isHidden = false
        horizontalLineView.isHidden = false
    }
    
    /// 界面处理。
    func interface(){
        print(#function)
    }
    
    /// 显示处理。
    func format(){
        print(#function)
    }
    
    // MARK: NSOutlineView
    /// 各级的Row数量。
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        guard let model = item as? Paraphrase else {
            return data.count
        }
        return model.children.count
    }
    
    /// 各级的Row数据。
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any{
        guard let model = item as? Paraphrase else {
            return data[index]
        }
        return model.children[index]
    }
    
    /// 各级的Row是否为子集显示展开与收拢功能。
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool{
        guard let model = item as? Paraphrase else {
            return false
        }
        return model.children.count > 0
    }
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView?{
        guard let columnIdentifier = tableColumn?.identifier else {
            return nil
        }
        guard let model = item as? Paraphrase else {
            return nil
        }

        // 标题。
        if columnIdentifier == NSUserInterfaceItemIdentifier(rawValue: "title") {
            let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "titleCellView")
            guard let cell = outlineView.makeView(withIdentifier: cellIdentifier, owner: nil) as? NSTableCellView else {
                return nil
            }

            cell.textField!.stringValue = model.title
            cell.imageView!.image = NSImage(named: "Article")
            return cell
        }
        return nil
    }
    
    // MARK: Action - Row Clicked
    @objc func outlineViewDidClick(_ event: NSEvent){
        let row = contentOutlineView.clickedRow
        if row < 0 {
            return 
        }
        let column = contentOutlineView.clickedColumn
        let onTitleImage = onImageViewWithCell(row: row, column: column)
        let unselected = -1

        if row == unselected && column == unselected{
            tableViewDidDeselectRow()
            return
        }else if row != unselected && column != unselected{
            tableViewDidSelectRow(row, column, onTitleImage)
            return
        }else if column != unselected && row == unselected{
            tableviewDidSelectHeader(column)
        }
    }
    
    // 判断是否在图片上点击。、
    private func onImageViewWithCell(row: Int, column: Int) -> Bool{
        guard let titleCell: NSTableCellView = contentOutlineView.view(atColumn: column, row: row, makeIfNecessary: true) as? NSTableCellView else {
            return false
        }
        guard let view = titleCell.imageView else {
            return false
        }
        guard let point = view.window?.mouseLocationOutsideOfEventStream else {
            return false
        }
        let p = (self.window?.contentView?.convert(point, to: view.superview))!
        return view.isMousePoint(p, in: view.frame)
    }
    
    /// 取消行选择。
    func tableViewDidDeselectRow() {
        print(#function)
    }

    /// 选择行。
    func tableViewDidSelectRow(_ row : Int, _ column: Int, _ onTitleImage: Bool){
        print(#function)
    }

    /// 选择了表头。
    func tableviewDidSelectHeader(_ column : Int){
        print(#function)
    }
    
    /// 更新当前行数据。
    func reloadDataWithRow(_ row: Int) {
        contentOutlineView.removeItems(at: IndexSet(integer: row), inParent: nil, withAnimation: .effectFade)
        contentOutlineView.insertItems(at: IndexSet(integer: row), inParent: nil, withAnimation: .effectFade)
    }

    /// 双击当前行。
    @objc func rowDoubleClicked(_ sender: Any){
        print(#function)
    }
}
