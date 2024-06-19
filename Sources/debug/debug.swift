//
//  File.swift
//  
//
//  Created by Dave DeLong on 6/2/24.
//

import Foundation
import ORM

struct Account: Storable {
    typealias RawID = Int
    
    static var storageRepresentation: some StorageRepresentation {
        StoredRepresentation(Self.self) {
            StoredProperty(keyPath: \.id)
            StoredProperty(keyPath: \.email)
            StoredProperty(keyPath: \.settings)
        }
    }
    
    var id: StoredID<Self, Int>
    var parentID: ID?
    var email: String
    
    var computers: Array<Computer.ID>
    var settings: Settings
}

struct Settings: PersistentValue {
    var hasPro: Bool
    var permissionLevel: Int
}

struct User: Storable {
    typealias RawID = UUID
    var id: StoredID<Self, UUID>
    var name: String? = nil
    var email: String? = nil
    var aliases: Array<String>
    var age: Int
    
    var computers: Array<Computer.ID>
}

struct Computer: Storable {
    typealias RawID = UUID
    var id: StoredID<Self, UUID>
    var name: String
    var owner: User.ID?
}











@main
struct Debug {
    static func main() async throws {
        let b = StoredRepresentation(Account.self)
        print(b)
        
        let schema = try Schema(entities: Account.self)
//        print(schema)
        
        
        
        
        
        
        
        try schema.run()
        
        
        
        
        
        
        
        
        
        
        let user = Snapshot(entity: try User.entityDescription, values: [
            "id": "3388D19F-283E-40DB-98DB-A8FFC2B0BA1C",
            "name": "Dave",
            "computers": ["E9653C88-8A64-4EF0-88CD-D69A72D61540"],
            "age": 37
        ])
        
        
        
        
        
        
        
        print(user.id)
        print(user.name?.count)
        print(user.email)
        print(user.age)
        print(user.aliases)
        print(user.computers)
    }
}
