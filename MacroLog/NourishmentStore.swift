//
//  NourishmentStore.swift
//  MacroLog
//
//  Created by Sumangala Rao on 23/9/2026.
//
import CoreData

/// The Core Data stack for MacroLog.
///
/// the database file is placed inside the shared App Group container,
/// so the widget extension can later read the very same data the app writes.
/// Nothing above this type ever touches Core
/// Data: screens and view models talk to a repository, and the repository is
/// the only thing that talks to this store.
///
final class NourishmentStore {

    /// The shared instance the running app uses.
    static let shared = NourishmentStore()

    let container: NSPersistentContainer

    /// The main-queue context the app reads and writes on.
    var viewContext: NSManagedObjectContext { container.viewContext }

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "MacroLog")

        if inMemory {
            // Used by previews and any test that wants the real Core Data stack
            // without writing a file to disk.
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        } else if let sharedURL = NourishmentStore.sharedStoreURL {
            container.persistentStoreDescriptions = [NSPersistentStoreDescription(url: sharedURL)]
        }
        // If the App Group container is unavailable (for example the entitlement
        // is missing on this build configuration), we fall through to Core
        // Data's default location so the app still runs during development.

        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                assertionFailure("Could not load the nourishment store: \(error), \(error.userInfo)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    /// The database file inside the App Group container, shared with the widget.
    private static var sharedStoreURL: URL? {
        FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: AppGroup.identifier)?
            .appendingPathComponent("MacroLog.sqlite")
    }
}
