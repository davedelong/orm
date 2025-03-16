//
//  File.swift
//  
//
//  Created by Dave DeLong on 6/16/24.
//

import Foundation

internal struct Bimap<L: Hashable, R: Hashable>: CustomStringConvertible {
    
    private var leftToRight: Dictionary<L, R>
    private var rightToLeft: Dictionary<R, L>
    
    internal var description: String {
        let pairs = leftToRight.map { "\($0) <-> \($1)" }.joined(separator: ", ")
        return "Bimap<\(L.self), \(R.self)>(\(leftToRight.count): \(pairs))"
    }
    
    internal init() {
        leftToRight = [:]
        rightToLeft = [:]
    }
    
    internal init(_ elements: any Collection<(L, R)>) {
        leftToRight = Dictionary(uniqueKeysWithValues: elements)
        rightToLeft = Dictionary(uniqueKeysWithValues: elements.map { ($1, $0) })
    }
    
    subscript(left: L) -> R? {
        get { leftToRight[left] }
        set { leftToRight[left] = newValue }
    }
    
    subscript(right: R) -> L? {
        get { rightToLeft[right] }
        set { rightToLeft[right] = newValue }
    }
}
