//
//  PersistenceController.swift
//  SharedModule
//
//  Created by Brenna Pavlinchak on 8/10/25.
//

import Foundation
import CoreData

class PersistenceController
{
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false)
    {
        container = NSPersistentContainer(name: "SwimCraft")
        if inMemory
        {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores
        {
            _, error in
            
            if let error = error
            {
                print("Error loading Core Data: \(error.localizedDescription)")
            }
            else
            {
                print("Core Data loaded successfully")
            }
        }
    }
    
    var context: NSManagedObjectContext
    {
        container.viewContext
    }
}
