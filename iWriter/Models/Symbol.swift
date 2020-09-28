//
//  Symbol.swift
//  iWriter
//
//  Created by Jiangyouhua on 2019/7/9.
//  Copyright © 2019 Jiangyouhua. All rights reserved.
//

import Foundation

/**
 ## Works Role。
   作品符号，作品中的常用对象，如：降龙十八掌、天机处等。
 */
struct Symbol: FileDelegate {
    
    var name: String                     // 符号名称。
    var info: String                     // 符号信息。
    var creation: Int                    // 创建时间，时间戮。
    var status: Bool                     // 是否有效，无效时开启编辑状态。
    
    init() {
        self.name = ""
        self.info = ""
        self.creation = 0
        self.status = true
    }
    
    /// 使用字典进行初始化。
    init(dictionary: [String : Any]) {
        self.name = dictionary["name"] as? String ?? ""
        self.info = dictionary["info"] as? String ?? ""
        self.creation = dictionary["creation"] as? Int ?? 0
        self.status = dictionary["status"] as? Bool ?? false
    }
    
    /// 转为字典。
    /// - returns: 字典。
    func forDictionary()->Dictionary<String, Any>{
        var dic:Dictionary<String, Any> = [:]
        
        dic["name"] = self.name
        dic["info"] = self.info
        dic["creation"] = self.creation
        dic["status"] = self.status
        return dic
    }
}
