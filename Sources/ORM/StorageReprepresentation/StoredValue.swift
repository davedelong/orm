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
