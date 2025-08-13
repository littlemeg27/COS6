//
//  PersistenceController.swift
//  SharedModule
//
//  Created by Brenna Pavlinchak on 8/10/25.
//

import Foundation
import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    var context: NSManagedObjectContext {
        return container.viewContext
    }
    
    init() {
        let bundle = Bundle.main
        print("Using bundle: \(bundle.bundleIdentifier ?? "nil") at path: \(bundle.bundlePath)")
        
        let momdResources = bundle.urls(forResourcesWithExtension: "momd", subdirectory: nil)
        print("Available .momd resources in bundle: \(momdResources ?? [])")
        
        guard let modelURL = bundle.url(forResource: "SwimCraft", withExtension: "momd") else {
            print("Error: Failed to find SwimCraft.momd in bundle: \(bundle.bundlePath)")
            fatalError("Failed to load Core Data model named SwimCraft")
        }
        print("Found modelURL: \(modelURL)")
        
        guard let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
            print("Error: Failed to initialize NSManagedObjectModel with URL: \(modelURL)")
            fatalError("Failed to load Core Data model named SwimCraft")
        }
        print("Initialized managedObjectModel successfully")
        
        container = NSPersistentContainer(name: "SwimCraft", managedObjectModel: managedObjectModel)
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                print("Core Data failed to load: \(error), \(error.userInfo)")
            } else {
                print("Core Data loaded successfully")
            }
        }
    }
}
