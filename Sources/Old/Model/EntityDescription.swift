//
//  File.swift
//  
//
//  Created by Dave DeLong on 6/8/24.
//

import Foundation
import SQLKit

public protocol AnyEntityDescription: CustomStringConvertible {
    var name: String { get }
    var attributes: Array<EntityAttribute> { get }
    func builders(for database: any SQLDatabase) throws -> Array<SQLQueryBuilder>
}

extension AnyEntityDescription {
    internal var referencedEntities: Array<any Storable.Type> {
        return attributes.flatMap(\.referencedEntities)
    }
    internal func attribute(for keyPath: AnyKeyPath) -> EntityAttribute? {
        let match = attributes.first(where: { $0.matches(keyPath) })
        return match
    }
    internal func name(for keyPath: AnyKeyPath) -> String? {
        attribute(for: keyPath)?.name
    }
}

public struct EntityDescription<E: Storable>: AnyEntityDescription {
    public var name: String
    internal let idKeyPath: KeyPath<E, E.ID>
    public internal(set) var attributes: Array<EntityAttribute>
    internal var constraints: Array<EntityConstraint>
    
    internal var compositeEntities: Array<AnyEntityDescription>
    
    internal init(entity: E.Type = E.self) throws {
        self.name = entity.name
        self.attributes = []
        self.constraints = []
        self.compositeEntities = []
        
        for (name, keyPath) in E.properties {
            let attr = try EntityAttribute(name: name, keyPath: keyPath)
            attributes.append(attr)
        }
        
        guard let idAttr = attributes.first(where: { $0.name == "id" }) else {
            throw EntityError.missingID(E.self)
        }
        self.idKeyPath = idAttr.keyPath as! KeyPath<E, E.ID>
    }
    
    public func name(for keyPath: AnyKeyPath) -> String? {
        guard let partial = keyPath as? PartialKeyPath<E> else { return nil }
        return attribute(for: partial)?.name
    }
    
    public func attribute(for keyPath: PartialKeyPath<E>) -> EntityAttribute? {
        let match = attributes.first(where: { $0.matches(keyPath) })
        return match
    }
    
    // MARK: - Entity Customization
    
    public func defaultValue<V: PersistentValue>(_ keyPath: KeyPath<E, V>, _ value: V) throws -> Self {
        if keyPath == E.idKeyPath {
            throw EntityError.invalidDefaultValue("Entity IDs may not have a default value", value)
        }
        var copy = self
        
        guard let idx = copy.attributes.firstIndex(where: { $0.matches(keyPath) }) else {
            throw EntityError.invalidAttribute("Cannot locate attribute for keyPath", keyPath)
        }
        
        copy.attributes[idx].defaultValue = value
        
        return copy
    }
    
    // MARK: - Adding Constraints
    
    private func constraint(_ newConstraint: EntityConstraint) throws -> Self {
        var copy = self
        copy.constraints.append(newConstraint)
        return copy
    }
    
    public func reference<F: ForeignKeyValue>(_ base: KeyPath<E, F>, onUpdate: ReferenceAction? = nil, onDelete: ReferenceAction? = nil) throws -> Self {
        if F.targetEntity == E.self {
            guard attribute(for: base) != nil else {
                throw EntityError.invalidAttribute("Cannot locate stored property", base)
            }
        } else {
            let basic = try E.defaultEntityDescription
            guard basic.attribute(for: base) != nil else {
                throw EntityError.invalidAttribute("Cannot locate stored property", base)
            }
        }
        return try constraint(.foreignKey(source: base, target: F.targetEntity, onUpdate: onUpdate, onDelete: onDelete))
    }
    
    public func unique(_ keyPaths: PartialKeyPath<E>...) throws -> Self {
        for keyPath in keyPaths {
            guard attribute(for: keyPath) != nil else {
                throw EntityError.invalidAttribute("Cannot locate stored property", keyPath)
            }
        }
        if keyPaths.count == 1 {
            let keyPath = keyPaths[0]
            var copy = self
            guard let idx = copy.attributes.firstIndex(where: { $0.matches(keyPath) }) else {
                throw EntityError.invalidAttribute("Cannot locate attribute for keyPath", keyPath)
            }
            
            copy.attributes[idx].unique = true
            return copy
        } else {
            return try constraint(.unique(properties: keyPaths))
        }
    }
    
    public func indexed<V>(_ keyPath: KeyPath<E, V>) throws -> Self {
        guard attribute(for: keyPath) != nil else {
            throw EntityError.invalidAttribute("Cannot locate stored property", keyPath)
        }
        return try constraint(.indexed(property: keyPath))
    }
}
