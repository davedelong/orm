//
//  File.swift
//  
//
//  Created by Dave DeLong on 6/2/24.
//

import Foundation

internal protocol _TableProperty {
    var wrappedValueType: Any.Type { get }
    var persistentValueType: any PersistentValue.Type { get }
}

extension _TableProperty {
    var semantics: _PersistentValueSemantics { persistentValueType.semantics }
}

extension PrimaryKey: _TableProperty {
    var wrappedValueType: any Any.Type { Value.self }
    var persistentValueType: any PersistentValue.Type { Value.self }
}
extension Field: _TableProperty {
    var wrappedValueType: any Any.Type { Value.self }
    var persistentValueType: any PersistentValue.Type { Value.self }
}
extension Unique: _TableProperty {
    var wrappedValueType: any Any.Type { Value.self }
    var persistentValueType: any PersistentValue.Type { Value.self }
}
extension ForeignKey: _TableProperty { 
    var wrappedValueType: any Any.Type { Value.self }
    var persistentValueType: any PersistentValue.Type { Value.self }
}

enum TableError: Error {
    case missingID
    case multipleIDs
    case invalidProperty(String)
}

internal struct Table {
    let entity: (any Entity.Type)
    let name: String
    
    let primaryKey: TableField
    let otherColumns: Array<TableField>
    let constraints: Array<TableConstraint>
}

struct TableField {
    let name: String
    let dataType: PersistentType
    let defaultValue: String?
    let notNull: Bool
}

struct TableConstraint {
    
}
