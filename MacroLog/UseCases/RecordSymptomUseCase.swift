//
//  RecordSymptomUseCase.swift
//  MacroLog
//
//  Created by Sumangala Rao on 1/10/2026.
//
import Foundation

/// Notes how the user felt, so her symptoms can later be lined up against how
/// she ate and where she is in her cycle. The rule is honesty about time: she
/// can only note a symptom she has actually felt, not one in the future.
struct RecordSymptomUseCase {

    let repository: NourishmentRepository
    var now: () -> Date = { Date() }

    func execute(_ symptom: SymptomObservation) throws {
        guard symptom.observedAt <= now() else {
            throw RecordSymptomError.observationInTheFuture
        }
        try repository.record(symptom)
    }
}

enum RecordSymptomError: LocalizedError, Equatable {
    case observationInTheFuture

    var errorDescription: String? {
        switch self {
        case .observationInTheFuture:
            return "You're noting a symptom for a time that hasn't happened yet."
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .observationInTheFuture:
            return "Pick when you actually felt it."
        }
    }
}
