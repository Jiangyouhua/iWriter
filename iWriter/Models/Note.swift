//
//  Note.swift
//  iWriter
//
//  Created by 姜友华 on 2020/4/25.
//  Copyright © 2020 Jiangyouhua. All rights reserved.
//

import Foundation

// 便条。
class Note: Model {
    var checked: Bool             // 是否检查。
    
    override init() {
        self.checked = false
        super.init()
    }
    
    required init(dictionary: [String : Any]) {
        self.checked = dictionary["check"] as? Bool ?? false
        // 父类的。
        super.init(dictionary: dictionary)
        modelsFromDictionary(object: dictionary["children"], node: self)
    }
    
    override func toDictionary() -> Dictionary<String, Any> {
        // 父类的。
        var dic = super.toDictionary()
        dic["children"] = modelsToDictionary(array: self.children)
        
        dic["check"] = self.checked
        return dic
    }
}
