//
//  File.swift
//  
//
//  Created by Dave DeLong on 6/19/24.
//

import Foundation

public protocol Attribute<StoredType> {
    associatedtype StoredType: Storable
}

internal protocol _Attribute: Attribute {
    var description: _AttributeDescription { get }
}

extension Property: Attribute, _Attribute {
    public typealias StoredType = S
    
    var description: any _AttributeDescription { _property }
}

extension Relationship: Attribute, _Attribute {
    public typealias StoredType = Source
    
    var description: any _AttributeDescription { _relationship }
}
