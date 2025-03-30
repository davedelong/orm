import Testing
@testable import ORM


struct SchemaTests {
    
    @Test func storedTypeCannotBeAClass() {
        class S: StoredType { }
        #expect(throws: Schema.Error.storedTypeMustBeValueType(S.self)) { try Schema(S.self) }
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
        
        #expect(throws: Schema.Error.identifierMustBePrimitive(S.self)) { try Schema(S.self) }
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
        
        #expect(throws: Schema.Error.identifierMustBePrimitive(S.self)) { try Schema(S.self) }
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
    
    @Test func storedDictionaryCannotHaveOptionalKey() throws {
        struct A: StoredType {
            var map: Dictionary<String?, Int>
        }
        
        #expect(throws: Schema.Error.dictionaryKeyCannotBeOptional(A.self, try A.Fields.map)) { try Schema(A.self) }
    }
    
    @Test func storedDictionaryCannotHaveComplexKey() throws {
        struct A: StoredType {
            var map: Dictionary<B, Int>
        }
        struct B: StoredType, Hashable {
            var value: Int
        }
        
        #expect(throws: Schema.Error.dictionaryKeyMustBePrimitive(A.self, try A.Fields.map)) { try Schema(A.self) }
    }
    
    @Test func multiValueFieldsCannotBeOptional() throws {
        struct A: StoredType {
            var ints: Array<Int>?
        }
        
        #expect(throws: Schema.Error.multiValueFieldsCannotBeOptional(A.self, try A.Fields.ints)) { try Schema(A.self) }
    }
    
    @Test func multiValueFieldsCannotBeNested() throws {
        struct A: StoredType {
            var names: Array<Array<String>>
        }
        
        #expect(throws: Schema.Error.multiValueFieldsCannotBeNested(A.self, try A.Fields.names)) { try Schema(A.self) }
    }
    
    @Test func dictionaryValuesCannotBeNested() throws {
        struct A: StoredType {
            var names: Dictionary<String, Array<String>>
        }
        
        #expect(throws: Schema.Error.multiValueFieldsCannotBeNested(A.self, try A.Fields.names)) { try Schema(A.self) }
    }
    
    @Test func noDoubleOptionals() throws {
        struct A: StoredType {
            var name: String??
        }
        
        #expect(throws: Schema.Error.optionalFieldCannotNestOptional(A.self, try A.Fields.name)) { try Schema(A.self) }
    }
}
