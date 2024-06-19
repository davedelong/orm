//
//  File.swift
//  
//
//  Created by Dave DeLong on 6/16/24.
//

import Foundation

@resultBuilder
public struct ArrayBuilder<T> {
    
    // single expressions of one or more value
    public static func buildExpression(_ expression: T) -> Array<T> {
        return [expression]
    }
    
    public static func buildExpression(_ expression: Array<T>) -> Array<T> {
        return expression
    }
    
    // sequence of zero or more values
    public static func buildBlock() -> Array<T> {
        return []
    }
    
    public static func buildBlock(_ components: T...) -> Array<T> {
        return components
    }
    
    public static func buildBlock(_ components: Array<T>...) -> Array<T> {
        return components.flatMap { $0 }
    }
    
    // for loops of values
    public static func buildArray(_ components: [Array<T>]) -> Array<T> {
        return components.flatMap { $0 }
    }
    
    // optionals
    
    public static func buildExpression(_ expression: T?) -> Array<T> {
        return expression.map { [$0] } ?? []
    }
    
    public static func buildExpression(_ expression: Array<T>?) -> Array<T> {
        return expression ?? []
    }
    
    // conditionals
    
    public static func buildEither(first component: Array<T>) -> Array<T> {
        return component
    }
    
    public static func buildEither(second component: Array<T>) -> Array<T> {
        return component
    }
    
    // availability
    
    public static func buildLimitedAvailability(_ component: Array<T>) -> Array<T> {
        return component
    }
    
    // final
    
    public static func buildFinalResult(_ component: Array<T>) -> Array<T> {
        return component
    }
    
}
