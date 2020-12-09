//
//  JYHSearchView.swift
//  iWriter
//
//  Created by 姜友华 on 2020/5/6.
//  Copyright © 2020 Jiangyouhua. All rights reserved.
//

import Cocoa

protocol JYHSearchViewDelegate {
    func blockTitleClicked(_ target: JYHSearchView)
    func searchWord(_ word: String)
    func replaceWord(from: String, to: String, item: Any)
    func currentSearch(chapter: Chapter, mark: Mark)
}

class JYHSearchView: NSView, NSOutlineViewDelegate, NSOutlineViewDataSource, NSMenuDelegate{

    @IBOutlet var view: NSView!
    @IBOutlet weak var titleIconButton: NSButton!
    @IBOutlet weak var horizontalLineView: JYHView!
    @IBOutlet weak var contentScrollView: NSScrollView!
    @IBOutlet weak var replaceView: NSView!
    @IBOutlet weak var searchTextField: NSTextField!
    @IBOutlet weak var replaceTextField: NSTextField!
    @IBOutlet weak var previousButton: NSButton!
    @IBOutlet weak var nextButton: NSButton!
    @IBOutlet weak var toggleButton: NSButton!
    @IBOutlet weak var replaceButton: NSButton!
    @IBOutlet weak var replaceViewConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var contentOutlineView: NSOutlineView!
    @IBOutlet weak var titleColumn: NSTableColumn!
    
    /// Context Menu
    
    /// 跟区域大小相关的分割线，点击标题栏时需要改变其位置。
    var data: [Search] = []{
        didSet{
            contentOutlineView.reloadData()
            contentOutlineView.expandItem(nil, expandChildren: true)
            previousButton.isEnabled = data.count > 0
            nextButton.isEnabled = data.count > 0
        }
    }
    var heights = [Int: CGFloat]()
    var delegate: JYHSearchViewDelegate?
    
    // MARK: Action - Title Clicked
    /// Title Icon clicked
    @IBAction func titleIconButtonClick(_ sender: Any) {
        self.delegate?.blockTitleClicked(self)
    }
    
    @IBAction func searchTextFieldSend(_ sender: Any) {
        guard let word = (sender as? NSTextField)?.stringValue else {
            return
        }
        self.delegate?.searchWord(word)
    }
       
    @IBAction func replaceTextFieldSend(_ sender: Any) {
        return
    }
    
    @IBAction func previousButtonClicked(_ sender: Any) {
        let row = previousRow(index: contentOutlineView.selectedRow)
        contentOutlineView.selectRowIndexes(IndexSet(integer: row), byExtendingSelection: false)
        contentOutlineView.scrollRowToVisible(row)
    }
    
    @IBAction func nextButtonClicked(_ sender: Any) {
        let row = nextRow(index: contentOutlineView.selectedRow)
        contentOutlineView.selectRowIndexes(IndexSet(integer: row), byExtendingSelection: false)
        contentOutlineView.scrollRowToVisible(row)
    }
    
    @IBAction func toggleButtonClicked(_ sender: Any) {
        let b:Bool = replaceViewConstraint.constant > 0
        replaceViewConstraint.constant = b ? 0 : 26
        toggleButton.image = NSImage(named: b ? "NSTouchBarGoUpTemplate" : "NSTouchBarGoDownTemplate")
    }
    
    @IBAction func replaceButtonClicked(_ sender: Any) {
        guard let item = contentOutlineView.item(atRow: contentOutlineView.selectedRow) else {
            return
        }
        self.delegate?.replaceWord(from: searchTextField.stringValue, to: replaceTextField.stringValue, item: item)
        self.delegate?.searchWord(searchTextField.stringValue)
    }
    
    func previousRow(index: Int) -> Int{
        var row = index - 1
        if row < 1 {
            row = contentOutlineView.numberOfRows - 1
        }
        if (contentOutlineView.item(atRow: row) as? Search) != nil {
            return previousRow(index: row)
        }
        return row
    }
    
    func nextRow(index: Int) -> Int{
        var row = index + 1
        if row > contentOutlineView.numberOfRows - 1 {
            row = 0
        }
        if (contentOutlineView.item(atRow: row) as? Search) != nil {
            return nextRow(index: row)
        }
        return row
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
        Bundle.main.loadNibNamed("JYHSearchView", owner: self, topLevelObjects: nil)
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
            replaceView.isHidden = true
            searchTextField.isHidden = true
            previousButton.isHidden = true
            nextButton.isHidden = true
            toggleButton.isHidden = true
            contentScrollView.isHidden = true
            horizontalLineView.isHidden = true
            return
        }
        
        // title上元素的显示。
        replaceView.isHidden = false
        searchTextField.isHidden = false
        previousButton.isHidden = false
        nextButton.isHidden = false
        toggleButton.isHidden = false
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
        guard let model = item as? Search else {
            return data.count
        }
        return model.marks.count
    }
    
    /// 各级的Row数据。
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any{
        guard let model = item as? Search else {
            return data[index]
        }
        return model.marks[index]
    }
    
    /// 各级的Row是否为子集显示展开与收拢功能。
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool{
        guard let model = item as? Search else {
            return false
        }
        return model.marks.count > 0
    }
    
    /// 显示内容。
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView?{
        guard let columnIdentifier = tableColumn?.identifier else {
            return nil
        }
        
        var title = NSMutableAttributedString(string: "")
        var image = NSImage(named: "Article")
        switch item {
        case is Search:
            let search = (item as! Search)
            let s = titleWith(chapter: search.chapter) + ("(\(search.marks.count))")
            title = NSMutableAttributedString(string: s)
        case is Mark:
            let mark = item as! Mark
            title = attributeWith(mark: mark)
            image = NSImage(named: "Word")
        default:
            return nil
        }

        // 标题。
        if columnIdentifier == NSUserInterfaceItemIdentifier(rawValue: "title") {
            let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "titleCellView")
            guard let cell = outlineView.makeView(withIdentifier: cellIdentifier, owner: nil) as? NSTableCellView else {
                return nil
            }
            
            // 为Table Cell View设置Title与Icon。
            cell.textField!.allowsEditingTextAttributes = true
            cell.textField!.attributedStringValue = title
            cell.imageView!.image = image
            return cell
        }
        return nil
    }
    
    func outlineViewSelectionDidChange(_ notification: Notification){
        tableViewDidSelectRow(contentOutlineView.selectedRow, contentOutlineView.selectedColumn, false)
    }
    
    private func titleWith(chapter: Model) -> String {
        let title = chapter.content
        if chapter.parent == nil {
            return title
        }
        return title + " → " +  titleWith(chapter: chapter.parent!)
    }
    
    private func attributeWith(mark: Mark) -> NSMutableAttributedString {
        let s = NSMutableAttributedString(string: mark.paragraph)
        s.addAttributes([NSAttributedString.Key.backgroundColor: NSColor.linkColor], range: NSRange(mark.paragraphRange, in: mark.paragraph))
        return s
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
        let item = contentOutlineView.item(atRow: row)
        guard let mark = item as? Mark else {
            return
        }
        guard let search = contentOutlineView.parent(forItem: item) as? Search else {
            return
        }
        self.delegate?.currentSearch(chapter: search.chapter, mark: mark)
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
