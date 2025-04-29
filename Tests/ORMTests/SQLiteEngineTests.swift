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
    
}
