//
//  File.swift
//  
//
//  Created by Dave DeLong on 6/8/24.
//

import Foundation

func fields(of type: Any.Type) -> Array<(String, AnyKeyPath, Any.Type)> {
    _openExistential(type, do: fields(of:))
}

func fields<T>(of type: T.Type = T.self) -> Array<(String, PartialKeyPath<T>, Any.Type)> {
    var all = Array<(String, PartialKeyPath<T>, Any.Type)>()
    enumerateFields(of: type, using: {
        all.append(($0, $1, $2))
    })
    return all
}

func enumerateFields<T>(of type: T.Type = T.self, using block: (String, PartialKeyPath<T>, Any.Type) -> Void) {
    var options = EachFieldOptions()
    _ = forEachFieldWithKeyPath(of: type, options: &options, body: { label, keyPath in
        let string = String(cString: label)
        block(string, keyPath, keyPath.valueType)
        return true
    })
}

extension PartialKeyPath {
    var valueType: Any.Type { Self.valueType }
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
