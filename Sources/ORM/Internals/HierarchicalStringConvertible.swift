//
//  File.swift
//  
//
//  Created by Dave DeLong on 6/15/24.
//

import Foundation

public protocol _HierarchicalStringConvertible {
    func description(at level: Int) -> Array<String>
}

extension CustomStringConvertible where Self: _HierarchicalStringConvertible {
    
    public var description: String {
        self.description(at: 0).joined(separator: "\n")
    }
    
}

extension String {
    init(indent level: Int) { self.init(repeating: "  ", count: level) }
}

/*
extension EntityDescription: _HierarchicalStringConvertible {
    
    public func description(at level: Int) -> Array<String> {
        let indent = String(indent: level)
        var lines = [indent + "\(name) (\(E.self))"]
        for attr in attributes {
            lines.append(contentsOf: attr.description(at: level+1))
        }
        for constraint in constraints {
            lines.append(contentsOf: constraint.description(at: level+1))
        }
        return lines
    }
    
}

extension EntityAttribute: _HierarchicalStringConvertible {
    public func description(at level: Int) -> Array<String> {
        let indent = String(indent: level)
        
        let def = defaultValue.map { ", default: \($0)" } ?? ""
        let opt = semantics.canBeNull ? ", optional" : ", required"
        let many = semantics.isMultiValue ? ", multi" : ""
        
        var lines = Array<String>()
        if case .composite(let attrs) = semantics.persistentType {
            lines.append(indent + "\(name): \(attributeType) {")
            for attr in attrs {
                lines.append(contentsOf: attr.description(at: level+1))
            }
            lines.append(indent + "}\(opt)\(many)\(def)")
        } else {
            lines.append(indent + "\(name): \(attributeType) \(semantics.persistentType)\(opt)\(many)\(def)")
        }
        return lines
    }
}

extension EntityConstraint: _HierarchicalStringConvertible {
    public func description(at level: Int) -> Array<String> {
        let indent = String(indent: level)
        switch self {
            case .foreignKey(source: let baseKeyPath, target: let targetType, onUpdate: let onUpdate, onDelete: let onDelete):
                let baseEntityType = baseKeyPath.erasedRootType as! any Storable.Type
                let baseEntityDesc = try! baseEntityType.erasedDefaultEntityDescription
                let baseName = baseEntityDesc.name(for: baseKeyPath)!
                
                let targetEntityDesc = try! targetType.erasedDefaultEntityDescription
                let targetName = targetEntityDesc.name
                
                var base = "FOREIGN KEY \(baseName) REFERENCES \(targetName).id"
                if let onUpdate {
                    base.append(" ON UPDATE \(onUpdate)")
                }
                if let onDelete {
                    base.append(" ON DELETE \(onDelete)")
                }
                return [indent+base]
            case .unique(properties: let keyPaths):
                let baseEntityType = keyPaths[0].erasedRootType as! any Storable.Type
                let baseEntityDesc = try! baseEntityType.erasedDefaultEntityDescription
                let names = keyPaths.map { baseEntityDesc.name(for: $0)! }.joined(separator: ", ")
                return [indent+"UNIQUE (\(names))"]
            case .indexed(property: let keyPath):
                let baseEntityType = keyPath.erasedRootType as! any Storable.Type
                let baseEntityDesc = try! baseEntityType.erasedDefaultEntityDescription
                return [indent+"INDEXED \(baseEntityDesc.name(for: keyPath)!)"]
        }
    }
}
*/
