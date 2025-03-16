//
//  File.swift
//  ORM
//
//  Created by Dave DeLong on 3/15/25.
//

import Foundation

public protocol StorageEngine: Actor {
    
    init(schema: Schema) throws
    
}

extension StorageEngine {
    
    public init<F: StoredType, each S: StoredType>(_ first: F.Type, _ types: repeat (each S).Type) throws(Error) {
        let s = try Schema(first, repeat each types)
        try self.init(schema: s)
    }
    
}
