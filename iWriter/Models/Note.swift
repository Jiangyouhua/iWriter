//
//  Note.swift
//  iWriter
//
//  Created by 姜友华 on 2020/4/25.
//  Copyright © 2020 Jiangyouhua. All rights reserved.
//

import Foundation

// 便条。
struct Note: FileDelegate {
    var content: String         // 备注内容。
    var check: Bool             // 是否检查。
    var creation: Int           // 创建时间。
    var status: Bool            // 是否有效，无效时开启编辑状态。
    
    init() {
        self.content = ""
        self.check = false
        self.creation = 0
        self.status = true
    }
    
    init(dictionary: [String : Any]) {
        self.content = dictionary["content"] as? String ?? ""
        self.check = dictionary["status"] as? Bool ?? false
        self.creation = dictionary["creation"] as? Int ?? 0
        self.status = dictionary["status"] as? Bool ?? false
    }
    
    func forDictionary() -> Dictionary<String, Any> {
        var dic:Dictionary<String, Any> = [:]
        
        dic["content"] = self.content
        dic["check"] = self.check
        dic["creation"] = self.creation
        dic["status"] = self.status
        return dic
    }
}
