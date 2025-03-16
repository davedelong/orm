//
//  Schema.swift
//  ORM
//
//  Created by Dave DeLong on 3/15/25.
//

public struct Schema {
    
    public let storedTypes: Array<any StoredTypeDescription>
    
    public var compositeTypes: Array<CompositeTypeDescription> {
        storedTypes.compactMap({ $0 as? CompositeTypeDescription })
    }
    
    public var primitiveTypes: Array<PrimitiveTypeDescription> {
        storedTypes.compactMap({ $0 as? PrimitiveTypeDescription })
    }
    
    public var baseTypes: Array<any StoredType.Type> {
        storedTypes.map(\.baseType)
    }
    
    public init<F: StoredType, each S: StoredType>(_ first: F.Type, _ types: repeat (each S).Type) throws(Error) {
        var unprocessedTypeDescriptions = Array<any StoredTypeDescription>()
        unprocessedTypeDescriptions.append(try first.storedTypeDescription)
        repeat unprocessedTypeDescriptions.append(try (each types).storedTypeDescription)
        
        var processedTypes = Set<ObjectIdentifier>()
        var storageDescriptions = Array<any StoredTypeDescription>()
        
        repeat {
            let description = unprocessedTypeDescriptions.removeFirst()
            let typeIdentifier = ObjectIdentifier(description.baseType)
            guard processedTypes.insert(typeIdentifier).inserted == true else { continue }
            
            storageDescriptions.append(description)
            
            unprocessedTypeDescriptions.append(contentsOf: description.transitiveTypeDescriptions)
            
        } while unprocessedTypeDescriptions.isEmpty == false
        
        self.storedTypes = storageDescriptions
    }
    
}
