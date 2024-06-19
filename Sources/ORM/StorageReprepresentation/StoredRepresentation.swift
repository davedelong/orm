//
//  File.swift
//  
//
//  Created by Dave DeLong on 6/16/24.
//

import Foundation

public struct StoredRepresentation<S: Storable>: StorageRepresentation, _StorageRepresentation {
    internal var name: String { description.name }
    
    internal var description: _StoredObjectDescription
    
    public init(_ entity: S.Type = S.self, name: String? = nil) {
        description = .init(name: name, entity: entity)
        
        var properties = Array<_PropertyDescription>()
        var relationships = Array<_RelationshipDescription>()
        
        for (name, keyPath) in S.properties {
            if name == "id" {
                let p = _PropertyDescription(name: name,
                                                   keyPath: keyPath,
                                                   isUnique: false,
                                                   isIndexed: false)
                properties.append(p)
            } else if let entityType = keyPath.erasedValueType as? any Storable.Type {
                print("Found reference to directly-stored entity \(entityType): \(name) - \(keyPath)")
                let p = _PropertyDescription(name: name,
                                                   keyPath: keyPath,
                                                   isUnique: false,
                                                   isIndexed: false)
                properties.append(p)
            } else {
                print("Unknown property type \(keyPath.erasedValueType); skipping")
            }
        }
        
        description.storedProperties = properties
        description.relationships = relationships
    }
    
    public init(_ entity: S.Type = S.self, name: String? = nil, @ArrayBuilder<any Attribute<S>> properties: () -> Array<any Attribute<S>>) {
        self.description = _StoredObjectDescription(name: name, entity: entity)
        
        let properties = properties().map { $0 as! any _Attribute }
        self.description.storedProperties = properties.compactMap { $0.description as? _PropertyDescription }
        self.description.relationships = properties.compactMap { $0.description as? _RelationshipDescription }
    }
    
}
