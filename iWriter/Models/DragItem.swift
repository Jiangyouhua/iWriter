//
//  DragItem.swift
//  iWriter
//
//  Created by 姜友华 on 2020/3/14.
//  Copyright © 2020 Jiangyouhua. All rights reserved.
//

import Cocoa

class DragItem: NSObject {
    var at: Int = -1          // 在父项的位置。
    var inParent: Any? = nil  // 父项。
}
