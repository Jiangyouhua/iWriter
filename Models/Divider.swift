//
//  Divider.swift
//  iWriter
//
//  Created by Jiangyouhua on 2019/7/14.
//  Copyright © 2019 Jiangyouhua. All rights reserved.
//

import Foundation

/**
 ## 提供分隔线数据的关键字
 */
struct Divider {
    static func leftRightSplitView(at : Int) -> String{
        return "leftRightSplitView\(at)"
    }
    static func leftAreaSplitView(at : Int) -> String{
        return "leftAreaSplitView\(at)"
    }
    static func centerAreaSplitView(at : Int) -> String{
        return "centerAreaSplitView\(at)"
    }
    static func rightAreaSplitView(at : Int) -> String{
        return "rightAreaSplitView\(at)"
    }
}
