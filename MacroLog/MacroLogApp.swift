//
//  MacroLogApp.swift
//  MacroLog
//
//  Created by Sumangala Rao on 23/9/2026.
//

import SwiftUI
import CoreData

@main
struct MacroLogApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
