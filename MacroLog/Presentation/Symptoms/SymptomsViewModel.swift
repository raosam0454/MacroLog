//
//  SymptomsViewModel.swift
//  MacroLog
//
//  Created by Sumangala Rao on 1/10/2026.
//
import Foundation
import Observation

/// The view model behind the Symptoms screen: it loads today's noted symptoms
/// and records new ones through `RecordSymptomUseCase`.
@MainActor
@Observable
final class SymptomsViewModel {

    private let repository: NourishmentRepository

    private(set) var todaysSymptoms: [SymptomObservation] = []
    var selectedKind: SymptomKind = .fatigue
    var selectedSeverity: SymptomSeverity = .moderate
    var errorMessage: String?

    init(repository: NourishmentRepository) {
        self.repository = repository
    }

    func load() {
        todaysSymptoms = (try? repository.symptoms(on: Date())) ?? []
    }

    func noteSymptom() {
        errorMessage = nil
        let symptom = SymptomObservation(
            kind: selectedKind,
            severity: selectedSeverity,
            observedAt: Date()
        )
        do {
            try RecordSymptomUseCase(repository: repository).execute(symptom)
            load()
        } catch {
            errorMessage = SymptomsViewModel.humanMessage(for: error)
        }
    }

    private static func humanMessage(for error: Error) -> String {
        guard let localized = error as? LocalizedError else { return "Couldn't note that symptom." }
        return [localized.errorDescription, localized.recoverySuggestion]
            .compactMap { $0 }
            .joined(separator: " ")
    }
}
