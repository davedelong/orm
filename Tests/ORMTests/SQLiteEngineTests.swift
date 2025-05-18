//
//  File.swift
//  ORM
//
//  Created by Dave DeLong on 4/29/25.
//

@testable import ORM
import Testing
import Foundation

@Suite(.serialized)
struct SQLiteEngineTests {
    
    func temporaryURL(_ caller: StaticString = #function) -> URL {
        let name = "\(Self.self)-\(caller.description).db"
        return URL.temporaryDirectory.appending(component: name)
    }
    
    @Test func simpleStruct() async throws {
        struct Simple: StoredType {
            var name: String
        }
        
        let url = temporaryURL()
        let _ = try await SQLiteEngine(Simple.self, at: url)
        print(url)
    }
    
    @Test func simpleIdentifiableStruct() async throws {
        
        struct Simple: Identifiable, StoredType {
            var id: UUID
            var name: String
            var age: Int
            var registrationDate: Date
        }
        
        let url = temporaryURL()
        let _ = try await SQLiteEngine(Simple.self, at: url)
        print(url)
    }
    
    @Test func simpleIdentifiableWithOptionalsStruct() async throws {
        
        struct Simple: Identifiable, StoredType {
            var id: UUID
            var name: String?
            var age: Int?
            var registrationDate: Date
        }
        
        let url = temporaryURL()
        let _ = try await SQLiteEngine(Simple.self, at: url)
        print(url)
    }
    
    @Test func simpleStructWithArray() async throws {
        struct S: StoredType {
            var name: String
            var emails: Array<String>
        }
        
        let _ = try await SQLiteEngine(S.self, at: temporaryURL())
    }
    
    @Test func relationshipBetweenIdentifiables() async throws {
        struct A: Identifiable, StoredType {
            let id: UUID
            var name: String
        }
        
        struct B: Identifiable, StoredType {
            let id: UUID
            var name: String
            var a: A?
        }
        
        let _ = try await SQLiteEngine(B.self, at: temporaryURL())
    }
    
    @Test func saveSimpleValue() async throws {
        struct A: Identifiable, StoredType {
            let id: String
            let name: String
        }
        
        let e = try await SQLiteEngine(A.self, at: temporaryURL())
        try await e.save(A(id: "test", name: "Arthur"))
    }
    
}
