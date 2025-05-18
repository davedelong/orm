//
//  File.swift
//  ORM
//
//  Created by Dave DeLong on 4/3/25.
//

import Foundation
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
    
    func build(into connection: SQLiteHandle) throws {
        try connection.transaction { h in
            for table in tables {
                let sql = try table.create.sql()
                try h.execute(sql)
            }
        }
    }
    
}
