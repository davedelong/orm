//
//  File.swift
//  
//
//  Created by Dave DeLong on 6/19/24.
//

import Foundation

public struct RelationshipProperty<Source: Storable, Destination: Storable>: Attribute {
    public typealias StoredType = Source
    
    
    public var name: String { _relationship.name }
    
    private var _relationship: _RelationshipProperty
    
    // Relationship to a single Storable
    
    public init(name: String? = nil, keyPath: KeyPath<Source, Destination>) {
        self._relationship = _RelationshipProperty(name: name ?? Source.propertyLookup[keyPath]!,
                                                   keyPath: keyPath,
                                                   destinationEntity: Destination.self,
                                                   isToMany: false)
    }
    
    public init(name: String? = nil, keyPath: KeyPath<Source, Destination.ID>) {
        self._relationship = _RelationshipProperty(name: name ?? Source.propertyLookup[keyPath]!,
                                                   keyPath: keyPath,
                                                   destinationEntity: Destination.self,
                                                   isToMany: false)
    }
    
    public init(name: String? = nil, keyPath: KeyPath<Source, Destination.ID?>) {
        self._relationship = _RelationshipProperty(name: name ?? Source.propertyLookup[keyPath]!,
                                                   keyPath: keyPath,
                                                   destinationEntity: Destination.self,
                                                   isToMany: false)
    }
    
    // Relationship to ordered Storables
    
    public init(name: String? = nil, keyPath: KeyPath<Source, Array<Destination>>) {
        self._relationship = _RelationshipProperty(name: name ?? Source.propertyLookup[keyPath]!,
                                                   keyPath: keyPath,
                                                   destinationEntity: Destination.self,
                                                   isToMany: true)
    }
    
    public init(name: String? = nil, keyPath: KeyPath<Source, Array<Destination.ID>>) {
        self._relationship = _RelationshipProperty(name: name ?? Source.propertyLookup[keyPath]!,
                                                   keyPath: keyPath,
                                                   destinationEntity: Destination.self,
                                                   isToMany: true)
    }
    
    public init(name: String? = nil, keyPath: KeyPath<Source, Array<Destination.ID>?>) {
        self._relationship = _RelationshipProperty(name: name ?? Source.propertyLookup[keyPath]!,
                                                   keyPath: keyPath,
                                                   destinationEntity: Destination.self,
                                                   isToMany: true)
    }
    
    // Relationship to unordered Storables
    
    public init(name: String? = nil, keyPath: KeyPath<Source, Set<Destination>>) where Destination: Hashable {
        self._relationship = _RelationshipProperty(name: name ?? Source.propertyLookup[keyPath]!,
                                                   keyPath: keyPath,
                                                   destinationEntity: Destination.self,
                                                   isToMany: true)
    }
    
    public init(name: String? = nil, keyPath: KeyPath<Source, Set<Destination.ID>>) {
        self._relationship = _RelationshipProperty(name: name ?? Source.propertyLookup[keyPath]!,
                                                   keyPath: keyPath,
                                                   destinationEntity: Destination.self,
                                                   isToMany: true)
    }
    
    public init(name: String? = nil, keyPath: KeyPath<Source, Set<Destination.ID>?>) {
        self._relationship = _RelationshipProperty(name: name ?? Source.propertyLookup[keyPath]!,
                                                   keyPath: keyPath,
                                                   destinationEntity: Destination.self,
                                                   isToMany: true)
    }
    
    // TODO: actions
}
