//
//  File.swift
//  
//
//  Created by Dave DeLong on 6/2/24.
//

import Foundation

public protocol PersistentValue {
    static var missingValue: Self { get throws }
    static var semantics: _PersistentValueSemantics { get throws }
    static func coerce(_ value: Any) -> Self?
}

extension PersistentValue {
    public static var missingValue: Self {
        get throws { throw PersistentValueError.missingValue }
    }
    public static func coerce(_ value: Any) -> Self? { return value as? Self }
}

// any RawRepresentable with a RawValue: PersistentValue
extension RawRepresentable where Self: PersistentValue & CaseIterable, RawValue: PersistentValue {
    public static var missingValue: Self {
        get throws { .init(rawValue: try RawValue.missingValue)! }
    }
    public static var semantics: _PersistentValueSemantics {
        get throws {
            let base = try RawValue.semantics
            return .init(persistentType: base.persistentType, isMultiValue: base.isMultiValue)
        }
    }
    public static func coerce(_ value: Any) -> Self? {
        if let rr = value as? Self { return rr }
        if let raw = RawValue.coerce(value) { return .init(rawValue: raw) }
        return nil
    }
}

extension RawRepresentable where Self: PersistentValue, RawValue: PersistentValue {
    public static var missingValue: Self {
        get throws { .init(rawValue: try RawValue.missingValue)! }
    }
    public static var semantics: _PersistentValueSemantics {
        get throws {
            let base = try RawValue.semantics
            return .init(persistentType: base.persistentType, canBeNull: true, isMultiValue: base.isMultiValue)
        }
    }
    public static func coerce(_ value: Any) -> Self? {
        if let rr = value as? Self { return rr }
        if let raw = RawValue.coerce(value) { return .init(rawValue: raw) }
        return nil
    }
}

// any Codable value

extension Encodable where Self: PersistentValue & Decodable {
    public static var semantics: _PersistentValueSemantics { .init(persistentType: .codable) }
}

public struct _PersistentValueSemantics {
    internal let persistentType: PersistentType
    internal let canBeNull: Bool
    internal let isMultiValue: Bool
    internal var notNull: Bool { canBeNull == false }
    
    init(persistentType: PersistentType, canBeNull: Bool = false, isMultiValue: Bool = false) {
        self.persistentType = persistentType
        self.canBeNull = canBeNull
        self.isMultiValue = isMultiValue
    }
}

public enum PersistentType {
    case uuid
    case boolean
    case string
    case integer
    case floatingPoint
    case binary
    case timestamp
    case codable
    case composite(Array<EntityAttribute>)
    case collection
    
    case _entity
}

public protocol ForeignKeyValue: PersistentValue {
    static var targetEntity: any Entity.Type { get }
    static var targetKeyPath: AnyKeyPath { get }
}

extension Optional: ForeignKeyValue where Wrapped: ForeignKeyValue {
    public static var targetEntity: any Entity.Type { Wrapped.targetEntity }
    public static var targetKeyPath: AnyKeyPath { Wrapped.targetKeyPath }
}

extension Array: ForeignKeyValue where Element: ForeignKeyValue {
    public static var targetEntity: any Entity.Type { Element.targetEntity }
    public static var targetKeyPath: AnyKeyPath { Element.targetKeyPath }
}

extension Set: ForeignKeyValue where Element: ForeignKeyValue {
    public static var targetEntity: any Entity.Type { Element.targetEntity }
    public static var targetKeyPath: AnyKeyPath { Element.targetKeyPath }
}
