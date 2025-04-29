//
//  MultiValueTypeDescription.swift
//  ORM
//
//  Created by Dave DeLong on 3/15/25.
//

public struct MultiValueTypeDescription: StoredTypeDescription {
    public var baseType: any StoredType.Type
    public var isOrdered: Bool
    public var keyType: StoredTypeDescription?
    public var valueType: StoredTypeDescription
    
    public var transitiveTypeDescriptions: Array<any StoredTypeDescription> {
        if let keyType { return [keyType, valueType] }
        return [valueType]
    }
}

extension Array: StoredType where Element: StoredType {
    public static var storedTypeDescription: any StoredTypeDescription {
        get throws(StorageError) {
            return MultiValueTypeDescription(baseType: Self.self,
                                             isOrdered: true,
                                             valueType: try Element.storedTypeDescription)
        }
    }
}

extension Set: StoredType where Element: StoredType {
    public static var storedTypeDescription: any StoredTypeDescription {
        get throws(StorageError) {
            return MultiValueTypeDescription(baseType: Self.self,
                                             isOrdered: false,
                                             valueType: try Element.storedTypeDescription)
        }
    }
}

extension Dictionary: StoredType where Key: StoredType, Value: StoredType {
    public static var storedTypeDescription: any StoredTypeDescription {
        get throws(StorageError) {
            return MultiValueTypeDescription(baseType: Self.self,
                                             isOrdered: false,
                                             keyType: try Key.storedTypeDescription,
                                             valueType: try Value.storedTypeDescription)
        }
    }
}
