//
//  WorksDelegate.swift
//  iWriter
//
//  Created by Jiangyouhua on 2019/7/9.
//  Copyright © 2019 Jiangyouhua. All rights reserved.
//

import Foundation

/**
 ## 作品数据协议，用多态进行同一处理。
 */
protocol FileDelegate {
    // 使用字典初始化。
    init(dictionary:[String: Any])
    // 转化为字典。
    func forDictionary() -> Dictionary<String, Any>
}
