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

struct Meetup: StoredType, Identifiable {
    var id: UUID
    var name: String
    
    var startDate: Date
    var attendees: Array<Person>
}

struct Person: StoredType, Identifiable {
    var id: UUID
    var firstName: String
    var lastName: String
    var emails: Array<String>
    
    var settings: Dictionary<String, String>
}

let schema = try Schema(Meetup.self)
print(schema.compositeTypes)

let url = URL(filePath: "/Users/dave/Desktop/schema.sql")
let engine = try await CoreDataEngine(schema: schema, at: url)
