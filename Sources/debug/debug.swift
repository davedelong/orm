//
//  File.swift
//  
//
//  Created by Dave DeLong on 6/2/24.
//

import Foundation
import ORM

struct User: Entity {
    var id: EntityID<Self, UUID>
    var name: String? = nil
    var email: String? = nil
    var aliases: Array<String>
    
    var computers: Array<Computer.ID>
}

struct Computer: Entity {
    var id: EntityID<Self, UUID>
    var name: String
    var owner: User.ID?
}

@main
struct Debug {
    static func main() async throws {
        let schema = try Schema(entities: User.self)
        print(schema)
    }
}
