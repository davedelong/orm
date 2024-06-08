//
//  File.swift
//  
//
//  Created by Dave DeLong on 6/8/24.
//

import Foundation

public struct EntityConstraint<E: Entity> {
    
    internal enum Details {
        case foreignKey(source: PartialKeyPath<E>, target: AnyKeyPath, isWeak: Bool)
        case unique(properties: Array<PartialKeyPath<E>>)
        case indexed(property: PartialKeyPath<E>)
    }
    
    internal let details: Details
    
    public static func strongReference<Target: Entity>(to base: KeyPath<E, EntityID<Target, Target.RawID>>) -> Self {
        return .init(details: .foreignKey(source: base, target: Target.idKeyPath, isWeak: false))
    }
    
    public static func weakReference<Target: Entity>(to base: KeyPath<E, EntityID<Target, Target.RawID>?>) -> Self {
        return .init(details: .foreignKey(source: base, target: Target.idKeyPath, isWeak: true))
    }
    
    public static func unique(_ keyPaths: PartialKeyPath<E>...) -> Self {
        return .init(details: .unique(properties: keyPaths))
    }
    
    public static func indexed<V>(_ keyPath: KeyPath<E, V>) -> Self {
        return .init(details: .indexed(property: keyPath))
    }
    
}

internal enum ForeignKeyBehavior {
    case cascade
    case deny
    case setNull
}
