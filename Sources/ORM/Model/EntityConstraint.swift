//
//  File.swift
//  
//
//  Created by Dave DeLong on 6/8/24.
//

import Foundation

internal enum EntityConstraint {
    case foreignKey(source: AnyKeyPath,
                    target: any Storable.Type,
                    onUpdate: ReferenceAction?,
                    onDelete: ReferenceAction?)
    
    case unique(properties: Array<AnyKeyPath>)
    
    case indexed(property: AnyKeyPath)
}

public enum ReferenceAction {
    case cascade
    case deny
    case setNull
    case revertToDefault
}
