//
//  SQLiteEngine.swift
//  ORM
//
//  Created by Dave DeLong on 3/15/25.
//

import Foundation
import SQLite
import SQLite3
import SQLiteSyntax

/*
 
 NOTES:
 - sqlite3_deserialize + sqlite3_serialize to convert an in-memory database to/from a writable Data
 - sqlite3_snapshot_open for queries? to make sure that retrieving related values is consistent?
 - sqlite3_update_hook for observation deltas
 
 */

public actor SQLiteEngine: StorageEngine {
    private let schema: Schema
    private let sqliteSchema: SQLiteSchema
    private let handle: SQLiteHandle
    
    public init(schema: Schema, at url: URL) async throws {
        self.schema = schema
        self.sqliteSchema = try! SQLiteSchema(schema: schema)
        
        self.handle = try SQLiteHandle(path: url.path(percentEncoded: false))
        
        try! self.sqliteSchema.build(into: handle)
    }
    
    public func save(_ value: any StoredType) throws(StorageError) {
        let valueType = type(of: value)
        guard let description = schema.compositeTypes.first(where: { $0.baseType == valueType }) else {
            throw StorageError.unknownStoredType(value)
        }
        guard let table = sqliteSchema.tables.first(where: { $0.name == description.name }) else {
            throw StorageError.unknownStoredType(value)
        }
        
        let (insert, keyPaths) = table.insertStatement(valueCount: 1)
        
        do {
            try handle.transaction { h in
                let sql = try insert.sql()
                let statement = try h.prepare(sql)
                
                let values = try description.extract(values: keyPaths, from: value)
                for (offset, value) in values.enumerated() {
                    try statement.bind(value, at: Int32(offset + 1))
                }
                
                let result = try h.run(statement)
                print(result)
                try statement.finish()
            }
        } catch {
            print("ERROR: \(error)")
        }
    }
    
}

extension CompositeTypeDescription {
    
    fileprivate func extract(values keyPaths: Array<AnyKeyPath>, from value: any StoredType) throws -> Array<SQLiteValue> {
        guard type(of: value) == self.baseType else { throw StorageError.unknownStoredType(value) }
        
        return try keyPaths.map { kp in
            let field = try self.fieldsByKeyPath[kp] ?! StorageError.unknownFieldType(self.baseType, "", kp, kp.erasedValueType)
            guard field.kind != .multiValue else { fatalError() }
            
            guard field.kind == .primitive else { fatalError("FOR NOW") }
            
            let raw = value[keyPath: kp]
            if let opt = raw as? OptionalType, opt.isNull {
                return .null
            } else if let b = raw as? Bool {
                return .bool(b)
            } else if let i = raw as? Int64 {
                return .int(i)
            } else if let d = raw as? Double {
                return .double(d)
            } else if let s = raw as? String {
                return .text(s)
            } else if let d = raw as? Data {
                return .blob(d)
            } else {
                throw StorageError.unknownFieldType(self.baseType, field.name, kp, kp.erasedValueType)
            }
        }
    }
    
    
}
