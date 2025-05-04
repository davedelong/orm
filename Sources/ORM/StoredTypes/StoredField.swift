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
    
    internal enum Kind {
        case primitive
        case reference
        case multiValue
        
        init(_ type: any StoredTypeDescription) {
            if type is PrimitiveTypeDescription {
                self = .primitive
            } else if type is CompositeTypeDescription {
                self = .reference
            } else if type is MultiValueTypeDescription {
                self = .multiValue
            } else if let o = type as? OptionalTypeDescription {
                self = Kind(o.wrappedType)
            } else {
                fatalError("UNKNOWN TYPE DESCRIPTION \(type)")
            }
        }
    }
    
    public let name: String
    public let keyPath: AnyKeyPath
    public let description: any StoredTypeDescription
    
    internal let kind: Kind
    internal let isOptional: Bool
    
    internal init(baseType: any StoredType.Type,
         name: String,
         keyPath: AnyKeyPath) throws(StorageError) {
        
        let fieldType = keyPath.erasedValueType
        
        self.name = name
        self.keyPath = keyPath
        self.isOptional = fieldType is OptionalType
        
        if let storedType = fieldType as? any StoredType.Type {
            let description = try storedType.storedTypeDescription
            self.description = description
            self.kind = Kind(description)
            
        } else if let rawType = fieldType as? any RawRepresentable.Type, let desc = try rawType.storedTypeDescription {
            self.description = desc
            self.kind = Kind(desc)
            
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
