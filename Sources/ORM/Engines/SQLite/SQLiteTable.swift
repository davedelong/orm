//
//  File.swift
//  ORM
//
//  Created by Dave DeLong on 5/2/25.
//

import Foundation
import SQLite
import SQLiteSyntax

/*
 NOTES ON INSERTING:
 
 When inserting values, it needs to be done in a particular order:
 1. First, non-identifiable related values need to be inserted (INSERT OR IGNORE), so that their respective ROWIDs can be used
 2. Then, the row can be inserted for the value, using any ROWIDs for single-value non-identifiable relations
 3. Then, the multi-value values can be inserted, using the ROWID/id of the value that was just inserted
 4. Finally, ordered-multi-values need their orders updated
 
 */

struct SQLiteColumn {
    let name: String
    let keyPath: AnyKeyPath
    let sqliteName: Name<SQLiteSyntax.Column>
}

internal struct SQLiteTable {
    
    let name: String
    
    var create: SQLiteSyntax.Table.Create
    
    var columns = Array<SQLiteColumn>()
    private(set) var insertValuesKeyPaths = Array<AnyKeyPath>()
    private(set) var insertStatement: SQLiteSyntax.InsertStatement
    private var insertValuesTemplate = Group<List<SQLiteSyntax.Expression>>(contents: [])
    
    init(name: String) {
        self.name = name
        self.create = Table.Create(name: Name(value: name))
        self.insertStatement = InsertStatement(
            action: .insert(.replace),
            tableName: Name(value: name),
            values: .values([], nil),
            returning: nil
        )
    }
    
    fileprivate mutating func finalizeInitialization(forIdentifiableType isIdentifiable: Bool) {
        self.insertValuesKeyPaths = columns.map(\.keyPath)
        self.insertStatement.columns = List(columns.map(\.sqliteName))
        self.insertValuesTemplate.contents.items = (0 ..< columns.count).map { _ in
            return .bindParameter(.next)
        }
        
        let idColumn = isIdentifiable ? Name<Column>(value: "id") : Name(value: "ROWID")
        self.insertStatement.returning = .init(values: [.expression(.column(idColumn), alias: Name("id"))])
    }
    
    func insertStatement(valueCount: Int) -> (SQLiteSyntax.InsertStatement, Array<AnyKeyPath>) {
        var stmt = insertStatement
        let values = Array(repeating: insertValuesTemplate, count: valueCount)
        stmt.values = .values(List(values), nil)
        
        return (stmt, insertValuesKeyPaths)
    }
}

extension SQLiteTable {
    
    static func buildTables(from thisType: CompositeTypeDescription, into schema: inout SQLiteSchema) {
        var base = SQLiteTable(name: thisType.name)
        for field in thisType.fields {
            if let p = field.description as? PrimitiveTypeDescription {
                var column = SQLiteSyntax.ColumnDefinition(name: Name(value: field.name),
                                                           typeName: p.sqliteTypeName,
                                                           constraints: [
                                                            .notNull
                                                           ])
                if field.name == "id" && thisType.isIdentifiable {
                    column.constraints?.append(.init(name: nil, constraint: .primaryKey(nil, .none, autoincrement: false)))
                }
                base.create.columns.append(column)
                base.columns.append(.init(name: field.name, keyPath: field.keyPath, sqliteName: column.name))
                
            } else if let o = field.description as? OptionalTypeDescription, let p = o.wrappedType as? PrimitiveTypeDescription {
                let column = SQLiteSyntax.ColumnDefinition(name: Name(value: field.name),
                                                           typeName: p.sqliteTypeName,
                                                           constraints: [])
                base.create.columns.append(column)
                base.columns.append(.init(name: field.name, keyPath: field.keyPath, sqliteName: column.name))
                
            } else if let thatType = field.description as? CompositeTypeDescription {
                let name = Name<Column>(value: field.name)
                let that = Name<SQLiteSyntax.Table>(value: thatType.name)
                if thatType.isIdentifiable {
                    // if that thing gets deleted, cascade delete this
                    let thatIDType = thatType.idField
                    base.create.addForeignKey(name, references: that, column: "id", type: thatIDType?.sqliteTypeName, canBeNull: false, onDelete: .cascade)
                } else {
                    // if that thing gets deleted, do nothing
                    // Maybe we add a trigger that cascade deletes the value if this is deleted?
                    base.create.addForeignKey(name, references: that, column: "ROWID", type: .integer, canBeNull: false)
                }
                base.columns.append(.init(name: field.name, keyPath: field.keyPath, sqliteName: name))
                
            } else if let o = field.description as? OptionalTypeDescription, let c = o.wrappedType as? CompositeTypeDescription {
                let name = Name<Column>(value: field.name)
                let that = Name<SQLiteSyntax.Table>(value: c.name)
                let ref = Name<Column>(value: c.isIdentifiable ? "id" : "ROWID")
                let type: TypeName = c.idField?.sqliteTypeName ?? .integer
                base.create.addForeignKey(name, references: that, column: ref, type: type, canBeNull: true)
                base.columns.append(.init(name: field.name, keyPath: field.keyPath, sqliteName: name))
                
            } else if let m = field.description as? MultiValueTypeDescription {
                // need an intermediate table
                
                let joinTableName = "\(thisType.name)_\(field.name)"
                var join = SQLiteTable(name: joinTableName)
                
                var uniqueTuple = Array<String>()
                
                let parentIDColumn: Name<Column> = thisType.isIdentifiable ? "id" : "ROWID"
                let parentIDType: TypeName = thisType.idField?.sqliteTypeName ?? .integer
                join.create.addForeignKey("parent",
                                          references: Name(value: thisType.name),
                                          column: parentIDColumn,
                                          type: parentIDType,
                                          canBeNull: false,
                                          onDelete: .cascade)
                uniqueTuple.append("parent")
                
                if let key = m.keyType as? PrimitiveTypeDescription {
                    join.create.addColumn("key", type: key.sqliteTypeName, canBeNull: false)
                    uniqueTuple.append("key")
                } else if m.isOrdered {
                    join.create.addColumn("order", type: .integer, canBeNull: false)
                    uniqueTuple.append("order")
                }
                
                if let p = m.valueType as? PrimitiveTypeDescription {
                    join.create.addColumn("value", type: p.sqliteTypeName, canBeNull: false)
                } else if let c = m.valueType as? CompositeTypeDescription {
                    let name: Name<Column> = c.isIdentifiable ? "id" : "ROWID"
                    let type = c.idField?.sqliteTypeName ?? .integer
                    join.create.addForeignKey("value", references: Name(value: c.name), column: name, type: type, canBeNull: false, onDelete: .cascade)
                }
                
                if m.isOrdered == false && m.keyType == nil {
                    // this is a "set", so duplicate values are not allowed
                    uniqueTuple.append("value")
                }
                
                join.create.addColumn("processed", type: .integer)
                
                let uniqueColumns = uniqueTuple.map { IndexedColumn(name: .columnName(Name(value: $0))) }
                join.create.constraints.append(
                    TableConstraint(constraint: .unique(List(uniqueColumns), .abort))
                )
                
                join.finalizeInitialization(forIdentifiableType: false)
                schema.tables.append(join)
            }
        }
        
        base.finalizeInitialization(forIdentifiableType: thisType.isIdentifiable)
        schema.tables.append(base)
    }
    
}

