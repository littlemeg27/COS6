//
//  SwimCraftApp.swift
//  SwimCraft
//
//  Created by Brenna Pavlinchak on 8/20/25.
//

import SwiftUI

@main
struct SwimCraftApp: App
{
    let persistenceController = PersistenceController.shared
    
    var body: some Scene
    {
        WindowGroup
        {
            SplashView()
                .environment(\.managedObjectContext, persistenceController.context)
        }
    }
}
