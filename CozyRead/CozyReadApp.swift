//
//  CozyReadApp.swift
//  CozyRead
//
//  Created by Samuel Baxter on 8/1/23.
//

import SwiftUI

@main
struct CozyReadApp: App {
    @Environment(\.scenePhase) var scenePhase
    
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            NavBarView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
        .onChange(of: scenePhase) { _ in
            persistenceController.save()
        }
    }
}
