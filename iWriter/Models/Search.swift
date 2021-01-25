//
//  Search.swift
//  iWriter
//
//  Created by 姜友华 on 2020/11/9.
//  Copyright © 2020 Jiangyouhua. All rights reserved.
//

import Cocoa

// 标志特定内容。
struct Mark {
    var paragraph: String                       // 段落文本。
    var paragraphRange: Range<String.Index>     // 在段落中的位置。
    var articleRange: Range<String.Index>       // 在全文中的位置。
}

// 实现全文索。
class Search {
    var word: String                            // 搜索的词。
    var chapter: Chapter                        // 搜索的范围。
    var marks: [Mark]                           // 搜索到的结果。
    
    init(word: String, chapter: Chapter) {
        self.word = word
        self.chapter = chapter
        self.marks = [Mark]()
        if chapter.leaf {
            marksFromArticle()
        }
    }
    
    private func marksFromArticle() {
        if chapter.article.isEmpty {
            return
        }
        // 分段。
        let paragraphs = chapter.article.components(separatedBy: CharacterSet(charactersIn: "\n"))
        // 逐个处理。
        var offset = 0
        paragraphs.forEach { pg in
            let ms = allIndex(paragraph: pg, offset: offset)
            offset += (pg.count + 1)
            self.marks.append(contentsOf: ms)
        }
    }

    // 查一段文本里的词。
    func allIndex(paragraph: String, offset:  Int) -> [Mark] {
        var indices = [Mark]()
        var paragraphStart = paragraph.startIndex

        while paragraphStart < paragraph.endIndex,
              let range = paragraph.range(of: self.word, range: paragraphStart..<paragraph.endIndex),
            !range.isEmpty
        {
            let lowerPosition = paragraph.distance(from: paragraph.startIndex, to: range.lowerBound)
            let upPosition = paragraph.distance(from: paragraph.startIndex, to: range.upperBound)
            let start = chapter.article.index(chapter.article.startIndex, offsetBy: lowerPosition + offset)
            let end = chapter.article.index(chapter.article.startIndex, offsetBy: upPosition + offset)

            let mark = Mark(
                paragraph: paragraph,
                paragraphRange: range,
                articleRange: start..<end)
            indices.append(mark)
            paragraphStart = range.upperBound
        }
        return indices
    }
}
