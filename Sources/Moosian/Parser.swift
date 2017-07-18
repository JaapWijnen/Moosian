//
//  Parser.swift
//  Moosian
//
//  Created by Jaap Wijnen on 16/07/2017.
//

import Foundation

enum ParseError: Error, CustomStringConvertible {
    case unexpectedToken(token: Token.TType)
    
    var description: String {
        switch self {
        case .unexpectedToken(let token):
            return "unexpected token '\(token)'"
        }
    }
}

class Parser {
    var tokenIndex = 0
    var tokens: [Token]
    
    init(tokens: [Token]) {
        self.tokens = tokens
    }
    
    func peek(ahead index: Int = 0) -> Token.TType {
        guard tokens.indices.contains(tokenIndex + index) else {
            return .eof
        }
        return tokens[tokenIndex + index].type
    }
    
    func currentToken() -> Token {
        guard tokens.indices.contains(tokenIndex) else {
            return Token(type: .eof, range: .zero)
        }
        return tokens[tokenIndex]
    }
    
    
}
