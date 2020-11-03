//
//  Cache.swift
//  iWriter
//
//  Created by 姜友华 on 2020/4/21.
//  Copyright © 2020 Jiangyouhua. All rights reserved.
//

import Cocoa

class Cache: NSObject {
    let defaults = UserDefaults.standard
    
    // 最近打开的文件，是文件名组成的数组。
    func addOpenedFile(file: String) {
        let key = "openedFiles"
        guard var array = deleteOpenedFile(file: file) else {
            return defaults.set([file], forKey: key)
        }
        // 不允许超过用户设置的数量。
        if array.count >= getOpenedFilesCount() {
            array.removeLast()
        }
        // 插入。
        array.insert(file, at: 0)
        defaults.set(array, forKey: key)
    }
    
    func getOpenedFiles() -> [String]? {
        let key = "openedFiles"
        guard let array = defaults.array(forKey: key) as? [String] else {
            return nil
        }
        return array
    }
    
    func deleteOpenedFile(file: String) -> [String]? {
        let key = "openedFiles"
        guard var array = getOpenedFiles() else {
            return nil
        }
        guard let index = array.firstIndex(of: file) else {
            return array
        }
        array.remove(at: index)
        defaults.set(array, forKey: key)
        return array
    }
    
    func clearOpenedFiles() {
        let key = "openedFiles"
        defaults.set(nil, forKey: key)
    }
    
    // 最近打开文件的阈值。
    func setOpenedFilesCount(count: Int = 0){
        let key = "openedFilesCount"
        defaults.set(count, forKey: key)
    }
    
    func getOpenedFilesCount() -> Int {
        let key = "openedFilesCount"
        var i = defaults.integer(forKey: key)
        if i < 1 {
            i = 1
        }
        return i
    }
    
    // 每天输入字的阈值。
    func setDailyInputWordsCount(count: Int) {
        let key = "dailyInputWordsCount"
        // 保存。
        defaults.set(count, forKey: key)
    }
    
    func getDailyInputWordsCount() -> Int {
        let key = "dailyInputWordsCount"
        var i = defaults.integer(forKey: key)
        if i < 20 {
            i = 20
        }
        return i
    }
    
    // 笔名。
    func setPseudonym(name: String) {
        let key = "pseudonym"
        // 保存。
        defaults.set(name, forKey: key)
    }
    
    func getPseudonym() -> String {
        let key = "pseudonym"
        // 保存。
        guard let s = defaults.string(forKey: key) else {
            return  "iWriter"
        }
        if s.isEmpty {
            return  "iWriter"
        }
        return s
    }
    
    /// 沙盒外权限保存，缓存bookmarkData。
    func saveBookmark(path: String){
        let url = URL.init(fileURLWithPath: path)
        guard let bookmarkData = try? url.bookmarkData(options: URL.BookmarkCreationOptions.withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil) else {
            return
        }
        defaults.set(bookmarkData, forKey: path)
    }
    
    /// 沙盒外权限获取， 从bookmarkData获取Url。
    func urlBookmark(path: String) -> NSURL? {
        guard let bookmarkData = defaults.data(forKey: path) else {
            return nil
        }
        
        return try? NSURL.init(resolvingBookmarkData: bookmarkData, options: [NSURL.BookmarkResolutionOptions.withSecurityScope, NSURL.BookmarkResolutionOptions.withoutUI], relativeTo: nil, bookmarkDataIsStale: nil)
    }
    
    // MARK: 缓存布局。
    /**
     *  1. 各区块都有两个属性。
     *  2. 该区域是否关闭。
     *  3. 该区块是如何分割。
     */
    /// 保存分割视图各图的位置。
    func getPositionWithSplitView(position: SplitLine) -> CGFloat {
        // 返回默认值。
        let key = "positionOfSplitView\(position)"
        var value: CGFloat? = defaults.value(forKey: key) as? CGFloat
        if value == nil {
            value = defaultPositionWithSplitView(position: position)
        }
        return value!
    }
    
    func setPositionWithSplitView(position: SplitLine, value: CGFloat?) {
        let key = "positionOfSplitView\(position)"
        var v = value
        if value == nil {
            v = defaultPositionWithSplitView(position: position)
        }
        
        // 第一分割线直取，第二分割线求差值。
        defaults.set(v, forKey: key)
    }
    
    func defaultPositionWithSplitView(position: SplitLine) -> CGFloat {
        // 返回默认值。
        switch position {
        case .leftOfHorizontal:
            return minAreaWidth
        case .rightOfHorizontal:
            return windowSize.width - minAreaWidth
        case .leftTopOfVertical, .centerTopOfVertical, .rightTopOfVertical:
            return windowSize.height / 3
        case .leftBottomOfVertical, .centerBottomOfVertical, .rightBottomOfVertical:
            return windowSize.height / 3 * 2
        }
    }
    
    /// 获取各区块列表是否被隐藏的状态。
    func getStateWithBlock(block: AreaBlock) -> Bool {
        let key = "stateFromCache\(block)"
        return defaults.bool(forKey: key)
    }
    
    /// 保存各区块列表是否被隐藏的状态。
    func setStateWithBlock(block: AreaBlock, value: Bool) {
        let key = "stateFromCache\(block)"
        defaults.set(value, forKey: key)
    }
}
