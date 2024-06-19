//
//  File.swift
//  
//
//  Created by Dave DeLong on 6/16/24.
//

import Foundation

public struct Property<S: Storable, V: Storable> {
    internal var _property: _PropertyDescription
    
    public var name: String { _property.name }
    public var isUnique: Bool { _property.isUnique }
    public var isIndexed: Bool { _property.isIndexed }
    public var defaultValue: V? { _property.defaultValue as? V }
    
    public init(name: String? = nil, keyPath: KeyPath<S, V>) {
        self._property = _PropertyDescription(name: name ?? S.propertyLookup[keyPath]!,
                                         keyPath: keyPath,
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
    
    // TODO: type-specific constraints would go here
}


