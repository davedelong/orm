//
//  PrimitiveTypeDescription.swift
//  ORM
//
//  Created by Dave DeLong on 3/15/25.
//

import Foundation
import SQLiteSyntax

public struct PrimitiveTypeDescription: StoredTypeDescription {
    public var baseType: any StoredType.Type
    public var transitiveTypeDescriptions: Array<any StoredTypeDescription> { [] }
    
    internal let sqliteTypeName: TypeName
    
    init<T: StoredType>(_ type: T.Type, typeName: TypeName) {
        baseType = T.self
        sqliteTypeName = typeName
    }
}

struct OptionalTypeDescription: StoredTypeDescription {
    var baseType: any StoredType.Type
    var wrappedType: any StoredTypeDescription
    var transitiveTypeDescriptions: Array<any StoredTypeDescription> { [wrappedType] }
    
    init<T: StoredType>(_ type: Optional<T>.Type) throws(StorageError) {
        baseType = Optional<T>.self
        wrappedType = try T.storedTypeDescription
    }
}

extension Character: StoredType {
    static public var storedTypeDescription: any StoredTypeDescription {
        PrimitiveTypeDescription(Self.self, typeName: .text)
    }
}

extension String: StoredType {
    static public var storedTypeDescription: any StoredTypeDescription {
        PrimitiveTypeDescription(Self.self, typeName: .text)
    }
}

extension UUID: StoredType {
    static public var storedTypeDescription: any StoredTypeDescription {
        PrimitiveTypeDescription(Self.self, typeName: .text)
    }
}

extension Bool: StoredType {
    static public var storedTypeDescription: any StoredTypeDescription {
        PrimitiveTypeDescription(Self.self, typeName: .integer)
    }
}

extension Int: StoredType {
    static public var storedTypeDescription: any StoredTypeDescription {
        PrimitiveTypeDescription(Self.self, typeName: .integer)
    }
}

extension Int8: StoredType {
    static public var storedTypeDescription: any StoredTypeDescription {
        PrimitiveTypeDescription(Self.self, typeName: .integer)
    }
}

extension Int16: StoredType {
    static public var storedTypeDescription: any StoredTypeDescription {
        PrimitiveTypeDescription(Self.self, typeName: .integer)
    }
}

extension Int32: StoredType {
    static public var storedTypeDescription: any StoredTypeDescription {
        PrimitiveTypeDescription(Self.self, typeName: .integer)
    }
}

extension Int64: StoredType {
    static public var storedTypeDescription: any StoredTypeDescription {
        PrimitiveTypeDescription(Self.self, typeName: .integer)
    }
}

extension UInt: StoredType {
    static public var storedTypeDescription: any StoredTypeDescription {
        PrimitiveTypeDescription(Self.self, typeName: .integer)
    }
}

extension UInt8: StoredType {
    static public var storedTypeDescription: any StoredTypeDescription {
        PrimitiveTypeDescription(Self.self, typeName: .integer)
    }
}

extension UInt16: StoredType {
    static public var storedTypeDescription: any StoredTypeDescription {
        PrimitiveTypeDescription(Self.self, typeName: .integer)
    }
}

extension UInt32: StoredType {
    static public var storedTypeDescription: any StoredTypeDescription {
        PrimitiveTypeDescription(Self.self, typeName: .integer)
    }
}

extension UInt64: StoredType {
    static public var storedTypeDescription: any StoredTypeDescription {
        PrimitiveTypeDescription(Self.self, typeName: .integer)
    }
}

extension Float: StoredType {
    static public var storedTypeDescription: any StoredTypeDescription {
        PrimitiveTypeDescription(Self.self, typeName: .real)
    }
}

extension Double: StoredType {
    static public var storedTypeDescription: any StoredTypeDescription {
        PrimitiveTypeDescription(Self.self, typeName: .real)
    }
}

extension Decimal: StoredType {
    static public var storedTypeDescription: any StoredTypeDescription {
        PrimitiveTypeDescription(Self.self, typeName: .numeric)
    }
}

extension Date: StoredType {
    static public var storedTypeDescription: any StoredTypeDescription {
        PrimitiveTypeDescription(Self.self, typeName: .text)
    }
}

extension Data: StoredType {
    static public var storedTypeDescription: any StoredTypeDescription {
        PrimitiveTypeDescription(Self.self, typeName: .blob)
    }
}

extension RawRepresentable {
    
    static internal var storedTypeDescription: (any StoredTypeDescription)? {
        get throws(StorageError) {
            guard let storedRawType = RawValue.self as? any StoredType.Type else {
                return nil
            }
            return try storedRawType.storedTypeDescription
        }
    }
    
}
