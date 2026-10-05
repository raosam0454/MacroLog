//
//  SharedInboxStore.swift
//  MacroLog
//
//  Created by Sumangala Rao on 3/10/2026.
//
import Foundation

/// The "to log" inbox, kept as a JSON list in the shared App Group container.
/// The Share Extension appends to it; the app reads it and removes items as they
/// are logged. Living on the App Group is what lets the two separate processes
/// hand items to each other.
enum SharedInboxStore {

    private static let fileName = "share-inbox.json"

    private static var fileURL: URL? {
        FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: AppGroup.identifier)?
            .appendingPathComponent(fileName)
    }

    /// Everything waiting to be logged, oldest first.
    static func all() -> [SharedItem] {
        guard let url = fileURL, let data = try? Data(contentsOf: url) else { return [] }
        return (try? JSONDecoder().decode([SharedItem].self, from: data)) ?? []
    }

    /// Called by the Share Extension when something is shared in.
    static func append(_ item: SharedItem) {
        var items = all()
        items.append(item)
        write(items)
    }

    /// Called by the app once an item has been turned into a meal.
    static func remove(id: UUID) {
        write(all().filter { $0.id != id })
    }

    private static func write(_ items: [SharedItem]) {
        guard let url = fileURL, let data = try? JSONEncoder().encode(items) else { return }
        try? data.write(to: url, options: .atomic)
    }
}
