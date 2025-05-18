//
//  TypeDetectors.swift
//  ORM
//
//  Created by Dave DeLong on 3/13/25.
//

internal protocol ArrayType {
    static var elementType: Any.Type { get }
}

internal protocol SetType {
    static var elementType: Any.Type { get }
}

internal protocol DictionaryType {
    static var keyType: Any.Type { get }
    static var valueType: Any.Type { get }
}

internal protocol OptionalType {
    static var wrappedType: Any.Type { get }
    var isNull: Bool { get }
}

extension Array: ArrayType {
    static var elementType: any Any.Type { Element.self }
}

extension Set: SetType {
    static var elementType: any Any.Type { Element.self }
}

extension Dictionary: DictionaryType {
    static var keyType: Any.Type { Key.self }
    static var valueType: any Any.Type { Value.self }
}

extension Optional: OptionalType {
    static var wrappedType: any Any.Type { Wrapped.self }
    var isNull: Bool {
        if case .none = self { return true }
        return false
    }
}

extension RawRepresentable {
    static var rawValueType: Any.Type { RawValue.self }
}
