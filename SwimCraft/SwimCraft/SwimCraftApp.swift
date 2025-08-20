//
//  SwimCraftApp.swift
//  SwimCraft
//
//  Created by Brenna Pavlinchak on 8/20/25.
//

import Foundation
import SwiftUI
import CoreData  // For PersistenceController

@main
struct SwimCraftApp: App {
    let persistenceController = PersistenceController.shared  // Your Core Data setup

    var body: some Scene {
        WindowGroup {
            WorkoutListView()  // Your main view (we'll create this next)
                .environment(\.managedObjectContext, persistenceController.context)  // Inject Core Data context
        }
    }
}
