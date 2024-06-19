//
//  File.swift
//
//
//  Created by Dave DeLong on 6/8/24.
//

import Foundation

//func fields(of type: Any.Type) -> Array<(String, AnyKeyPath)> {
//    _openExistential(type, do: fields(of:))
//}

func fields<T>(of type: T.Type = T.self) -> Array<(String, PartialKeyPath<T>)> {
    var all = Array<(String, PartialKeyPath<T>)>()
    enumerateFields(of: type, using: {
        all.append(($0, $1))
    })
    return all
}

func enumerateFields<T>(of type: T.Type = T.self, using block: (String, PartialKeyPath<T>) -> Void) {
    var options: EachFieldOptions = [.ignoreUnknown]
    _ = forEachFieldWithKeyPath(of: type, options: &options, body: { label, keyPath in
        let string = String(cString: label)
        block(string, keyPath)
        return true
    })
}

extension AnyKeyPath {
    internal var erasedRootType: any Any.Type { type(of: self).rootType }
    internal var erasedValueType: any Any.Type { type(of: self).valueType }
}

internal struct EachFieldOptions: OptionSet {
    static let classType = Self(rawValue: 1 << 0)
    static let ignoreUnknown = Self(rawValue: 1 << 1)
    
    let rawValue: UInt32
    
    init(rawValue: UInt32) {
        self.rawValue = rawValue
    }
}

@discardableResult
@_silgen_name("$ss24_forEachFieldWithKeyPath2of7options4bodySbxm_s01_bC7OptionsVSbSPys4Int8VG_s07PartialeF0CyxGtXEtlF")
private func forEachFieldWithKeyPath<Root>(
    of type: Root.Type,
    options: inout EachFieldOptions,
    body: (UnsafePointer<CChar>, PartialKeyPath<Root>) -> Bool
) -> Bool
