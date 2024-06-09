//
//  File.swift
//  
//
//  Created by Dave DeLong on 6/8/24.
//

import Foundation

public struct EntityAttribute<E: Entity> {
    public var name: String
    internal let semantics: _PersistentValueSemantics
    internal let keyPath: PartialKeyPath<E>
    internal let storedType: Any.Type
    internal var defaultValue: Any?
    
    public var isNullable: Bool { semantics.canBeNull }
    public var valueType: PersistentType { semantics.persistentType }
    public var isMultiValue: Bool { semantics.isMultiValue }
    
    internal var referencedEntity: (any Entity.Type)? {
        if valueType == .composite, let persistentValue = storedType as? (any Entity).Type {
            
        }
        
        if let foreignKey = storedType as? ForeignKeyValue.Type {
            let type = foreignKey.targetEntity
            if type != E.self { return type }
        }
        
        return nil
    }
    
    internal var compositeEntity: AnyEntityDescription? {
        nil
    }
    
}
