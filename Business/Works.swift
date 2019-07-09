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
    case folderCreat         // 创建文件夹
    case folderRemove        // 删除文件夹
    case folderZip           // 压缩文件夹
    case fileCreat           // 创建文件
    case fileRead            // 读文件
    case fileWrite           // 写文件
    case fileUnzip           // 解压文件
    case jsonData            // JSON转Data
    case jsonObject          // JSON转Object
}

/**
 ## Works类的操作错误
 1. 操作码：指明作哪类操作；
 2. 位置：在个方法里返回的；
 3. 话术：显示给用户看的信息。
 */
enum WorksError: Error {
    case operateError(OperateCode, String, String)  // 操作码、位置、话术
}

/**
 ## Works类
    配置文件操作：New File、Open File、Save File、Save As File
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
    // 文件管理
    let fileManager: FileManager
    
    // 错误话术
    let fileError: String
    let jsonError: String
    
    // 缓存区及初始文件
    let cache = NSHomeDirectory() + "/iWriter"
    let infoFile: String
    let catalogFile: String
    let roleFile: String
    let symbolFile: String
    
    // 初始数据
    var infoData: Info
    var catalogData: [Catalog]
    var roleData: [Role]
    var symbolData: [Symbol]
    
    // 数据状态
    var dataStatus: Status
    
    // 作品路径
    private var path: String {
        set{
            infoData.file = newValue
        }
        get{
            return infoData.file
        }
    }
    
    // 当前章节ID
    private var currentChapterId: Int {
        set{
            infoData.currentChapter = newValue
            addChapterOnBar(id: newValue)
        }
        get{
            return infoData.currentChapter
        }
    }
    
    // 当前章节内容
    var currentChapterData: String

    
    override init(){
        fileManager = FileManager.default
        fileError = "No Operating Rights"
        jsonError = "JSON Conversion Error"
        
        infoFile = cache + "/info.txt"
        catalogFile = cache + "/catalog.txt"
        roleFile = cache + "/role.txt"
        symbolFile = cache + "/symbol.txt"
        
        infoData = Info()
        catalogData = [Catalog]()
        roleData = [Role]()
        symbolData = [Symbol]()
        
        dataStatus = Status()
        currentChapterData = ""
    }
}

// MARK: - Match File Action
extension Works {
    
    /// 新建文件
    /// - parameter path: 指定的保存路径（含文件名称）
    /// - throws: 读写错误、JSON解析错误
    func newFile(path: String) throws {
        self.path = path
        do{
            try emptyOrCreatCacheFolder()     // 清空或创建缓存文件夹
            try defaultFilesInCacheFolder()   // 在缓存文件夹创建默认的文件
            try writeDefaultDataInfoFile()    // 写入作品初始信息
            try zipCacheFolderToUsers()       // 将缓存文件夹打包到用户指定的位置
        } catch {
            throw error
        }
    }
    
    /// 打开文件
    /// - parameter path: 指定的打开文件（含文件路径）
    /// - throws: 读写错误、JSON解析错误
    func openFile(path: String) throws {
        self.path = path
        do{
            try emptyOrCreatCacheFolder()     // 清空或创建缓存文件夹
            try unZipUsersToCacheFolder()     // 解压指定文件（含路径）到缓存文件夹
            try openWorksFromCacheFolder()    // 从缓存文件夹打开作品
        } catch {
            throw error
        }
    }
    
    /// 保存文件
    /// - throws: 读写错误、JSON解析错误
    func saveFile() throws {
        do{
            try saveWorksToCacheFolder()      // 保存作品数据到缓存文件
            try zipCacheFolderToUsers()       // 将缓存文件夹打包到用户指定的位置
        } catch {
            throw error
        }
    }
    
    /// 另存文件
    /// - parameter path: 用户指定的保存路径（含文件名称）
    /// - throws: 读写错误、JSON解析错误
    func saveAsFile(path: String) throws {
        self.path =  path                     // 指定新的保存位置
        do{
            try saveFile()                        // 保存作品
        } catch {
            throw error
        }
    }
    
    /// 打开作品
    /// - throws: 读写错误、JSON解析错误
    func openWorksFromCacheFolder() throws {
        do {
            try readInfoFile()                // 读作品信息
            try readCatalogFile()             // 读作品目录
            try readRoleFile()                // 读作品角色
            try readSymbolFile()              // 读作品符号
            try readCurrentChapterFile()      // 读作品当前章节
        } catch {
            throw error
        }
    }
    
    /// 保存作品
    /// - throws: 读写错误、JSON解析错误
    func saveWorksToCacheFolder()throws{
        do{
            try writeInfoFile()               // 写作品信息
            try writeCatalogFile()            // 写作品目录
            try writeRoleFile()               // 写作品角色
            try writeSymbolFile()             // 写作品符号
            try writeCurrentChapterFile()     // 写作品当前章节
        } catch {
            throw error
        }
    }
}

// MARK: - Private
extension Works {
    
    // MARK: - Init Cache Folder
    /// 清空或新建缓存文件夹
    private func emptyOrCreatCacheFolder() throws {
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
            throw WorksError.operateError(OperateCode.folderCreat, #function, fileError)
        }
    }
    
    /// 设置初始文件：info.txt、catalog.txt、role.txt、symbol.txt
    private func defaultFilesInCacheFolder() throws {
        guard fileManager.createFile(atPath: infoFile, contents: nil, attributes: nil)
            || fileManager.createFile(atPath: catalogFile, contents: nil, attributes: nil)
            || fileManager.createFile(atPath: roleFile, contents: nil, attributes: nil)
            || fileManager.createFile(atPath: symbolFile, contents: nil, attributes: nil) else {
            throw WorksError.operateError(OperateCode.fileCreat, #function, fileError)
        }
    }
    
    // MARK: - Info File
    /// 读Info File
    private func readInfoFile() throws {
        guard let data = fileManager.contents(atPath: infoFile) else {
            throw WorksError.operateError(OperateCode.fileRead, #function, fileError)
        }
        do {
            let dic = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
            for (key, value) in dic as! [String: Any]{
                infoData[key] = value
            }
        } catch {
            throw WorksError.operateError(OperateCode.jsonObject, #function, jsonError)
        }
    }
    
    /// 写Info File
    private func writeInfoFile() throws {
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
    
    // 写初始数到Info File
    private func writeDefaultDataInfoFile() throws {
        infoData.author = authorName()
        infoData.creation = creationTime()
        do {
            try writeInfoFile()
        } catch {
            throw error
        }
    }
    
    // MARK: - Catalog File
    /// 读Catalog File
    private func readCatalogFile() throws {
        guard let data = fileManager.contents(atPath: catalogFile) else {
            throw WorksError.operateError(OperateCode.fileRead, #function, fileError)
        }
        do {
            let array = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
            catalogData = forCatalog(array: array as! [Any])
        } catch {
            throw WorksError.operateError(OperateCode.jsonObject, #function, jsonError)
        }
    }
    
    /// 转为多级目录
    private func forCatalog(array:[Any]) -> [Catalog]{
        var catalogs = [Catalog]()
        for item in array {
            var catalog = Catalog()
            for (key, value) in item as! [String: Any]{
                if key == "subset" {
                    catalog[key] = forCatalog(array: value as! [Any])
                }else{
                    catalog[key] = value
                }
            }
            catalogs.append(catalog)
        }
        return catalogs
    }
    
    /// 写Catalog File
    private func writeCatalogFile() throws {
        let data:Data
        do {
            data = try JSONSerialization.data(withJSONObject: catalogData, options: .prettyPrinted)
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
    
    // MARK: - Role File
    /// 读Role File
    private func readRoleFile() throws {
        guard let data = fileManager.contents(atPath: roleFile) else {
            throw WorksError.operateError(OperateCode.fileRead, #function, fileError)
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
    
    /// 写Role File
    private func writeRoleFile() throws {
        let data:Data
        do {
            data = try JSONSerialization.data(withJSONObject: roleData, options: .prettyPrinted)
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
    
    // MARK: - Symbol File
    /// 读Symbol File
    private func readSymbolFile() throws {
        guard let data = fileManager.contents(atPath: symbolFile) else {
            throw WorksError.operateError(OperateCode.fileRead, #function, fileError)
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
    
    /// 写Symbol File
    private func writeSymbolFile() throws {
        let data:Data
        do {
            data = try JSONSerialization.data(withJSONObject: symbolData, options: .prettyPrinted)
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
    
    // MARK: - Current Chpater File
    /// 读当前章节
    private func readCurrentChapterFile() throws {
        guard currentChapterId > 0 else {
            return
        }
        let file = cache + "/chapter\(currentChapterId).txt"
        do {
            currentChapterData = try String(contentsOfFile: file)
        } catch {
            throw WorksError.operateError(OperateCode.fileRead, #function, fileError)
        }
    }
    
    /// 写当前章节
    private func writeCurrentChapterFile() throws {
        guard currentChapterId > 0 else {
            return
        }
        let file = cache + "/chapter\(currentChapterId).txt"
        do{
            try currentChapterData.write(toFile: file, atomically: false, encoding: String.Encoding.utf8)
        } catch {
            throw WorksError.operateError(OperateCode.fileWrite, #function, fileError)
        }
    }
    
    func zipCacheFolderToUsers() throws {
        guard SSZipArchive.createZipFile(atPath: path, withContentsOfDirectory: cache) else {
            throw WorksError.operateError(OperateCode.folderZip, #function, fileError)
        }
    }
    
    func unZipUsersToCacheFolder() throws {
        guard SSZipArchive.unzipFile(atPath: path, toDestination: cache) else {
            throw WorksError.operateError(OperateCode.folderZip, #function, fileError)
        }
    }
}

// MARK: - Assist
extension Works {
    
    // MARK: - Note File
    /// 读备注
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
    
    /// 写备注
    func writeNoteFileWith(id: Int) throws -> Bool {
        guard id > 0 else {
            return false
        }
        let file = cache + "/note\(id).txt"
        do{
            try currentChapterData.write(toFile: file, atomically: false, encoding: String.Encoding.utf8)
            return true
        } catch {
            throw WorksError.operateError(OperateCode.fileWrite, #function, fileError)
        }
    }
    
    private func addChapterOnBar(id: Int) {
        if infoData.chaptersOnBar.contains(id){
            return
        }
        infoData.chaptersOnBar.append(id)
    }
}

// MARK: - Helper
extension Works {
    
    func creationTime() -> Int {
        let now = Date()
        return Int(now.timeIntervalSince1970)
    }
    
    func authorName() -> String{
        return  "iWriter"
    }
}
