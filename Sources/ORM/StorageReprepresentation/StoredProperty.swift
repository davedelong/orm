//
//  File.swift
//  
//
//  Created by Dave DeLong on 6/16/24.
//

import Foundation

public protocol Attribute<StoredType> {
    associatedtype StoredType: Storable
    
    var name: String { get }
}

public struct StoredProperty<S: Storable, V: StoredValue>: Attribute {
    public typealias StoredType = S
    
    internal var _property: _StoredProperty
    
    public var name: String { _property.name }
    public var isUnique: Bool { _property.isUnique }
    public var isIndexed: Bool { _property.isIndexed }
    public var defaultValue: V? { _property.defaultValue as? V }
    
    public init(name: String? = nil, keyPath: KeyPath<S, V>) {
        let type = V.semantics.persistentType
        self._property = _StoredProperty(name: name ?? S.propertyLookup[keyPath]!,
                                         keyPath: keyPath,
                                         storageType: type,
                                         isUnique: false, 
                                         isIndexed: false)
    }
    
    public mutating func unique(_ isUnique: Bool = true) -> Self {
        _property.isIndexed = isUnique
        return self
    }
    
    public mutating func indexed(_ isIndexed: Bool = true) -> Self {
        _property.isIndexed = isIndexed
        return self
    }
    
    public mutating func defaultValue(_ value: V?) -> Self {
        _property.defaultValue = value
        return self
    }
}
