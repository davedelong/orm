//
//  File.swift
//  ORM
//
//  Created by Dave DeLong on 3/18/25.
//

#if canImport(CoreData)

import Foundation
import CoreData

extension NSManagedObjectModel {
    private typealias NSAD = NSAttributeDescription
    private typealias NSRD = NSRelationshipDescription
    
    convenience init(compositeTypes: Array<CompositeTypeDescription>) throws(StorageError) {
        self.init()
        
        for compositeType in compositeTypes {
            try buildEntity(from: compositeType)
        }
        
        // Relationships can't be created until all the base entities exist
        // create them now (which may involve creating more entities)
        for compositeType in compositeTypes {
            try buildRelationships(from: compositeType)
        }
        
    }
    
    fileprivate func entity(named name: String) -> NSEntityDescription {
        guard let e = entitiesByName[name] else {
            fatalError("Entity '\(name)' is missing!")
        }
        
        return e
    }
    
    private func buildEntity(from description: CompositeTypeDescription) throws(StorageError) {
        let e = NSEntityDescription()
        e.name = description.name
        e.properties = description.fields.compactMap { NSAD.attribute(from: $0) }
        
        if description.isIdentifiable {
            e.uniquenessConstraints = [["id"]]
        }
        
        self.entities.append(e)
    }
    
    private func buildRelationships(from description: CompositeTypeDescription) throws(StorageError) {
        
        for field in description.fields {
            if field.description is CompositeTypeDescription {
                try NSRD.singleValueRelationship(from: description, field: field, in: self)
            } else if let opt = field.description as? OptionalTypeDescription, opt.wrappedType is CompositeTypeDescription {
                try NSRD.singleValueRelationship(from: description, field: field, in: self)
            } else if field.description is MultiValueTypeDescription {
                try NSRD.multiValueRelationship(from: description, field: field, in: self)
            }
        }
        
    }
    
}

extension NSAttributeDescription {
    
    internal static func attribute(from field: StoredField) -> NSAttributeDescription? {
        return attribute(named: field.name, description: field.description)
    }
    
    fileprivate static func attribute(named name: String, description: any StoredTypeDescription) -> NSAttributeDescription? {
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
            let attr = attribute(named: name, description: o.wrappedType)
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
    
    fileprivate static func singleValueRelationship(from sourceType: CompositeTypeDescription, field: StoredField, in model: NSManagedObjectModel) throws(StorageError) {
        
        let sourceEntity = model.entity(named: sourceType.name)
        
        let destinationType: CompositeTypeDescription
        let isOptional: Bool
        
        if let composite = field.description as? CompositeTypeDescription {
            destinationType = composite
            isOptional = false
        } else if let opt = field.description as? OptionalTypeDescription, let composite = opt.wrappedType as? CompositeTypeDescription {
            destinationType = composite
            isOptional = true
        } else {
            return
        }
        
        let destinationEntity = model.entity(named: destinationType.name)
        
        let srcToDest = NSRelationshipDescription()
        srcToDest.name = field.name
        srcToDest.destinationEntity = destinationEntity
        srcToDest.maxCount = 1
        srcToDest.minCount = isOptional ? 0 : 1
        srcToDest.isOptional = isOptional
        srcToDest.deleteRule = .nullifyDeleteRule
        
        let destToSrc = NSRelationshipDescription()
        destToSrc.name = "\(sourceType.name)_\(field.name)"
        destToSrc.destinationEntity = sourceEntity
        destToSrc.minCount = 0
        destToSrc.maxCount = destinationType.isIdentifiable ? Int.max : 1
        destToSrc.isOptional = true
        
        switch (sourceType.isIdentifiable, isOptional) {
            case (true, true): destToSrc.deleteRule = .nullifyDeleteRule
            case (false, true): destToSrc.deleteRule = .nullifyDeleteRule
            case (true, false): destToSrc.deleteRule = .denyDeleteRule
            case (false, false): destToSrc.deleteRule = .cascadeDeleteRule
        }
        
        srcToDest.inverseRelationship = destToSrc
        destToSrc.inverseRelationship = srcToDest
        
        sourceEntity.properties.append(srcToDest)
        destinationEntity.properties.append(destToSrc)
    }
    
    fileprivate static func multiValueRelationship(from sourceType: CompositeTypeDescription, field: StoredField, in model: NSManagedObjectModel) throws(StorageError) {
        
        guard let multi = field.description as? MultiValueTypeDescription else { return }
        
        /*
         Scenarios:
         - List to entity
         - List to primitive (requires intermediate entity)
         - Map to primitive (requires intermediate entity)
         - Map to entity (requires intermediate entity)
         */
        
        if multi.keyType == nil {
            try multiValueList(from: sourceType, field: field, in: model)
        } else {
            try multiValueMap(from: sourceType, field: field, in: model)
        }
        
    }
    
    private static func multiValueList(from sourceType: CompositeTypeDescription, field: StoredField, in model: NSManagedObjectModel) throws(StorageError) {
        
        let multi = field.description as! MultiValueTypeDescription
        
        let sourceEntity = model.entity(named: sourceType.name)
        let destinationEntity: NSEntityDescription
        
        let srcToDest = NSRelationshipDescription()
        srcToDest.name = field.name
        srcToDest.minCount = 0
        srcToDest.maxCount = Int.max
        srcToDest.isOrdered = multi.isOrdered
        
        let destToSrc = NSRelationshipDescription()
        destToSrc.name = "\(sourceType.name)_\(field.name)"
        destToSrc.deleteRule = .nullifyDeleteRule
        
        if let p = multi.valueType as? PrimitiveTypeDescription {
            srcToDest.deleteRule = .cascadeDeleteRule
            
            destinationEntity = NSEntityDescription()
            destinationEntity.name = "\(sourceType.name)_\(field.name)"
            model.entities.append(destinationEntity)
            
            guard let value = NSAttributeDescription.attribute(named: "value", description: p) else {
                fatalError("Cannot construct value property for intermediate entity off of \(sourceType.name).\(field.name)")
            }
            
            destinationEntity.properties.append(value)
            
            destToSrc.minCount = 1
            destToSrc.maxCount = 1
            destToSrc.isOptional = false
            
        } else if let c = multi.valueType as? CompositeTypeDescription {
            srcToDest.deleteRule = .nullifyDeleteRule
            
            destinationEntity = model.entity(named: c.name)
            
            destToSrc.minCount = 0
            destToSrc.maxCount = c.isIdentifiable ? Int.max : 1
            destToSrc.isOptional = true
        } else {
            return
        }
        
        srcToDest.destinationEntity = destinationEntity
        destToSrc.destinationEntity = sourceEntity
        
        srcToDest.inverseRelationship = destToSrc
        destToSrc.inverseRelationship = srcToDest
        
        sourceEntity.properties.append(srcToDest)
        destinationEntity.properties.append(destToSrc)
    }
    
    private static func multiValueMap(from sourceType: CompositeTypeDescription, field: StoredField, in model: NSManagedObjectModel) throws(StorageError) {
        
        let multi = field.description as! MultiValueTypeDescription
        let key = multi.keyType!
        
        let sourceEntity = model.entity(named: sourceType.name)
        
        // build the destination entity
        let mapEntity = NSEntityDescription()
        mapEntity.name = "\(sourceType.name)_\(field.name)"
        model.entities.append(mapEntity)
        
        guard let keyAttr = NSAttributeDescription.attribute(named: "key", description: key) else {
            fatalError("Invalid key type on \(sourceType.name).\(field.name)")
        }
        
        mapEntity.properties.append(keyAttr)
        
        if let primitive = multi.valueType as? PrimitiveTypeDescription {
            // map to primitive
            guard let valueAttr = NSAttributeDescription.attribute(named: "value", description: primitive) else {
                fatalError("Invalid value type on \(sourceType.name).\(field.name)")
            }
            mapEntity.properties.append(valueAttr)
        } else if let composite = multi.valueType as? CompositeTypeDescription {
            // map to stored type
            let valueEntity = model.entity(named: composite.name)
            
            let mapToValue = NSRelationshipDescription()
            mapToValue.name = "value"
            mapToValue.minCount = 1
            mapToValue.maxCount = 1
            mapToValue.isOptional = false
            mapToValue.destinationEntity = valueEntity
            mapToValue.deleteRule = .nullifyDeleteRule
            
            let valueToMap = NSRelationshipDescription()
            valueToMap.name = "\(sourceType.name)_\(field.name)"
            valueToMap.minCount = 0
            valueToMap.maxCount = Int.max
            valueToMap.isOptional = true
            valueToMap.deleteRule = .cascadeDeleteRule // when the destination deletes, cascade and delete the map entry
            
            mapToValue.inverseRelationship = valueToMap
            valueToMap.inverseRelationship = mapToValue
            
            mapEntity.properties.append(mapToValue)
            valueEntity.properties.append(valueToMap)
        } else {
            fatalError("This should be unreachable")
        }
        
        let srcToMap = NSRelationshipDescription()
        srcToMap.name = field.name
        srcToMap.destinationEntity = mapEntity
        srcToMap.minCount = 0
        srcToMap.maxCount = Int.max
        srcToMap.deleteRule = .cascadeDeleteRule
        
        let mapToSrc = NSRelationshipDescription()
        mapToSrc.name = "source"
        mapToSrc.destinationEntity = sourceEntity
        mapToSrc.deleteRule = .nullifyDeleteRule
        mapToSrc.minCount = 1
        mapToSrc.maxCount = 1
        mapToSrc.isOptional = false
        mapToSrc.deleteRule = .nullifyDeleteRule
        
        srcToMap.inverseRelationship = mapToSrc
        mapToSrc.inverseRelationship = srcToMap
        
        sourceEntity.properties.append(srcToMap)
        mapEntity.properties.append(mapToSrc)
        
        mapEntity.uniquenessConstraints = [["source", "key"]]
    }
}


#endif
