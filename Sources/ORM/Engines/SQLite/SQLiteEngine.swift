//
//  SQLiteEngine.swift
//  ORM
//
//  Created by Dave DeLong on 3/15/25.
//

import Foundation
import SQLite
import SQLite3

/*
 
 NOTES:
 - sqlite3_deserialize + sqlite3_serialize to convert an in-memory database to/from a writable Data
 - sqlite3_snapshot_open for queries? to make sure that retrieving related values is consistent?
 
 */

public actor SQLiteEngine: StorageEngine {
    private let schema: Schema
    private let sqliteSchema: SQLiteSchema
    private let connection: SQLite.Connection
    
    public init(schema: Schema, at url: URL) async throws(StorageError) {
        self.schema = schema
        self.sqliteSchema = try! SQLiteSchema(schema: schema)
        
        connection = try! .init(.uri(url.path(percentEncoded: false),
                                     parameters: []))
        
        try! self.sqliteSchema.build(into: connection)
    }
    
    public func save(_ value: any StoredType) throws(StorageError) {
        guard let table = sqliteSchema.table(for: value) else {
            throw StorageError.unknownStoredType(value)
        }
        
        
    }
    
}
