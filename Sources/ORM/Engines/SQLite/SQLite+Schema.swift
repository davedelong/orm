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
        tables = schema.compositeTypes.map { SQLiteTable(type: $0) }
        
        for type in schema.compositeTypes {
            try SQLiteTable.build(type: type, into: &self)
        }
    }
    
    subscript(table name: String) -> SQLiteTable {
        get {
            tables.first(where: { $0.name == name })!
        }
        set {
            let index = tables.firstIndex(where: { $0.name == name })!
            tables[index] = newValue
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
    
    static func build(type: CompositeTypeDescription, into schema: inout SQLiteSchema) throws {
        var base = schema[table: type.name]
        
        for field in type.fields {
            if let primitive = field.description as? PrimitiveTypeDescription {
                var column = SQLiteSyntax.ColumnDefinition(name: Name(value: field.name),
                                                           typeName: primitive.sqliteTypeName,
                                                           constraints: [
                                                            .notNull
                                                           ])
                if field.name == "id" && type.isIdentifiable {
                    column.constraints?.append(.init(name: nil, constraint: .primaryKey(nil, .none, autoincrement: false)))
                }
                base.create.columns.append(column)
                
            } else if let opt = field.description as? OptionalTypeDescription, let primitive = opt.wrappedType as? PrimitiveTypeDescription {
                let column = SQLiteSyntax.ColumnDefinition(name: Name(value: field.name),
                                                           typeName: primitive.sqliteTypeName,
                                                           constraints: [])
                base.create.columns.append(column)
            } else if let rel = field.description as? CompositeTypeDescription {
                switch (type.isIdentifiable, rel.isIdentifiable) {
                    case (true, true):
                        // both identifiable; THIS has a ON DELETE DENY foreign key to THAT
                    case (false, true):
                        // that's identifiable; THIS has a ON DELETE CASCADE fk to THAT
                    case (true, false):
                        // this is identiable; THAT has a ON DELETE CASCADE fk to THIS
                    case (false, false):
                        // neither is identifiable
                }
                if rel.isIdentifiable {
                    //
                } else {
                    
                }
            } else if let opt = field.description as? OptionalTypeDescription, let rel = opt.wrappedType as? CompositeTypeDescription {
                if rel.isIdentifiable {
                    
                } else {
                    
                }
            } else if let mul = field.description as? MultiValueTypeDescription {
                // need an intermediate table
            }
        }
        
        schema[table: type.name] = base
    }
    
    let name: String
    let isIdentifiable: Bool
    var create: SQLiteSyntax.Table.Create
    
    init(type: CompositeTypeDescription) {
        self.name = type.name
        self.isIdentifiable = type.isIdentifiable
        self.create = Table.Create(name: Name(value: name))
    }
    
    fileprivate func create(using connection: SQLite.Connection) throws {
        let sql = try create.sql()
        try connection.execute(sql)
    }
}
