//
//  CoreDataEngine.swift
//  ORM
//
//  Created by Dave DeLong on 3/16/25.
//

#if canImport(CoreData)
import CoreData

public actor CoreDataEngine: StorageEngine {
    
    internal let model: NSManagedObjectModel
    
    public init(schema: Schema) throws(Schema.Error) {
        self.model = try NSManagedObjectModel(compositeTypes: schema.compositeTypes)
    }
    
}

#endif
