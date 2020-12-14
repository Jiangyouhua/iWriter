//
//  Tree.swift
//  iWriter
//
//  Created by 姜友华 on 2020/12/9.
//  Copyright © 2020 Jiangyouhua. All rights reserved.
//

import Foundation

// Node 树状结构类。
class Node {
    var id: Int
    var value: String
    var parent: Node?               // 父节点。
    var children: [Node] = []       // 子节点集。
    
    /// 初始化。
    init(id: Int = 0, value: String = ""){
        self.id = id
        self.value = value
    }
    
    /// 使用字典进行初始化。
    required init(dictionary: [String : Any]) {
        self.value = dictionary["value"] as? String ?? ""
        self.id = dictionary["id"] as? Int ?? 0
    }
    
    /// 转为字典。
    /// - returns: 字典。
    func toDictionary() -> Dictionary<String, Any> {
        var dic:Dictionary<String, Any> = [:]
        dic["value"] = self.value
        dic["children"] = [Any]()
        dic["id"] = self.id
        return dic
    }
    
    /// 添加子节点。
    func add(child: Node) {
        children.append(child)
        child.parent = self
    }
    
    /// 插入子节点。
    func insert(child: Node, at: Int){
        children.insert(child, at: at)
        child.parent = self
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
    
    /// 在父级同中的位置。
    func indexParent() -> Int {
        guard let i = self.parent?.children.firstIndex(where:
                {$0.id == self.id}) else {
                return -1
        }
        return i
    }
    
    /// 在数组中的位置。
    func indexArray<T: Node>(_ nodes: [T]) -> Int {
        guard let i = nodes.firstIndex(where:
                {$0.id == self.id}) else {
                return -1
        }
        return i
    }
    
    /// 从父级中删除自身。
    func removeFromParent() -> Int{
        // 从自身的父节点中移除自己。
        let i = indexParent()
        self.parent?.children.remove(at: i)
        return i
    }
    
    /// 从数组中删除自身。
    func removeFromArray<T: Node>(_ nodes: inout [T]) -> Int {
        // 从自身的父节点中移除自己。
        let i = indexArray(nodes)
        nodes.remove(at: i)
        return i
    }
}
