//
//  File.swift
//  
//
//  Created by Dave DeLong on 1/9/25.
//

import Foundation
import SQLite

public protocol StoredTypeDescription {
    var baseType: any StoredType.Type { get }
    var transitiveTypeDescriptions: Array<any StoredTypeDescription> { get }
}

extension StoredTypeDescription {
    
    internal var isIdentifiable: Bool { baseType is any Identifiable.Type }
    internal var isOptional: Bool { baseType is any OptionalType.Type }
    
}
