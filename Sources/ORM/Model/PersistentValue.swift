//
//  File.swift
//  
//
//  Created by Dave DeLong on 6/2/24.
//

import Foundation

public protocol PersistentValue {
    static var missingValue: Self { get throws }
    static var semantics: _PersistentValueSemantics { get }
    static func coerce(_ value: Any) -> Self?
}

internal enum PersistentValueError: Error {
    case missingValue
}

extension PersistentValue {
    public static var missingValue: Self {
        get throws { throw PersistentValueError.missingValue }
    }
    public static func coerce(_ value: Any) -> Self? { return value as? Self }
}

extension UUID: PersistentValue { 
    public static let semantics: _PersistentValueSemantics = .init(persistentType: .uuid)
    public static func coerce(_ value: Any) -> UUID? {
        if let uuid = value as? UUID { return uuid }
        if let str = value as? String { return .init(uuidString: str) }
        return nil
    }
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
    public static func coerce(_ value: Any) -> Data? {
        if let data = value as? Data { return data }
        if let str = String.coerce(value) { return Data(base64Encoded: str) }
        return nil
    }
}
extension URL: PersistentValue {
    public static let semantics: _PersistentValueSemantics = .init(persistentType: .string(maxLength: nil))
    public static func coerce(_ value: Any) -> URL? {
        if let url = value as? URL { return url }
        if let str = String.coerce(value) { return URL(string: str) }
        return nil
    }
}
extension Date: PersistentValue {
    public static let semantics: _PersistentValueSemantics = .init(persistentType: .timestamp)
    public static func coerce(_ value: Any) -> Date? {
        if let date = value as? Date { return date }
        if let dbl = Double.coerce(value) { return Date(timeIntervalSince1970: dbl) }
        if let sec = Int.coerce(value) { return Date(timeIntervalSince1970: TimeInterval(sec)) }
        // TODO: string?
        return nil
    }
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
    public static var missingValue: Self { .none }
    public static var semantics: _PersistentValueSemantics {
        let base = Wrapped.semantics
        return .init(persistentType: base.persistentType, canBeNull: true, isMultiValue: base.isMultiValue)
    }
}

// any RawRepresentable with a RawValue: PersistentValue
extension RawRepresentable where Self: PersistentValue & CaseIterable, RawValue: PersistentValue {
    public static var missingValue: Self {
        get throws { .init(rawValue: try RawValue.missingValue)! }
    }
    public static var semantics: _PersistentValueSemantics {
        let base = RawValue.semantics
        return .init(persistentType: base.persistentType, isMultiValue: base.isMultiValue)
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
        let base = RawValue.semantics
        return .init(persistentType: base.persistentType, canBeNull: true, isMultiValue: base.isMultiValue)
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

// generates an intermediate table with 3 columns:
// 1. foreign key to owner
// 2. order value
// 3. value-or-foreign-key to element
// with a unique index on (owner id, order value)
extension Array: PersistentValue where Element: PersistentValue {
    public static var missingValue: Self { [] }
    public static var semantics: _PersistentValueSemantics { .init(persistentType: .composite, isMultiValue: true) }
    public static func coerce(_ value: Any) -> Self? {
        if let arr = value as? Self { return arr }
        if let anyArr = value as? Array<Any> {
            var final = Array()
            final.reserveCapacity(anyArr.count)
            for anyValue in anyArr {
                guard let element = Element.coerce(anyValue) else { return nil }
                final.append(element)
            }
            return final
        }
        return nil
    }
}

// generates an intermediate table with 2 columns:
// 1. foreign key to owner
// 2. value-or-foreign-key to element
// with a unique index on (owner id, value-or-foreign-key)
extension Set: PersistentValue where Element: PersistentValue {
    public static var missingValue: Self { [] }
    public static var semantics: _PersistentValueSemantics { .init(persistentType: .composite, isMultiValue: true) }
    public static func coerce(_ value: Any) -> Self? {
        if let arr = value as? Self { return arr }
        if let anyArr = value as? Set<AnyHashable> {
            var final = Set<Element>()
            final.reserveCapacity(anyArr.count)
            for anyValue in anyArr {
                guard let element = Element.coerce(anyValue) else { return nil }
                final.insert(element)
            }
            return final
        }
        if let anyArr = value as? Array<Any> {
            var final = Set<Element>()
            final.reserveCapacity(anyArr.count)
            for anyValue in anyArr {
                guard let element = Element.coerce(anyValue) else { return nil }
                final.insert(element)
            }
            return final
        }
        return nil
    }
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
    public static var missingValue: Self { [:] }
    public static var semantics: _PersistentValueSemantics { .init(persistentType: .composite, isMultiValue: true) }
    public static func coerce(_ value: Any) -> Self? {
        if let arr = value as? Self { return arr }
        if let anyDict = value as? Dictionary<AnyHashable, Any> {
            var final = Self()
            final.reserveCapacity(anyDict.count)
            for (anyKey, anyValue) in anyDict {
                guard let key = Key.coerce(anyKey) else { return nil }
                guard let val = Value.coerce(anyValue) else { return nil }
                final[key] = val
            }
            return final
        }
        return nil
    }
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
