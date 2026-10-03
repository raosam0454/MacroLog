//
//  LogMealViewModel.swift
//  MacroLog
//
//  Created by Sumangala Rao on 24/9/2026.
//
import Foundation

/// The view model behind the Log a meal screen. It gathers what the woman types,
/// hands it to `LogMealUseCase`, and if the use case refuses, turns the domain
/// error into a sentence she can act on.
@MainActor
@Observable
final class LogMealViewModel {

    private let repository: NourishmentRepository

    var name: String = ""
    var occasion: MealOccasion = .breakfast
    var carbohydrateText: String = ""
    var glycaemicIndexBand: GlycaemicIndexBand = .low
    var eatenAt: Date = Date()

    var errorMessage: String?
    private(set) var didSave = false

    init(repository: NourishmentRepository) {
        self.repository = repository
    }

    func save() {
        errorMessage = nil

        // A blank or non-numeric field becomes an invalid amount, which the use
        // case rejects with a clear message rather than silently logging zero.
        let carbohydrateGrams = Double(carbohydrateText) ?? -1

        let meal = Meal(
            name: name,
            occasion: occasion,
            carbohydrateGrams: carbohydrateGrams,
            glycaemicIndexBand: glycaemicIndexBand,
            eatenAt: eatenAt
        )

        do {
            try LogMealUseCase(repository: repository).execute(meal)
            didSave = true
        } catch {
            errorMessage = LogMealViewModel.humanMessage(for: error)
        }
    }

    /// Combines the "what went wrong" and "what to do next" of a domain error
    /// into one sentence for an alert.
    private static func humanMessage(for error: Error) -> String {
        guard let localized = error as? LocalizedError else {
            return "Something went wrong. Please try again."
        }
        let whatWentWrong = localized.errorDescription ?? "That didn't work."
        if let whatToDoNext = localized.recoverySuggestion {
            return "\(whatWentWrong) \(whatToDoNext)"
        }
        return whatWentWrong
    }
}
