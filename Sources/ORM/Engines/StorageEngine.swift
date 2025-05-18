//
//  File.swift
//  ORM
//
//  Created by Dave DeLong on 3/15/25.
//

import Foundation

public protocol StorageEngine: Actor {
    
    init(schema: Schema, at url: URL) async throws
    
    func save(_ value: any StoredType) throws
}

extension StorageEngine {
    
    public init(_ first: any StoredType.Type, _ others: any StoredType.Type..., at url: URL) async throws {
        var all: Array<any StoredType.Type> = [first]
        all.append(contentsOf: others)
        let s = try Schema(types: all)
        try await self.init(schema: s, at: url)
    }
    
}
