//
//  File.swift
//  
//
//  Created by Dave DeLong on 6/2/24.
//

import Foundation
import SQLKit
import Logging
import NIOCore

public struct Schema: CustomStringConvertible {
    
    internal let entities: Array<_StoredObjectDescription>
    
    public init(entities: any Storable.Type...) throws {
        
        var descriptions = Array<_StoredObjectDescription>()
        var objectsAndNames = Bimap<ObjectIdentifier, String>()
        
        var entitiesToProcess = entities
        
        while entitiesToProcess.count > 0 {
            let next = entitiesToProcess.removeFirst()
            
            let rep = next.storageRepresentation as! _StorageRepresentation
            let objectID = next.id
            
            let description = rep.description
            
            let name = description.name
            
            if let existingName = objectsAndNames[objectID] {
                guard existingName == name else {
                    throw StorableError("The Storable type '\(description.entity)' can only have a single name in a schema, not two: \(name) and \(existingName)")
                }
                
                // this id has already been processed
                continue
            }
            
            if let existingID = objectsAndNames[name] {
                guard existingID == objectID else {
                    throw StorableError("The name '\(name)' cannot be used for two different Storable types")
                }
                
                // this name has already been processed. this should be unreachable
                continue
            }
            
            objectsAndNames[name] = objectID
            
            entitiesToProcess.append(contentsOf: description.relatedTypes)
            
            // TODO: validate the type
            
            descriptions.append(description)
        }
        
        self.entities = descriptions
    }
    
    public var description: String {
        return "[" + entities.map({ "\($0)" }).joined(separator: "\n") + "]"
    }
    
    public func run() throws {
//        let db = DB()
//        var builders = Array<any SQLQueryBuilder>()
//        for entity in entities {
//            builders.append(contentsOf: try entity.builders(for: db))
//        }
//        
//        for builder in builders {
//            var serializer = SQLSerializer(database: db)
//            builder.query.serialize(to: &serializer)
//            print(serializer.sql)
//        }
    }
}

private struct DB: SQLDatabase {
    
    struct Dialect: SQLDialect {
        var name: String { "custom" }
        
        var identifierQuote: any SQLKit.SQLExpression { SQLRaw("'") }
        
        var supportsAutoIncrement: Bool { true }
        
        var autoIncrementClause: any SQLKit.SQLExpression { SQLRaw("AUTOINCREMENT") }
        
        func bindPlaceholder(at position: Int) -> any SQLKit.SQLExpression {
            fatalError()
        }
        
        func literalBoolean(_ value: Bool) -> any SQLKit.SQLExpression {
            return value ? SQLRaw("true") : SQLRaw("false")
        }
    }
    
    var logger: Logging.Logger { Logger(label: "custom") }
    
    var eventLoop: any NIOCore.EventLoop { FakeEventLoop() }
    
    var dialect: any SQLKit.SQLDialect { Dialect() }
    
    func execute(sql query: any SQLKit.SQLExpression, _ onRow: @escaping @Sendable (any SQLKit.SQLRow) -> ()) -> NIOCore.EventLoopFuture<Void> {
        print(query)
        return eventLoop.makeSucceededVoidFuture()
    }
    
}

final class FakeEventLoop: EventLoop, @unchecked Sendable {
    func shutdownGracefully(queue: DispatchQueue, _: @escaping @Sendable ((any Error)?) -> Void) {}
    var inEventLoop: Bool = false
    func execute(_ work: @escaping @Sendable () -> Void) { self.inEventLoop = true; work(); self.inEventLoop = false }
    @discardableResult func scheduleTask<T>(deadline: NIODeadline, _: @escaping @Sendable () throws -> T) -> Scheduled<T> { fatalError() }
    @discardableResult func scheduleTask<T>(in: TimeAmount, _: @escaping @Sendable () throws -> T) -> Scheduled<T> { fatalError() }
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
