//
//  File.swift
//  ORM
//
//  Created by Dave DeLong on 4/3/25.
//

import Foundation
import SQLite
import SQLiteSyntax

internal struct SQLiteSchema {
    
    let base: Schema
    var tables: Array<SQLiteTable>
    
    init(schema: Schema) throws {
        self.base = schema
        self.tables = []
        
        for type in schema.compositeTypes {
            SQLiteTable.buildTables(from: type, into: &self)
        }
    }
    
    func build(into connection: SQLite.Connection) throws {
        try connection.transaction {
            for table in tables {
                try table.create(using: connection)
            }
        }
    }
    
}

internal struct SQLiteTable {
    
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
            } else if let o = field.description as? OptionalTypeDescription, let p = o.wrappedType as? PrimitiveTypeDescription {
                let column = SQLiteSyntax.ColumnDefinition(name: Name(value: field.name),
                                                           typeName: p.sqliteTypeName,
                                                           constraints: [])
                base.create.columns.append(column)
                
            } else if let thatType = field.description as? CompositeTypeDescription {
                let name = Name<Column>(value: field.name)
                let that = Name<SQLiteSyntax.Table>(value: thatType.name)
                if thatType.isIdentifiable {
                    // if that thing gets deleted, cascade delete this
                    base.create.addForeignKey(name, references: that, column: "id", canBeNull: false, onDelete: .cascade)
                } else {
                    // if that thing gets deleted, do nothing
                    // Maybe we add a trigger that cascade deletes the value if this is deleted?
                    base.create.addForeignKey(name, references: that, column: "ROWID", canBeNull: false)
                }
            } else if let o = field.description as? OptionalTypeDescription, let c = o.wrappedType as? CompositeTypeDescription {
                let name = Name<Column>(value: field.name)
                let that = Name<SQLiteSyntax.Table>(value: c.name)
                let ref = Name<Column>(value: c.isIdentifiable ? "id" : "ROWID")
                base.create.addForeignKey(name, references: that, column: ref, canBeNull: true)
            } else if let m = field.description as? MultiValueTypeDescription {
                // need an intermediate table
                
                let joinTableName = "\(thisType.name)_\(field.name)"
                var join = SQLiteTable(name: joinTableName)
                
                var uniqueTuple = Array<String>()
                
                let parentIDColumn: Name<Column> = thisType.isIdentifiable ? "id" : "ROWID"
                join.create.addForeignKey("parent",
                                          references: Name(value: thisType.name),
                                          column: parentIDColumn,
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
                    join.create.addForeignKey("value", references: Name(value: c.name), column: name, canBeNull: false, onDelete: .cascade)
                }
                
                if m.isOrdered == false && m.keyType == nil {
                    // this is a "set", so duplicate values are not allowed
                    uniqueTuple.append("value")
                }
                
                let uniqueColumns = uniqueTuple.map { IndexedColumn(name: .columnName(Name(value: $0))) }
                join.create.constraints.append(
                    TableConstraint(constraint: .unique(List(uniqueColumns), .abort))
                )
                
                schema.tables.append(join)
            }
        }
        schema.tables.append(base)
    }
    
    let name: String
    var create: SQLiteSyntax.Table.Create
    
    init(name: String) {
        self.name = name
        self.create = Table.Create(name: Name(value: name))
    }
    
    fileprivate func create(using connection: SQLite.Connection) throws {
        let sql = try create.sql()
        print(sql)
        try connection.execute(sql)
    }
}
