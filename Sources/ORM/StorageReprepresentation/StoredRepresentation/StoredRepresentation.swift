//
//  File.swift
//  
//
//  Created by Dave DeLong on 6/16/24.
//

import Foundation

public struct StoredRepresentation<StoredType: Storable>: StorageRepresentation {
    public var name: String?
    internal var customAttributes: (() -> Array<any Attribute<StoredType>>)?
    
    public init(_ entity: StoredType.Type = StoredType.self, name: String? = nil) {
        self.name = name ?? "\(entity)"
        self.customAttributes = nil
    }
    
    public init(_ entity: StoredType.Type = StoredType.self, name: String? = nil, @ArrayBuilder<any Attribute<StoredType>> properties: @escaping () -> Array<any Attribute<StoredType>>) {
        self.name = name ?? "\(entity)"
        self.customAttributes = properties
    }
    
    public func _build(into builder: _StorageBuilder) throws {
        if let custom = customAttributes {
            try _buildCustom(attributes: custom(), into: builder)
        } else {
            try _buildDefault(into: builder)
        }
    }
    
    private func _buildCustom(attributes: Array<any Attribute<StoredType>>, into builder: _StorageBuilder) throws {
        
    }
    
    private func _buildDefault(into builder: _StorageBuilder) throws {
        // what if it's a RawRepresentable struct?
        // what if it's a CaseIterable enum?
        
        var properties = Array<_PropertyDescription>()
        var relationships = Array<_RelationshipDescription>()
        
        for (name, keyPath) in StoredType.properties {
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
    }
    
}
