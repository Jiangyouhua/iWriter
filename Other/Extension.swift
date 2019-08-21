//
//  Extension.swift
//  iWriter
//
//  Created by Jiangyouhua on 2019/7/21.
//  Copyright © 2019 Jiangyouhua. All rights reserved.
//

import Cocoa

/**
 ## 文件路径字符串处理。
 */
extension String {
    /// 获取文件路径中的文件名。
    func fileName() -> String {
       return ((self as NSString).lastPathComponent as NSString).deletingPathExtension
    }
    /// 获取文件路径中的目录。
    func fileDir() -> String {
        return (self as NSString).deletingLastPathComponent
    }
}
