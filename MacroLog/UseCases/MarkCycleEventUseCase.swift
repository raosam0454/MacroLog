//
//  MarkCycleEventUseCase.swift
//  MacroLog
//
//  Created by Sumangala Rao on 1/10/2026.
//
import Foundation

/// Marks a point in the user's cycle (period started/ended, spotting). Two
/// rules keep the record trustworthy: an event can't be marked in the future,
/// and the same event can't be marked twice on the same day.
struct MarkCycleEventUseCase {

    let repository: NourishmentRepository
    var now: () -> Date = { Date() }

    func execute(_ marker: CycleMarker) throws {
        guard marker.markedOn <= now() else {
            throw MarkCycleEventError.eventInTheFuture
        }

        let sameDay = try repository.cycleMarkers(on: marker.markedOn)
        if sameDay.contains(where: { $0.kind == marker.kind }) {
            throw MarkCycleEventError.alreadyMarkedToday(kind: marker.kind)
        }

        try repository.record(marker)
    }
}

enum MarkCycleEventError: LocalizedError, Equatable {
    case eventInTheFuture
    case alreadyMarkedToday(kind: CycleMarkerKind)

    var errorDescription: String? {
        switch self {
        case .eventInTheFuture:
            return "You're marking a cycle event in the future."
        case .alreadyMarkedToday(let kind):
            return "You've already marked \"\(kind.displayName)\" today."
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .eventInTheFuture:
            return "Mark it on the day it happens."
        case .alreadyMarkedToday:
            return "There's no need to mark the same event twice in one day."
        }
    }
}
