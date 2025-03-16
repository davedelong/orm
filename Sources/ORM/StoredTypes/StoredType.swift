//
//  File.swift
//  
//
//  Created by Dave DeLong on 12/22/24.
//

import Foundation

public protocol StoredType {
    static var storedTypeDescription: any StoredTypeDescription {
        get throws(Schema.Error)
    }
}

extension StoredType {
    
    internal static var fields: Array<(String, PartialKeyPath<Self>)> {
        return ORM.fields(of: Self.self)
    }
    
    public static var storedTypeDescription: any StoredTypeDescription {
        get throws(Schema.Error) {
            try CompositeTypeDescription(Self.self)
        }
    }
    
}

extension StoredType where Self: AnyObject {
    
    public static var storedTypeDescription: any StoredTypeDescription {
        get throws(Schema.Error) {
            try CompositeTypeDescription(Self.self)
        }
    }
}

extension Optional: StoredType where Wrapped: StoredType {
    public static var storedTypeDescription: any StoredTypeDescription {
        get throws(Schema.Error) { try OptionalTypeDescription(Self.self) }
    }
}
