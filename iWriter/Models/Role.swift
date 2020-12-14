//
//  Role.swift
//  iWriter
//
//  Created by Jiangyouhua on 2019/7/9.
//  Copyright © 2019 Jiangyouhua. All rights reserved.
//

import Foundation

/**
 ## Works Role。
    作品角色，通过标签注释角色信息。
 */
class Role: Model {
    
    var gender: String                     // 角色出现的次数。
    
    init(id: Int = 0, value: String = "", naming: Bool = true, status: Bool = true, expanded: Bool = false, gender: String = "") {
        self.gender = gender
        super.init(id: id, value: value, naming: naming, status: status, expanded: expanded)
    }
    
    /// 使用字典进行初始化。
    required init(dictionary: [String : Any]) {
        self.gender = dictionary["gender"] as? String ?? ""
        // 父类的。
        super.init(dictionary: dictionary)
        modelsFromDictionary(object: dictionary["children"], node: self)
    }
    
    /// 转为字典。
    /// - returns: 字典。
    override func toDictionary()->Dictionary<String, Any>{
        // 父类的。
        var dic = super.toDictionary()
        dic["children"] = modelsToDictionary(array: self.children)
        
        dic["gender"] = self.gender
        return dic
    }
}

