//
//  File.swift
//  
//
//  Created by Dave DeLong on 6/8/24.
//

import Foundation

public struct EntityConstraint<E: Entity> {
    
    internal enum Details {
        case foreignKey(source: PartialKeyPath<E>,
                        target: AnyKeyPath,
                        onUpdate: ReferenceAction?,
                        onDelete: ReferenceAction?)
        
        case unique(properties: Array<PartialKeyPath<E>>)
        
        case indexed(property: PartialKeyPath<E>)
    }
    
    internal let details: Details
    
    public static func reference<Target: Entity>(to base: KeyPath<E, EntityID<Target, Target.RawID>>, onUpdate: ReferenceAction? = nil, onDelete: ReferenceAction? = nil) -> Self {
        return .init(details: .foreignKey(source: base, 
                                          target: Target.idKeyPath,
                                          onUpdate: onUpdate,
                                          onDelete: onDelete))
    }
    
    public static func unique(_ keyPaths: PartialKeyPath<E>...) -> Self {
        return .init(details: .unique(properties: keyPaths))
    }
    
    public static func indexed<V>(_ keyPath: KeyPath<E, V>) -> Self {
        return .init(details: .indexed(property: keyPath))
    }
    
}

public enum ReferenceAction {
    case cascade
    case deny
    case setNull
    case revertToDefault
}
