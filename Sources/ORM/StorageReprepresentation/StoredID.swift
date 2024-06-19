//
//  File.swift
//  
//
//  Created by Dave DeLong on 6/15/24.
//

import Foundation

public struct StoredID<E: Storable, V: EntityIDType>: Hashable, StoredValue, PersistentValue, ForeignKeyValue {
    public static var semantics: _PersistentValueSemantics { V.semantics }
    public static func coerce(_ value: Any) -> StoredID<E, V>? {
        if let id = value as? Self { return id }
        if let raw = V.coerce(value) { return .init(rawValue: raw) }
        return nil
    }
    
    public static var targetEntity: any Storable.Type { E.self }
    public static var targetKeyPath: AnyKeyPath { E.idKeyPath }
    
    internal var actualValue: V?
    
    public var rawValue: V {
        get { actualValue! }
        set { actualValue = newValue }
    }
    
    public init(rawValue: V) {
        self.actualValue = rawValue
    }
    
    public init() {
        self.actualValue = nil
    }
}

public enum EntityIDBehavior {
    case autogenerate
    case manual
}

public protocol EntityIDType: PersistentValue & Hashable {
    static var behavior: EntityIDBehavior { get }
}

extension StoredID: EntityIDType {
    public static var behavior: EntityIDBehavior { V.behavior }
}

extension UUID: EntityIDType {
    public static var behavior: EntityIDBehavior { .autogenerate }
}

extension String: EntityIDType {
    public static var behavior: EntityIDBehavior { .manual }
}
extension Int: EntityIDType {
    public static var behavior: EntityIDBehavior { .autogenerate }
}
extension Int8: EntityIDType {
    public static var behavior: EntityIDBehavior { .autogenerate }
}
extension Int16: EntityIDType {
    public static var behavior: EntityIDBehavior { .autogenerate }
}
extension Int32: EntityIDType {
    public static var behavior: EntityIDBehavior { .autogenerate }
}
extension Int64: EntityIDType {
    public static var behavior: EntityIDBehavior { .autogenerate }
}
extension UInt: EntityIDType {
    public static var behavior: EntityIDBehavior { .autogenerate }
}
extension UInt8: EntityIDType {
    public static var behavior: EntityIDBehavior { .autogenerate }
}
extension UInt16: EntityIDType {
    public static var behavior: EntityIDBehavior { .autogenerate }
}
extension UInt32: EntityIDType {
    public static var behavior: EntityIDBehavior { .autogenerate }
}
extension UInt64: EntityIDType {
    public static var behavior: EntityIDBehavior { .autogenerate }
}
