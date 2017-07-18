//
//  AST.swift
//  Moosian
//
//  Created by Jaap Wijnen on 18/07/2017.
//

import Foundation

class ASTNode: Equatable {
    let sourceRange: SourceRange?
    
    var startLocation: SourceLocation? { return sourceRange?.start }
    var endLocation: SourceLocation? { return sourceRange?.end }
    
    init(sourceRange: SourceRange? = nil) {
        self.sourceRange = sourceRange
    }
    
    
    static func ==(lhs: ASTNode, rhs: ASTNode) -> Bool {
        <#code#>
    }
}
