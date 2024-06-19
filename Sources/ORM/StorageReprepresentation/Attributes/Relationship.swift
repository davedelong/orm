//
//  File.swift
//
//
//  Created by Dave DeLong on 6/19/24.
//

import Foundation

public enum RelationshipAction {
    case cascade
    case deny
    case setNull
    case revertToDefault
}

public struct Relationship<Source: Storable, Destination: Storable> {
    
    public var name: String { _relationship.name }
    
    internal var _relationship: _RelationshipDescription
    
    // Relationship to a single Storable
    
    @_disfavoredOverload
    public init(name: String? = nil, keyPath: KeyPath<Source, Destination>) {
        self._relationship = _RelationshipDescription(name: name ?? Source.propertyLookup[keyPath]!,
                                                              keyPath: keyPath,
                                                              destinationEntity: Destination.self,
                                                              cardinality: .single)
    }
    
//    public init(name: String? = nil, keyPath: KeyPath<Source, Destination.ID>) {
//        self._relationship = _RelationshipDescription(name: name ?? Source.propertyLookup[keyPath]!,
//                                                              keyPath: keyPath,
//                                                              destinationEntity: Destination.self,
//                                                              cardinality: .single)
//    }
//    
//    public init(name: String? = nil, keyPath: KeyPath<Source, Destination.ID?>) {
//        self._relationship = _RelationshipDescription(name: name ?? Source.propertyLookup[keyPath]!,
//                                                              keyPath: keyPath,
//                                                              destinationEntity: Destination.self,
//                                                              cardinality: .single)
//    }
    
    // Relationship to ordered Storables
    
    public init(name: String? = nil, keyPath: KeyPath<Source, Array<Destination>>) {
        self._relationship = _RelationshipDescription(name: name ?? Source.propertyLookup[keyPath]!,
                                                              keyPath: keyPath,
                                                              destinationEntity: Destination.self,
                                                              cardinality: .orderedMany)
    }
    
//    public init(name: String? = nil, keyPath: KeyPath<Source, Array<StoredID<Destination, Destination.RawID>>>) {
//        self._relationship = _RelationshipDescription(name: name ?? Source.propertyLookup[keyPath]!,
//                                                              keyPath: keyPath,
//                                                              destinationEntity: Destination.self,
//                                                              cardinality: .orderedMany)
//    }
//    
//    public init(name: String? = nil, keyPath: KeyPath<Source, Array<StoredID<Destination, Destination.RawID>>?>) {
//        self._relationship = _RelationshipDescription(name: name ?? Source.propertyLookup[keyPath]!,
//                                                              keyPath: keyPath,
//                                                              destinationEntity: Destination.self,
//                                                              cardinality: .orderedMany)
//    }
    
    // Relationship to unordered Storables
    
    public init(name: String? = nil, keyPath: KeyPath<Source, Set<Destination>>) where Destination: Hashable {
        self._relationship = _RelationshipDescription(name: name ?? Source.propertyLookup[keyPath]!,
                                                              keyPath: keyPath,
                                                              destinationEntity: Destination.self,
                                                              cardinality: .unorderedMany)
    }
    
//    public init(name: String? = nil, keyPath: KeyPath<Source, Set<StoredID<Destination, Destination.RawID>>>) {
//        self._relationship = _RelationshipDescription(name: name ?? Source.propertyLookup[keyPath]!,
//                                                              keyPath: keyPath,
//                                                              destinationEntity: Destination.self,
//                                                              cardinality: .unorderedMany)
//    }
//    
//    public init(name: String? = nil, keyPath: KeyPath<Source, Set<StoredID<Destination, Destination.RawID>>?>) {
//        self._relationship = _RelationshipDescription(name: name ?? Source.propertyLookup[keyPath]!,
//                                                              keyPath: keyPath,
//                                                              destinationEntity: Destination.self,
//                                                              cardinality: .unorderedMany)
//    }
    
    // TODO: actions
}
