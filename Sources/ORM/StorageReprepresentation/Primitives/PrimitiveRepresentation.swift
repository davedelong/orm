//
//  File.swift
//  
//
//  Created by Dave DeLong on 6/19/24.
//

import Foundation
import SQLKit

public struct PrimitiveType {
    public static let uuid = PrimitiveType(name: "uuid", rawType: .text)
    public static let boolean = PrimitiveType(name: "boolean", rawType: .smallint)
    public static let string = PrimitiveType(name: "string", rawType: .text)
    public static let smallInteger = PrimitiveType(name: "smallInteger", rawType: .smallint)
    public static let integer = PrimitiveType(name: "integer", rawType: .int)
    public static let floatingPoint = PrimitiveType(name: "floatingPoint", rawType: .real)
    public static let binary = PrimitiveType(name: "binary", rawType: .blob)
    public static let timestamp = PrimitiveType(name: "timestamp", rawType: .timestamp)
    public static let codable = PrimitiveType(name: "codable", rawType: .blob)
    
    internal let name: String
    internal let rawType: SQLDataType
}

public struct PrimitiveRepresentation<StoredType: Storable>: StorageRepresentation {
    
    public var name: String?
    internal let primitiveType: PrimitiveType
    
    public init(_ primitiveType: PrimitiveType) {
        self.primitiveType = primitiveType
    }
}

extension UUID: Storable {
    public static var storageRepresentation: any StorageRepresentation<Self> {
        PrimitiveRepresentation<UUID>(.uuid)
    }
}

extension Bool: Storable {
    public static var storageRepresentation: any StorageRepresentation<Self> {
        PrimitiveRepresentation<Self>(.boolean)
    }
}

extension String: Storable {
    public static var storageRepresentation: any StorageRepresentation<Self> {
        PrimitiveRepresentation<Self>(.string)
    }
}

extension Int: Storable {
    public static var storageRepresentation: any StorageRepresentation<Self> {
        PrimitiveRepresentation<Self>(.integer)
    }
}

extension Int8: Storable {
    public static var storageRepresentation: any StorageRepresentation<Self> {
        PrimitiveRepresentation<Self>(.integer)
    }
}

extension Int16: Storable {
    public static var storageRepresentation: any StorageRepresentation<Self> {
        PrimitiveRepresentation<Self>(.integer)
    }
}

extension Int32: Storable {
    public static var storageRepresentation: any StorageRepresentation<Self> {
        PrimitiveRepresentation<Self>(.integer)
    }
}

extension Int64: Storable {
    public static var storageRepresentation: any StorageRepresentation<Self> {
        PrimitiveRepresentation<Self>(.integer)
    }
}

extension UInt: Storable {
    public static var storageRepresentation: any StorageRepresentation<Self> {
        PrimitiveRepresentation<Self>(.integer)
    }
}

extension UInt8: Storable {
    public static var storageRepresentation: any StorageRepresentation<Self> {
        PrimitiveRepresentation<Self>(.integer)
    }
}

extension UInt16: Storable {
    public static var storageRepresentation: any StorageRepresentation<Self> {
        PrimitiveRepresentation<Self>(.integer)
    }
}

extension UInt32: Storable {
    public static var storageRepresentation: any StorageRepresentation<Self> {
        PrimitiveRepresentation<Self>(.integer)
    }
}

extension UInt64: Storable {
    public static var storageRepresentation: any StorageRepresentation<Self> {
        PrimitiveRepresentation<Self>(.integer)
    }
}

extension Data: Storable {
    public static var storageRepresentation: any StorageRepresentation<Self> {
        PrimitiveRepresentation<Self>(.binary)
    }
}

extension URL: Storable {
    public static var storageRepresentation: any StorageRepresentation<Self> {
        PrimitiveRepresentation<Self>(.string)
    }
}

extension Date: Storable {
    public static var storageRepresentation: any StorageRepresentation<Self> {
        PrimitiveRepresentation<Self>(.timestamp)
    }
}

extension Double: Storable {
    public static var storageRepresentation: any StorageRepresentation<Self> {
        PrimitiveRepresentation<Self>(.floatingPoint)
    }
}

extension Float: Storable {
    public static var storageRepresentation: any StorageRepresentation<Self> {
        PrimitiveRepresentation<Self>(.floatingPoint)
    }
}

extension Float16: Storable {
    public static var storageRepresentation: any StorageRepresentation<Self> {
        PrimitiveRepresentation<Self>(.floatingPoint)
    }
}

extension Optional: Storable where Wrapped: Storable {
    public static var storageRepresentation: any StorageRepresentation<Self> {
        return OptionalStorage<Wrapped>()
    }
}

extension Array: Storable where Element: Storable {
    public static var storageRepresentation: any StorageRepresentation<Self> {
        return OrderedManyStorage<Element>()
    }
    public static var missingValue: Array<Element>? { [] }
}

extension Set: Storable where Element: Storable {
    public static var storageRepresentation: any StorageRepresentation<Self> {
        return UnorderedManyStorage<Element>()
    }
    public static var missingValue: Set<Element>? { [] }
}
