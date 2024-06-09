//
//  File.swift
//  
//
//  Created by Dave DeLong on 6/9/24.
//

import Foundation

@dynamicMemberLookup
public struct Snapshot<E: Entity> {
    private let entity: EntityDescription<E>
    private let values: Dictionary<String, Any>
    
    public init(entity: EntityDescription<E>, values: Dictionary<String, Any>) {
        self.entity = entity
        self.values = values
    }
    
    // TODO: if the DML is to another entity, box it in a Snapshot first
    
    public subscript<Value: PersistentValue>(dynamicMember keyPath: KeyPath<E, Value>) -> Value {
        guard let attr = entity.attributes.first(where: { $0.keyPath == keyPath }) else {
            fatalError("Unknown \(E.self) keyPath: \(keyPath)")
        }
        if let anyValue = values[attr.name], let value = Value.coerce(anyValue) {
            return value
        } else if let defaultValue = attr.defaultValue as? Value {
            return defaultValue
        } else if let missing = try? Value.missingValue {
            return missing
        } else {
            fatalError("No value available for \(E.name).\(attr.name)")
        }
    }
    
}
