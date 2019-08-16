//
//  Info.swift
//  iWriter
//
//  Created by Jiangyouhua on 2019/7/9.
//  Copyright © 2019 Jiangyouhua. All rights reserved.
//

import Foundation

/**
 ## Works Info。
    作品信息。
 1. 支持subscript，方便与Dictionary转换；
 2. 提供forDictionary方法，支持转换为Dictionary。
 */
struct Info: DataDelegate {
    
    var file: String                    // 作品名称，含路径。
    var author: String                  // 作者，前期使用iwriter，后期从设置中读取。
    var creation: Int                   // 创建时间，时间戮。
    var contentTitleOnBar: [Catalog]        // 在章节标题栏上的章节。
    var currentContent: Catalog?        // 当前编辑的章节。
    var isTemp: Bool                    // 退出前未保存。
    var other:Dictionary<String, Any>
    
    init() {
        self.file = ""
        self.author = ""
        self.creation = 0
        self.contentTitleOnBar = [Catalog]()
        self.isTemp = true
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
                return self.contentTitleOnBar
            case "currentChapter":
                return self.currentContent
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
                self.contentTitleOnBar = newValue as? [Catalog]  ?? [Catalog]()
            case "currentChapter":
                self.currentContent = newValue as? Catalog ?? nil
            default:
                self.other[key] = newValue
            }
        }
    }
    
    /// 转为字典。
    /// - returns: 字典。
    func forDictionary()->Dictionary<String, Any>{
        var dic:Dictionary<String, Any> = [:]
        dic["file"] = self.file
        dic["author"] = self.author
        dic["creation"] = self.creation
        var array = [Any]()
        for catalog in contentTitleOnBar {
            array.append(catalog.forDictionary())
        }
        dic["chaptersOnBar"] = array
        dic["currentChapter"] = self.currentContent?.forDictionary()
        for (key, value) in self.other {
            dic[key] = value
        }
        return dic
    }
}
