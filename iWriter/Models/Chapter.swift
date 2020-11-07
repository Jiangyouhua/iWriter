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
class Chapter: Model {
    
    var title: String                    // 章节标题。
    var info: String                     // 章节信息，概述。
    var count: Int                       // 章节字数。
    var leaf: Bool                       // 是否为叶节点。
    var snapshot: [String]               // 每个快照加一串关键词, 将索引加在另存文件名后。
    var x: Int                           // 在画布中x轴的位置。
    var y: Int                           // 在画布中y轴的位置。
    var opened: Bool                     // 被打开的。
    
    override init() {
        self.title = ""
        self.info = ""
        self.count = 0
        self.leaf = false
        self.snapshot = [String]()
        self.x = 0
        self.y = 0
        self.opened = true
        super.init()
    }
    
    /// 使用字典进行初始化。
    required init(dictionary: [String : Any]) {
        // 本类的。
        self.title = dictionary["title"] as? String ?? ""
        self.info = dictionary["info"] as? String ?? ""
        self.count = dictionary["count"] as? Int ?? 0
        self.leaf = dictionary["leaf"] as? Bool ?? false
        self.snapshot = dictionary["snapshot"] as? [String] ?? [String]()
        self.x = dictionary["x"] as? Int ?? 0
        self.y = dictionary["y"] as? Int ?? 0
        self.opened = dictionary["opened"] as? Bool ??  false
        // 父类的。
        super.init(dictionary: dictionary)
        modelsFromDictionary(object: dictionary["children"], node: self)
    }
    
    
    
    /// 转为字典。
    /// - returns: 字典。
    override func toDictionary() -> Dictionary<String, Any> {
        // 父类的。
        var dic = super.toDictionary()
        dic["children"] = modelsToDictionary(array: self.children)
        // 本类的。
        dic["title"] = self.title
        dic["info"] = self.info
        dic["count"] = self.count
        dic["leaf"] = self.leaf
        dic["snapshot"] = self.snapshot
        dic["x"] = self.x
        dic["y"] = self.y
        dic["opened"] = self.opened
        return dic
    }
    
    /// 章节内容的缓存路径。
    func contentFile() -> String {
        return CACHE_PATH + "/c\(self.creation).txt"
    }
    
    /// 删除当前节点关联的内容
    func deleteFiles() {
        if self.leaf {
            // 删除关联的内容。
            let path = self.contentFile()
            try? FileManager.default.removeItem(atPath: path)
            return
        }
        
        for it in self.children {
            guard let s = it as? Chapter else {
                return
            }
            return s.deleteFiles()
        }
    }
}
