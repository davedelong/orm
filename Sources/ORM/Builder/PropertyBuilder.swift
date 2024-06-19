//
//  File.swift
//  
//
//  Created by Dave DeLong on 6/16/24.
//

import Foundation

public protocol Property<EntityType> {
    associatedtype EntityType: Entity
    
    var name: String { get set }
}

public struct StoredProperty<E: Entity, V: PersistentValue>: Property {
    public typealias EntityType = E
    
    internal var _property: _StoredProperty
    
    public var name: String {
        get { _property.name }
        set { _property.name = newValue }
    }
    
    public var isUnique: Bool {
        get { _property.isUnique }
        set { _property.isUnique = newValue }
    }
    
    public var isIndexed: Bool {
        get { _property.isIndexed }
        set { _property.isIndexed = newValue }
    }
    
    public var defaultValue: V? {
        get { _property.defaultValue as? V }
        set { _property.defaultValue = newValue }
    }
    
    public init(name: String? = nil, keyPath: KeyPath<E, V>) throws {
        guard let actualName = E.propertyLookup[keyPath] else {
            throw EntityError.invalidAttribute("KeyPath \(keyPath) does not refer to a stored value", keyPath)
        }
        
        let type = try V.semantics.persistentType
        self._property = _StoredProperty(name: name ?? actualName, keyPath: keyPath, storageType: type, isUnique: false, isIndexed: false)
    }
    
    public mutating func unique(_ isUnique: Bool = true) -> Self {
        self.isUnique = isUnique
        return self
    }
    
    public mutating func indexed(_ isIndexed: Bool = true) -> Self {
        self.isIndexed = isIndexed
        return self
    }
    
    public mutating func defaultValue(_ value: V?) -> Self {
        self.defaultValue = value
        return self
    }
}
