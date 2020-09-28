//
//  Annotation.swift
//  iWriter
//
//  Created by 姜友华 on 2020/4/25.
//  Copyright © 2020 Jiangyouhua. All rights reserved.
//

import Foundation

// 批注，允许同一选择文本有多条批注。
struct Annotation: FileDelegate {
    var content: String           // 内容。
    var creation: Int             // 创建时间。
    var status: Bool              // 是否有效，无效时开启编辑状态。
    
    init() {
        self.content = ""
        self.creation = 0
        self.status = true
    }
    
    init(dictionary: [String : Any]) {
        self.content = dictionary["content"] as? String ?? ""
        self.creation = dictionary["creation"] as? Int ?? 0
        self.status = dictionary["status"] as? Bool ?? false
    }
    
    func forDictionary() -> Dictionary<String, Any> {
        var dic:Dictionary<String, Any> = [:]
        
        dic["content"] = self.content
        dic["creation"] = self.creation
        dic["status"] = self.status
        return dic
    }
}
