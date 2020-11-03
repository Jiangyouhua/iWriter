//
//  Note.swift
//  iWriter
//
//  Created by 姜友华 on 2020/4/25.
//  Copyright © 2020 Jiangyouhua. All rights reserved.
//

import Foundation

// 便条。
class Note: FileDelegate {
    var content: String         // 备注内容。
    var parent: Note?           // 父节点。
    var children: [Note]        // 章节的层级。
    var expanded: Bool          // 节点是否为展开状态。
    var naming: Bool            // 节点是否为命名状态。
    var check: Bool             // 是否检查。
    var creation: Int           // 创建时间。
    var status: Bool            // 是否有效，无效时开启编辑状态。
    
    init() {
        self.content = ""
        self.children = [Note]()
        self.expanded = false
        self.check = false
        self.naming = false
        self.creation = 0
        self.status = true
    }
    
    required init(dictionary: [String : Any]) {
        self.content = dictionary["content"] as? String ?? ""
        self.children = [Note]()
        self.expanded = dictionary["expanded"] as? Bool ?? false
        self.check = dictionary["check"] as? Bool ?? false
        self.naming = dictionary["naming"] as? Bool ?? false
        self.creation = dictionary["creation"] as? Int ?? 0
        self.status = dictionary["status"] as? Bool ?? false
        // 递归处理children。
        self.children = childrenInit(object: dictionary["children"])
    }
    
    func childrenInit(object: Any?) -> [Note] {
        var notes = [Note]()
        guard let array = object as? [Any] else {
            return notes
        }
        array.forEach{ item in
            guard let dic = item as? [String: Any] else {
                return
            }
            let node = Note(dictionary: dic)
            node.parent = self
            notes.append(node)
        }
        return notes
    }
    
    func forDictionary() -> Dictionary<String, Any> {
        var dic:Dictionary<String, Any> = [:]
        
        dic["content"] = self.content
        dic["children"] = [Any]()
        dic["expanded"] = self.expanded
        dic["check"] = self.check
        dic["naming"] = self.naming
        dic["creation"] = self.creation
        dic["status"] = self.status
        // 递归处理children。
        dic["children"] = childrenDictionary()
        return dic
    }
    
    func childrenDictionary() -> [Any] {
        var a: [Any] = [Any]()
        self.children.forEach{ note in
            let d = note.forDictionary()
            a.append(d)
        }
        return a
    }
    
    /// 在你级的位置。
    func indexParent() -> Int {
        guard let i = self.parent?.children.firstIndex(where:
                {$0.creation == self.creation}) else {
                return -1
        }
        return i
    }
}
