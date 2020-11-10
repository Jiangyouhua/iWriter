//
//  File.swift
//  iWriter
//
//  Created by 姜友华 on 2020/4/17.
//  Copyright © 2020 Jiangyouhua. All rights reserved.
//

import Cocoa

// MARK: 错误提醒信息。
let RIGHT_ERROR = "No Operating Rights"               // 没有权限。

// MARK: 缓存中一开始需要创建的默认文件。
let CACHE_PATH = NSHomeDirectory() + "/iWriter"       // 缓存目录。
let INFO_FILE = CACHE_PATH + "/info.txt"              // 保存文件头信息数据的文件地址，单一文件。
let OUTLINE_FILE = CACHE_PATH + "/outline.txt"        // 保存大纲数据的文件地址，第一个为目录，单一文件。
let NOTE_FILE = CACHE_PATH + "/note.txt"              // 保存便条数据的文件地址，单一文件。
let ROLE_FILE = CACHE_PATH + "/role.txt"              // 保存角色数据的文件地址，单一文件。
let SYMBOL_FILE = CACHE_PATH + "/symbol.txt"          // 保存符号数据的文件地址，单一文件。

// MARK: 布局相关。
var windowSize = NSApp.windows.first!.contentViewController!.view.frame.size
let iconWidth: CGFloat = 30                            // icon尺寸。
let minAreaWidth: CGFloat = 200                        // 区块有效宽，小于该宽度则隐藏。
let minBlockHeight: CGFloat = 120
let cache = Cache()

// MARK: 页面布局的定义。
/// 分割线。
enum SplitLine {
    case leftOfHorizontal
    case rightOfHorizontal
    case leftTopOfVertical
    case leftBottomOfVertical
    case centerTopOfVertical
    case centerBottomOfVertical
    case rightTopOfVertical
    case rightBottomOfVertical
}

/// 区块。
enum AreaBlock {
    case left
    case right
}

/// 是否为深色模式。
func isDarkMode() -> Bool {
    let style = UserDefaults.standard.string(forKey: "AppleInterfaceStyle")
    return style == "Dark"
}

// 字典数组转为结构数组。
func dictionaryToStructWith<T: ModelDelegate>(array: [Any]) -> [T] {
    var objects = [T]()
    array.forEach{ item in
        guard let object = item as? [String: Any] else {
            return
        }
        objects.append(T(dictionary: object))
    }
    return objects
}

// 结构数组转为字典数组。
func structToDictionaryWith<T: ModelDelegate>(array: [T]) -> [Any] {
    var maps = [Any]()
    array.forEach{ item in
        let map = item.toDictionary()
        maps.append(map)
    }
    return maps
}

// 字典数组转为结构数组。
func dictionaryToStructWith<T: ModelDelegate>(dic: [Int: Any]) -> [Int: T] {
    var objects: [Int: T] = [:]
    dic.forEach{ (key, value) in
        guard let object = value as? [String: Any] else {
            return
        }
        objects[key] = T(dictionary: object)
    }
    return objects
}

// 结构数组转为字典数组。
func structToDictionaryWith<T: ModelDelegate>(dic: [Int: T]) -> [Int: Any] {
    var maps:[Int: Any] = [:]
    dic.forEach{ (key, value) in
        let map = value.toDictionary()
        maps[key] = map
    }
    return maps
}

func modelsFromDictionary<T: Model>(object: Any?, node: T) {
    guard let array = object as? [Any] else {
        return
    }
    var models = [T]()
    array.forEach{ item in
        guard let dic = item as? [String: Any] else {
            return
        }
        let child = T(dictionary: dic)
        child.parent = node
        models.append(child)
    }
    node.children = models
}

func modelsToDictionary<T: Model>(array: [T]) -> [Any] {
    var a: [Any] = [Any]()
    array.forEach{ node in
        let d = node.toDictionary()
        a.append(d)
    }
    return a
}

/// 全局ID，以时间戳为基础。
func creationTime() -> Int {
    let now = Date()
    return Int(now.timeIntervalSince1970)
}

// 标题栏标签，普通状态时的背景色。深色模式时标题栏浅，反之则
func tabBackgroundColorOfNormalState() -> CGColor {
    // 0为黑，1为白。如果是深色，88%黑色；反之，88%白色
    return isDarkMode() ? CGColor(gray: 0.12, alpha: 1) : CGColor(gray: 0.88, alpha: 1)
}

// 标题栏标签，激活状态时的背景色。深色模式时标题栏黑，反之则白。
func tabBackgroundColorOfActiveState() -> CGColor {
    // 0为黑，1为白。如果是深色，100%白色；反之，90%黑色
    return isDarkMode() ? CGColor(gray: 0.085, alpha: 1) : CGColor(gray: 1, alpha: 1)
}

func tabBorderColor() -> CGColor {
    // 0为黑，1为白。如果是深色，95%黑色；反之，30%黑色
    return isDarkMode() ? CGColor(gray: 0, alpha: 1) : CGColor(gray: 0.7, alpha: 1)
}

func titleBackgroundColor() ->CGColor {
    // 0为黑，1为白。如果是深色，95%白色；反之，95%黑色
    return isDarkMode() ? CGColor(gray: 0.9, alpha: 1) : CGColor(gray: 0.1, alpha: 1)
}
