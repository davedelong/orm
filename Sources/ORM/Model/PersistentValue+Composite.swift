//
//  File.swift
//  
//
//  Created by Dave DeLong on 6/15/24.
//

import Foundation

extension PersistentValue {
    
    public static var semantics: _PersistentValueSemantics {
        get throws {
            let fields = ORM.fields(of: Self.self)
            let attrs = try fields.map { try EntityAttribute(name: $0, keyPath: $1) }
            return .init(persistentType: .composite(attrs))
        }
    }
    
}

// generates an intermediate table with 3 columns:
// 1. foreign key to owner
// 2. order value
// 3. value-or-foreign-key to element
// with a unique index on (owner id, order value)
extension Array: PersistentValue where Element: PersistentValue {
    public static var missingValue: Self { [] }
    public static var semantics: _PersistentValueSemantics { .init(persistentType: .collection, isMultiValue: true) }
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
    public static var semantics: _PersistentValueSemantics { .init(persistentType: .collection, isMultiValue: true) }
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
//    public static var semantics: _PersistentValueSemantics { .init(persistentType: .collection, canBeNull: fals, isMultiValue: true) }
//}

// generates an intermediate table with 3 columns:
// 1. foreign key to owner
// 2. key-or-foreign-key-to-key
// 3. value-or-foreign-key-to-value
// with a unique index on (owner id, key name)
extension Dictionary: PersistentValue where Key: PersistentValue, Value: PersistentValue {
    public static var missingValue: Self { [:] }
    public static var semantics: _PersistentValueSemantics { .init(persistentType: .collection, isMultiValue: true) }
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
