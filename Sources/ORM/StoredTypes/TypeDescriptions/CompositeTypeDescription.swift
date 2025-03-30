//
//  File.swift
//  
//
//  Created by Dave DeLong on 1/9/25.
//

import Foundation

public struct CompositeTypeDescription: StoredTypeDescription {
    public let name: String
    public let baseType: any StoredType.Type
    public let fields: Array<StoredField>
    
    public var isIdentifiable: Bool { baseType is any Identifiable.Type }
    
    public var transitiveTypeDescriptions: Array<any StoredTypeDescription> {
        return fields.map(\.description)
    }
    
    init<S: StoredType & AnyObject>(_ type: S.Type) throws(Schema.Error) {
        throw .storedTypeMustBeValueType(S.self)
    }
    
    init<S: StoredType>(_ type: S.Type) throws(Schema.Error) {
        self.baseType = type
        self.name = "\(S.self)"
        self.fields = try S.storedFields
        
        if fields.isEmpty { throw .storedTypeIsEmpty(S.self) }
        try validateIdentifiable()
        for field in fields {
            try field.validate(on: baseType)
        }
    }
    
    private func validateIdentifiable() throws(Schema.Error) {
        let isIdentifiable = (baseType is any Identifiable.Type)
        if let field = fields.first(where: { $0.name == "id" }) {
            guard isIdentifiable else {
                // a stored type with an "id" field must be Identifiable
                throw .storedTypeIsNotIdentifiable(baseType)
            }
            
            if field.description.isOptional { throw .identifierCannotBeOptional(baseType) }
            guard field.description is PrimitiveTypeDescription else { throw .identifierMustBePrimitive(baseType) }
            
        } else if isIdentifiable {
            throw .storedTypeMissingIdentifier(baseType)
        }
    }
}

extension StoredField {
    
    func validate(on baseType: any StoredType.Type) throws(Schema.Error) {
        
        if let opt = description as? OptionalTypeDescription {
            if opt.wrappedType is MultiValueTypeDescription {
                throw .multiValueFieldsCannotBeOptional(baseType, self)
            }
            
            if opt.wrappedType is OptionalTypeDescription {
                throw .optionalFieldCannotNestOptional(baseType, self)
            }
        }
        
        if let multi = description as? MultiValueTypeDescription {
            // disallow eg Arrays of Arrays
            if multi.valueType is MultiValueTypeDescription {
                throw .multiValueFieldsCannotBeNested(baseType, self)
            }
            if multi.valueType is OptionalTypeDescription {
                throw .multiValueFieldsCannotNestOptionals(baseType, self)
            }
            
            if let key = multi.keyType {
                // dictionary field
                
                if key is OptionalTypeDescription {
                    throw .dictionaryKeyCannotBeOptional(baseType, self)
                }
                
                if (key is PrimitiveTypeDescription) == false {
                    throw .dictionaryKeyMustBePrimitive(baseType, self)
                }
            }
            
        }
    }
    
}
