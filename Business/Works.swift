//
//  Works.swift
//  iWriter
//
//  Created by Jiangyouhua on 2019/7/9.
//  Copyright © 2019 Jiangyouhua. All rights reserved.
//

import Cocoa
import ZipArchive

/**
 ## 操作码
 */
enum OperateCode: String{
    case folderCreate        // 创建文件夹。
    case folderRemove        // 删除文件夹。
    case folderZip           // 压缩文件夹。
    case fileCreate          // 创建文件。
    case fileRead            // 读文件。
    case fileWrite           // 写文件。
    case fileUnzip           // 解压文件。
    case jsonData            // JSON转Data。
    case jsonObject          // JSON转Object。
}

/**
 ## Works类的操作错误。
 1. 操作码：指明作哪类操作；
 2. 位置：在个方法里返回的；
 3. 话术：显示给用户看的信息。
 */
enum WorksError: Error {
    case operateError(OperateCode, String, String)  // 操作码、位置、话术。
}


protocol WorksDelegate {
    func loadedFile(file: String)
    func catalogUpdatedItem()
    func catalogMovedItem()
}

/**
 ## Works类
 配置文件操作：New File、Open File、Save File、Save As File。
 各业务流程如下：
 1. New File
 1.1 清空或新建缓存文件夹iWriter；
 1.2 在iWriter里新建默认文件：info.txt、catalog.txt、role.txt、symbol.txt；
 1.3 在info.txt里存储默认数据；
 1.4 压缩iWriter文件夹到指定路径（含文件名）。
 2. Open File
 2.1 清空或新建缓存文件夹iWriter；
 2.2 解压指定文件（含路径）到iWriter；
 2.3 从iWriter打开作品。
 3. Save File
 3.1 保存所有更新的数据到iWriter；
 3.2 压缩iWriter文件夹到指定路径（含文件名）。
 4. Save As File
 4.1 指定新的保存路径；
 4.2 保存所有更新的数据到iWriter；
 4.3 压缩iWriter文件夹到新指定路径（含文件名）。
 */
class Works: NSObject {
    var delegate: WorksDelegate?
    var timeInterval = 0         // 最近生成的时间戳
    var isUserOperate = true     // 是否为用户操作
    
    // 文件管理。
    var fileManager: FileManager
    
    // 话术。
    let fileError: String = "No Operating Rights"       // 文件读写出错。
    let jsonError: String = "JSON Conversion Error"     // JSON出错。
    let Undefined: String = "Undefined"                 // 未定义。
    
    // 缓存区及初始文件。
    let cache = NSHomeDirectory() + "/iWriter"
    var infoFile: String
    let catalogFile: String
    let roleFile: String
    let symbolFile: String
    
    // 初始数据。
    var infoData: Info
    var catalogData: [Catalog]
    var roleData: [Role]
    var symbolData: [Symbol]
    var noteData: [Int: String]
    var searchData: [Search]
    var dictionaryData: [String]
    
    // 数据状态。
    var dataStatus: Status
    
    // 最近打开
    let lastTag = "LastFiles"
    let defaults = UserDefaults.standard
    var recentMenu: NSMenu?                // 菜单上的最近打开
    var reeentSelect: NSPopUpButton?       // 标题栏上的最近打开
    
    // 作品路径。
    private var path: String {
        set{
            infoData.file = newValue
        }
        get{
            return infoData.file
        }
    }
    
    // 当前章节索引，即在catalogData的创建时间。
    var currentContent: Catalog {
        set{
            infoData.currentContent = newValue
            if newValue.creation > 0{
                addChapterOnBar(catalog: newValue)
            }
        }
        get{
            return infoData.currentContent ?? Catalog()
        }
    }
    // 当前章节内容。
    var currentContentData: String
    
    /// 初始化
    override init(){
        fileManager = FileManager.default
        
        infoFile = cache + "/info.txt"
        catalogFile = cache + "/catalog.txt"
        roleFile = cache + "/role.txt"
        symbolFile = cache + "/symbol.txt"
        infoData = Info()
        catalogData = [Catalog]()
        roleData = [Role]()
        symbolData = [Symbol]()
        noteData = [:]
        searchData = [Search]()
        dictionaryData = []
        dataStatus = Status()
        currentContentData = ""
    }
    
    func initWordsData(){
        let filePath = path
        infoData = Info()
        path = filePath
        catalogData = [Catalog]()
        roleData = [Role]()
        symbolData = [Symbol]()
        noteData = [:]
        searchData = [Search]()
        dictionaryData = []
        dataStatus = Status()
        currentContentData = ""
        
    }
}

// MARK: - Match File Action。
extension Works {
    
    /// 新建文件。
    /// - parameter path: 指定的保存路径（含文件名称）。
    /// - throws: 读写错误、JSON解析错误。
    func newFile(path: String) throws {
        self.path = path
        isUserOperate = true
        do{
            try emptyOrCreatCacheFolder()       // 清空或创建缓存文件夹。
            try defaultFilesInCacheFolder()     // 在缓存文件夹创建默认的文件。
            try writeDefaultDataToCatalogFile() // 写入作品初始目录信息。文件信息需要章节信息，所以在后。
            try writeDefaultDataToInfoFile()    // 写入作品初始信息。
            try zipCacheFolderToUsers()         // 将缓存文件夹打包到用户指定的位置。
            try openWorksFromCacheFolder()      // 从缓存文件夹打开作品。
            // 调用完成方法
            delegate?.loadedFile(file: path)
            formatRecentMenu()
            formatRecentSelect()
        } catch {
            throw error
        }
    }
    
    /// 打开文件。
    /// - parameter path: 指定的打开文件（含文件路径）。
    /// - throws: 读写错误、JSON解析错误。
    func openFile(path: String) throws {
        self.path = path
        isUserOperate = false
        do{
            try emptyOrCreatCacheFolder()     // 清空或创建缓存文件夹。
            try unZipUsersToCacheFolder()     // 解压指定文件（含路径）到缓存文件夹。
            try openWorksFromCacheFolder()    // 从缓存文件夹打开作品。
            delegate?.loadedFile(file: path)
            formatRecentMenu()
            formatRecentSelect()
        } catch {
            throw error
        }
    }
    
    /// 保存文件。
    /// - throws: 读写错误、JSON解析错误。
    func saveFile() throws {
        guard !infoData.needSaveToFile else {
            return
        }
        do{
            try saveWorksToCacheFolder()      // 保存作品数据到缓存文件。
            try zipCacheFolderToUsers()       // 将缓存文件夹打包到用户指定的位置。
        } catch {
            throw error
        }
    }
    
    /// 另存文件。
    /// - parameter path: 用户指定的保存路径（含文件名称）。
    /// - throws: 读写错误、JSON解析错误。
    func saveAsFile(path: String) throws {
        self.path =  path                     // 指定新的保存位置。
        do{
            try saveFile()                    // 保存作品。
        } catch {
            throw error
        }
    }
    
    /// 加载最近编辑
    func autoLoadLast() throws {
        do{
            try openWorksFromCacheFolder()    // 从缓存文件夹打开作品。
            delegate?.loadedFile(file: path)
        } catch {
            throw error
        }
    }
    
    /// 打开作品
    /// - throws: 读写错误、JSON解析错误
    func openWorksFromCacheFolder() throws {
        do {
            try readInfoFile()                // 读作品信息。
            try readCatalogFile()             // 读作品目录。
            try readRoleFile()                // 读作品角色。
            try readSymbolFile()              // 读作品符号。
            try readCurrentContentFile()      // 读作品当前章节。
        } catch {
            throw error
        }
    }
    
    /// 保存作品。
    /// - throws: 读写错误、JSON解析错误。
    func saveWorksToCacheFolder()throws{
        do{
            try writeCurrentContentFile()     // 写作品当前章节。
            try writeInfoFile()               // 写作品信息。
            try writeCatalogFile()            // 写作品目录。
            try writeRoleFile()               // 写作品角色。
            try writeSymbolFile()             // 写作品符号。
        } catch {
            throw error
        }
    }
}

// MARK: - Private。
extension Works {
    
    // MARK: - Init Cache Folder。
    /// 清空或新建缓存文件夹。
    private func emptyOrCreatCacheFolder() throws {
        initWordsData()
        do {
            if fileManager.fileExists(atPath: cache) {
                try fileManager.removeItem(atPath: cache)
            }
        } catch {
            throw WorksError.operateError(OperateCode.folderRemove, #function, fileError)
        }
        
        do {
            try fileManager.createDirectory(atPath: cache, withIntermediateDirectories: false, attributes: nil)
        } catch {
            throw WorksError.operateError(OperateCode.folderCreate, #function, fileError)
        }
    }
    
    /// 设置初始文件：info.txt、catalog.txt、role.txt、symbol.txt。
    private func defaultFilesInCacheFolder() throws {
        guard fileManager.createFile(atPath: infoFile, contents: nil, attributes: nil)
            && fileManager.createFile(atPath: catalogFile, contents: nil, attributes: nil)
            && fileManager.createFile(atPath: roleFile, contents: nil, attributes: nil)
            && fileManager.createFile(atPath: symbolFile, contents: nil, attributes: nil) else {
                throw WorksError.operateError(OperateCode.fileCreate, #function, fileError)
        }
    }
    
    // MARK: - Info File。
    /// 读Info File。
    private func readInfoFile() throws {
        guard let data = fileManager.contents(atPath: infoFile) else {
            throw WorksError.operateError(OperateCode.fileRead, #function, fileError)
        }
        if data.count == 0 {
            return;
        }
        do {
            let dic = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
            for (key, value) in dic as! [String: Any]{
                switch key {
                case "chaptersOnBar":
                    infoData[key] = catalogDictionaryToObjects(dictionaries: value as! [Any])
                case "currentChapter":
                    infoData[key] = catalogDictionaryToObjects(dictionaries: [value])[0]
                default:
                    infoData[key] = value
                }
            }
        } catch {
            throw WorksError.operateError(OperateCode.jsonObject, #function, jsonError)
        }
    }
    
    /// 写Info File。
    func writeInfoFile() throws {
        infoData.needSaveToFile = true
        let dic = infoData.forDictionary()
        let data:Data
        do {
            data = try JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
        } catch {
            throw WorksError.operateError(OperateCode.jsonData, #function, jsonError)
        }
        guard dataStatus.isSave(info: data) else {
            return
        }
        do {
            try data.write(to: URL(fileURLWithPath: infoFile))
        } catch {
            throw WorksError.operateError(OperateCode.fileWrite, #function, fileError)
        }
    }
    
    // 写初始数到Info File。
    private func writeDefaultDataToInfoFile() throws {
        infoData.author = authorName()
        infoData.creation = creationTime()
        do {
            try writeInfoFile()
        } catch {
            throw error
        }
    }
    
    // MARK: - Catalog File。
    /// 读Catalog File。
    private func readCatalogFile() throws {
        guard let data = fileManager.contents(atPath: catalogFile) else {
            throw WorksError.operateError(OperateCode.fileRead, #function, fileError)
        }
        if data.count == 0 {
            return;
        }
        do {
            let array = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
            catalogData = catalogDictionaryToObjects(dictionaries: array as! [Any])
        } catch {
            throw WorksError.operateError(OperateCode.jsonObject, #function, jsonError)
        }
    }
    
    /// 多级目录，数组字典，转为数组对象。
    func catalogDictionaryToObjects(dictionaries: [Any]) -> [Catalog]{
        var array = [Catalog]()
        for dic in dictionaries {
            let catalog = Catalog()
            for (key, value) in dic as! [String: Any]{
                if key == "sub" {
                    catalog.sub = catalogDictionaryToObjects(dictionaries: value as! [Any] )
                } else {
                    catalog[key] = value
                }
            }
            array.append(catalog)
        }
        return array
    }
    
    /// 写Catalog File。
    func writeCatalogFile() throws {
        infoData.needSaveToFile = true
        let array = arrayWorksDelegates(objects: catalogData, isCatalog: true)
        let data:Data
        do {
            data = try JSONSerialization.data(withJSONObject: array, options: .prettyPrinted)
        } catch {
            throw WorksError.operateError(OperateCode.jsonData, #function, jsonError)
        }
        guard dataStatus.isSave(catalog: data) else {
            return
        }
        do {
            try data.write(to: URL(fileURLWithPath: catalogFile))
        } catch {
            throw WorksError.operateError(OperateCode.fileWrite, #function, fileError)
        }
    }
    
    /// 写默认数据到Catalog File。
    private func writeDefaultDataToCatalogFile() throws {
        // 书名。
        let book = Catalog()
        book.title =  infoData.file.fileName()
        book.info = infoData.author
        book.creation = infoData.creation
        catalogData = [book]
        
        // 默认章。
        let chapter = Catalog()
        chapter.title =  "Chapter Title"
        chapter.info = ""
        chapter.creation = creationTime()
        chapter.level = 1
        book.sub = [chapter]
        currentContent = chapter
        do {
            try writeCurrentContentFile()    // 建立内容文件。
        } catch {
            throw error
        }
        // 默认节。
        let section = Catalog()
        section.title =  "Section Title"
        section.info = ""
        section.creation = creationTime()
        section.level = 2
        chapter.sub = [section]
        currentContent = section
        do {
            try writeCurrentContentFile()    // 建立内容文件
        } catch {
            throw error
        }
        
        do {
            try writeCatalogFile()
        } catch {
            throw error
        }
    }
    
    // MARK: - Role File。
    /// 读Role File。
    private func readRoleFile() throws {
        guard let data = fileManager.contents(atPath: roleFile) else {
            throw WorksError.operateError(OperateCode.fileRead, #function, fileError)
        }
        if data.count == 0 {
            return
        }
        do {
            let array = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
            for item in array as! [Any]{
                var role = Role()
                for (key, value) in item as! [String: Any]{
                    role[key] = value
                }
                roleData.append(role)
            }
        } catch {
            throw WorksError.operateError(OperateCode.jsonObject, #function, jsonError)
        }
    }
    
    /// 写Role File。
    func writeRoleFile() throws {
        infoData.needSaveToFile = true
        let array = arrayWorksDelegates(objects: roleData, isCatalog: false)
        let data:Data
        do {
            data = try JSONSerialization.data(withJSONObject: array, options: .prettyPrinted)
        } catch {
            throw WorksError.operateError(OperateCode.jsonData, #function, jsonError)
        }
        guard dataStatus.isSave(role: data) else {
            return
        }
        do {
            try data.write(to: URL(fileURLWithPath: roleFile))
        } catch {
            throw WorksError.operateError(OperateCode.fileWrite, #function, fileError)
        }
    }
    
    // MARK: - Symbol File。
    /// 读Symbol File。
    private func readSymbolFile() throws {
        guard let data = fileManager.contents(atPath: symbolFile) else {
            throw WorksError.operateError(OperateCode.fileRead, #function, fileError)
        }
        if data.count == 0 {
            return
        }
        do {
            let array = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
            for item in array as! [Any]{
                var symbol = Symbol()
                for (key, value) in item as! [String: Any]{
                    symbol[key] = value
                }
                symbolData.append(symbol)
            }
        } catch {
            throw WorksError.operateError(OperateCode.jsonObject, #function, jsonError)
        }
    }
    
    /// 写Symbol File。
    func writeSymbolFile() throws {
        infoData.needSaveToFile = true
        let array = arrayWorksDelegates(objects: symbolData, isCatalog: false)
        let data:Data
        do {
            data = try JSONSerialization.data(withJSONObject: array, options: .prettyPrinted)
        } catch {
            throw WorksError.operateError(OperateCode.jsonData, #function, jsonError)
        }
        guard dataStatus.isSave(symbol: data) else {
            return
        }
        do {
            try data.write(to: URL(fileURLWithPath: symbolFile))
        } catch {
            throw WorksError.operateError(OperateCode.fileWrite, #function, fileError)
        }
    }
    
    // MARK: - Current Chpater File。
    /// 读当前章节。
    func readCurrentContentFile() throws {
        guard currentContent.creation > 0 else {
            return
        }
        // 章节以创建时间为标识保存。
        let file = cache + "/chapter\(currentContent.creation).txt"
        do {
            currentContentData = ""
            currentContentData = try String(contentsOfFile: file)
        } catch {
            throw WorksError.operateError(OperateCode.fileRead, #function, fileError)
        }
    }
    
    /// 写当前章节。
    func writeCurrentContentFile() throws {
        infoData.needSaveToFile = true
        guard currentContent.creation > 0 else {
            return
        }
        // 章节以创建时间为标识保存。
        let file = cache + "/chapter\(currentContent.creation).txt"
        do{
            try currentContentData.write(toFile: file, atomically: false, encoding: String.Encoding.utf8)
        } catch {
            throw WorksError.operateError(OperateCode.fileWrite, #function, fileError)
        }
    }
    
    /// 压宿文件到用户指定位置。
    func zipCacheFolderToUsers() throws {
        infoData.needSaveToFile = false
        // 用户操作
        if isUserOperate {
            guard SSZipArchive.createZipFile(atPath: path, withContentsOfDirectory: cache) else {
                throw WorksError.operateError(OperateCode.folderZip, #function, fileError)
            }
            return
        }
        
        // 非用户操作
        guard let url = urlBookmark(file: path) else {
            return
        }
        url.startAccessingSecurityScopedResource()
        guard SSZipArchive.createZipFile(atPath: path, withContentsOfDirectory: cache) else {
            throw WorksError.operateError(OperateCode.folderZip, #function, fileError)
        }
        url.stopAccessingSecurityScopedResource()
    }
    
    /// 解压文件到缓存区。
    func unZipUsersToCacheFolder() throws {
        infoData.needSaveToFile = false
        guard SSZipArchive.unzipFile(atPath: path, toDestination: cache) else {
            throw WorksError.operateError(OperateCode.folderZip, #function, fileError)
        }
    }
}

// MARK: - Assist。
extension Works {
    
    // MARK: - Note File。
    /// 读备注。
    func readNoteFileWith(id: Int) throws -> String?{
        guard id > 0 else {
            return ""
        }
        let file = cache + "/note\(id).txt"
        do {
            return try String(contentsOfFile: file)
        } catch {
            throw WorksError.operateError(OperateCode.fileRead, #function, fileError)
        }
    }
    
    /// 写备注。
    func writeNoteFileWith(id: Int) throws -> Bool {
        guard id > 0 else {
            return false
        }
        let file = cache + "/note\(id).txt"
        do{
            try currentContentData.write(toFile: file, atomically: false, encoding: String.Encoding.utf8)
            return true
        } catch {
            throw WorksError.operateError(OperateCode.fileWrite, #function, fileError)
        }
    }
    
    /// 将作品协议的实例数组转为Dictionary的数组。
    func arrayWorksDelegates(objects: [DataDelegate], isCatalog: Bool) -> Array<Any> {
        var array = [Any]()
        for object in objects {
            var dic = object.forDictionary()
            if isCatalog, let catalog = object as? Catalog {
                dic["sub"] = arrayWorksDelegates(objects: catalog.sub, isCatalog: true)
            }
            array.append(dic)
        }
        return array
    }
    
    /// 根据最近打开的数据，显示标签。
    private func addChapterOnBar(catalog: Catalog) {
        infoData.contentTitleOnBar.insert(catalog, at: 0)
        var array: [Catalog] = [Catalog]()
        for item in infoData.contentTitleOnBar {
            if array.contains(where: {return $0.creation == item.creation }) {
                continue
            }
            array.append(item)
        }
        infoData.contentTitleOnBar = array
    }
}

/// MARK: - Catalog Data。
extension Works {
    /// 添加节点。
    func addCatalog(item: Catalog, inParent: Catalog, index: Int = -1) {
        if index < 0 || index >= inParent.sub.count {
            return inParent.sub.append(item)
        }
        return inParent.sub.insert(item, at: index)
    }
    
    /// 添加节点后，引起其它项操作。
    func addOtherItem(catalog: Catalog){
        currentContent = catalog
        // 添加内容文件。
        try? writeCurrentContentFile()
        // 委托。
        delegate?.catalogUpdatedItem()
    }
    
    /// 删除节点。
    func delCatalog(inParent: Catalog, index: Int) -> Catalog? {
        return inParent.sub.remove(at: index)
    }
    
    /// 删除节点后，引起其它项操作。
    func delOtherItem(catalog: Catalog){
        var index = -1
        for (i, item) in infoData.contentTitleOnBar.enumerated() {
            if item === catalog {
                index = i
                break
            }
        }
        
        if index < 0 {
            return
        }
        
        infoData.contentTitleOnBar.remove(at: index)
        if index > 0 {
            return
        }
        
        currentContent = infoData.contentTitleOnBar[0]
    }
    
    /// 移动节点。
    func moveCatalog(at: Int, atParent: Catalog, to: Int, toParent: Catalog) {
        if atParent === toParent && at == to {
            return
        }
        guard let catalog = delCatalog(inParent: atParent, index: at) else {
            return
        }
        addCatalog(item: catalog, inParent: toParent, index: to)
        try? writeCatalogFile()
    }
    
    /// 父节点。
    /// return: 父项、在父项的位置。
    func parentCatalog(inSub: Catalog, catalog: Catalog) -> (Catalog?, Int) {
        if inSub.sub.count == 0 {
            return (nil, -1)
        }
        for (n, item) in inSub.sub.enumerated() {
            if item.creation == catalog.creation {
                return (inSub, n)
            }
            
            let (obj, j) = parentCatalog(inSub: item, catalog: catalog)
            if j >= 0 {
                return (obj, j)
            }
        }
        return (nil, -1)
    }
}

// MARK: - Last Files
extension Works {
    /// 最近打开。
    func lastFiles(_ file: String = "") -> [String]{
        var array = [String]()
        // 获取数据。
        
        let a = defaults.value(forKey: lastTag) as? [String]
        if a != nil {
            array = a!
        }
        // 返回数据。
        if file.isEmpty {
            return array
        }
        
        // 保存到bookmarks。
        saveBookmark(file: file)
        
        // 保存到UserDefaults。
        if array.isEmpty {
            array.append(file)
            defaults.set(array, forKey: lastTag)
            return array
        }
        
        array = array.filter{$0 != file}
        array.insert(file, at: 0)
        if array.count > 10 {
            array = Array(array.suffix(10))
        }
        defaults.set(array, forKey: lastTag)
        return array
    }
    
    /// 移除所有缓存下来的文件名。
    func clearLastFiles(){
        defaults.removeObject(forKey: lastTag)
    }
    
    /// 获取权限打开文件。
    func openLastFile(file: String, index: Int){
        guard let url = urlBookmark(file: file) else {
            return removeInvalidFile(file: file, index: index)
        }
        url.startAccessingSecurityScopedResource()
        do {
            try openFile(path: file)
        } catch {
            removeInvalidFile(file: file, index:index)
        }
        url.stopAccessingSecurityScopedResource()
    }
    
    func removeInvalidFile(file: String, index: Int) {
        // 显示提示窗。
        let alert = NSAlert()
        alert.messageText = "File does not exist"
        alert.informativeText = "\(file), No such file or directory"
        alert.runModal()
        removeLastFile(file)
        removRecentMenuItem(index: index)
        removRecentSelectItem(index: index)
    }
    
    /// 移除缓存下来的文件名。
    private func removeLastFile(_ file: String){
        var array = defaults.value(forKey: lastTag) as? [String]
        array = array?.filter{$0 != file}
        defaults.set(array, forKey: lastTag)
    }
    
    /// 菜单点击事件。
    @objc func openRecentFile(sender: Any){
        let item = sender as! NSMenuItem
        
        let file = item.toolTip!
        let index = item.parent?.submenu?.index(of: item) ?? 0
        openLastFile(file: file, index: index)
    }
}

// MARK: - Menu Edit
extension Works {
    /// 格式化主菜单最近打开。
    func formatRecentMenu(){
        if recentMenu == nil {
            return
        }
        // 清除当前
        recentMenu!.removeAllItems()
        // 获取数据
        let array = lastFiles()
        if array.isEmpty {
            return
        }
        // 实例菜单项
        for file in array {
            let item = NSMenuItem.init(title: file.fileName(), action: #selector(openRecentFile(sender:)), keyEquivalent: "")
            item.toolTip = file
            recentMenu!.addItem(item)
        }
    }
    
    /// 删除子项。
    private func removRecentMenuItem(index: Int){
        recentMenu?.removeItem(at: index)
    }
    
    /// 格式化标题栏最近打开。
    func formatRecentSelect(){
        if reeentSelect == nil {
            return
        }
        reeentSelect!.removeAllItems()
        let array = lastFiles()
        if array.isEmpty {
            return
        }
        for file in array {
            reeentSelect!.addItem(withTitle: file.fileName())
            let item = reeentSelect!.lastItem
            item?.toolTip = file
        }
    }
    
    private func removRecentSelectItem(index: Int){
        reeentSelect?.removeItem(at: index)
    }
}

// MARK: - Helper。
extension Works {
    func authorName() -> String{
        return  "iWriter"
    }
    
    /// 由于Catalog数据是多层结构，所以需要自己实现增删改。
    /// 删。
    func catalogDataRomoveItem(index: Int) -> Bool{
        return catalogDataRomoveItemByRecursive(index: index, catalogs: &catalogData, start: 0)
    }
    
    /// 递归实现删除。
    private func catalogDataRomoveItemByRecursive(index: Int, catalogs: inout [Catalog], start: Int) -> Bool {
        var j = start
        for (i, catalog) in catalogs.enumerated() {
            if index == j {
                catalogs.remove(at: i)
                return true
            }
            j += 1
            if catalogDataRomoveItemByRecursive(index: index, catalogs:&catalog.sub, start: j) {
                return true
            }
        }
        return false
    }
    
    /// 沙盒外权限保存，缓存bookmarkData。
    private func saveBookmark(file: String){
        let url = URL.init(fileURLWithPath: file)
        guard let bookmarkData = try? url.bookmarkData(options: URL.BookmarkCreationOptions.withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil) else {
            return
        }
        defaults.set(bookmarkData, forKey: file)
    }
    
    /// 沙盒外权限获取， 从bookmarkData获取Url。
    private func urlBookmark(file: String) -> NSURL? {
        guard let bookmarkData = defaults.data(forKey: file) else {
            return nil
        }
        
        return try? NSURL.init(resolvingBookmarkData: bookmarkData, options: [NSURL.BookmarkResolutionOptions.withSecurityScope, NSURL.BookmarkResolutionOptions.withoutUI], relativeTo: nil, bookmarkDataIsStale: nil)
    }
    
    /// 全局ID，以时间戳为基础。
    func creationTime() -> Int {
        let now = Date()
        let t = Int(now.timeIntervalSince1970)
        if t > timeInterval  {
            timeInterval = t
            return t
        }
        timeInterval += 1
        return timeInterval
    }
}
