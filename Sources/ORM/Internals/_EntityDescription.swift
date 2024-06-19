//
//  File.swift
//  
//
//  Created by Dave DeLong on 6/16/24.
//

import Foundation

internal struct _EntityDescription {
    
    let entity: any Entity.Type
    let lookup: Bimap<String, AnyKeyPath>
    
    var name: String
    var storedProperties = Array<_StoredProperty>()
    var relationships = Array<_RelationshipProperty>()
    var indexes = Array<_IndexedProperties>()
    var uniqueProperties = Array<_UniqueProperties>()
    
    init(entity: any Entity.Type) {
        self.entity = entity
        self.lookup = entity.propertyLookup
        self.name = "\(entity)"
    }
    
}

internal struct _StoredProperty {
    var name: String
    var keyPath: AnyKeyPath
    var storageType: PersistentType
    var isUnique: Bool
    var isIndexed: Bool
    var defaultValue: Any?
}

internal struct _RelationshipProperty {
    var name: String
    var keyPath: AnyKeyPath
    
    var destinationEntity: any Entity.Type
    var isToMany: Bool
    var deleteRule: ReferenceAction?
}

internal struct _IndexedProperties {
    var names: Array<String>
}

internal struct _UniqueProperties {
    var names: Array<String>
}
