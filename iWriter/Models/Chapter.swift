//
//  Chapter.swift
//  iWriter
//
//  Created by Jiangyouhua on 2019/7/9.
//  Copyright © 2019 Jiangyouhua. All rights reserved.
//

import Foundation

/**
 ## Chapter。
    作品目录，使用时确定顺序按层级递进。
 1. 存储时抛弃父类；
 2. 读取时获取父类；
 */
class Chapter: FileDelegate {
    
    var title: String                    // 章节标题。
    var info: String                     // 章节信息，概述。
    var parent: Chapter?                 // 父节点。
    var children: [Chapter]              // 章节的层级。
    var count: Int                       // 章节字数。
    var leaf: Bool                       // 是否为叶节点。
    var snapshot: [String]               // 每个快照加一串关键词, 将索引加在另存文件名后。
    var x: Int                           // 在画布中x轴的位置。
    var y: Int                           // 在画布中y轴的位置。
    var creation: Int                    // 创建时间，时间戮。
    var expanded: Bool                   // 节点是否为展开状态。
    var naming: Bool                     // 节点是否为命名状态。
    var status: Bool                     // 是否有效。
    
    init() {
        self.title = ""
        self.info = ""
        self.children = [Chapter]()
        self.count = 0
        self.leaf = false
        self.snapshot = [String]()
        self.x = 0
        self.y = 0
        self.creation = 0
        self.expanded = false
        self.naming = false
        self.status = true
    }
    
    /// 使用字典进行初始化。
    required init(dictionary: [String : Any]) {
        self.title = dictionary["title"] as? String ?? ""
        self.info = dictionary["info"] as? String ?? ""
        self.children = [Chapter]()
        self.count = dictionary["count"] as? Int ?? 0
        self.leaf = dictionary["leaf"] as? Bool ?? false
        self.snapshot = dictionary["snapshot"] as? [String] ?? [String]()
        self.x = dictionary["x"] as? Int ?? 0
        self.y = dictionary["y"] as? Int ?? 0
        self.creation = dictionary["creation"] as? Int ?? 0
        self.expanded = dictionary["expanded"] as? Bool ?? false
        self.naming = dictionary["naming"] as? Bool ?? false
        self.status = dictionary["status"] as? Bool ?? false
        
        // 递归处理children。
        self.children = childrenInit(object: dictionary["children"])
    }
    
    func childrenInit(object: Any?) -> [Chapter] {
        var chapters = [Chapter]()
        guard let array = object as? [Any] else {
            return chapters
        }
        array.forEach{ item in
            guard let dic = item as? [String: Any] else {
                return
            }
            let node = Chapter(dictionary: dic)
            node.parent = self
            chapters.append(node)
        }
        return chapters
    }
    
    /// 转为字典。
    /// - returns: 字典。
    func forDictionary() -> Dictionary<String, Any> {
        var dic:Dictionary<String, Any> = [:]
        
        dic["title"] = self.title
        dic["info"] = self.info
        dic["children"] = [Any]()
        dic["count"] = self.count
        dic["leaf"] = self.leaf
        dic["snapshot"] = self.snapshot
        dic["x"] = self.x
        dic["y"] = self.y
        dic["expanded"] = self.expanded
        dic["naming"] = self.naming
        dic["creation"] = self.creation
        dic["status"] = self.status
        
        // 递归处理children。
        dic["children"] = childrenDictionary()
        return dic
    }
    
    func childrenDictionary() -> [Any] {
        var a: [Any] = [Any]()
        self.children.forEach{ chapter in
            let d = chapter.forDictionary()
            a.append(d)
        }
        return a
    }
    
    /// 章节内容的缓存路径。
    func contentFile() -> String {
        return CACHE_PATH + "/c\(self.creation).txt"
    }

    /// 按章节保存批注的路径。
    func annotationFile() -> String {
        return CACHE_PATH + "/a\(self.creation).txt"
    }
    
    /// 统计所有子项数量，含自身。
    func countChildren() -> Int {
        var i = 1
        if self.children.count == 0 {
            return i
        }
        for node in self.children {
            i += node.countChildren()
        }
        return i
    }
    
    /// 删除当前节点关联的内容
    func deleteFiles() {
        if self.leaf {
            // 删除关联的内容。
            let content = self.contentFile()
            try? FileManager.default.removeItem(atPath: content)
            // 删除关联的批注。
            let annotation = self.annotationFile()
            try? FileManager.default.removeItem(atPath: annotation)
            return
        }
        
        for it in self.children {
            return it.deleteFiles()
        }
    }
    
    /// 在你级的位置。
    func indexParent() -> Int {
        guard let i = self.parent?.children.firstIndex(where:
                {$0.creation == self.creation}) else {
                return -1
        }
        return i
    }
    
    /// 删除自身。
    func removeFromParent() -> Int{
        // 从自身的父节点中移除自己。
        let i = indexParent()
        self.parent?.children.remove(at: i)
        self.parent = nil
        return i
    }
}
