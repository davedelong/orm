//
//  File.swift
//  
//
//  Created by Dave DeLong on 1/9/25.
//

import Foundation

public struct CompositeTypeDescription: StoredTypeDescription {
    public typealias Field = (String, AnyKeyPath, any StoredTypeDescription)
    
    public let name: String
    public let baseType: any StoredType.Type
    public let fields: Array<Field>
    
    public var isIdentifiable: Bool { baseType is any Identifiable.Type }
    
    public var transitiveTypeDescriptions: Array<any StoredTypeDescription> {
        return fields.map(\.2)
    }
    
    init<S: StoredType & AnyObject>(_ type: S.Type) throws(Schema.Error) {
        throw .storedTypeMustBeValueType(S.self)
    }
    
    init<S: StoredType>(_ type: S.Type) throws(Schema.Error) {
        self.baseType = type
        self.name = "\(S.self)"
        
        var fields = Array<Field>()
        
        for (name, keyPath) in S.fields {
            let fieldType = keyPath.erasedValueType
            
            if let storedType = fieldType as? any StoredType.Type {
                let description = try storedType.storedTypeDescription
                fields.append((name, keyPath, description))
            } else if let rawType = fieldType as? any RawRepresentable.Type, let desc = try rawType.storedTypeDescription {
                fields.append((name, keyPath, desc))
            } else {
                throw .unknownFieldType(S.self, name, keyPath, fieldType)
            }
        }
        
        if fields.isEmpty { throw .storedTypeIsEmpty(S.self) }
        
        let isIdentifiable = (S.self is any Identifiable.Type)
        if let (_, _, description) = fields.first(where: { $0.0 == "id" }) {
            guard isIdentifiable else {
                // a stored type with an "id" field must be Identifiable
                throw .storedTypeIsNotIdentifiable(S.self)
            }
            
            if description.isOptional { throw .identifierCannotBeOptional(S.self) }
            guard description is PrimitiveTypeDescription else { throw .identifierMustBePrimitive(S.self) }
            
        } else if isIdentifiable {
            throw .storedTypeMissingIdentifier(S.self)
        }
        
        for (name, keyPath, description) in fields {
            guard let multi = description as? MultiValueTypeDescription else { continue }
            guard let key = multi.keyType else { continue }
            
            if key is OptionalTypeDescription {
                throw .dictionaryKeyCannotBeOptional(S.self, name, keyPath, key.baseType)
            }
            
            if (key is PrimitiveTypeDescription) == false {
                throw .dictionaryKeyMustBePrimitive(S.self, name, keyPath, key.baseType)
            }
        }
        
        self.fields = fields
    }
    
}
