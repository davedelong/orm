//
//  File.swift
//  
//
//  Created by Dave DeLong on 6/16/24.
//

import Foundation

public struct EntityBuilder<E: Storable> {
    internal var name: String { _desc.name }
    
    internal var _desc: _EntityDescription
    
    public init(_ entity: E.Type = E.self) throws {
        _desc = .init(entity: entity)
        
        var properties = Array<_StoredProperty>()
        
        for (name, keyPath) in ORM.fields(of: E.self) {
            if name == "id" {
                guard let entityIDType = keyPath.erasedValueType as? any EntityIDType.Type else {
                    throw EntityError.invalidPropertyType(name, E.self, keyPath.erasedValueType)
                }
                let storageType = try entityIDType.semantics.persistentType
                let p = _StoredProperty(name: name, keyPath: keyPath,
                                        storageType: storageType, isUnique: false, isIndexed: false)
                properties.append(p)
            } else if let entityType = keyPath.erasedValueType as? any StorageRepresentation.Type {
                print("Found reference to directly-stored entity \(entityType): \(name) - \(keyPath)")
            } else if let foreignKeyType = keyPath.erasedValueType as? any ForeignKeyValue.Type {
                // entity ids, arrays, and sets
                print("Found reference to related entities \(foreignKeyType): \(name) - \(keyPath)")
//            } else if let collectionType = keyPath.erasedValueType as? any Collection.Type {
                // array, set, dictionary, etc of regular persistable types
//                print("Found reference to multiple persistent values: \(name) - \(keyPath)")
            } else if let valueType = keyPath.erasedValueType as? any PersistentValue.Type {
                let storageType = try valueType.semantics.persistentType
                let p = _StoredProperty(name: name, keyPath: keyPath,
                                        storageType: storageType, isUnique: false, isIndexed: false)
                properties.append(p)
                print("Found stored property: \(name) - \(keyPath)")
            } else {
                print("Unknown property type \(keyPath.erasedValueType); skipping")
            }
        }
        
        _desc.storedProperties = properties
        
        try validate()
    }
    
    public init(_ entity: E.Type = E.self, @ArrayBuilder<any Property<E>> properties: () -> Array<any Property<E>>) throws {
        self._desc = _EntityDescription(entity: entity)
        // TODO: get the stored properties from the array
        
        try validate()
    }
    
    private func validate() throws {
        guard _desc.storedProperties.count > 0 else {
            throw EntityError.noStoredProperties(E.self)
        }
        
        guard _desc.storedProperties.contains(where: { $0.name == "id" }) else {
            throw EntityError.missingID(E.self)
        }
    }
}
