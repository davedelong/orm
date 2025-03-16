//
//  File.swift
//  
//
//  Created by Dave DeLong on 1/7/25.
//

import Foundation
import ORM

struct T1: StoredType, Identifiable {
    var id: UUID
    var name: String
    var t2: T2?
}

struct T2: StoredType {
    var age: Int
}

let schema = try Schema(T1.self, T2.self)
