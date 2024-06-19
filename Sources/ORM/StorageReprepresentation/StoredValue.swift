//
//  File.swift
//  
//
//  Created by Dave DeLong on 6/19/24.
//

import Foundation

public protocol StoredValue {
    
    static var missingValue: Self { get throws }
    
    static func coerce(_ value: Any) -> Self?
    
}

extension StoredValue {
    
    public static var missingValue: Self {
        get throws { throw PersistentValueError.missingValue }
    }
    
    public static func coerce(_ value: Any) -> Self? { return value as? Self }
}

extension UUID: StoredValue { }
extension Bool: StoredValue { }
extension String: StoredValue { }
extension Int: StoredValue { }
extension Int8: StoredValue { }
extension Int16: StoredValue { }
extension Int32: StoredValue { }
extension Int64: StoredValue { }
extension UInt: StoredValue { }
extension UInt8: StoredValue { }
extension UInt16: StoredValue { }
extension UInt32: StoredValue { }
extension UInt64: StoredValue { }
extension Data: StoredValue { }
extension URL: StoredValue { }
extension Date: StoredValue { }
extension Double: StoredValue { }
extension Float: StoredValue { }
extension Float16: StoredValue { }
extension Optional: StoredValue where Wrapped: StoredValue { }
