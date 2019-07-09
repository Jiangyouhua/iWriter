//
//  Info.swift
//  iWriter
//
//  Created by Jiangyouhua on 2019/7/9.
//  Copyright © 2019 Jiangyouhua. All rights reserved.
//

import Foundation

/**
 ## Works Info
    作品信息
 1. 支持subscript，方便与Dictionary转换
 2. 提供forDictionary方法，支持转换为Dictionary
 */
struct Info: WorksDelegate {
    
    var file: String                    // 作品名
    var author: String                   // 作者，前期使用iwriter，后期从设置中读取
    var creation: Int                    // 创建时间，时间戮
    var chaptersOnBar: [Int]                  // 打开的章节，用 catalog->creation
    var currentChapter: Int              // 当前编辑的章节，用 catalog->creation
    var other:Dictionary<String, Any>
    
    init() {
        self.file = ""
        self.author = ""
        self.creation = 0
        self.chaptersOnBar = [Int]()
        self.currentChapter = 0
        self.other = [:]
    }
    
    subscript(key:String)->Any?{
        get{
            switch key {
            case "file":
                return self.file
            case "author":
                return self.author
            case "creation":
                return self.creation
            case "chaptersOnBar":
                return self.chaptersOnBar
            case "currentChapter":
                return self.currentChapter
            default:
                return self.other[key]
            }
        }
        set{
            switch key {
            case "file":
                self.file = newValue as? String ?? ""
            case "author":
                self.author = newValue as? String ?? ""
            case "creation":
                self.creation = newValue as? Int  ?? 0
            case "chaptersOnBar":
                self.chaptersOnBar = newValue as? [Int]  ?? [Int]()
            case "currentChapter":
                self.currentChapter = newValue as? Int  ?? 0
            default:
                self.other[key] = newValue
            }
        }
    }
    
    /// 转为字典
    /// - returns: 字典
    func forDictionary()->Dictionary<String, Any>{
        var dic:Dictionary<String, Any> = [:]
        dic["file"] = self.file
        dic["author"] = self.author
        dic["creation"] = self.creation
        dic["chaptersOnBar"] = self.chaptersOnBar
        dic["currentChapter"] = self.currentChapter
        for (key, value) in self.other {
            dic[key] = value
        }
        return dic
    }
}
