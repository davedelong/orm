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
        self.model = NSManagedObjectModel()
        
        for compositeType in schema.compositeTypes {
            try NSEntityDescription.buildEntity(from: compositeType, into: model)
        }
        
        // Relationships can't be created until all the base entities exist
        // create them now (which may involve creating more entities)
        for compositeType in schema.compositeTypes {
            try NSRelationshipDescription.buildRelationships(for: compositeType, into: model)
        }
    }
    
}

extension NSEntityDescription {
    
    fileprivate static func buildEntity(from description: CompositeTypeDescription, into model: NSManagedObjectModel) throws(Schema.Error) {
        let e = NSEntityDescription()
        e.name = description.name
        e.properties = NSAttributeDescription.attributes(from: description)
        
        if description.isIdentifiable {
            e.uniquenessConstraints = [["id"]]
        }
        
        model.entities.append(e)
    }
    
}

extension NSAttributeDescription {
    
    fileprivate static func attributes(from description: CompositeTypeDescription) -> Array<NSAttributeDescription> {
        var all = Array<NSAttributeDescription>()
        
        for (name, _, description) in description.fields {
            if let attr = attribute(named: name, from: description) {
                all.append(attr)
            }
        }
        
        return all
    }
    
    fileprivate static func attribute(named name: String, from description: any StoredTypeDescription) -> NSAttributeDescription? {
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
            let attr = attribute(named: name, from: o.wrappedType)
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

extension NSRelationshipDescription {
    
    static func buildRelationships(for type: CompositeTypeDescription, into model: NSManagedObjectModel) throws(Schema.Error) {
        guard let entity = model.entitiesByName[type.name] else { fatalError("Entity is suddenly missing!") }
        
        // some relationships require an intermediate entity, namely dictionaries
        for (name, kp, description) in type.fields {
            if let composite = description as? CompositeTypeDescription {
                try buildSingleValueRelationship(from: type, sourceEntity: entity,
                                                 named: name, keyPath: kp, targetType: composite, isOptional: false,
                                                 in: model)
            } else if let opt = description as? OptionalTypeDescription, let composite = opt.wrappedType as? CompositeTypeDescription {
                try buildSingleValueRelationship(from: type, sourceEntity: entity,
                                                 named: name, keyPath: kp, targetType: composite, isOptional: true,
                                                 in: model)
            } else if let multi = description as? MultiValueTypeDescription {
                try buildMultiValueRelationship(from: type, sourceEntity: entity,
                                                named: name, keyPath: kp, targetType: multi,
                                                in: model)
            } else {
                continue
            }
        }
    }
    
    private static func buildSingleValueRelationship(from sourceType: CompositeTypeDescription,
                                                     sourceEntity: NSEntityDescription,
                                                     named name: String,
                                                     keyPath: AnyKeyPath,
                                                     targetType: CompositeTypeDescription,
                                                     isOptional: Bool,
                                                     in model: NSManagedObjectModel) throws(Schema.Error) {
        
        guard let destinationEntity = model.entitiesByName[targetType.name] else {
            fatalError("Suddenly missing entity named \(targetType.name)?!")
        }
        
        let sourceRel = NSRelationshipDescription()
        sourceRel.name = name
        sourceRel.destinationEntity = destinationEntity
        sourceRel.maxCount = 1
        sourceRel.isOptional = isOptional
        
        let destRel = NSRelationshipDescription()
        destRel.name = "\(sourceType.name)_\(name)"
        destRel.deleteRule = isOptional ? .nullifyDeleteRule : .denyDeleteRule
        
        sourceRel.inverseRelationship = destRel
        destRel.inverseRelationship = sourceRel
        
        if targetType.isIdentifiable {
            // when the source value is deleted, null out the destRel property
            sourceRel.deleteRule = .nullifyDeleteRule
            destRel.maxCount = 0
        } else {
            sourceRel.deleteRule = .cascadeDeleteRule
            destRel.maxCount = 1
        }
        
        // when the target value is deleted, either nil out (if optional) or deny (if required)
        if isOptional {
            destRel.deleteRule = .nullifyDeleteRule
        } else if sourceType.isIdentifiable == false {
            destRel.deleteRule = .cascadeDeleteRule
        } else {
            destRel.deleteRule = .denyDeleteRule
        }
        
        sourceEntity.properties.append(sourceRel)
        destinationEntity.properties.append(destRel)
    }
    
    private static func buildMultiValueRelationship(from sourceType: CompositeTypeDescription, sourceEntity: NSEntityDescription, named name: String, keyPath: AnyKeyPath, targetType: MultiValueTypeDescription, in model: NSManagedObjectModel) throws(Schema.Error) {
        
        if let keyType = targetType.keyType { /*
            let dictEntity = NSEntityDescription()
            dictEntity.name = "\(type.name)_\(name)"
            
            // because of the schema construction, we know that the key type is primitive
            guard let primitiveKey = keyType as? PrimitiveTypeDescription else {
                throw .dictionaryKeyMustBePrimitive(type.baseType, name, kp, keyType.baseType)
            }
            
            guard let keyAttr = NSAttributeDescription.attribute(named: "key", from: primitiveKey) else {
                fatalError("Invalid key type on \(type.name).\(name)?!")
            }
            dictEntity.properties.append(keyAttr)
            
            // dictionary
            let valueType: any StoredTypeDescription
            let isRequired: Bool
            
            if let opt = multiValueDescription.valueType as? OptionalTypeDescription {
                isRequired = false
                valueType = opt.wrappedType
            } else {
                isRequired = true
                valueType = multiValueDescription.valueType
            }
            
            if let composite = valueType as? CompositeTypeDescription {
                // this is a relationship to another StoredType/Entity
            } else if let primitive = valueType as? PrimitiveTypeDescription {
                // this is a relationship to a primitive (ie, Array of Strings etc)
            } else {
                // we probably don't support this; this would be an array of array of strings, for example
            }
            
            
            let dictSourceRel = NSRelationshipDescription()
            dictSourceRel.name = "source"
            dictSourceRel.destinationEntity = entity
            dictSourceRel.isOrdered = false
            dictSourceRel.maxCount = 1
            dictSourceRel.isOptional = false
            dictSourceRel.deleteRule = .nullifyDeleteRule
            
            let entityDictRel = NSRelationshipDescription()
            entityDictRel.name = name
            entityDictRel.destinationEntity = dictEntity
            entityDictRel.isOrdered = false
            entityDictRel.maxCount = 0
            entityDictRel.deleteRule = .cascadeDeleteRule
            
            dictEntity.properties.append(dictSourceRel)
            entity.properties.append(entityDictRel)
            
            dictEntity.uniquenessConstraints = [["source", "key"]]
            
          */ } else {
            // set or ordered set
            let valueType: any StoredTypeDescription
            let isRequired: Bool
            
            if let opt = targetType.valueType as? OptionalTypeDescription {
                isRequired = false
                valueType = opt.wrappedType
            } else {
                isRequired = true
                valueType = targetType.valueType
            }
            
            if let composite = valueType as? CompositeTypeDescription {
                // this is a relationship to another StoredType/Entity
                // Core Data supports this natively
            } else if let primitive = valueType as? PrimitiveTypeDescription {
                // this is a relationship to a primitive (ie, Array of Strings etc)
                // we need an intermediate entity
            } else {
                // we probably don't support this; this would be an array of array of strings, for example
            }
        }
        
    }
}

#endif
