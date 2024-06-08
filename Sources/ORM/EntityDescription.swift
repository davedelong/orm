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
    internal var idKeyPath: KeyPath<E, E.ID> { \.id }
    public var attributes: Array<EntityAttribute<E>>
    public var constraints: Array<EntityConstraint<E>>
    
    internal var compositeEntities: Array<AnyEntityDescription>
    
    public var referencedEntities: Array<any Entity.Type> {
        return E.fields.compactMap { _, keyPath, type -> (any Entity.Type)? in
            guard let foreignKey = type as? ForeignKeyValue.Type else { return nil }
            let type = foreignKey.targetEntity
            guard type != Self.self else { return nil }
            return type
        }
    }
    
    internal init(entity: E.Type = E.self) {
        self.name = entity.name
        self.attributes = []
        self.constraints = []
        self.compositeEntities = []
        
        for (name, keyPath, type) in E.fields {
            if let persistentType = type as? PersistentValue.Type {
                let semantics = persistentType.semantics
                
                attributes.append(.init(name: name, semantics: semantics, keyPath: keyPath))
                
                if semantics.persistentType == .composite {
                    // we need a new composite table
                } else {
                    // "regular" attribute
                    if name != "id", let foreignKey = persistentType as? ForeignKeyValue.Type {
                        let constraint = EntityConstraint<E>(details: .foreignKey(source: keyPath,
                                                                                  target: foreignKey.targetKeyPath,
                                                                                  isWeak: semantics.canBeNull))
                        constraints.append(constraint)
                    }
                }
                
            } else {
                fatalError("\(E.name).\(name) is not a persistable type")
            }
        }
        
        if attributes.contains(where: { $0.name == "id" }) == false {
            fatalError("\(E.self) does not contain a stored property called 'id'")
        }
    }
    
    public func constraint(_ newConstraint: EntityConstraint<E>) -> Self {
        var copy = self
        copy.constraints.append(newConstraint)
        return copy
    }
}
