//
//  Info.swift
//  iWriter
//
//  Created by Jiangyouhua on 2019/7/9.
//  Copyright © 2019 Jiangyouhua. All rights reserved.
//

import Foundation

/**
 ## Info。
    作品信息。
 */
struct Info: FileDelegate {
    
    var file: String                     // 文件的保存路径。
    var title: String                    // 作品名称。
    var info: String                     // 作品信息。
    var author: String                   // 作者。
    var version: String                  // 作者，前期使用iWriter，后期从设置中读取。
    var creation: Int                    // 创建时间，时间戮。
    var saved: Bool                      // 是否被保存。
    var chapterEditingId: Int              // 正编辑的创建时间。
    var chapterSelection: Chapter        // 被选中的。
    var chapterOpened: [Chapter]         // 打开了的，不作序列化。
    
    init() {
        self.file = ""
        self.title = ""
        self.info = ""
        self.author = ""
        self.version = ""
        self.creation = 0
        self.saved = false
        self.chapterEditingId = 0
        self.chapterSelection = Chapter()
        self.chapterOpened = [Chapter]()
    }
    
    /// 使用字典进行初始化。
    init(dictionary: [String : Any]) {
        self.file = dictionary["file"] as? String ?? ""
        self.title = dictionary["title"] as? String ?? ""
        self.info = dictionary["info"] as? String ?? ""
        self.author = dictionary["author"] as? String ?? ""
        self.version = dictionary["version"] as? String ?? ""
        self.creation = dictionary["creation"] as? Int ?? 0
        self.saved = dictionary["saved"] as? Bool ?? false
        self.chapterEditingId = dictionary["chapterEditing"] as? Int ?? 0
        self.chapterSelection = Chapter(dictionary: dictionary["chapterSelection"] as! [String : Any])
        self.chapterOpened = [Chapter]()
    }
    
    /// 转为字典。
    /// - returns: 字典。
    func forDictionary()->Dictionary<String, Any> {
        var dic:Dictionary<String, Any> = [:]
        
        dic["file"] = self.file
        dic["title"] = self.title
        dic["info"] = self.info
        dic["author"] = self.author
        dic["version"] = self.version
        dic["creation"] = self.creation
        dic["saved"] = self.saved
        dic["chapterEditing"] = self.chapterEditingId
        dic["chapterSelection"] = self.chapterSelection.forDictionary()
        return dic
    }
}
