//
//  File.swift
//  
//
//  Created by Dave DeLong on 6/16/24.
//

import Foundation

internal struct _StoredObjectDescription {
    
    let entity: any Storable.Type
    let lookup: Bimap<String, AnyKeyPath>
    
    var name: String
    var storedProperties = Array<_PropertyDescription>()
    var relationships = Array<_RelationshipDescription>()
    var indexes = Array<_IndexDescription>()
    var uniqueProperties = Array<_UniquePropertiesDescription>()
    
    init(name: String?, entity: any Storable.Type) {
        self.name = name ?? "\(entity)"
        self.entity = entity
        self.lookup = entity.propertyLookup
    }
    
    internal func description(for keyPath: AnyKeyPath) -> _AttributeDescription? {
        if let stored = storedProperties.first(where: { $0.keyPath == keyPath }) {
            return stored
        }
        if let related = relationships.first(where: { $0.keyPath == keyPath }) {
            return related
        }
        return nil
    }
    
    var relatedTypes: Array<any Storable.Type> {
        return relationships.map(\.destinationEntity)
    }
}

internal protocol _AttributeDescription {
    var name: String { get }
    var defaultValue: Any? { get }
    func coerce(_ value: Any) -> Any?
}

internal struct _PrimitiveDescription: _AttributeDescription {
    var name: String
    var type: PrimitiveType
    var defaultValue: Any?
    
    func coerce(_ value: Any) -> Any? {
        return nil
    }
}

internal struct _PropertyDescription: _AttributeDescription {
    var name: String
    var keyPath: AnyKeyPath
    var isUnique: Bool
    var isIndexed: Bool
    var defaultValue: Any?
    
    func coerce(_ value: Any) -> Any? {
        return nil
    }
}

internal enum RelationshipCardinality {
    case single
    case orderedMany
    case unorderedMany
}

internal struct _RelationshipDescription: _AttributeDescription {
    var name: String
    var keyPath: AnyKeyPath
    
    var destinationEntity: any Storable.Type
    var cardinality: RelationshipCardinality
    var deleteRule: RelationshipAction?
    var defaultValue: Any?
    
    func coerce(_ value: Any) -> Any? {
        return nil
    }
}

internal struct _IndexDescription {
    var names: Array<String>
}

internal struct _UniquePropertiesDescription {
    var names: Array<String>
}
