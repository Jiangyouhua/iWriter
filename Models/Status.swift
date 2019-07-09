//
//  Status.swift
//  iWriter
//
//  Created by Jiangyouhua on 2019/7/9.
//  Copyright © 2019 Jiangyouhua. All rights reserved.
//

import Foundation
import CommonCrypto

/**
 ## Works Data Status
 作品数据状态
 1. 为Info、Catalog、Role、Symbol保存最近的MD5值；
 2. 判断新的MD5值与原值是否相同，不同表示数据有更新，需要保存；
 3. 提供Data的MD5方法。
 */
struct Status {
    private var infoCode: String
    private var catalogCode: String
    private var roleCode: String
    private var symbolCode: String
    
    init(){
        infoCode = ""
        catalogCode = ""
        roleCode = ""
        symbolCode = ""
    }
    
    /// MD5
    func md5(data: Data) -> String{
        let hash = data.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) -> [UInt8] in
            var hash = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
            CC_MD5(bytes.baseAddress, CC_LONG(data.count), &hash)
            return hash
        }
        return hash.map { String(format: "%02x", $0) }.joined()
    }
    
    /// 判断Info数据是否需要保存
    mutating func isSave(info: Data) -> Bool {
        let m = md5(data: info)
        if m == infoCode {
            return false
        }
        infoCode = m
        return true
    }
    
    /// 判断Catalog数据是否需要保存
    mutating func isSave(catalog: Data) -> Bool {
        let m = md5(data: catalog)
        if m == catalogCode {
            return false
        }
        catalogCode = m
        return true
    }
    
    /// 判断Role数据是否需要保存
    mutating func isSave(role: Data) -> Bool {
        let m = md5(data: role)
        if m == roleCode {
            return false
        }
        roleCode = m
        return true
    }
    
    /// 判断Symbol数据是否需要保存
    mutating func isSave(symbol: Data) -> Bool {
        let m = md5(data: symbol)
        if m == symbolCode {
            return false
        }
        symbolCode = m
        return true
    }
}
