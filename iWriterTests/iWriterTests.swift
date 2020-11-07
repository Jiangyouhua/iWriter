//
//  iWriterTests.swift
//  iWriterTests
//
//  Created by Jiangyouhua on 2019/7/9.
//  Copyright © 2019 Jiangyouhua. All rights reserved.
//

import XCTest
@testable import iWriter

class iWriterTests: XCTestCase {
    
    var works: Works!
    var recent: Recent!
    var folder: String!
    
    override func setUp() {
        works = Works()
        recent = Recent()
        folder = "/Users/jiangyouhua/Downloads"
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    /// 测试Info数据模型
    func testInfo(){
        //  未赋值
        var info = Info()
        
        // 判断是否符合预期
        XCTAssertEqual(info.pathToFile, "")
        XCTAssertEqual(info.version, "")
        XCTAssertEqual(info.creation, 0)
        XCTAssertTrue(info.contentTitleOnBar.isEmpty)
        XCTAssertTrue(info.currentContent == nil)
        
        // 赋值
        info.pathToFile = "/User/jiangyouhau/work/Sinlge Men.iw"
        info.version = "Jiang Youhua"
        info.creation = 123456
        info.contentTitleOnBar = [Chapter()]
        info.currentContent = Chapter()
        info.other["key"] = "value"
        
        // 转Dictionary
        let dic = info.forDictionary()
        
        // 转Info
        var temp = Info()
        for (key, value) in dic {
            // 使用Subscript赋值
            temp[key] = value
        }
        
        // 判断是否符合预期
        XCTAssertEqual(info.pathToFile, temp.pathToFile)
        XCTAssertEqual(info.version, temp.version)
        XCTAssertEqual(info.creation, temp.creation)
        XCTAssertEqual(info.contentTitleOnBar[0].creation, temp.contentTitleOnBar[0].creation)
        XCTAssertEqual(info.currentContent?.creation, temp.currentContent?.creation)
        XCTAssertEqual(info["key"] as! String, temp["key"] as! String)
        
        // 脏数据
        info["file"] = true
        info["author"] = 0
        info["creation"] = "2019.04.16"
        info["chaptersOnBar"] = "1, 2, 3"
        info["currentChapter"] = "第一章"
        info["key"] = 123456
        
        // 判断是否符合预期
        XCTAssertEqual(info.pathToFile, "")
        XCTAssertEqual(info.version, "")
        XCTAssertEqual(info.creation, 0)
        XCTAssertTrue(info.contentTitleOnBar.isEmpty)
        XCTAssertTrue(info.currentContent == nil)
        XCTAssertEqual(info["key"] as! Int, 123456)
    }
    
    /// 测试Catalog数据模型
    func testCatalog(){
        //  未赋值
        let catalog = Chapter()
        
        // 判断是否符合预期
        XCTAssertEqual(catalog.level, 0)
        XCTAssertEqual(catalog.title, "")
        XCTAssertEqual(catalog.info, "")
        XCTAssertEqual(catalog.creation, 0)
        XCTAssertEqual(catalog.count, 0)
        
        
        // 赋值
        catalog.level = 1
        catalog.title = "Chapter 1"
        catalog.info = "Chapter Info"
        catalog.creation = 123456
        catalog.count = 3650
        
        // 转Dictionary
        let dic = catalog.toDictionary()
        
        // 转Info
        let temp = Chapter()
        for (key, value) in dic {
            // 使用Subscript赋值
            temp[key] = value
        }
        
        // 判断是否符合预期
        XCTAssertEqual(catalog.level, temp.level)
        XCTAssertEqual(catalog.title, temp.title)
        XCTAssertEqual(catalog.info, temp.info)
        XCTAssertEqual(catalog.creation, temp.creation)
        XCTAssertEqual(catalog.count, temp.count)
        
        // 脏数据
        catalog["level"] = "0"
        catalog["title"] = true
        catalog["info"] = 0
        catalog["creation"] = "2019.04.16"
        catalog["number"] = "1, 2, 3"
        
        // 判断是否符合预期
        XCTAssertEqual(catalog.level, 0)
        XCTAssertEqual(catalog.title, "")
        XCTAssertEqual(catalog.info, "")
        XCTAssertEqual(catalog.creation, 0)
        XCTAssertEqual(catalog.count, 0)
    }
    
    // 判断Catalog索引与转换
    func testCatalogOther(){
        let root = Chapter()
        root.title = "Single Man"
        root.creation = works.creationTime()
        
        let chapter1 = Chapter()
        chapter1.title = "Chapter 1"
        root.creation = works.creationTime()
        root.children.append(chapter1)
        
        let chapter2 = Chapter()
        chapter2.title = "Chapter 2"
        root.creation =  works.creationTime()
        root.children.append(chapter2)
        
        let section1_1 = Chapter()
        section1_1.title = "Section 1.1"
        section1_1.creation = works.creationTime()
        chapter1.children.append(section1_1)
        
        let section1_2 = Chapter()
        section1_2.title = "Section 1.2"
        section1_2.creation = works.creationTime()
        chapter1.children.append(section1_2)
        
        let section2_1 = Chapter()
        section2_1.title = "Section 2.1"
        section2_1.creation = works.creationTime()
        chapter2.children.append(section2_1)
        
        let section2_2 = Chapter()
        section2_2.title = "Section 2.2"
        section2_2.creation = works.creationTime()
        chapter2.children.append(section2_2)
    }
    
    /// 测试Role数据模型
    func testRole(){
        //  未赋值
        var role = Role()
        
        // 判断是否符合预期
        XCTAssertEqual(role.content, "")
        XCTAssertEqual(role.info, "")
        XCTAssertEqual(role.creation, 0)
        
        // 赋值
        role.content = "Role 1"
        role.info = "Role Info"
        role.creation = 123456
        
        // 转Dictionary
        let dic = role.forDictionary()
        
        // 转Info
        var temp = Role()
        for (key, value) in dic {
            // 使用Subscript赋值
            temp[key] = value
        }
        
        // 判断是否符合预期
        XCTAssertEqual(role.content, temp.content)
        XCTAssertEqual(role.info, temp.info)
        XCTAssertEqual(role.creation, temp.creation)
        
        // 脏数据
        role["name"] = true
        role["info"] = 0
        role["creation"] = "2019.04.16"
        
        // 判断是否符合预期
        XCTAssertEqual(role.content, "")
        XCTAssertEqual(role.info, "")
        XCTAssertEqual(role.creation, 0)
    }
    
    /// 测试Symbol数据模型
    func testSymbol(){
        //  未赋值
        var symbol = Symbol()
        
        // 判断是否符合预期
        XCTAssertEqual(symbol.content, "")
        XCTAssertEqual(symbol.info, "")
        XCTAssertEqual(symbol.creation, 0)
        
        // 赋值
        symbol.content = "Symbol title"
        symbol.info = "Symbol Info"
        symbol.creation = 123456
        
        // 转Dictionary
        let dic = symbol.forDictionary()
        
        // 转Info
        var temp = Symbol()
        for (key, value) in dic {
            // 使用Subscript赋值
            temp[key] = value
        }
        
        // 判断是否符合预期
        XCTAssertEqual(symbol.content, temp.content)
        XCTAssertEqual(symbol.info, temp.info)
        XCTAssertEqual(symbol.creation, temp.creation)
        
        // 脏数据
        symbol["name"] = true
        symbol["info"] = 0
        symbol["creation"] = "2019.04.16"
        
        // 判断是否符合预期
        XCTAssertEqual(symbol.content, "")
        XCTAssertEqual(symbol.info, "")
        XCTAssertEqual(symbol.creation, 0)
    }
    
    /// 测试Satus数据模型
    func testStatus(){
        var status = Status()
        let md5 = status.md5(data: "Jiang Youhua".data(using: .utf8)!)
        XCTAssertEqual(md5, "5118b4139073c2b71bbb8a00b1f0f966")
        XCTAssertTrue(status.isSave(info: "info".data(using: .utf8)!))
        XCTAssertTrue(status.isSave(catalog: "catalog".data(using: .utf8)!))
        XCTAssertTrue(status.isSave(role: "role".data(using: .utf8)!))
        XCTAssertTrue(status.isSave(symbol: "symbol".data(using: .utf8)!))
    }
    
    /// 测试Works数据模型
    func testWorksForReadAndWrite(){
        // New File
        var file = folder + "/new_file.iw"
        try? works.newFile(path: file)
        XCTAssertTrue(works.fileManager.fileExists(atPath: file))
        XCTAssertTrue(works.fileManager.fileExists(atPath: works.infoFile))
        XCTAssertTrue(works.fileManager.fileExists(atPath: works.catalogFile))
        XCTAssertTrue(works.fileManager.fileExists(atPath: works.roleFile))
        XCTAssertTrue(works.fileManager.fileExists(atPath: works.symbolFile))
        
        // Save File
        let catalog = Chapter()
        catalog.title = "Chapter title"
        catalog.info = "Chapter info"
        catalog.creation = works.creationTime()
        works.catalogData.append(catalog)
        works.currentContentData = "Current Chapter Data"
        try? works.saveFile()
        let data = works.fileManager.contents(atPath: works.catalogFile)!
        let array = try! JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! [Any]
        let dic = array[0] as! [String: Any]
        XCTAssertEqual(catalog.info, dic["info"] as! String)
        XCTAssertTrue(works.fileManager.fileExists(atPath: "\(works.cache)/chapter\(catalog.creation).txt"))
        
        // Save As File
        file = folder + "/save_as_file.iw"
        try? works.saveAsFile(path: file)
        XCTAssertTrue(works.fileManager.fileExists(atPath: file))
        
        // Open File
        try? works.openFile(path: file)
        XCTAssertEqual(works.currentContentData, "Current Chapter Data")
        XCTAssertEqual(works.currentContentData.count, works.currentContent.count)
    }
    
    func testWorksWithCatalog(){
        
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
