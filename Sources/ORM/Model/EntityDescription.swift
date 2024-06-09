//
//  File.swift
//  
//
//  Created by Dave DeLong on 6/8/24.
//

import Foundation

public protocol AnyEntityDescription {
    var name: String { get }
    var referencedEntities: Array<any Entity.Type> { get }
}

public struct EntityDescription<E: Entity>: AnyEntityDescription {
    public var name: String
    internal let idKeyPath: KeyPath<E, E.ID>
    public var attributes: Array<EntityAttribute<E>>
    public var constraints: Array<EntityConstraint<E>>
    
    internal var compositeEntities: Array<AnyEntityDescription>
    
    public var referencedEntities: Array<any Entity.Type> {
        return attributes.compactMap(\.referencedEntity)
    }
    
    internal init(entity: E.Type = E.self) {
        self.name = entity.name
        self.attributes = []
        self.constraints = []
        self.compositeEntities = []
        
        for (name, keyPath, type) in E.storedProperties {
            guard let persistentType = type as? PersistentValue.Type else {
                fatalError("\(E.name).\(name) is not a persistable type")
            }
            
            let semantics = persistentType.semantics
            
            attributes.append(.init(name: name, semantics: semantics, keyPath: keyPath, storedType: type))
            
            guard name != "id" else { continue }
            
            if semantics.isMultiValue {
                // multi-value things typically need a join table
                if let foreignKey = persistentType as? ForeignKeyValue.Type {
                    // multi-value foreign key
                } else if let entity = persistentType as? any Entity.Type {
                    // multi-value foreign key
                } else if semantics.persistentType == .composite {
                    // multi-value composite, like a dictionary
                } else {
                    // multi-value "primitive"
                }
            } else {
                if let foreignKey = persistentType as? ForeignKeyValue.Type {
                    // single-value foreign key
                } else if let entity = persistentType as? any Entity.Type {
                    // single-value foreign key
                } else if semantics.persistentType == .composite {
                    // single-value composite
                } else {
                    // single-value "primitive"
                }
            }
        }
        
        guard let id = attributes.first(where: { $0.name == "id" }) else {
            fatalError("\(E.self) does not contain a stored property called 'id'")
        }
        self.idKeyPath = id.keyPath as! KeyPath<E, E.ID>
    }
    
    public func constraint(_ newConstraint: EntityConstraint<E>) -> Self {
        var copy = self
        copy.constraints.append(newConstraint)
        return copy
    }
}
