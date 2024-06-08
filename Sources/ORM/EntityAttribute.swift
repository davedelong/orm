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
    
    public var isNullable: Bool { semantics.canBeNull }
    public var valueType: PersistentType { semantics.persistentType }
    public var isMultiValue: Bool { semantics.isMultiValue }
}
