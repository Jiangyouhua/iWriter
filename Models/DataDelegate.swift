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
protocol DataDelegate {
    func forDictionary() -> Dictionary<String, Any>
}
