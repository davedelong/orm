//
//  CoreDataEngine.swift
//  ORM
//
//  Created by Dave DeLong on 3/16/25.
//

#if canImport(CoreData)
import CoreData

public actor CoreDataEngine: StorageEngine {
    
    internal let model: NSManagedObjectModel
    
    public init(schema: Schema) throws(Schema.Error) {
        model = NSManagedObjectModel()
        
        var entities = Array<NSEntityDescription>()
        for compositeType in schema.compositeTypes {
            let e = NSEntityDescription()
            e.name = compositeType.name
            e.properties = NSAttributeDescription.attributes(from: compositeType)
            
            if compositeType.isIdentifiable {
                e.uniquenessConstraints = [["id"]]
            }
            
            entities.append(e)
        }
        model.entities = entities
    }
    
}

extension NSAttributeDescription {
    
    fileprivate static func attributes(from description: CompositeTypeDescription) -> Array<NSAttributeDescription> {
        var all = Array<NSAttributeDescription>()
        
        for (name, _, description) in description.fields {
            if let attr = attribute(with: name, from: description) {
                all.append(attr)
            }
        }
        
        return all
    }
    
    private static func attribute(with name: String, from description: any StoredTypeDescription) -> NSAttributeDescription? {
        if let p = description as? PrimitiveTypeDescription {
            var type: NSAttributeType?
            switch p.baseType {
                case is Bool.Type: type = .booleanAttributeType
                case is Int.Type: type = .integer64AttributeType
                case is Int8.Type: type = .integer16AttributeType
                case is Int16.Type: type = .integer16AttributeType
                case is Int32.Type: type = .integer32AttributeType
                case is Int64.Type: type = .integer64AttributeType
                case is UInt.Type: type = .integer64AttributeType
                case is UInt8.Type: type = .integer16AttributeType
                case is UInt16.Type: type = .integer16AttributeType
                case is UInt32.Type: type = .integer32AttributeType
                case is UInt64.Type: type = .integer64AttributeType
                case is Float.Type: type = .floatAttributeType
                case is Double.Type: type = .doubleAttributeType
                case is String.Type: type = .stringAttributeType
                case is Date.Type: type = .dateAttributeType
                case is Data.Type: type = .binaryDataAttributeType
                case is UUID.Type: type = .UUIDAttributeType
                default: break
            }
            guard let type else {
                fatalError("Unknown primitive type: \(p.baseType)")
            }
            
            let a = NSAttributeDescription()
            a.name = name
            a.attributeType = type
            a.isOptional = false
            return a
        } else if let o = description as? OptionalTypeDescription {
            let attr = attribute(with: name, from: o.wrappedType)
            attr?.isOptional = true
            return attr
        } else if description is MultiValueTypeDescription {
            return nil
        } else if description is CompositeTypeDescription {
            return nil
        } else {
            fatalError("Unknown StoredTypeDescription: \(description)")
        }
    }
    
}

#endif
