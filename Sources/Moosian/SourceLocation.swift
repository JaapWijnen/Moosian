//
//  SourceLocation.swift
//  Moosian
//
//  Created by Jaap Wijnen on 27/06/2017.
//

import Foundation

struct SourceLocation: CustomStringConvertible {
    let filePath: String?
    var line: Int
    var column: Int
    var charOffset: Int
    
    var description: String {
        let basename: String
        if let filePath = filePath {
            basename = URL(fileURLWithPath: filePath).lastPathComponent
        } else {
            basename = "unknown"
        }
        return "\(basename):\(line):\(column)"
    }
    
    init(line: Int, column: Int, filePath: String? = nil, charOffset: Int = 0) {
        self.filePath = filePath
        self.line = line
        self.column = column
        self.charOffset = charOffset
    }
    
    static let zero = SourceLocation(line: 0, column: 0)
}

extension SourceLocation: Equatable, Comparable {
    static func ==(lhs: SourceLocation, rhs: SourceLocation) -> Bool {
        if lhs.charOffset == rhs.charOffset { return true }
        return lhs.line == rhs.line && lhs.column == rhs.column
    }
    
    static func <(lhs: SourceLocation, rhs: SourceLocation) -> Bool {
        if lhs.charOffset < rhs.charOffset { return true }
        if lhs.line < rhs.line { return true }
        return lhs.column < rhs.column
    }
}

struct SourceRange {
    let start: SourceLocation
    let end: SourceLocation
    
    static let zero = SourceRange(start: .zero, end: .zero)
}

extension SourceRange: Equatable {
    static func ==(lhs: SourceRange, rhs: SourceRange) -> Bool {
        return lhs.start == rhs.start && lhs.end == rhs.end
    }
}
