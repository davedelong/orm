//
//  PrimitiveTypeDescription.swift
//  ORM
//
//  Created by Dave DeLong on 3/15/25.
//

import Foundation

public struct PrimitiveTypeDescription: StoredTypeDescription {
    public var baseType: any StoredType.Type
    public var transitiveTypeDescriptions: Array<any StoredTypeDescription> { [] }
    
    init<T: StoredType>(_ type: T.Type) {
        baseType = T.self
    }
}

struct OptionalTypeDescription: StoredTypeDescription {
    var baseType: any StoredType.Type
    var wrappedType: any StoredTypeDescription
    var transitiveTypeDescriptions: Array<any StoredTypeDescription> { [wrappedType] }
    
    init<T: StoredType>(_ type: Optional<T>.Type) throws(Schema.Error) {
        baseType = Optional<T>.self
        wrappedType = try T.storedTypeDescription
    }
}

extension String: StoredType {
    static public var storedTypeDescription: any StoredTypeDescription {
        PrimitiveTypeDescription(Self.self)
    }
}

extension UUID: StoredType {
    static public var storedTypeDescription: any StoredTypeDescription {
        PrimitiveTypeDescription(Self.self)
    }
}

extension Bool: StoredType {
    static public var storedTypeDescription: any StoredTypeDescription {
        PrimitiveTypeDescription(Self.self)
    }
}

extension Int: StoredType {
    static public var storedTypeDescription: any StoredTypeDescription {
        PrimitiveTypeDescription(Self.self)
    }
}

extension Int8: StoredType {
    static public var storedTypeDescription: any StoredTypeDescription {
        PrimitiveTypeDescription(Self.self)
    }
}

extension Int16: StoredType {
    static public var storedTypeDescription: any StoredTypeDescription {
        PrimitiveTypeDescription(Self.self)
    }
}

extension Int32: StoredType {
    static public var storedTypeDescription: any StoredTypeDescription {
        PrimitiveTypeDescription(Self.self)
    }
}

extension Int64: StoredType {
    static public var storedTypeDescription: any StoredTypeDescription {
        PrimitiveTypeDescription(Self.self)
    }
}

extension UInt: StoredType {
    static public var storedTypeDescription: any StoredTypeDescription {
        PrimitiveTypeDescription(Self.self)
    }
}

extension UInt8: StoredType {
    static public var storedTypeDescription: any StoredTypeDescription {
        PrimitiveTypeDescription(Self.self)
    }
}

extension UInt16: StoredType {
    static public var storedTypeDescription: any StoredTypeDescription {
        PrimitiveTypeDescription(Self.self)
    }
}

extension UInt32: StoredType {
    static public var storedTypeDescription: any StoredTypeDescription {
        PrimitiveTypeDescription(Self.self)
    }
}

extension UInt64: StoredType {
    static public var storedTypeDescription: any StoredTypeDescription {
        PrimitiveTypeDescription(Self.self)
    }
}

extension Float: StoredType {
    static public var storedTypeDescription: any StoredTypeDescription {
        PrimitiveTypeDescription(Self.self)
    }
}

extension Double: StoredType {
    static public var storedTypeDescription: any StoredTypeDescription {
        PrimitiveTypeDescription(Self.self)
    }
}

extension Date: StoredType {
    static public var storedTypeDescription: any StoredTypeDescription {
        PrimitiveTypeDescription(Self.self)
    }
}

extension Data: StoredType {
    static public var storedTypeDescription: any StoredTypeDescription {
        PrimitiveTypeDescription(Self.self)
    }
}

extension RawRepresentable {
    
    static internal var storedTypeDescription: (any StoredTypeDescription)? {
        get throws(Schema.Error) {
            guard let storedRawType = RawValue.self as? any StoredType.Type else {
                return nil
            }
            return try storedRawType.storedTypeDescription
        }
    }
    
}
