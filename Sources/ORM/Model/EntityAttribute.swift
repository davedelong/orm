//
//  File.swift
//  
//
//  Created by Dave DeLong on 6/8/24.
//

import Foundation

public struct EntityAttribute {
    public let name: String
    
    internal let keyPath: AnyKeyPath?
    internal let attributeType: any PersistentValue.Type
    internal let referencedEntities: Array<any Entity.Type>
    
    internal var defaultValue: Any?
    internal var unique = false
    
    internal let semantics: _PersistentValueSemantics
    public var isNullable: Bool { semantics.canBeNull }
    public var valueType: PersistentType { semantics.persistentType }
    public var isMultiValue: Bool { semantics.isMultiValue }
    
    internal init(name: String, keyPath: AnyKeyPath) throws {
        let selfType = keyPath.erasedRootType
        let type = keyPath.erasedValueType
        
        if type is any Entity.Type {
            throw EntityError.invalidPropertyType(name, selfType, type)
        }
        
        guard let persistentType = type as? PersistentValue.Type else {
            throw EntityError.invalidPropertyType(name, selfType, type)
        }
        
        try self.init(name: name, keyPath: keyPath, selfType: selfType, type: persistentType)
    }
    
    init(name: String, keyPath: AnyKeyPath? = nil, selfType: Any.Type? = nil, type: any PersistentValue.Type) throws {
        self.name = name
        self.defaultValue = nil
        self.keyPath = keyPath
        self.attributeType = type
        self.semantics = try type.semantics
        
        var referenced = Array<any Entity.Type>()
            
        if let foreignKey = type as? any ForeignKeyValue.Type, selfType != foreignKey.targetEntity {
            referenced = [foreignKey.targetEntity]
        }
        self.referencedEntities = referenced
    }
    
    internal func matches(_ keyPath: AnyKeyPath) -> Bool {
        return self.keyPath == keyPath
    }
    
    internal var compositeEntity: AnyEntityDescription? {
        nil
    }
    
}
