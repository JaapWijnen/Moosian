//
//  Helpers.swift
//  Moosian
//
//  Created by Jaap Wijnen on 13/07/2017.
//

import Foundation

extension UnicodeScalar {
    static let operatorChars: Set<UnicodeScalar> = Set("~*+-/<>=%^|&!".unicodeScalars)
    var isNumeric: Bool {
        return isnumber(Int32(self.value)) != 0
    }
    var isSpace: Bool {
        return isspace(Int32(self.value)) != 0 && self != "\n"
    }
    var isLineSeparator: Bool {
        return self == "\n" || self == ";"
    }
    var isIdentifier: Bool {
        return isalnum(Int32(self.value)) != 0 || self == "_"
    }
    var isOperator: Bool {
        return UnicodeScalar.operatorChars.contains(self)
    }
    var isHexadecimal: Bool {
        return ishexnumber(Int32(self.value)) != 0
    }
}

extension String {
    func removing(_ string: String) -> String {
        return self.replacingOccurrences(of: string, with: "")
    }
    
    func asNumber() -> Int64? {
        let prefixMap = ["0x": 16, "0b": 2, "0o": 8]
        if characters.count <= 2 {
            return Int64(self, radix: 10)
        }
        let prefix = substring(to: characters.index(startIndex, offsetBy: 2))
        guard let radix = prefixMap[prefix] else {
            return Int64(removing("_"), radix: 10)
        }
        let suffix = removing("_").substring(from: characters.index(startIndex, offsetBy: 2))
        return Int64(suffix, radix: radix)
    }
}
