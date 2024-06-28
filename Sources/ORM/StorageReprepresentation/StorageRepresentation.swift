//
//  File.swift
//  
//
//  Created by Dave DeLong on 6/19/24.
//

import Foundation

public protocol StorageRepresentation<StoredType> {
    associatedtype StoredType: Storable
    
    var name: String? { get set }
    func _build(into builder: _StorageBuilder) throws
}

extension StorageRepresentation {
    public func _build(into builder: _StorageBuilder) throws {
        throw StorableError("Custom StorageRepresentations are not supported")
    }
}

internal struct OptionalStorage<Inner: Storable>: StorageRepresentation {
    typealias StoredType = Inner?
    
    var name: String?
    var inner: any StorageRepresentation
    
    init() {
        self.inner = Inner.storageRepresentation
    }
}

internal struct OrderedManyStorage<Inner: Storable>: StorageRepresentation {
    typealias StoredType = Array<Inner>
    
    var name: String?
    var inner: any StorageRepresentation
    
    init() {
        self.inner = Inner.storageRepresentation
    }
}

internal struct UnorderedManyStorage<Inner: Storable & Hashable>: StorageRepresentation {
    typealias StoredType = Set<Inner>
    
    var name: String?
    var inner: any StorageRepresentation
    
    init() {
        self.inner = Inner.storageRepresentation
    }
}

internal struct BoxedRepresentation<Outer: Storable>: StorageRepresentation {
    typealias StoredType = Outer
    
    var name: String?
    var inner: any StorageRepresentation
    
    init(outer: Outer.Type = Outer.self, inner: any StorageRepresentation) {
        self.inner = inner
    }
}
