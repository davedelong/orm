//
//  File.swift
//  
//
//  Created by Dave DeLong on 6/19/24.
//

import Foundation

public struct StorableError: Error, CustomStringConvertible {
    
    public let description: String
    
    internal init(_ description: String) {
        self.description = description
    }
    
}
