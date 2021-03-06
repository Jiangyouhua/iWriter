//
//  Words.swift
//  iWriter
//
//  Created by 姜友华 on 2020/12/4.
//  Copyright © 2020 Jiangyouhua. All rights reserved.
//

import Foundation
import SQLite3

class Database {
    var items = [Node]()
    var db: OpaquePointer?
    
    init(){
        guard let path = Bundle.main.path(forResource: "foo", ofType: "db") else {
            return
        }
        guard sqlite3_open(path, &db) == SQLITE_OK else {
            sqlite3_close(db)
            db = nil
            return
        }
    }
    
    func find(text: String) -> [Node]? {
        if text.isEmpty || db == nil {
            return nil
        }
        items = [Node]()
        if text.count < 2 {
            guard let result = query("SELECT * FROM character WHERE word = '\(text)'") else {
                return nil
            }
            items.append(formatCharacter(result: result))
        }
        if text.count < 4 {
            guard let result = query("SELECT * FROM word WHERE word like '%\(text)%'") else {
                return nil
            }
            items.append(formatWord(result: result))
        }
        if text.count < 5 {
            guard let result = query("SELECT * FROM idiom WHERE word like '%\(text)%'") else {
                return nil
            }
            items.append(formatIdiom(result: result))
        }
        guard let result = query("SELECT * FROM allegorical WHERE answer like '%\(text)%'") else {
            return nil
        }
        items.append(formatAllegorical(result: result))
        
        return items
    }
    
    private func query(_ sql: String) -> OpaquePointer? {
        var stmt:OpaquePointer?
        guard sqlite3_prepare(db, sql, -1, &stmt, nil) == SQLITE_OK else {
            let err = String(cString: sqlite3_errmsg(db)!)
            fatalError("Sqlite3 query: \(err)")
        }
        return stmt
    }
    
    func formatCharacter(result: OpaquePointer) ->Node {
        let paraphrase = Node()
        paraphrase.value = "字"
        while (sqlite3_step(result) == SQLITE_ROW) {
            let id = sqlite3_column_int(result, 0)
//            let word = String(cString: sqlite3_column_text(result, 1))
//            let alias = String(cString: sqlite3_column_text(result, 2))
//            let strokes = String(cString: sqlite3_column_text(result, 3))
//            let pinyin = String(cString: sqlite3_column_text(result, 4))
//            let radicals = String(cString: sqlite3_column_text(result, 5))
            let explanation = String(cString: sqlite3_column_text(result, 6))
            let more = String(cString: sqlite3_column_text(result, 7))
            let item = Node(id: Int(id), value: String(format: "%@\n%@", explanation, more))
            paraphrase.children.append(item)
        }
        return paraphrase
    }
    
    func formatWord(result: OpaquePointer) ->Node {
        let paraphrase = Node(value: "词")
        while (sqlite3_step(result) == SQLITE_ROW) {
            let id = sqlite3_column_int(result, 0)
            let word = String(cString: sqlite3_column_text(result, 1))
            let explanation = String(cString: sqlite3_column_text(result, 2))
            let item = Node(id: Int(id), value: String(format: "%@：%@", word, explanation))
            paraphrase.children.append(item)
        }
        return paraphrase
    }
    
    func formatIdiom(result: OpaquePointer) -> Node {
        let paraphrase = Node(value: "成语")
        while (sqlite3_step(result) == SQLITE_ROW) {
            let id = sqlite3_column_int(result, 0)
            let word = String(cString: sqlite3_column_text(result, 1))
//            let pinyin = String(cString: sqlite3_column_text(result, 2))
            let example = String(cString: sqlite3_column_text(result, 3))
            let explanation = String(cString: sqlite3_column_text(result, 4))
            let derivation = String(cString: sqlite3_column_text(result, 5))
            let abbreviation = String(cString: sqlite3_column_text(result, 6))
            let item = Node(id: Int(id), value: String(format: "%@：%@\n%@\n%@\n%@", word, example, explanation, derivation, abbreviation))
            paraphrase.children.append(item)
        }
        return paraphrase
    }
    
    func formatAllegorical(result: OpaquePointer) -> Node {
        let paraphrase = Node(value: "歇后语")
        while (sqlite3_step(result) == SQLITE_ROW) {
            let id = sqlite3_column_int(result, 0)
            let riddle = String(cString: sqlite3_column_text(result, 1))
            let answer = String(cString: sqlite3_column_text(result, 2))
            let item = Node(id: Int(id), value: String(format: "%@——%@", riddle, answer))
            paraphrase.children.append(item)
        }
        return paraphrase
    }
}
