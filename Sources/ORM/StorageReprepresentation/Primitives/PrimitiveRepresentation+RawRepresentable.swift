//
//  File.swift
//  
//
//  Created by Dave DeLong on 6/19/24.
//

import Foundation

// any RawRepresentable with a RawValue: PersistentValue
extension RawRepresentable where Self: Storable, RawValue: Storable {
    
    public static var storageRepresentation: some StorageRepresentation {
        BoxedRepresentation(outer: Self.self, inner: RawValue.storageRepresentation)
    }
    
    public static var missingValue: Self? {
        guard let missingRawValue = RawValue.missingValue else { return nil }
        return Self(rawValue: missingRawValue)
    }
}

// any Codable value

extension Encodable where Self: Storable & Decodable {
    
    public static var storageRepresentation: some StorageRepresentation {
        PrimitiveRepresentation<Self>(.codable)
    }
    
}
