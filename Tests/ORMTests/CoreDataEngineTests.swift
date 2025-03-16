//
//  CoreDataEngineTests.swift
//  ORM
//
//  Created by Dave DeLong on 3/16/25.
//

@testable import ORM
import Testing

#if canImport(CoreData)
import CoreData

@Suite("Core Data Engine")
struct CoreDataEngineTests {
    @Test func singlePropertyEntity() async throws {
        struct S: StoredType {
            var name: String
        }
        
        let e = try CoreDataEngine(S.self)
        let model = await e.model
        let sEntity = try #require(model.entities.first)
        #expect(sEntity.name == "S")
        #expect(sEntity.properties.count == 1)
        #expect(sEntity.uniquenessConstraints.isEmpty)
        
        let nameAttr = try #require(sEntity.attributesByName["name"])
        #expect(nameAttr.type == .string)
        #expect(nameAttr.isOptional == false)
    }
    
    @Test func singlePropertyUniqueEntity() async throws {
        struct S: StoredType, Identifiable {
            var id: String
        }
        
        let e = try CoreDataEngine(S.self)
        let model = await e.model
        let sEntity = try #require(model.entities.first)
        #expect(sEntity.name == "S")
        #expect(sEntity.properties.count == 1)
        
        let nameAttr = try #require(sEntity.attributesByName["id"])
        #expect(nameAttr.type == .string)
        #expect(nameAttr.isOptional == false)
        
        let constraints = try #require(sEntity.uniquenessConstraints as? Array<[String]>)
        #expect(constraints == [["id"]])
    }
    
    @Test func multipleSimpleEntities() async throws {
        struct A: StoredType, Identifiable {
            var id: String
            var value: Data?
        }
        
        struct B: StoredType {
            var timestamp: Date
            var message: String
        }
        
        let e = try CoreDataEngine(A.self, B.self)
        
        let a = try #require(await e.model.entitiesByName["A"])
        let aUnique = try #require(a.uniquenessConstraints as? Array<[String]>)
        #expect(aUnique == [["id"]])
        
        let aID = try #require(a.attributesByName["id"])
        #expect(aID.attributeType == .stringAttributeType)
        #expect(aID.isOptional == false)
        
        let aValue = try #require(a.attributesByName["value"])
        #expect(aValue.attributeType == .binaryDataAttributeType)
        #expect(aValue.isOptional == true)
        
        let b = try #require(await e.model.entitiesByName["B"])
        #expect(b.uniquenessConstraints.isEmpty)
        
        let bTimestamp = try #require(b.attributesByName["timestamp"])
        #expect(bTimestamp.attributeType == .dateAttributeType)
        #expect(bTimestamp.isOptional == false)
        
        let bMessage = try #require(b.attributesByName["message"])
        #expect(bMessage.attributeType == .stringAttributeType)
        #expect(bMessage.isOptional == false)
    }
    
    @Test func requireToOneRelationship_UnidentifiedToUnidentified() async throws {
        struct A: StoredType {
            var b: B
        }
        
        struct B: StoredType {
            var name: String
        }
        
        let e = try CoreDataEngine(A.self)
        
        let a = try #require(await e.model.entitiesByName["A"])
        let b = try #require(await e.model.entitiesByName["B"])
        
        let aB = try #require(a.relationshipsByName["b"])
        #expect(aB.isOrdered == false)
        #expect(aB.isToMany == false)
        #expect(aB.isOptional == false)
        #expect(aB.deleteRule == .cascadeDeleteRule)
        
        let aBInverse = try #require(aB.inverseRelationship)
        #expect(aBInverse.name == "A_b")
        #expect(aBInverse.isOrdered == false)
        #expect(aBInverse.isToMany == false) // this is false because B is not Identifiable
        #expect(aBInverse.deleteRule == .cascadeDeleteRule)
        
        let bName = try #require(b.attributesByName["name"])
        #expect(bName.type == .string)
        #expect(bName.isOptional == false)
    }
    
    @Test func requireToOneRelationship_IdentifiedToUnidentified() async throws {
        struct A: StoredType, Identifiable {
            var id: String
            var b: B
        }
        
        struct B: StoredType {
            var name: String
        }
        
        let e = try CoreDataEngine(A.self)
        
        let a = try #require(await e.model.entitiesByName["A"])
        let b = try #require(await e.model.entitiesByName["B"])
        
        let aB = try #require(a.relationshipsByName["b"])
        #expect(aB.isOrdered == false)
        #expect(aB.isToMany == false)
        #expect(aB.isOptional == false)
        #expect(aB.deleteRule == .cascadeDeleteRule)
        
        let aBInverse = try #require(aB.inverseRelationship)
        #expect(aBInverse.name == "A_b")
        #expect(aBInverse.isOrdered == false)
        #expect(aBInverse.isToMany == false) // this is false because B is not Identifiable
        #expect(aBInverse.deleteRule == .denyDeleteRule)
        
        let bName = try #require(b.attributesByName["name"])
        #expect(bName.type == .string)
        #expect(bName.isOptional == false)
    }
    
    @Test func requireToOneRelationship_IdentifiedToIdentified() async throws {
        struct A: StoredType, Identifiable {
            var id: String
            var b: B
        }
        
        struct B: StoredType, Identifiable {
            var id: String
            var name: String
        }
        
        let e = try CoreDataEngine(A.self)
        
        let a = try #require(await e.model.entitiesByName["A"])
        let b = try #require(await e.model.entitiesByName["B"])
        
        let aB = try #require(a.relationshipsByName["b"])
        #expect(aB.isOrdered == false)
        #expect(aB.isToMany == false)
        #expect(aB.isOptional == false)
        #expect(aB.deleteRule == .nullifyDeleteRule)
        
        let aBInverse = try #require(aB.inverseRelationship)
        #expect(aBInverse.name == "A_b")
        #expect(aBInverse.isOrdered == false)
        #expect(aBInverse.isToMany == true) // this is false because B is not Identifiable
        #expect(aBInverse.deleteRule == .denyDeleteRule)
        
        let bName = try #require(b.attributesByName["name"])
        #expect(bName.type == .string)
        #expect(bName.isOptional == false)
    }
    
    @Test func requireToOneRelationship_UnidentifiedToIdentified() async throws {
        struct A: StoredType {
            var b: B
        }
        
        struct B: StoredType, Identifiable {
            var id: String
            var name: String
        }
        
        let e = try CoreDataEngine(A.self)
        
        let a = try #require(await e.model.entitiesByName["A"])
        let b = try #require(await e.model.entitiesByName["B"])
        
        let aB = try #require(a.relationshipsByName["b"])
        #expect(aB.isOrdered == false)
        #expect(aB.isToMany == false)
        #expect(aB.isOptional == false)
        #expect(aB.deleteRule == .nullifyDeleteRule)
        
        let aBInverse = try #require(aB.inverseRelationship)
        #expect(aBInverse.name == "A_b")
        #expect(aBInverse.isOrdered == false)
        #expect(aBInverse.isToMany == true) // this is false because B is not Identifiable
        #expect(aBInverse.deleteRule == .cascadeDeleteRule)
        
        let bName = try #require(b.attributesByName["name"])
        #expect(bName.type == .string)
        #expect(bName.isOptional == false)
    }
}

#endif
