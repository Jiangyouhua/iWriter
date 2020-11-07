//
//  Model.swift
//  iWriter
//
//  Created by 姜友华 on 2020/11/6.
//  Copyright © 2020 Jiangyouhua. All rights reserved.
//

import Cocoa

class Model: ModelDelegate {
    var content: String
    var parent: Model?                              // 父节点。
    var children: [Model] = []                      // 章节的层级。
    var creation: Int
    var naming: Bool
    var status: Bool
    var expanded: Bool
    
    init() {
        self.content = ""
        self.creation = creationTime()
        self.naming = true
        self.status = true
        self.expanded = false
    }
    
    /// 使用字典进行初始化。
    required init(dictionary: [String : Any]) {
        self.content = dictionary["content"] as? String ?? ""
        self.creation = dictionary["creation"] as? Int ?? 0
        self.expanded = dictionary["expanded"] as? Bool ?? false
        self.naming = dictionary["naming"] as? Bool ?? false
        self.status = dictionary["status"] as? Bool ?? false
    }
    
    /// 转为字典。
    /// - returns: 字典。
    func toDictionary() -> Dictionary<String, Any> {
        var dic:Dictionary<String, Any> = [:]
        dic["content"] = self.content
        dic["children"] = [Any]()
        dic["creation"] = self.creation
        dic["expanded"] = self.expanded
        dic["naming"] = self.naming
        dic["status"] = self.status
        return dic
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
        return i
    }
    
    /// 在你级的位置。
    func indexArray(_ nodes: [Model]) -> Int? {
        guard let i = nodes.firstIndex(where:
                {$0.creation == self.creation}) else {
                return nil
        }
        return i
    }
    
    /// 删除自身。
    func removeFromArray(_ nodes: inout [Model]) -> Int? {
        // 从自身的父节点中移除自己。
        guard let i = indexArray(nodes) else {
            return nil
        }
        nodes.remove(at: i)
        return i
    }
    
    func initChilden() -> Model? {
        return nil
    }
}
