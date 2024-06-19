//
//  File.swift
//  
//
//  Created by Dave DeLong on 6/9/24.
//

import Foundation

@dynamicMemberLookup
public struct Snapshot<S: Storable> {
    private let entity: _StoredObjectDescription
    private let values: Dictionary<String, Any>
    
    internal init(entity: _StoredObjectDescription, values: Dictionary<String, Any>) {
        self.entity = entity
        self.values = values
    }
    
    // TODO: if the DML is to another entity, box it in a Snapshot first
    
    public subscript<Value: Storable>(dynamicMember keyPath: KeyPath<S, Value>) -> Value {
        guard let desc = entity.description(for: keyPath) else {
            fatalError("Unknown \(S.self) keyPath: \(keyPath)")
        }
        if let anyValue = values[desc.name], let value = desc.coerce(anyValue) as? Value {
            return value
        } else if let defaultValue = desc.defaultValue as? Value {
            return defaultValue
        } else if let missing = Value.missingValue {
            return missing
        } else {
            fatalError("No value available for \(entity.name).\(desc.name)")
        }
    }
    
}
