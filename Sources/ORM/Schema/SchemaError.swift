//
//  File.swift
//  ORM
//
//  Created by Dave DeLong on 3/16/25.
//

import Foundation

extension Schema {
    
    public enum Error: Swift.Error, Equatable {
        public static func ==(lhs: Self, rhs: Self) -> Bool {
            switch (lhs, rhs) {
                case (.storedTypeMissingIdentifier(let l), .storedTypeMissingIdentifier(let r)):
                    return l == r
                case (.storedTypeIsEmpty(let l), .storedTypeIsEmpty(let r)):
                    return l == r
                case (.storedTypeIsNotIdentifiable(let l), .storedTypeIsNotIdentifiable(let r)):
                    return l == r
                case (.storedTypeMustBeValueType(let l), .storedTypeMustBeValueType(let r)):
                    return l == r
                
                case (.identifierCannotBeOptional(let l), .identifierCannotBeOptional(let r)):
                    return l == r
                case (.identifierMustBePrimitive(let l), .identifierMustBePrimitive(let r)):
                    return l == r
                
                case (.unknownFieldType(let lType, let lName, _, _), .unknownFieldType(let rType, let rName, _, _)):
                    return lType == rType && lName == rName
                    
                case (.multiValueFieldsCannotBeOptional(let lType, let lName, _, _), .multiValueFieldsCannotBeOptional(let rType, let rName, _, _)):
                    return lType == rType && lName == rName
                    
                case (.dictionaryKeyCannotBeOptional(let lType, let lName, _, _), .dictionaryKeyCannotBeOptional(let rType, let rName, _, _)):
                    return lType == rType && lName == rName
                    
                case (.dictionaryKeyMustBePrimitive(let lType, let lName, _, _), .dictionaryKeyMustBePrimitive(let rType, let rName, _, _)):
                    return lType == rType && lName == rName
                
                default:
                    return false
            }
        }
        
        case storedTypeMissingIdentifier(any StoredType.Type)
        case storedTypeIsEmpty(any StoredType.Type)
        case storedTypeIsNotIdentifiable(any StoredType.Type)
        case storedTypeMustBeValueType(any StoredType.Type)
        
        case identifierCannotBeOptional(any StoredType.Type)
        case identifierMustBePrimitive(any StoredType.Type)
        
        case unknownFieldType(any StoredType.Type, String, AnyKeyPath, Any.Type)
        
        case multiValueFieldsCannotBeOptional(any StoredType.Type, String, AnyKeyPath, Any.Type)
        
        case dictionaryKeyCannotBeOptional(any StoredType.Type, String, AnyKeyPath, Any.Type)
        case dictionaryKeyMustBePrimitive(any StoredType.Type, String, AnyKeyPath, Any.Type)
    }
    
}
