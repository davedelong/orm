//
//  File.swift
//  ORM
//
//  Created by Dave DeLong on 4/1/25.
//

import Foundation
import ORM

@dynamicMemberLookup
struct Snapshot<T: StoredType> {
    
    subscript<V>(dynamicMember keyPath: KeyPath<T, V>) -> V {
        fatalError()
    }
    
}
