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

public struct PrimitiveRepresentation: StorageRepresentation/*, _StorageRepresentation*/ {
    internal let primitiveType: PrimitiveType
    
    public init(_ primitiveType: PrimitiveType) {
        self.primitiveType = primitiveType
    }
}

extension UUID: Storable {
    public static var storageRepresentation: some StorageRepresentation {
        PrimitiveRepresentation(.uuid)
    }
}

extension Bool: Storable {
    public static var storageRepresentation: some StorageRepresentation {
        PrimitiveRepresentation(.boolean)
    }
}

extension String: Storable {
    public static var storageRepresentation: some StorageRepresentation {
        PrimitiveRepresentation(.string)
    }
}

extension Int: Storable {
    public static var storageRepresentation: some StorageRepresentation {
        PrimitiveRepresentation(.integer)
    }
}

extension Int8: Storable {
    public static var storageRepresentation: some StorageRepresentation {
        PrimitiveRepresentation(.integer)
    }
}

extension Int16: Storable {
    public static var storageRepresentation: some StorageRepresentation {
        PrimitiveRepresentation(.integer)
    }
}

extension Int32: Storable {
    public static var storageRepresentation: some StorageRepresentation {
        PrimitiveRepresentation(.integer)
    }
}

extension Int64: Storable {
    public static var storageRepresentation: some StorageRepresentation {
        PrimitiveRepresentation(.integer)
    }
}

extension UInt: Storable {
    public static var storageRepresentation: some StorageRepresentation {
        PrimitiveRepresentation(.integer)
    }
}

extension UInt8: Storable {
    public static var storageRepresentation: some StorageRepresentation {
        PrimitiveRepresentation(.integer)
    }
}

extension UInt16: Storable {
    public static var storageRepresentation: some StorageRepresentation {
        PrimitiveRepresentation(.integer)
    }
}

extension UInt32: Storable {
    public static var storageRepresentation: some StorageRepresentation {
        PrimitiveRepresentation(.integer)
    }
}

extension UInt64: Storable {
    public static var storageRepresentation: some StorageRepresentation {
        PrimitiveRepresentation(.integer)
    }
}

extension Data: Storable {
    public static var storageRepresentation: some StorageRepresentation {
        PrimitiveRepresentation(.binary)
    }
}

extension URL: Storable {
    public static var storageRepresentation: some StorageRepresentation {
        PrimitiveRepresentation(.string)
    }
}

extension Date: Storable {
    public static var storageRepresentation: some StorageRepresentation {
        PrimitiveRepresentation(.timestamp)
    }
}

extension Double: Storable {
    public static var storageRepresentation: some StorageRepresentation {
        PrimitiveRepresentation(.floatingPoint)
    }
}

extension Float: Storable {
    public static var storageRepresentation: some StorageRepresentation {
        PrimitiveRepresentation(.floatingPoint)
    }
}

extension Float16: Storable {
    public static var storageRepresentation: some StorageRepresentation {
        PrimitiveRepresentation(.floatingPoint)
    }
}

extension Optional: Storable where Wrapped: Storable {
    public static var storageRepresentation: some StorageRepresentation {
        return OptionalStorage<Wrapped>()
    }
}

extension Array: Storable where Element: Storable {
    public static var storageRepresentation: some StorageRepresentation {
        return OrderedManyStorage<Element>()
    }
}

extension Set: Storable where Element: Storable {
    public static var storageRepresentation: some StorageRepresentation {
        return UnorderedManyStorage<Element>()
    }
}
