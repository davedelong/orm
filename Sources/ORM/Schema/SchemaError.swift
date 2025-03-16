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
                case (.storedTypeIsNotValueType(let l), .storedTypeIsNotValueType(let r)):
                    return l == r
                
                case (.identifierCannotBeOptional(let l), .identifierCannotBeOptional(let r)):
                    return l == r
                case (.identifierIsNotPrimitive(let l), .identifierIsNotPrimitive(let r)):
                    return l == r
                
                case (.unknownFieldType(let lType, let lName, _, _), .unknownFieldType(let rType, let rName, _, _)):
                    return lType == rType && lName == rName
                
                default:
                    return false
            }
        }
        
        case storedTypeMissingIdentifier(any StoredType.Type)
        case storedTypeIsEmpty(any StoredType.Type)
        case storedTypeIsNotIdentifiable(any StoredType.Type)
        case storedTypeIsNotValueType(any StoredType.Type)
        
        case identifierCannotBeOptional(any StoredType.Type)
        case identifierIsNotPrimitive(any StoredType.Type)
        
        case unknownFieldType(any StoredType.Type, String, AnyKeyPath, Any.Type)
    }
    
}
