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
    internal let coordinator: NSPersistentStoreCoordinator
    
    public init(schema: Schema, at url: URL) async throws(StorageError) {
        self.model = try NSManagedObjectModel(compositeTypes: schema.compositeTypes)
        
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        do {
            try await withUnsafeThrowingContinuation { (c: UnsafeContinuation<Void, Error>) in
                let desc = NSPersistentStoreDescription(url: url)
                desc.type = NSSQLiteStoreType
                desc.shouldAddStoreAsynchronously = true
                desc.shouldMigrateStoreAutomatically = true
                coordinator.addPersistentStore(with: desc, completionHandler: { _, err in
                    if let err {
                        c.resume(throwing: err)
                    } else {
                        c.resume(returning: ())
                    }
                })
            }
        } catch {
            
        }
        
        self.coordinator = coordinator
    }
    
    public func save(_ value: any StoredType) throws(StorageError) {
        
    }
    
}

#endif
