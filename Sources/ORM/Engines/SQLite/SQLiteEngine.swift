//
//  SQLiteEngine.swift
//  ORM
//
//  Created by Dave DeLong on 3/15/25.
//

import Foundation
import SQLite

public actor SQLiteEngine: StorageEngine {
    private let schema: SQLiteSchema
    private let connection: SQLite.Connection
    
    public init(schema: Schema, at url: URL) async throws(StorageError) {
        self.schema = try! SQLiteSchema(schema: schema)
        
        connection = try! .init(.uri(url.path(percentEncoded: false),
                                     parameters: []))
        
        try! self.schema.build(into: connection)
    }
    
    public func save(_ value: any StoredType) throws(StorageError) {
        
    }
    
}
