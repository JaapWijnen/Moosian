//
//  Operators.swift
//  Moosian
//
//  Created by Jaap Wijnen on 27/06/2017.
//

import Foundation

enum BuiltinOperator: String, CustomStringConvertible {
    case plus = "+"
    case minus = "-"
    case star = "*"
    case divide = "/"
    case mod = "%"
    case assign = "="
    case equalTo = "=="
    case notEqualTo = "!="
    case lessThan = "<"
    case lessThanOrEqual = "<="
    case greaterThan = ">"
    case greaterThanOrEqual = ">="
    case and = "&&"
    case or = "||"
    case xor = "^"
    case ampersand = "&"
    case bitwiseOr = "|"
    case not = "!"
    case bitwiseNot = "~"
    case leftShift = "<<"
    case rightShift = ">>"
    case plusAssign = "+="
    case minusAssign = "-="
    case timesAssign = "*="
    case divideAssign = "/="
    case modAssign = "%="
    case andAssign = "&="
    case orAssign = "|="
    case xorAssign = "^="
    case rightShiftAssign = ">>="
    case leftShiftAssign = "<<="
    
    
    
    var infixPrecedence: Int {
        switch self {
            
        case .leftShift: return 160
        case .rightShift: return 160
            
        case .star: return 150
        case .divide: return 150
        case .mod: return 150
        case .ampersand: return 150
            
        case .plus: return 140
        case .minus: return 140
        case .xor: return 140
        case .bitwiseOr: return 140
            
        case .equalTo: return 130
        case .notEqualTo: return 130
        case .lessThan: return 130
        case .lessThanOrEqual: return 130
        case .greaterThan: return 130
        case .greaterThanOrEqual: return 130
            
        case .and: return 120
        case .or: return 110
            
        case .assign: return 90
        case .plusAssign: return 90
        case .minusAssign: return 90
        case .timesAssign: return 90
        case .divideAssign: return 90
        case .modAssign: return 90
        case .andAssign: return 90
        case .orAssign: return 90
        case .xorAssign: return 90
        case .rightShiftAssign: return 90
        case .leftShiftAssign: return 90
            
        // prefix-only
        case .not: return 999
        case .bitwiseNot: return 999
        }
    }
    
    var description: String {
        return self.rawValue
    }
}
