//
//  File.swift
//  
//
//  Created by Dave DeLong on 6/2/24.
//

import Foundation

public protocol Entity: Identifiable where ID == EntityID<Self, RawID> {
    associatedtype RawID: EntityIDType
    
    static var entityDescription: EntityDescription<Self> { get throws }
}

extension Entity {
    internal static var erasedEntityDescription: AnyEntityDescription {
        get throws { try entityDescription }
    }
    internal static var erasedDefaultEntityDescription: AnyEntityDescription {
        get throws { try defaultEntityDescription }
    }
    
    public static var entityDescription: EntityDescription<Self> {
        get throws { try defaultEntityDescription }
    }
    public static var defaultEntityDescription: EntityDescription<Self> {
        get throws { return try .init() }
    }
    
    internal static var idKeyPath: KeyPath<Self, Self.ID> { \.id }
    internal static var storedProperties: Array<(String, PartialKeyPath<Self>)> { ORM.fields(of: Self.self) }
}

extension Entity {
    internal static var idSemantics: _PersistentValueSemantics {
        get throws { try Self.RawID.semantics }
    }
    internal static var name: String { "\(Self.self)" }
}
