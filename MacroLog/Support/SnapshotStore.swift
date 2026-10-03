//
//  SnapshotStore.swift
//  MacroLog
//
//  Created by Sumangala Rao on 2/10/2026.
//
import Foundation

/// Reads and writes the `TodaySnapshot` in the shared App Group container, as a
/// small JSON file. Both the main app (writer) and the widget (reader) use this,
/// which is why it lives on the App Group rather than in either target's private
/// storage.
enum SnapshotStore {

    private static let fileName = "today-snapshot.json"

    private static var fileURL: URL? {
        FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: AppGroup.identifier)?
            .appendingPathComponent(fileName)
    }

    /// Called by the app after today changes.
    static func save(_ snapshot: TodaySnapshot) {
        guard let url = fileURL else { return }
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        try? data.write(to: url, options: .atomic)
    }

    /// Called by the widget when it builds its timeline.
    static func load() -> TodaySnapshot? {
        guard let url = fileURL, let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(TodaySnapshot.self, from: data)
    }
}
