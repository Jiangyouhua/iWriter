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
    case fileRight           // 权限。
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
    func selectedLeaf(chapter: Chapter)
}

/**
 ## Works类
 */
class Works: NSObject {
    
    var delegate: WorksDelegate?
    var isUserOperate: Bool = false
    
    // 文件管理。
    var fileManager = FileManager.default

    var currentContent: String                    // 当前内容。
    var currentAnnotations: [Int: Annotation]     // 当前标注。
    
    // 初始数据。
    var info: Info                                // 信息。
    var outlines: [Chapter]                       // 大纲，目录为索引0。
    var notes: [Note]                             // 便条。
    var roles: [Role]                             // 角色。
    var symbols: [Symbol]                         // 符号。
    
    // 最近打开的文件的两处菜单。
    var openedFilesMenu: NSMenu?
    var openedFilesSelect: NSPopUpButton?
    
    /// 初始化
    override init(){
        currentContent = ""
        currentAnnotations = [:]
        
        info = Info()
        outlines = [Chapter]()
        notes = [Note]()
        roles = [Role]()
        symbols = [Symbol]()
    }
}

// MARK: - Match File Action。
extension Works {
    
    /// 新建文件。
    /// - parameter path: 指定的保存路径（含文件名称）。
    /// - throws: 读写错误、JSON解析错误。
    func newFile(path: String) throws {

        applyWorksPath(path: path)
        
        do{
            try emptyOrCreateCacheFolder()       // 清空或创建缓存文件夹。
            try defaultFilesInCacheFolder()      // 在缓存文件夹创建默认的文件。
            try defaultInfoFile()                // 写入作品初始信息。
            try defaultOutlineFile()             // 写入作品初始目录信息。文件信息需要章节信息，所以在后。
            try zipCacheToFile()                 // 将缓存文件夹打包到用户指定的位置。
            try openFilesFromCache()             // 从缓存文件夹打开作品。
            
            // 调用完成方法
            delegate?.loadedFile(file: path)
        } catch {
            throw error
        }
    }
    
    /// 打开文件。
    /// - parameter path: 指定的打开文件（含文件路径）。
    /// - throws: 读写错误、JSON解析错误。
    func openFile(path: String) throws {
        
        applyWorksPath(path: path)
        
        do{
            try emptyOrCreateCacheFolder()       // 清空或创建缓存文件夹。
            try unZipFileToCache()               // 解压指定文件（含路径）到缓存文件夹。
            try openFilesFromCache()             // 从缓存文件夹打开作品。

            delegate?.loadedFile(file: path)
        } catch {
            throw error
        }
    }
    
    /// 保存文件。
    /// - throws: 读写错误、JSON解析错误。
    func saveFile() throws {
        guard info.saved else {
            return
        }
        do{
            try zipCacheToFile()                 // 将缓存文件夹打包到用户指定的位置。
        } catch {
            throw error
        }
    }
    
    /// 另存文件。
    /// - parameter path: 用户指定的保存路径（含文件名称）。
    /// - throws: 读写错误、JSON解析错误。
    func saveAsFile(path: String) throws {
        
        applyWorksPath(path: path)
        
        do{
            try saveFile()                        // 保存作品。
        } catch {
            throw error
        }
    }
    
    /// 打开作品
    /// - throws: 读写错误、JSON解析错误
    func openFilesFromCache() throws {
        do {
            try readInfoFile()                      // 读作品信息。
            try readOutlineFile()                   // 读目录。
            try readNoteFile()                      // 读便条。
            try readRoleFile()                      // 读角色。
            try readSymbolFile()                    // 读符号。
            try readCurrentContentFile()            // 读当前章节内容。
            try readCurrentAnnotationFile()         // 读当前章节批注。
            
            delegate?.loadedFile(file: info.file)
        } catch {
            throw error
        }
    }
    
    /// 获取权限打开文件。
    func openLastFile(file: String) throws {
        guard let url = cache.urlBookmark(path: file) else {
            throw WorksError.operateError(OperateCode.fileRight, #function, RIGHT_ERROR)
        }
        url.startAccessingSecurityScopedResource()
        do {
            try openFile(path: file)
        } catch {
        throw (error)
        }
        url.stopAccessingSecurityScopedResource()
    }
}

// MARK: - Private。
extension Works {
    
    private func applyWorksPath(path: String) {
        isUserOperate = true
        info.file = path
        cache.addOpenedFile(file: path)
        cache.saveBookmark(path: path)
    }
    
    // MARK: - Init Cache Folder。
    /// 清空或新建缓存文件夹。
    private func emptyOrCreateCacheFolder() throws {
        // 有则删除。
        do {
            if fileManager.fileExists(atPath: CACHE_PATH) {
                try fileManager.removeItem(atPath: CACHE_PATH)
            }
        } catch {
            throw WorksError.operateError(OperateCode.folderRemove, #function, FILE_ERROR)
        }
        
        // 建立缓存文件夹。
        do {
            try fileManager.createDirectory(atPath: CACHE_PATH, withIntermediateDirectories: false, attributes: nil)
        } catch {
            throw WorksError.operateError(OperateCode.folderCreate, #function, FILE_ERROR)
        }
    }
    
    /// 设置初始文件。
    private func defaultFilesInCacheFolder() throws {
        // 创建5个默认文件。
        guard fileManager.createFile(atPath: INFO_FILE, contents: nil, attributes: nil)
            && fileManager.createFile(atPath: OUTLINE_FILE, contents: nil, attributes: nil)
            && fileManager.createFile(atPath: NOTE_FILE, contents: nil, attributes: nil)
            && fileManager.createFile(atPath: ROLE_FILE, contents: nil, attributes: nil)
            && fileManager.createFile(atPath: SYMBOL_FILE, contents: nil, attributes: nil) else {
                throw WorksError.operateError(OperateCode.fileCreate, #function, FILE_ERROR)
        }
    }
    
    // MARK: - Info File。
    /// 读 Info File。
    private func readInfoFile() throws {
        guard let data = fileManager.contents(atPath: INFO_FILE) else {
            throw WorksError.operateError(OperateCode.fileRead, #function, FILE_ERROR)
        }
        if data.count == 0 {
            return;
        }
        do {
            let dic = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
            info = Info(dictionary: dic as! [String : Any])
        } catch {
            throw WorksError.operateError(OperateCode.jsonObject, #function, JSON_ERROR)
        }
    }
    
    /// 写 Info File。
    func writeInfoFile() throws {
        info.saved = false
        let dic = info.forDictionary()
        let data:Data
        do {
            data = try JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
            try data.write(to: URL(fileURLWithPath: INFO_FILE))
        } catch {
            throw WorksError.operateError(OperateCode.jsonData, #function, JSON_ERROR)
        }
    }
    
    // 写初始数到Info File。
    private func defaultInfoFile() throws {
        info.title = info.file.fileName()
        info.info = ""
        info.author = "iWriter"
        info.version = "1.0"
        info.creation = creationTime()
        info.saved = false
        
        do {
            try writeInfoFile()
        } catch {
            throw error
        }
    }
    
    // MARK: - Catalog File。
    /// 读Catalog File。
    private func readOutlineFile() throws {
        guard let data = fileManager.contents(atPath: OUTLINE_FILE) else {
            throw WorksError.operateError(OperateCode.fileRead, #function, FILE_ERROR)
        }
        if data.count == 0 {
            return;
        }
        if data.count == 0 {
            return;
        }
        do {
            let array = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
            outlines = dictionaryToStructWith(array: array as! [Any])
        } catch {
            throw WorksError.operateError(OperateCode.jsonObject, #function, JSON_ERROR)
        }
    }

    
    /// 写Catalog File。
    func writeOutlineFile() throws {
        info.saved = false
        let array = structToDictionaryWith(array: outlines)
        let data:Data
        do {
            data = try JSONSerialization.data(withJSONObject: array, options: .prettyPrinted)
            try data.write(to: URL(fileURLWithPath: OUTLINE_FILE))
        } catch {
            throw WorksError.operateError(OperateCode.jsonData, #function, JSON_ERROR)
        }
    }
    
    /// 写默认数据到Catalog File。
    private func defaultOutlineFile() throws {
        // 书名。
        let catalog = Chapter()
        catalog.title =  info.title
        catalog.info = "Please enter the summary of each chapter"
        catalog.creation = info.creation
        catalog.leaf = false
        outlines.append(catalog)
        do {
            try writeOutlineFile()
        } catch {
            throw error
        }
    }
    
    // MARK: - Note File。
    /// 读Note File。
    private func readNoteFile() throws {
        guard let data = fileManager.contents(atPath: NOTE_FILE) else {
            throw WorksError.operateError(OperateCode.fileRead, #function, FILE_ERROR)
        }
        if data.count == 0 {
            return
        }
    
        do {
            let array = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
            notes = dictionaryToStructWith(array: array as! [Any])
        } catch {
            throw WorksError.operateError(OperateCode.jsonObject, #function, JSON_ERROR)
        }
    }
    
    /// 写Note File。
    func writeNoteFile() throws {
        info.saved = false
        let array = structToDictionaryWith(array: notes)
        let data:Data
        do {
            data = try JSONSerialization.data(withJSONObject: array, options: .prettyPrinted)
            try data.write(to: URL(fileURLWithPath: NOTE_FILE))
        } catch {
            throw WorksError.operateError(OperateCode.fileWrite, #function, FILE_ERROR)
        }
    }
    
    // MARK: - Role File。
    /// 读Role File。
    private func readRoleFile() throws {
        guard let data = fileManager.contents(atPath: ROLE_FILE) else {
            throw WorksError.operateError(OperateCode.fileRead, #function, FILE_ERROR)
        }
        if data.count == 0 {
            return
        }
    
        do {
            let array = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
            roles = dictionaryToStructWith(array: array as! [Any])
        } catch {
            throw WorksError.operateError(OperateCode.jsonObject, #function, JSON_ERROR)
        }
    }
    
    /// 写Role File。
    func writeRoleFile() throws {

        info.saved = false
        let array = structToDictionaryWith(array: roles)
        let data:Data
        do {
            data = try JSONSerialization.data(withJSONObject: array, options: .prettyPrinted)
            try data.write(to: URL(fileURLWithPath: ROLE_FILE))
        } catch {
            throw WorksError.operateError(OperateCode.fileWrite, #function, FILE_ERROR)
        }
    }
    
    // MARK: - Symbol File。
    /// 读Symbol File。
    private func readSymbolFile() throws {
        guard let data = fileManager.contents(atPath: SYMBOL_FILE) else {
            throw WorksError.operateError(OperateCode.fileRead, #function, FILE_ERROR)
        }
        if data.count == 0 {
            return
        }
        do {
            let array = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
            symbols = dictionaryToStructWith(array: array as! [Any])
        } catch {
            throw WorksError.operateError(OperateCode.jsonObject, #function, JSON_ERROR)
        }
    }
    
    /// 写Symbol File。
    func writeSymbolFile() throws {
        info.saved = false
        let array = structToDictionaryWith(array: symbols)
        let data:Data
        do {
            data = try JSONSerialization.data(withJSONObject: array, options: .prettyPrinted)
            try data.write(to: URL(fileURLWithPath: SYMBOL_FILE))
        } catch {
            throw WorksError.operateError(OperateCode.fileWrite, #function, FILE_ERROR)
        }
    }
    
    // MARK: - Current Catalog File。
    /// 读当前章节。
    func readCurrentContentFile() throws {
        // 没有正在编辑的文档。
        if info.chapterEditing.creation == 0 {
            return
        }

        // 章节以创建时间为标识保存。
        let file = info.chapterEditing.contentFile()
        do {
            currentContent = try String(contentsOfFile: file)
        } catch {
            throw WorksError.operateError(OperateCode.fileRead, #function, FILE_ERROR)
        }
    }
    
    /// 写当前章节。
    func writeCurrentContentFile() throws {
        if info.chapterEditing.creation == 0 {
            return
        }
        info.saved = false
        // 章节以创建时间为标识保存。
        let file = info.chapterEditing.contentFile()
        do{
            try currentContent.write(toFile: file, atomically: false, encoding: .utf8)
        } catch {
            throw WorksError.operateError(OperateCode.fileWrite, #function, FILE_ERROR)
        }
    }
    
    func defaultContentFile(chapter: Chapter) throws {
        if info.chapterEditing.creation == 0 {
            return
        }
        info.saved = false
        // 章节以创建时间为标识保存。
        let file = chapter.contentFile()
        do{
            try "Please ...".write(toFile: file, atomically: false, encoding: .utf8)
        } catch {
            throw WorksError.operateError(OperateCode.fileWrite, #function, FILE_ERROR)
        }
    }
    
    func readCurrentAnnotationFile() throws {
        if info.chapterEditing.creation == 0 {
            return
        }
        info.saved = false
        // 章节以创建时间为标识保存。
        let file = info.chapterEditing.annotationFile()
        guard let data = fileManager.contents(atPath: file) else {
            throw WorksError.operateError(OperateCode.fileRead, #function, FILE_ERROR)
        }
        if data.count == 0 {
            return
        }
        do {
            let map = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
            currentAnnotations = dictionaryToStructWith(dic: map as! [Int: Any])
        } catch {
            throw WorksError.operateError(OperateCode.jsonObject, #function, JSON_ERROR)
        }
    }
    
    /// 写当前章节。
    func writeCurrentAnnotationFile() throws {
        if info.chapterEditing.creation == 0 {
            return
        }
        info.saved = false
        // 章节以创建时间为标识保存。
        let file = info.chapterEditing.annotationFile()
        let dic = structToDictionaryWith(dic: currentAnnotations)
        let data:Data
        do {
            data = try JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
            try data.write(to: URL(fileURLWithPath: file))
        } catch {
            throw WorksError.operateError(OperateCode.fileWrite, #function, FILE_ERROR)
        }
    }
    
    /// 压宿文件到用户指定位置。
    func zipCacheToFile() throws {
        if info.file.isEmpty {
            return
        }
        info.saved = true
        // 用户操作，
        if isUserOperate {
            guard SSZipArchive.createZipFile(atPath: info.file, withContentsOfDirectory: CACHE_PATH) else {
                throw WorksError.operateError(OperateCode.folderZip, #function, FILE_ERROR)
            }
            return
        }
        
        // 非用户操作，有权限问题，需要将用户指定的目录加入权限中。
        guard let url = cache.urlBookmark(path: info.file) else {
            return
        }
        url.startAccessingSecurityScopedResource()
        guard SSZipArchive.createZipFile(atPath: info.file, withContentsOfDirectory: CACHE_PATH) else {
            throw WorksError.operateError(OperateCode.folderZip, #function, FILE_ERROR)
        }
        url.stopAccessingSecurityScopedResource()
    }
    
    /// 解压文件到缓存区。
    func unZipFileToCache() throws {
        if info.file.isEmpty {
            return
        }
        info.saved = true
        guard SSZipArchive.unzipFile(atPath: info.file, toDestination: CACHE_PATH) else {
            throw WorksError.operateError(OperateCode.folderZip, #function, FILE_ERROR)
        }
    }

    /// 菜单点击事件。
    @objc func openRecentFile(sender: Any){
        let item = sender as! NSMenuItem
        
        let file = item.toolTip!
        try? openLastFile(file: file)
    }
}
