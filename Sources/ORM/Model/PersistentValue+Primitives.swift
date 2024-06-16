//
//  File.swift
//  
//
//  Created by Dave DeLong on 6/15/24.
//

import Foundation

extension UUID: PersistentValue {
    public static let semantics: _PersistentValueSemantics = .init(persistentType: .uuid)
    public static func coerce(_ value: Any) -> UUID? {
        if let uuid = value as? UUID { return uuid }
        if let str = value as? String { return .init(uuidString: str) }
        return nil
    }
}
extension Bool: PersistentValue {
    public static let semantics: _PersistentValueSemantics = .init(persistentType: .boolean)
}
extension String: PersistentValue {
    public static let semantics: _PersistentValueSemantics = .init(persistentType: .string)
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
    public static let semantics: _PersistentValueSemantics = .init(persistentType: .string)
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
        get throws {
            let base = try Wrapped.semantics
            return .init(persistentType: base.persistentType, canBeNull: true, isMultiValue: base.isMultiValue)
        }
    }
}
