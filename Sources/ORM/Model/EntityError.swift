//
//  File.swift
//  
//
//  Created by Dave DeLong on 6/15/24.
//

import Foundation

public enum EntityError: Error {
    case invalidPropertyType(String, Any.Type, Any.Type)
    case invalidAttribute(String, AnyKeyPath)
    
    case invalidDefaultValue(String, Any)
    case missingID(any Entity.Type)
}


internal enum PersistentValueError: Error {
    case missingValue
}
