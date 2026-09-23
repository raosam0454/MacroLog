//
//  MacroLogApp.swift
//  MacroLog
//
//  Created by Sumangala Rao on 23/9/2026.
//
import SwiftUI

@main
struct MacroLogApp: App {

    /// The Core Data stack is created once, here, and lives for the life of the
    /// app. Screens will reach their data through a repository built on top of
    /// it, which we wire up when we build the first screen.
    private let store = NourishmentStore.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
