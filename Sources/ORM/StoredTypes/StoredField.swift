//
//  File.swift
//  ORM
//
//  Created by Dave DeLong on 3/30/25.
//

import Foundation

extension StoredType {
    
    internal static var storedFields: Array<StoredField> {
        get throws(StorageError) {
            var fields = Array<StoredField>()
            for (name, keyPath) in Self.fields {
                fields.append(try StoredField(baseType: Self.self, name: name, keyPath: keyPath))
            }
            return fields
        }
    }
    
    internal static var Fields: Fields<Self> { .init() }
    
}

public struct StoredField {
    
    public let name: String
    public let keyPath: AnyKeyPath
    public let description: any StoredTypeDescription
    
    internal init(baseType: any StoredType.Type,
         name: String,
         keyPath: AnyKeyPath) throws(StorageError) {
        
        let fieldType = keyPath.erasedValueType
        
        if let storedType = fieldType as? any StoredType.Type {
            let description = try storedType.storedTypeDescription
            self.name = name
            self.keyPath = keyPath
            self.description = description
            
        } else if let rawType = fieldType as? any RawRepresentable.Type, let desc = try rawType.storedTypeDescription {
            self.name = name
            self.keyPath = keyPath
            self.description = desc
            
        } else {
            throw StorageError.unknownFieldType(baseType, name, keyPath, fieldType)
        }
    }
    
}

@dynamicMemberLookup
internal struct Fields<S: StoredType> {
    
    subscript<V>(dynamicMember keyPath: KeyPath<S, V>) -> StoredField {
        get throws(StorageError) {
            guard let (name, keyPath) = S.fields.first(where: { $1 == keyPath }) else {
                throw .unknownFieldType(S.self, "", keyPath, V.self)
            }
            
            return try StoredField(baseType: S.self, name: name, keyPath: keyPath)
        }
    }
    
}
