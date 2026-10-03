//
//  MacroLogApp.swift
//  MacroLog
//
//  Created by Sumangala Rao on 23/9/2026.
//
import SwiftUI

@main
struct MacroLogApp: App {

    /// The composition root: the one place the real Core Data-backed repository
    /// is created and handed to the UI. Swap this line for an in-memory
    /// repository and the whole app would run on fake data, unchanged.
    private let repository: NourishmentRepository

    init() {
        repository = CoreDataNourishmentRepository(context: NourishmentStore.shared.viewContext)
    }

    var body: some Scene {
        WindowGroup {
            RootView(repository: repository)
        }
    }
}
