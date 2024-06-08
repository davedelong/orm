//
//  File.swift
//  
//
//  Created by Dave DeLong on 6/2/24.
//

import Foundation

public protocol Entity: PersistentValue, Identifiable where ID == EntityID<Self, RawID> {
    associatedtype RawID: PersistentValue
    
    static var entityDescription: EntityDescription<Self> { get }
    var id: EntityID<Self, RawID> { get }
    
//    init()
}

public struct EntityID<E: Entity, V: PersistentValue>: Hashable, PersistentValue, ForeignKeyValue {
    public static var semantics: _PersistentValueSemantics { V.semantics }
    internal static var targetEntity: any Entity.Type { E.self }
    internal static var targetKeyPath: AnyKeyPath { E.idKeyPath }
    
}

extension Entity {
    internal static var erasedEntityDescription: AnyEntityDescription { entityDescription }
    public static var entityDescription: EntityDescription<Self> { defaultEntityDescription }
    public static var defaultEntityDescription: EntityDescription<Self> { return .init() }
    
    internal static var idKeyPath: KeyPath<Self, Self.ID> { \.id }
    internal static var fields: Array<(String, PartialKeyPath<Self>, Any.Type)> { ORM.fields(of: Self.self) }
}

extension Entity {
    public static var semantics: _PersistentValueSemantics { .init(persistentType: .composite, canBeNull: false, isMultiValue: true) }
    internal static var idSemantics: _PersistentValueSemantics { Self.RawID.semantics }
    internal static var name: String { "\(Self.self)" }
}
