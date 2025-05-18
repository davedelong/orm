//
//  SQLiteHandle.swift
//  ORM
//
//  Created by Dave DeLong on 5/17/25.
//

import Foundation
import SQLite3

infix operator ?!: NilCoalescingPrecedence

internal func ?! <T, E: Error>(lhs: T?, rhs: @autoclosure () -> E) throws(E) -> T {
    if let lhs { return lhs }
    throw rhs()
}

fileprivate func unwrap<T>(_ lhs: T?) throws(SQLiteError) -> T {
    return try lhs ?! SQLiteError(rawValue: SQLITE_INTERNAL)
}

struct SQLiteError: Error, CustomStringConvertible {
    let rawValue: Int32
    
    var description: String {
        "SQLite Error \(rawValue): \(String(cString: sqlite3_errstr(rawValue)))"
    }
}

fileprivate func check(_ status: Int32) throws(SQLiteError) {
    if status == SQLITE_OK { return }
    if status == SQLITE_ROW { return }
    if status == SQLITE_DONE { return }
    
    throw SQLiteError(rawValue: status)
}

internal class SQLiteHandle {
    private let dbHandle: OpaquePointer
    private var statements = Dictionary<String, Weak<SQLiteStatement>>()
    
    init(path: String) throws {
        dbHandle = try path.withCString { pathPtr in
            var ptr: OpaquePointer?
            let status = sqlite3_open_v2(pathPtr, &ptr, (SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE | SQLITE_OPEN_FULLMUTEX | SQLITE_OPEN_URI), nil)
            try check(status)
            return try ptr ?! SQLiteError(rawValue: SQLITE_INTERNAL)
        }
    }
    
    deinit {
        statements.values.forEach { $0.value?.handle = nil; $0.value = nil }
        statements.removeAll()
        sqlite3_close_v2(dbHandle)
    }
    
    func transaction(_ perform: (SQLiteHandle) throws -> Void) throws {
        try execute("BEGIN TRANSACTION")
        try perform(self)
        let txn = try execute("COMMIT TRANSACTION")
        print(txn)
    }
    
    @discardableResult
    func execute(_ sql: String) throws -> SQLiteStatement.Step {
        let s = try prepare(sql)
        return try run(s)
    }
    
    func prepare(_ sql: String) throws -> SQLiteStatement {
        print(sql)
        if let existing = statements[sql]?.value {
            try existing.reset()
            return existing
        }
        
        var handle: OpaquePointer?
        let status = sqlite3_prepare_v2(dbHandle, sql, -1, &handle, nil)
        try check(status)
        
        let statement = try SQLiteStatement(handle: unwrap(handle))
        statements[sql] = Weak(value: statement)
        return statement
    }
    
    func run(_ statement: SQLiteStatement) throws -> SQLiteStatement.Step {
        return try statement.step()
    }
    
}

private class Weak<T: AnyObject> {
    
    fileprivate(set) weak var value: T?
    
    init(value: T) {
        self.value = value
    }
    
}

/**
 The constant, `SQLITE_TRANSIENT`, may be passed to indicate that the object is to be copied prior to the return from `sqlite3_bind_*()`.
 The object and pointer to it must remain valid until then. SQLite will then manage the lifetime of its private copy.
 
 ```
 #define SQLITE_TRANSIENT   ((sqlite3_destructor_type)-1)
 ```
 */
private let transient = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

internal class SQLiteStatement {
    
    enum Step {
        case ok(Dictionary<String, SQLiteValue>)
        case done(Dictionary<String, SQLiteValue>)
    }
    
    fileprivate var handle: OpaquePointer? {
        didSet {
            if let oldValue, handle == nil {
                sqlite3_finalize(oldValue)
            }
        }
    }
    let parameterCount: Int32
    
    fileprivate init(handle: OpaquePointer) {
        self.handle = handle
        self.parameterCount = sqlite3_bind_parameter_count(handle)
    }
    
    fileprivate func reset() throws {
        let h = try unwrap(handle)
        try check(sqlite3_reset(h))
        try check(sqlite3_clear_bindings(h))
    }
    
    internal func bind(_ value: SQLiteValue, name: String) throws {
        let h = try unwrap(handle)
        let idx = sqlite3_bind_parameter_index(h, name)
        try bind(value, at: idx)
    }
    
    internal func bind(_ value: SQLiteValue, at idx: Int32) throws {
        guard idx > 0 else { throw SQLiteError(rawValue: SQLITE_NOTFOUND) }
        guard idx <= parameterCount else { throw SQLiteError(rawValue: SQLITE_RANGE) }
        print("BINDING \(idx) = \(value)")
        let h = try unwrap(handle)
        switch value {
            case .null:
                try check(sqlite3_bind_null(h, idx))
            case .bool(let b):
                try check(sqlite3_bind_int64(h, idx, b ? 1 : 0))
            case .int(let i):
                try check(sqlite3_bind_int64(h, idx, i))
            case .double(let d):
                try check(sqlite3_bind_double(h, idx, d))
            case .text(let t):
                try check(sqlite3_bind_text(h, idx, t, -1, transient))
            case .blob(let d):
                if d.isEmpty {
                    try check(sqlite3_bind_zeroblob(h, idx, 0))
                } else {
                    try d.withUnsafeBytes { ptr in
                        try check(sqlite3_bind_blob(h, idx, ptr.baseAddress, Int32(ptr.count), transient))
                    }
                }
        }
    }
    
    fileprivate func step() throws -> Step {
        let stmt = try unwrap(handle)
        
        let status = sqlite3_step(stmt)
        try check(status)
        
        let columnCount = sqlite3_column_count(stmt)
        var results = Dictionary<String, SQLiteValue>()
        for col in 0 ..< columnCount {
            let name = String(cString: sqlite3_column_name(stmt, col))
            let type = sqlite3_column_type(stmt, col)
            switch type {
                case SQLITE_INTEGER:
                    results[name] = .int(Int64(sqlite3_column_int(stmt, col)))
                case SQLITE_FLOAT:
                    results[name] = .double(sqlite3_column_double(stmt, col))
                case SQLITE_TEXT:
                    results[name] = .text(String(cString: sqlite3_column_text(stmt, col)))
                case SQLITE_BLOB:
                    let byteCount = sqlite3_column_bytes(stmt, col)
                    if byteCount > 0 {
                        let data = Data(bytes: sqlite3_column_blob(stmt, col), count: Int(byteCount))
                        results[name] = .blob(data)
                    } else {
                        results[name] = .blob(Data())
                    }
                case SQLITE_NULL:
                    results[name] = .null
                default: fatalError()
            }
        }
        
        if status == SQLITE_DONE {
            return .done(results)
        } else {
            return .ok(results)
        }
    }
}

internal enum SQLiteValue {
    case null
    case bool(Bool)
    case int(Int64)
    case double(Double)
    case text(String)
    case blob(Data)
}
