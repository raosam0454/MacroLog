import CoreData

/// The Core Data stack for MacroLog.
///
/// The database file is placed inside the shared App Group container, so the
/// widget extension can later read the very same data the app writes. Nothing
/// above this type ever touches Core Data: screens and view models talk to a
/// repository, and the repository is the only thing that talks to this store.
///
/// The store is loaded defensively. If the file on disk cannot be opened (most
/// often because it was left over from an earlier version of the model during
/// development), the app resets the local store rather than crashing at launch.
final class NourishmentStore {

    /// The shared instance the running app uses.
    static let shared = NourishmentStore()

    let container: NSPersistentContainer

    /// The main-queue context the app reads and writes on.
    var viewContext: NSManagedObjectContext { container.viewContext }

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "MacroLog")
        container.persistentStoreDescriptions = [NourishmentStore.makeDescription(inMemory: inMemory)]
        loadStores(canRecover: !inMemory)
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    // MARK: - Store location

    private static func makeDescription(inMemory: Bool) -> NSPersistentStoreDescription {
        let description: NSPersistentStoreDescription

        if inMemory {
            description = NSPersistentStoreDescription(url: URL(fileURLWithPath: "/dev/null"))
        } else if let sharedURL = sharedStoreURL {
            description = NSPersistentStoreDescription(url: sharedURL)
        } else {
            // The App Group container is unavailable on this build (for example
            // the entitlement is off in Debug). Fall back to Core Data's own
            // default location so the app still runs during development.
            let fallback = NSPersistentContainer.defaultDirectoryURL()
                .appendingPathComponent("MacroLog.sqlite")
            description = NSPersistentStoreDescription(url: fallback)
        }

        description.shouldMigrateStoreAutomatically = true
        description.shouldInferMappingModelAutomatically = true
        return description
    }

    /// The database file inside the App Group container, shared with the widget.
    private static var sharedStoreURL: URL? {
        FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: AppGroup.identifier)?
            .appendingPathComponent("MacroLog.sqlite")
    }

    // MARK: - Loading with recovery

    private func loadStores(canRecover: Bool) {
        var loadError: Error?
        container.loadPersistentStores { _, error in loadError = error }
        guard let error = loadError else { return }

        print("NourishmentStore: could not open the store (\(error)).")

        guard canRecover,
              let url = container.persistentStoreDescriptions.first?.url,
              url.path != "/dev/null" else {
            fallBackToInMemory()
            return
        }

        destroyStore(at: url)

        var retryError: Error?
        container.loadPersistentStores { _, error in retryError = error }
        if let retryError {
            print("NourishmentStore: recovery failed (\(retryError)). Using an in-memory store.")
            fallBackToInMemory()
        } else {
            print("NourishmentStore: recovered by resetting the local store.")
        }
    }

    private func destroyStore(at url: URL) {
        try? container.persistentStoreCoordinator.destroyPersistentStore(
            at: url, ofType: NSSQLiteStoreType, options: nil
        )
        for suffix in ["", "-wal", "-shm"] {
            try? FileManager.default.removeItem(at: URL(fileURLWithPath: url.path + suffix))
        }
    }

    private func fallBackToInMemory() {
        container.persistentStoreDescriptions = [
            NSPersistentStoreDescription(url: URL(fileURLWithPath: "/dev/null"))
        ]
        container.loadPersistentStores { _, error in
            if let error {
                print("NourishmentStore: in-memory fallback failed (\(error)).")
            }
        }
    }
}
