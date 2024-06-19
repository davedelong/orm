//
//  File.swift
//  
//
//  Created by Dave DeLong on 6/2/24.
//

import Foundation

public protocol Storable: Identifiable where ID == StoredID<Self, RawID> {
    associatedtype Representation: StorageRepresentation
    associatedtype RawID: EntityIDType
    
    static var storageRepresentation: Representation { get }
}

extension Storable {
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
    
    public static func build() throws -> EntityBuilder<Self> { try .init() }
    internal static func buildDescription() throws -> _EntityDescription { try build()._desc }
}

extension Storable {
    internal static var idKeyPath: KeyPath<Self, Self.ID> { \.id }
    
    internal static var idSemantics: _PersistentValueSemantics {
        get throws { try Self.RawID.semantics }
    }
    internal static var name: String { "\(Self.self)" }
}

extension Storable {
    
    internal static var properties: Array<(String, AnyKeyPath)> {
        return lookupLock.withLock { withLock_properties }
    }
    
    internal static var propertyLookup: Bimap<String, AnyKeyPath> {
        return lookupLock.withLock { withLock_lookup }
    }
    
    private static var id: ObjectIdentifier { ObjectIdentifier(Self.self) }
    
    private static var withLock_properties: Array<(String, AnyKeyPath)> {
        if let e = lookupSequenceCache[id] { return e }
        let fields = ORM.fields(of: Self.self)
        lookupSequenceCache[id] = fields
        return fields
    }
    
    private static var withLock_lookup: Bimap<String, AnyKeyPath> {
        if let e = lookupBimapCache[id] { return e }
        
        let props = withLock_properties
        let map = Bimap(props)
        lookupBimapCache[id] = map
        return map
    }
    
}

private let lookupLock = NSLock()
private var lookupSequenceCache = Dictionary<ObjectIdentifier, Array<(String, AnyKeyPath)>>()
private var lookupBimapCache = Dictionary<ObjectIdentifier, Bimap<String, AnyKeyPath>>()
