//
//  Lexer.swift
//  Moosian
//
//  Created by Jaap Wijnen on 21/06/2017.
//

import Foundation

struct Token {
    let type: TType
    let range: SourceRange
    
    enum TType: Equatable {
        case integer(value: Int64)
        case real(value: Double)
        case char(UInt8)
        case stringLiteral(String)
        case stringInterpolationLiteral([[Token]])
        case `operator`(BuiltinOperator)
        case identifier(String)
        
        case leftParen
        case rightParen
        case newline
        case semicolon
        case ellipsis
        
        case `var`
        
        case `if`
        case `else`
        
        case eof
        
        case unknown(String)
        
        init(op: String) {
            switch op {
            case ";": self = .semicolon
            case "\n": self = .newline
            case "(": self = .leftParen
            case ")": self = .rightParen
            case "...": self = .ellipsis
            case "": self = .eof
            default: self = .unknown(op)
            }
            self = .leftParen
        }
        
        init(identifier: String) {
            switch identifier {
            case "if": self = .if
            case "else": self = .else
            case "var": self = .var
                
            default: self = .identifier(identifier)
            }
        }
        
        static func ==(lhs: Token.TType, rhs: Token.TType) -> Bool {
            switch (lhs, rhs) {
            case (.integer(let v1), .integer(let v2)):
                return v1 == v2
            case (.real(let v1), .real(let v2)):
                return v1 == v2
            case (.char(let v1), .char(let v2)):
                return v1 == v2
            case (.stringLiteral(let v1), .stringLiteral(let v2)):
                return v1 == v2
            case (.operator(let v1), .operator(let v2)):
                return v1 == v2
            case (.identifier(let v1), .identifier(let v2)):
                return v1 == v2
            case (.leftParen, .leftParen):
                return true
            case (.rightParen, .rightParen):
                return true
            case (.newline, .newline):
                return true
            case (.semicolon, .semicolon):
                return true
            case (.ellipsis, .ellipsis):
                return true
            case (.var, .var):
                return true
            case (.if, .if):
                return true
            case (.else, .else):
                return true
            case (.eof, .eof):
                return true
            case (.unknown(let v1), .unknown(let v2)):
                return v1 == v2
            default:
                return false
            }
        }
        
    }
}

enum LexError: Error, CustomStringConvertible {
    case invalidCharacter(char: UnicodeScalar)
    case invalidCharacterLiteral(literal: String)
    case invalidEscape(escapeChar: UnicodeScalar)
    case unexpectedEOF
    
    var description: String {
        switch self {
        case .invalidCharacter(char: let char):
            return "invalid character \(char) in source file"
        case .invalidCharacterLiteral(let literal):
            return "invalid character literal '\(literal)' in source file"
        case .invalidEscape(let escapeChar):
            return "invalid character escape '\(escapeChar)'"
        case .unexpectedEOF:
            return "unexpected EOF"
        }
    }
}

struct Lexer {
    var sourceLocation: SourceLocation
    var tokenIndex = 0
    var characters = [UnicodeScalar]()
    
    func range(from start: SourceLocation) -> SourceRange {
        return SourceRange(start: start, end: sourceLocation)
    }
    
    init(filePath: String) throws {
        sourceLocation = SourceLocation(line: 1, column: 1, filePath: filePath)
        characters = try Array(String(contentsOfFile: filePath).unicodeScalars)
    }
    
    mutating func lex() throws -> [Token] {
        var tokens: [Token] = []
        
        while true {
            do {
                let token = try advanceToNextToken()
                if case .eof = token.type {
                    break
                }
                tokens.append(token)
            } catch {
                print(error)
            }
        }
        
        return tokens
    }
    
    func peek(ahead index: Int = 0) -> UnicodeScalar? {
        guard tokenIndex + index < characters.endIndex else { return nil }
        return characters[tokenIndex + index]
    }
    
    func peekString(length: Int) -> String {
        var str = ""
        for i in 0..<length {
            guard let c = peek(ahead: i) else { continue }
            str.append(String(c))
        }
        return str
    }
    
    mutating func advance(_ n: Int = 1) {
        guard let c = peek() else { return }
        for _ in 0..<n {
            if c == "\n" {
                sourceLocation.line += 1
                sourceLocation.column = 1
            } else {
                sourceLocation.column += 1
            }
            sourceLocation.charOffset += 1
            tokenIndex += 1
        }
    }
    
    mutating func advanceIf(_ f: (UnicodeScalar) -> Bool, perform: () -> Void = {}) -> Bool {
        guard let c = peek() else { return false }
        if f(c) {
            perform()
            advance()
            return true
        }
        return false
    }
    
    mutating func advanceWhile(_ f: (UnicodeScalar) -> Bool, perform: () -> Void = {}) {
        while advanceIf(f, perform: perform) {}
    }
    
    mutating func collectWhile(_ f: (UnicodeScalar) -> Bool) -> String {
        var s = ""
        advanceWhile(f) {
            guard let c = peek() else { return }
            s.append(String(c))
        }
        return s
    }
    
    mutating func advanceToNextToken() throws -> Token {
        advanceWhile({ $0.isSpace })
        guard let c = peek() else {
            return Token(type: .eof, range: range(from: sourceLocation))
        }
        if c == "\n" {
            defer { advanceWhile({ $0.isSpace || $0.isLineSeparator }) }
            return Token(type: .newline, range: range(from: sourceLocation))
        }
        if c == ";" {
            defer { advanceWhile({ $0.isSpace || $0.isLineSeparator }) }
            return Token(type: .semicolon, range: range(from: sourceLocation))
        }
        
        // Skip comments
        if c == "/" {
            if peek(ahead: 1) == "/" {
                advanceWhile({ return $0 != "\n"})
                return try advanceToNextToken()
            } else if peek(ahead: 1) == "*" {
                advanceWhile({ _ in return peekString(length: 2) != "*/" })
                advance(2)
                return try advanceToNextToken()
            }
        }
        
        let startLocation = sourceLocation
        
        // character literals
        if c == "'" {
            advance()
            let scalar = try readChar()
            let value = UInt8(scalar.value & 0xff)
            guard peek() == "'" else {
                throw LexError.invalidCharacterLiteral(literal: "\(value)")
            }
            advance()
            return Token(type: .char(value), range: range(from: startLocation))
        }
        
        // string literal
        if c == "\"" {
            advance()
            var interpolations = [[Token]]()
            var str = ""
            while let char = peek(), char != "\"" {
                if peekString(length: 2) == "\\(" {
                    if !str.isEmpty { interpolations.append([Token(type: .stringLiteral(str), range: range(from: startLocation))]) }
                    advance(2)
                    str = ""
                    var interpolation = [Token]()
                    var parenLevel = 0
                    while peek() != ")" || parenLevel > 0 {
                        let token = try advanceToNextToken()
                        if token.type == .leftParen {
                            parenLevel += 1
                        } else if token.type == .rightParen {
                            parenLevel -= 1
                        }
                        interpolation.append(token)
                    }
                    advance()
                    interpolations.append(interpolation)
                } else {
                    str.append(String(try readChar()))
                }
                advance()
                if interpolations.isEmpty {
                    return Token(type: .stringLiteral(str), range: range(from: startLocation))
                }
                if !str.isEmpty { interpolations.append([Token(type: .stringLiteral(str), range: range(from: startLocation))]) }
                return Token(type: .stringInterpolationLiteral(interpolations), range: range(from: startLocation))
            }
        }
        
        if c.isIdentifier {
            let id = collectWhile { $0.isIdentifier }
            if let numVal = id.asNumber() {
                if peek() == ".", let c = peek(ahead: 1), c.isNumeric {
                    advance()
                    let num = collectWhile { $0.isNumeric }
                    if !num.isEmpty, let right = num.asNumber() {
                        return Token(type: .real(value: Double("\(numVal).\(right)")!), range: range(from: startLocation))
                    }
                } else {
                    return Token(type: .integer(value: numVal) , range: range(from: startLocation))
                }
            } else {
                return Token(type: Token.TType(identifier: id), range: range(from: startLocation))
            }
        }
        
        if peekString(length: 3) == "..." {
            advance(3)
            return Token(type: .ellipsis, range: range(from: startLocation))
        }
        
        if c.isOperator {
            let opStr = collectWhile { $0.isOperator }
            if let op = BuiltinOperator(rawValue: opStr) {
                return Token(type: .operator(op), range: range(from: startLocation))
            } else {
                return Token(type: Token.TType(op: opStr), range: range(from: startLocation))
            }
        }
        
        advance()
        return Token(type: Token.TType(op: String(c)), range: range(from: startLocation))
    }
    
    mutating func readChar() throws -> UnicodeScalar {
        guard let c = peek() else { throw LexError.unexpectedEOF }
        advance()
        if c == "\\" {
            guard let escaped = peek() else { throw LexError.unexpectedEOF }
            switch escaped {
            case "n":
                advance()
                return "\n" as UnicodeScalar
            case "t":
                advance()
                return "\t" as UnicodeScalar
            case "r":
                advance()
                return "\r" as UnicodeScalar
            case "x":
                advance()
                guard peek() == "{" else {
                    throw LexError.invalidCharacter(char: peek()!)
                }
                advance()
                let literal = collectWhile { $0.isHexadecimal }
                guard peek() == "}" else {
                    throw LexError.invalidCharacter(char: peek()!)
                }
                advance()
                guard let lit = UInt8(literal, radix: 16) else {
                    throw LexError.invalidCharacterLiteral(literal: "\\x{\(literal)}")
                }
                return UnicodeScalar(lit)
            case "\"":
                advance()
                return "\"" as UnicodeScalar
            default:
                throw LexError.invalidEscape(escapeChar: c)
            }
        }
        return c
    }
}


