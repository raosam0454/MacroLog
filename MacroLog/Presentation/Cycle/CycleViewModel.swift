//
//  CycleViewModel.swift
//  MacroLog
//
//  Created by Sumangala Rao on 1/10/2026.
//
import Foundation
import Observation

/// The view model behind the Cycle screen: it lists recent markers and records
/// new ones through `MarkCycleEventUseCase`, surfacing that use case's rules
/// (no future events, no marking the same event twice in a day).
@MainActor
@Observable
final class CycleViewModel {

    private let repository: NourishmentRepository

    private(set) var recentMarkers: [CycleMarker] = []
    var errorMessage: String?

    init(repository: NourishmentRepository) {
        self.repository = repository
    }

    func load() {
        recentMarkers = (try? repository.recentCycleMarkers(limit: 20)) ?? []
    }

    func mark(_ kind: CycleMarkerKind) {
        errorMessage = nil
        let marker = CycleMarker(kind: kind, markedOn: Date())
        do {
            try MarkCycleEventUseCase(repository: repository).execute(marker)
            load()
        } catch {
            errorMessage = CycleViewModel.humanMessage(for: error)
        }
    }

    private static func humanMessage(for error: Error) -> String {
        guard let localized = error as? LocalizedError else { return "Couldn't mark that." }
        return [localized.errorDescription, localized.recoverySuggestion]
            .compactMap { $0 }
            .joined(separator: " ")
    }
}
