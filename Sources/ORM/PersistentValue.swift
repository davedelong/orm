//
//  File.swift
//  
//
//  Created by Dave DeLong on 6/2/24.
//

import Foundation

public protocol PersistentValue { 
    static var semantics: _PersistentValueSemantics { get }
}

extension UUID: PersistentValue { 
    public static let semantics: _PersistentValueSemantics = .init(persistentType: .uuid)
}
extension String: PersistentValue {
    public static let semantics: _PersistentValueSemantics = .init(persistentType: .string(maxLength: nil))
}
extension Int: PersistentValue {
    public static let semantics: _PersistentValueSemantics = .init(persistentType: .integer)
}
extension Int8: PersistentValue {
    public static let semantics: _PersistentValueSemantics = .init(persistentType: .integer)
}
extension Int16: PersistentValue {
    public static let semantics: _PersistentValueSemantics = .init(persistentType: .integer)
}
extension Int32: PersistentValue {
    public static let semantics: _PersistentValueSemantics = .init(persistentType: .integer)
}
extension Int64: PersistentValue {
    public static let semantics: _PersistentValueSemantics = .init(persistentType: .integer)
}
extension UInt: PersistentValue {
    public static let semantics: _PersistentValueSemantics = .init(persistentType: .integer)
}
extension UInt8: PersistentValue {
    public static let semantics: _PersistentValueSemantics = .init(persistentType: .integer)
}
extension UInt16: PersistentValue {
    public static let semantics: _PersistentValueSemantics = .init(persistentType: .integer)
}
extension UInt32: PersistentValue {
    public static let semantics: _PersistentValueSemantics = .init(persistentType: .integer)
}
extension UInt64: PersistentValue {
    public static let semantics: _PersistentValueSemantics = .init(persistentType: .integer)
}
extension Data: PersistentValue {
    public static let semantics: _PersistentValueSemantics = .init(persistentType: .binary)
}
extension URL: PersistentValue {
    public static let semantics: _PersistentValueSemantics = .init(persistentType: .string(maxLength: nil))
}
extension Date: PersistentValue {
    public static let semantics: _PersistentValueSemantics = .init(persistentType: .timestamp)
}
extension Double: PersistentValue {
    public static let semantics: _PersistentValueSemantics = .init(persistentType: .floatingPoint)
}
extension Float: PersistentValue {
    public static let semantics: _PersistentValueSemantics = .init(persistentType: .floatingPoint)
}
extension Float16: PersistentValue {
    public static let semantics: _PersistentValueSemantics = .init(persistentType: .floatingPoint)
}

// generates a nullable field
extension Optional: PersistentValue where Wrapped: PersistentValue {
    public static var semantics: _PersistentValueSemantics {
        let base = Wrapped.semantics
        return .init(persistentType: base.persistentType, canBeNull: true, isMultiValue: base.isMultiValue)
    }
}

// any RawRepresentable with a RawValue: PersistentValue
extension RawRepresentable where Self: PersistentValue & CaseIterable, RawValue: PersistentValue {
    public static var semantics: _PersistentValueSemantics {
        let base = RawValue.semantics
        return .init(persistentType: base.persistentType, isMultiValue: base.isMultiValue)
    }
}

extension RawRepresentable where Self: PersistentValue, RawValue: PersistentValue {
    public static var semantics: _PersistentValueSemantics {
        let base = RawValue.semantics
        return .init(persistentType: base.persistentType, canBeNull: true, isMultiValue: base.isMultiValue)
    }
}

// any Codable value

extension Encodable where Self: PersistentValue & Decodable {
    public static var semantics: _PersistentValueSemantics { .init(persistentType: .codable) }
}

// generates an intermediate table with 3 columns:
// 1. foreign key to owner
// 2. order value
// 3. value-or-foreign-key to element
// with a unique index on (owner id, order value)
extension Array: PersistentValue where Element: PersistentValue {
    public static var semantics: _PersistentValueSemantics { .init(persistentType: .composite, isMultiValue: true) }
}

// generates an intermediate table with 2 columns:
// 1. foreign key to owner
// 2. value-or-foreign-key to element
// with a unique index on (owner id, value-or-foreign-key)
extension Set: PersistentValue where Element: PersistentValue {
    public static var semantics: _PersistentValueSemantics { .init(persistentType: .composite, isMultiValue: true) }
}

// generates an intermediate table with 3 columns:
// 1. foreign key to owner
// 2. order value
// 3. value-or-foreign-key to element
// with unique indexes on (owner id, order value) and (owner id, value-or-foreign-key)
// extension OrderedSet: PersistenValue where Element: PersistentValue {
//    public static var semantics: _PersistentValueSemantics { .init(persistentType: .composite, canBeNull: fals, isMultiValue: true) }
//}

// generates an intermediate table with 3 columns:
// 1. foreign key to owner
// 2. key-or-foreign-key-to-key
// 3. value-or-foreign-key-to-value
// with a unique index on (owner id, key name)
extension Dictionary: PersistentValue where Key: PersistentValue, Value: PersistentValue {
    public static var semantics: _PersistentValueSemantics { .init(persistentType: .composite, isMultiValue: true) }
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

public enum PersistentType: Equatable {
    case uuid
    case string(maxLength: Int?)
    case integer
    case floatingPoint
    case binary
    case timestamp
    case codable
    case composite
}

internal protocol ForeignKeyValue: PersistentValue {
    static var targetEntity: any Entity.Type { get }
    static var targetKeyPath: AnyKeyPath { get }
}

extension Optional: ForeignKeyValue where Wrapped: ForeignKeyValue {
    static var targetEntity: any Entity.Type { Wrapped.targetEntity }
    static var targetKeyPath: AnyKeyPath { Wrapped.targetKeyPath }
}

extension Array: ForeignKeyValue where Element: ForeignKeyValue {
    static var targetEntity: any Entity.Type { Element.targetEntity }
    static var targetKeyPath: AnyKeyPath { Element.targetKeyPath }
}

extension Set: ForeignKeyValue where Element: ForeignKeyValue {
    static var targetEntity: any Entity.Type { Element.targetEntity }
    static var targetKeyPath: AnyKeyPath { Element.targetKeyPath }
}
