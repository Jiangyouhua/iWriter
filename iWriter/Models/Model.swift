//
//  Model.swift
//  iWriter
//
//  Created by 姜友华 on 2020/11/6.
//  Copyright © 2020 Jiangyouhua. All rights reserved.
//

import Foundation

// Model 继承于Node类，将Chapter, Note, Role, Symbol的共同属性抽取出来。
class Model: Node {
    var naming: Bool
    var status: Bool
    var expanded: Bool
    
    init(id: Int = 0, value: String = "", naming: Bool = true, status: Bool = true, expanded: Bool = false) {
        self.naming = naming
        self.status = status
        self.expanded = expanded
        super.init(id: id, value: value)
    }
    
    /// 使用字典进行初始化。
    required init(dictionary: [String : Any]) {
        self.expanded = dictionary["expanded"] as? Bool ?? false
        self.naming = dictionary["naming"] as? Bool ?? false
        self.status = dictionary["status"] as? Bool ?? false
        super.init(dictionary: dictionary)
    }
    
    /// 转为字典。
    /// - returns: 字典。
    override func toDictionary() -> Dictionary<String, Any> {
        var dic:Dictionary<String, Any> = super.toDictionary()
        dic["expanded"] = self.expanded
        dic["naming"] = self.naming
        dic["status"] = self.status
        return dic
    }
}
