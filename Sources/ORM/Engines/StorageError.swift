//
//  StorageError.swift
//  ORM
//
//  Created by Dave DeLong on 3/30/25.
//

public enum StorageError: Error, Equatable {
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
            
            case (.invalidFieldName(let lType, let lName, _), .invalidFieldName(let rType, let rName, _)):
                return lType == rType && lName.lowercased() == rName.lowercased()
            case (.unknownFieldType(let lType, let lName, _, _), .unknownFieldType(let rType, let rName, _, _)):
                return lType == rType && lName == rName
                
            case (.multiValueFieldsCannotBeOptional(let lType, let lField), .multiValueFieldsCannotBeOptional(let rType, let rField)):
                return lType == rType && lField.name == rField.name
                
            case (.optionalFieldCannotNestOptional(let lType, let lField), .optionalFieldCannotNestOptional(let rType, let rField)):
                return lType == rType && lField.name == rField.name
                
            case (.multiValueFieldsCannotBeNested(let lType, let lField), .multiValueFieldsCannotBeNested(let rType, let rField)):
                return lType == rType && lField.name == rField.name
                
            case (.dictionaryKeyCannotBeOptional(let lType, let lField), .dictionaryKeyCannotBeOptional(let rType, let rField)):
                return lType == rType && lField.name == rField.name
                
            case (.dictionaryKeyMustBePrimitive(let lType, let lField), .dictionaryKeyMustBePrimitive(let rType, let rField)):
                return lType == rType && lField.name == rField.name
                
            case (.multiValueFieldsCannotNestOptionals(let lType, let lField), .multiValueFieldsCannotNestOptionals(let rType, let rField)):
                return lType == rType && lField.name == rField.name
            
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
    
    case invalidFieldName(any StoredType.Type, String, AnyKeyPath)
    case unknownFieldType(any StoredType.Type, String, AnyKeyPath, Any.Type)
    
    case optionalFieldCannotNestOptional(any StoredType.Type, StoredField)
    
    case multiValueFieldsCannotBeOptional(any StoredType.Type, StoredField)
    case multiValueFieldsCannotBeNested(any StoredType.Type, StoredField)
    case multiValueFieldsCannotNestOptionals(any StoredType.Type, StoredField)
    
    case dictionaryKeyCannotBeOptional(any StoredType.Type, StoredField)
    case dictionaryKeyMustBePrimitive(any StoredType.Type, StoredField)
    
    case unknownStoredType(any StoredType)
    
    case unknown(any Error)
}
