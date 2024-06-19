//
//  File.swift
//  
//
//  Created by Dave DeLong on 6/19/24.
//

import Foundation

public protocol StorageRepresentation { }

internal protocol _StorageRepresentation: StorageRepresentation {
    var description: _StoredObjectDescription { get }
}

internal struct OptionalStorage<Inner: Storable>: StorageRepresentation {
    
}

internal struct OrderedManyStorage<Inner: Storable>: StorageRepresentation {
    
}

internal struct UnorderedManyStorage<Inner: Storable>: StorageRepresentation {
    
}
