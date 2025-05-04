//
//  Schema.swift
//  ORM
//
//  Created by Dave DeLong on 3/15/25.
//

public struct Schema {
    
    public let storedTypes: Array<any StoredTypeDescription>
    
    public let compositeTypes: Array<CompositeTypeDescription>
    
    public var primitiveTypes: Array<PrimitiveTypeDescription> {
        storedTypes.compactMap({ $0 as? PrimitiveTypeDescription })
    }
    
    public var multiValueTypes: Array<MultiValueTypeDescription> {
        storedTypes.compactMap({ $0 as? MultiValueTypeDescription })
    }
    
    public let baseTypes: Array<any StoredType.Type>
    
    private let typeDescriptionLookup: Dictionary<ObjectIdentifier, CompositeTypeDescription>
    
    public init(_ first: any StoredType.Type, _ types: any StoredType.Type...) throws(StorageError) {
        let all = [first] + types
        try self.init(types: all)
    }
    
    public init(types: Array<any StoredType.Type>) throws(StorageError) {
        var unprocessedTypeDescriptions = Array<any StoredTypeDescription>()
        for type in types { unprocessedTypeDescriptions.append(try type.storedTypeDescription) }
        
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
        self.baseTypes = storageDescriptions.map(\.baseType)
        self.compositeTypes = storageDescriptions.compactMap({ $0 as? CompositeTypeDescription })
        
        self.typeDescriptionLookup = Dictionary(uniqueKeysWithValues: compositeTypes.map {
            (ObjectIdentifier($0.baseType), $0)
        })
    }
    
    internal func description(for value: any StoredType) -> CompositeTypeDescription? {
        let type = type(of: value)
        return typeDescriptionLookup[ObjectIdentifier(type)]
    }
    
}
