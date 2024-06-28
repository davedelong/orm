//
//  File.swift
//  
//
//  Created by Dave DeLong on 6/22/24.
//

import Foundation

public protocol _AnyBuilder { }

public class _StorageBuilder: _AnyBuilder {
    
    internal init() { }
    
    private var composites = Dictionary<String, _CompositeBuilder>()
    
    internal func compositeBuilder(for name: String) -> _CompositeBuilder {
        if let e = composites[name] {
            return e
        }
        
        let b = _CompositeBuilder()
        composites[name] = b
        return b
    }
}

internal class _CompositeBuilder: _AnyBuilder {
    
}
