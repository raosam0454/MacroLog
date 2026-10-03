//
//  DailyTargetViewModel.swift
//  MacroLog
//
//  Created by Sumangala Rao on 1/10/2026.
//
import Foundation
import Observation

/// The view model behind the Plan screen. It loads the current daily target and
/// saves a new one through `SetDailyTargetUseCase`, surfacing that use case's
/// human-centred errors if the number is out of range.
@MainActor
@Observable
final class DailyTargetViewModel {

    private let repository: NourishmentRepository

    var targetText: String = ""
    var message: String?
    var isError = false

    init(repository: NourishmentRepository) {
        self.repository = repository
    }

    func load() {
        let current = (try? repository.day(on: Date()))?.target.maximumGlycaemicLoad
            ?? DailyNourishmentTarget.gentleDefault.maximumGlycaemicLoad
        targetText = String(Int(current.rounded()))
    }

    func save() {
        message = nil
        isError = false

        let value = Double(targetText) ?? -1
        do {
            try SetDailyTargetUseCase(repository: repository)
                .execute(DailyNourishmentTarget(maximumGlycaemicLoad: value), on: Date())
            message = "Your daily target is set to \(Int(value)) glycaemic load."
        } catch {
            isError = true
            if let localized = error as? LocalizedError {
                message = [localized.errorDescription, localized.recoverySuggestion]
                    .compactMap { $0 }
                    .joined(separator: " ")
            } else {
                message = "Couldn't save your target."
            }
        }
    }
}
