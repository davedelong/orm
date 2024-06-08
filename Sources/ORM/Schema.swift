//
//  File.swift
//  
//
//  Created by Dave DeLong on 6/2/24.
//

import Foundation

public struct Schema {
    
    internal let entities: Array<AnyEntityDescription>
    
    public init(entities: any Entity.Type...) throws {
        var descriptions = Array<AnyEntityDescription>()
        
        var seen = Set<ObjectIdentifier>()
        var entitiesToProcess = entities
        
        while entitiesToProcess.count > 0 {
            let next = entitiesToProcess.removeFirst()
            let nextID = ObjectIdentifier(next)
            guard seen.contains(nextID) == false else { continue }
            seen.insert(nextID)
            
            let description = next.erasedEntityDescription
            descriptions.append(description)
            entitiesToProcess.append(contentsOf: description.referencedEntities)
        }
        
        self.entities = descriptions
    }
    
}

/*
private enum ValueToProcess {
    case entity(any Entity.Type)
    case persistentValue(String, any Entity.Type, _TableProperty)
}

private func process(_ entity: any Entity.Type) throws -> (Table, Array<ValueToProcess>) {
    let mirror = Mirror(reflecting: entity.init())
    
    var primary: TableField?
    var columns = Array<TableField>()
    var compositeFields = Array<ValueToProcess>()
    
    for (label, value) in mirror.children {
        guard let label else { throw TableError.invalidProperty("") }
        guard label.hasPrefix("_") else { throw TableError.invalidProperty(label) }
        
        let propertyName = String(label.dropFirst())
        guard let prop = value as? _TableProperty else {
            throw TableError.invalidProperty(propertyName)
        }
        
        let semantics = prop.semantics
        let type = semantics.persistentType
        
        if propertyName == "id" {
            guard primary == nil else { throw TableError.invalidProperty(propertyName) }
            
            primary = TableField(name: propertyName,
                                 dataType: type,
                                 defaultValue: nil,
                                 notNull: semantics.notNull)
        } else {
            if type == .composite {
                
                if let entityType = prop.wrappedValueType as? any Entity.Type {
                    // make sure we process the target entity
                    compositeFields.append(.entity(entityType))
                    // the column will refer to the entity's id
                    let entityKeyType = entity.idSemantics
                    columns.append(TableField(name: propertyName, dataType: entityKeyType.persistentType, defaultValue: nil, notNull: semantics.notNull))
                    
                } else if semantics.isMultiValue {
                    // needs another entity
                    compositeFields.append(.persistentValue("\(entity.name)_\(propertyName)", entity, prop))
                    // this does not add a column, because the intermediate table will refer back to this one
                } else {
                    // in theory this can be folded into this entity
                    // in practice this would have be be a struct that's a PersistentValue, but that is not an Entity
                    // however, that is bonkers
                    throw TableError.invalidProperty(propertyName)
                }
            } else {
                columns.append(TableField(name: propertyName, dataType: type, defaultValue: nil, notNull: semantics.notNull))
            }
        }
    }
    
    guard let primary else { throw TableError.missingID }
    
    let table = Table(entity: entity, name: entity.name, primaryKey: primary, otherColumns: columns, constraints: [])
    return (table, compositeFields)
}
*/
