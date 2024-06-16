//
//  File.swift
//  
//
//  Created by Dave DeLong on 6/15/24.
//

import Foundation
import SQLKit

extension EntityDescription {
    
    private func isUnique(_ keyPath: AnyKeyPath) -> Bool {
        return constraints.contains(where: { c -> Bool in
            if case .unique(let kps) = c, kps == [keyPath] { return true }
            return false
        })
    }
    
    public func builders(for database: any SQLDatabase) throws -> Array<SQLQueryBuilder> {
        var builders = Array<SQLQueryBuilder>()
        
        let tableBuilder = database.create(table: self.name)
        builders.append(tableBuilder)
        
        for attribute in self.attributes {
            builders.append(contentsOf: buildAttribute(attribute, into: tableBuilder, database: database))
        }
        
        for constraint in self.constraints {
            switch constraint {
                case .indexed(property: let kp):
                    let name = self.name(for: kp)!
                    builders.append(database.create(index: "idx-\(self.name)_\(name)"))
                case .unique(properties: let kps):
                    if kps.count > 1 { // 1-count unique constraints are handled at the column leve
                        let names = kps.map { self.name(for: $0)! }
                        tableBuilder.unique(names)
                    }
                case .foreignKey(source: let source, target: let targetEntityType, onUpdate: let update, onDelete: let delete):
                    let targetEntityName = try targetEntityType.erasedDefaultEntityDescription.name
                    tableBuilder.foreignKey([self.name(for: source)!],
                                            references: targetEntityName, ["id"],
                                            onDelete: delete?.foreignKeyAction,
                                            onUpdate: update?.foreignKeyAction)
                    break
            }
        }
        
        return builders
//        .create(table: "planets")
//            .column("id", type: .bigint, .primaryKey)
//            .column("name", type: .text, .default("unnamed"))
//            .column("galaxy_id", type: .bigint, .references("galaxies", "id"))
//            .column("diameter", type: .int, .check(SQLRaw("diameter > 0")))
//            .column("important", type: .text, .notNull)
//            .column("special", type: .text, .unique)
//            .column("automatic", type: .text, .generated(SQLRaw("CONCAT(name, special)")))
//            .column("collated", type: .text, .collate(name: "default"))
    }
    
    private func buildAttribute(_ attr: EntityAttribute, namePrefix: String = "", into builder: SQLCreateTableBuilder, database: any SQLDatabase) -> Array<SQLCreateTableBuilder> {
        if attr.isMultiValue == false {
            if let dataType = attr.valueType.sqlDataType {
                var constraints = Array<SQLColumnConstraintAlgorithm>()
                
                if attr.name == "id" {
                    let idType = attr.attributeType as! any EntityIDType.Type
                    if idType.behavior == .autogenerate, case .integer = attr.valueType {
                        constraints.append(.primaryKey(autoIncrement: true))
                    } else {
                        constraints.append(.primaryKey(autoIncrement: false))
                    }
                } else if isUnique(attr.keyPath) {
                    constraints.append(.unique)
                }
                
                if attr.isNullable == false {
                    constraints.append(.notNull)
                }
//                    if let defValue = attribute.defaultValue {
//                        constraints.append(.default(defValue))
//                    }
                
                builder.column(namePrefix + attr.name, type: dataType, constraints)
                return []
            } else if case .composite(let attrs) = attr.valueType {
                let nestedPrefix = namePrefix + attr.name + "_"
                var extraTables = Array<SQLCreateTableBuilder>()
                for attr in attrs {
                    extraTables.append(contentsOf: buildAttribute(attr, namePrefix: nestedPrefix, into: builder, database: database))
                }
                return extraTables
            } else {
                return []
            }
        } else {
            // need an intermediate table
            return []
        }
    }
    
}

extension PersistentType {
    
    fileprivate var sqlDataType: SQLDataType? {
        switch self {
            case .uuid: return .text
            case .boolean: return .smallint
            case .string: return .text
            case .integer: return .bigint
            case .floatingPoint: return .real
            case .binary: return .blob
            case .timestamp: return .timestamp
            case .codable: return .blob
            case .composite(_): return nil
            case .collection: return nil
            case ._entity: return nil
        }
    }
    
}

extension ReferenceAction {
    fileprivate var foreignKeyAction: SQLForeignKeyAction? {
        switch self {
            case .cascade: return .cascade
            case .deny: return .restrict
            case .setNull: return .setNull
            case .revertToDefault: return .setDefault
        }
    }
}
