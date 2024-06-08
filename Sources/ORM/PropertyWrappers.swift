//
//  File.swift
//  
//
//  Created by Dave DeLong on 6/2/24.
//

import Foundation

@propertyWrapper
public struct Weak<Value: Entity> {
    public var wrappedValue: Value?
    
    public init() { wrappedValue = nil }
}

@propertyWrapper
public struct Strong<Value: Entity> {
    public var wrappedValue: Value
    
    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }
}

@propertyWrapper
public struct Constraint<Value: PersistentValue> {
    
    public var wrappedValue: Value
    
    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }
    
}

@propertyWrapper
public struct PrimaryKey<Value: PersistentValue> {
    public var wrappedValue: Value
    
    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }
}

@propertyWrapper
public struct Field<Value: PersistentValue> {
    public var wrappedValue: Value
    
    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }
    public init<V>() where Value == V? {
        self.wrappedValue = nil
    }
    public init<V>(wrappedValue: V?) where Value == V? {
        self.wrappedValue = wrappedValue
    }
}

@propertyWrapper 
public struct Unique<Value: PersistentValue> {
    public var wrappedValue: Value
    internal let otherColumns: Array<String>
    
    public init(wrappedValue: Value, _ others: String...) {
        self.wrappedValue = wrappedValue
        self.otherColumns = others
    }
    public init<V>(_ others: String...) where Value == V? {
        self.wrappedValue = nil
        self.otherColumns = others
    }
    public init<V>() where Value == V? {
        self.wrappedValue = nil
        self.otherColumns = []
    }
    public init<V>(wrappedValue: Value, _ others: String...) where Value == V? {
        self.wrappedValue = wrappedValue
        self.otherColumns = others
    }
}

@propertyWrapper
public struct ForeignKey<E: Entity, Value: PersistentValue> {
    
    public var wrappedValue: Value {
        fatalError()
    }
    
    internal let reference: KeyPath<E, E.ID>
    
    public init(_ keyPath: KeyPath<E, E.ID>) where Value == E.ID? {
        self.reference = keyPath
    }
    
    public init(_ keyPath: KeyPath<E, E.ID>) where Value == E.ID {
        self.reference = keyPath
    }
}
