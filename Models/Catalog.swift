//
//  Catalog.swift
//  iWriter
//
//  Created by Jiangyouhua on 2019/7/9.
//  Copyright © 2019 Jiangyouhua. All rights reserved.
//

import Foundation

/**
 ## Works Catalog
    作品目录，使用时确定顺序按层级递进
 1. 支持subscript，方便与Dictionary转换
 2. 提供forDictionary方法，支持转换为Dictionary
 */
struct Catalog: WorksDelegate {
    
    var level: Int                       // 章节的层级
    var title: String                    // 章节标题
    var info: String                     // 章节信息，概述
    var creation: Int                    // 创建时间，时间戮
    var number: Int                      // 章节字数
    
    init() {
        self.level = 0
        self.title = ""
        self.info = ""
        self.creation = 0
        self.number = 0
    }
    
    subscript(key:String)->Any?{
        get{
            switch key {
            case "level":
                return self.level
            case "title":
                return self.title
            case "info":
                return self.info
            case "creation":
                return self.creation
            case "number":
                return self.number
            default:
                return nil
            }
        }
        set{
            switch key {
            case "level":
                self.level = newValue as? Int ?? 0
            case "title":
                self.title = newValue as? String ?? ""
            case "info":
                self.info = newValue as? String ?? ""
            case "creation":
                self.creation = newValue as? Int  ?? 0
            case "number":
                self.number = newValue as? Int  ?? 0
            default:
                return
            }
        }
    }
    
    /// 转为字典
    /// - returns: 字典
    func forDictionary()->Dictionary<String, Any>{
        var dic:Dictionary<String, Any> = [:]
        dic["level"] = self.level
        dic["title"] = self.title
        dic["info"] = self.info
        dic["creation"] = self.creation
        dic["number"] = self.number
        return dic
    }
}
