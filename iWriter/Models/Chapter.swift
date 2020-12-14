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
    
    var info: String                         // 章节信息，概述。
    var article: String                      // 文章内容。
    var loaded: Bool                         // 文章是否被加载。
    var opened: Bool                         // 被打开的。
    var count: Int                           // 章节字数。
    var leaf: Bool                           // 是否为叶节点。
    var snapshot: [String]                   // 每个快照加一串关键词, 将索引加在另存文件名后。
    var x: Int                               // 在画布中x轴的位置。
    var y: Int                               // 在画布中y轴的位置。
    
    init(id: Int = 0, value: String = "", naming: Bool = true, status: Bool = true, expanded: Bool = false, info: String = "", article: String = "", loaded: Bool = false, opened: Bool = true, count: Int = 0, leaf: Bool = false, snapshot: [String] = [], x: Int = 0, y: Int = 0) {
        self.info = info
        self.article = article
        self.loaded = loaded
        self.opened = opened
        self.count = count
        self.leaf = leaf
        self.snapshot = snapshot
        self.x = x
        self.y = y
        
        super.init(id: id, value: value, naming: naming, status: status, expanded: expanded)
    }
    
    /// 使用字典进行初始化。
    required init(dictionary: [String : Any]) {
        // 本类的。
        self.info = dictionary["info"] as? String ?? ""
        self.article = ""
        self.loaded = false
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
        dic["info"] = self.info
        dic["leaf"] = self.leaf
        dic["snapshot"] = self.snapshot
        dic["x"] = self.x
        dic["y"] = self.y
        dic["opened"] = self.opened
        return dic
    }
    
    /// 章节内容的缓存路径。
    func articleFile() -> String {
        return CACHE_PATH + "/c\(self.id).txt"
    }
    
    /// 删除当前节点关联的内容.
    func deleteFiles() {
        if self.leaf {
            // 删除关联的内容。
            let path = self.articleFile()
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
    
    /// 读当前章节。
    func readArticleFile() throws {
        // 没有正在编辑的文档。
        if self.id == 0 {
            return
        }

        // 章节以创建时间为标识保存。
        let file = self.articleFile()
        do {
            // rtf格式。
//            self.article = try NSMutableAttributedString(url: URL(fileURLWithPath: file), options: [.documentType: NSAttributedString.DocumentType.rtf], documentAttributes: nil)
            // txt格式。
            self.loaded = true
            self.article = try String(contentsOf: URL(fileURLWithPath: file))
        } catch {
            throw WorksError.operateError(OperateCode.fileRead, #function, error.localizedDescription)
        }
    }

    /// 写当前章节。
    func writeArticleFile() throws {
        if self.value.isEmpty {
            return
        }
        // 章节以创建时间为标识保存。
        let file = self.articleFile()
        do {
            // rtf格式。
//            let rtfData = try self.article.data(from: .init(location: 0, length: self.article.length), documentAttributes: [.documentType: NSAttributedString.DocumentType.rtf])
//           try rtfData.write(to: URL(fileURLWithPath: file), options: .atomic)
            // txt格式。
            try self.article.write(toFile: file, atomically: false, encoding: .utf8)
        } catch {
            throw WorksError.operateError(OperateCode.fileWrite, #function, error.localizedDescription)
        }
    }
    
    // MARK: Context.
    /// Search Text.
    func search(_ word: String) -> [Search] {
        var data = [Search]()
        if self.leaf {
            if !self.loaded {
                try? self.readArticleFile()
            }
            data.append(Search(word: word, chapter: self))
            return data
        }
        self.children.forEach({ item in
            guard let it = item as? Chapter else {
                return
            }
            let array = it.search(word)
            data.append(contentsOf: array)
        })
        return data
    }
}
 
