import Testing
@testable import ORM


struct SchemaTests {
    
    @Test func storedTypeCannotBeAClass() {
        class S: StoredType { }
        #expect(throws: Schema.Error.storedTypeIsNotValueType(S.self)) { try Schema(S.self) }
    }
    
    @Test func storedTypeCannotBeEmpty() {
        struct S: StoredType { }
        #expect(throws: Schema.Error.storedTypeIsEmpty(S.self)) { try Schema(S.self) }
    }
    
    @Test func storedTypeCannotHaveOptionalIdentifier() {
        struct S: StoredType, Identifiable {
            var id: String?
        }
        
        #expect(throws: Schema.Error.identifierCannotBeOptional(S.self)) { try Schema(S.self) }
    }
    
    @Test func storedTypeCannotHaveComplexIdentifier() {
        struct S: StoredType, Identifiable {
            var id: Array<Int>
        }
        
        #expect(throws: Schema.Error.identifierIsNotPrimitive(S.self)) { try Schema(S.self) }
    }
    
    @Test func storedTypeCannotHaveComputedIdentifier() {
        struct S: StoredType, Identifiable {
            var id: String { name }
            var name: String
        }
        
        #expect(throws: Schema.Error.storedTypeMissingIdentifier(S.self)) { try Schema(S.self) }
    }
    
    @Test func storedTypeCannotHaveNonStorableFields() {
        struct I { }
        struct S: StoredType {
            var i: I
        }
        
        #expect(throws: Schema.Error.unknownFieldType(S.self, "i", \S.i, I.self)) { try Schema(S.self) }
    }
    
    @Test func storedTypeCanHaveRawRepresentableID() throws {
        enum ID: String { case foo }
        struct S: StoredType, Identifiable {
            var id: ID
        }
        
        _ = try #require(try Schema(S.self))
    }
    
    @Test func storedTypeCannotHaveComplexRawRepresentableID() throws {
        struct ID: RawRepresentable, Hashable { var rawValue: Array<Int> }
        struct S: StoredType, Identifiable {
            var id: ID
        }
        
        #expect(throws: Schema.Error.identifierIsNotPrimitive(S.self)) { try Schema(S.self) }
    }
    
    @Test func schemaIgnoresDuplicateDeclaredTypes() throws {
        struct S: StoredType {
            var name: String
        }
        
        let s = try #require(try Schema(S.self, S.self))
        try #require(s.compositeTypes.count == 1)
    }
    
    @Test func schemaFollowsTransitiveDeclaredTypes() throws {
        struct S: StoredType {
            var t: T?
        }
        struct T: StoredType {
            var name: String
        }
        
        let s = try #require(try Schema(S.self))
        try #require(s.compositeTypes.count == 2)
    }
    
    @Test func schemaIgnoresTransitiveDuplicateTypes() throws {
        struct A: StoredType {
            var c: C
        }
        struct B: StoredType {
            var c: C
        }
        struct C: StoredType {
            var name: String
        }
        
        let s = try #require(try Schema(A.self, B.self))
        try #require(s.compositeTypes.count == 3)
    }
}
