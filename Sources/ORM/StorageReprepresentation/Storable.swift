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

extension Storable where Representation == StoredRepresentation<Self> {
    
    public static var storageRepresentation: Representation {
        return StoredRepresentation(Self.self)
    }
    
}

extension Storable {
    internal static var idKeyPath: KeyPath<Self, Self.ID> { \.id }
    
    internal static var idSemantics: _PersistentValueSemantics {
        Self.RawID.semantics
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
