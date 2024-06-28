//
//  File.swift
//  
//
//  Created by Dave DeLong on 6/2/24.
//

import Foundation

public protocol Storable {
    static var storageRepresentation: any StorageRepresentation<Self> { get }
    static var missingValue: Self? { get }
}

extension Storable {
    public static var missingValue: Self? { nil }
}

extension Storable {
    public static var storageRepresentation: any StorageRepresentation<Self> {
        return StoredRepresentation(Self.self)
    }
}

extension Storable where Self: RawRepresentable, RawValue: Storable {
    public static var storageRepresentation: any StorageRepresentation<Self> {
        BoxedRepresentation(inner: RawValue.storageRepresentation)
    }
}

extension Storable {
    
    internal static var properties: Array<(String, AnyKeyPath)> {
        return lookupLock.withLock { withLock_properties }
    }
    
    internal static var propertyLookup: Bimap<String, AnyKeyPath> {
        return lookupLock.withLock { withLock_lookup }
    }
    
    internal static var id: ObjectIdentifier { ObjectIdentifier(Self.self) }
    
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
