//
//  LogMealUseCase.swift
//  MacroLog
//
//  Created by Sumangala Rao on 24/9/2026.
//
import Foundation

/// Records a meal in the user's day, but only once it passes the checks that
/// keep her log trustworthy: a real name, a believable portion, and a time that
/// has actually happened.
///
/// This is the app's primary business operation. Everything the woman does most
/// often flows through here, and every rule that decides whether a meal is
/// allowed to be saved lives in one place: this struct.
struct LogMealUseCase {

    let repository: NourishmentRepository

    /// The current time, injected so tests can pin "now" and check the
    /// no-meals-in-the-future rule without waiting for the clock.
    var now: () -> Date = { Date() }

    /// The largest carbohydrate amount we treat as a real single portion.
    /// Anything larger is assumed to be a typo rather than a genuine meal.
    static let maximumBelievablePortion: Double = 1000

    func execute(_ meal: Meal) throws {
        let trimmedName = meal.name.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty else {
            throw LogMealError.unnamedMeal
        }
        guard meal.carbohydrateGrams > 0 else {
            throw LogMealError.emptyPortion
        }
        guard meal.carbohydrateGrams <= LogMealUseCase.maximumBelievablePortion else {
            throw LogMealError.implausiblePortion(grams: meal.carbohydrateGrams)
        }
        guard meal.eatenAt <= now() else {
            throw LogMealError.mealInTheFuture
        }

        var cleaned = meal
        cleaned.name = trimmedName
        try repository.record(cleaned)
    }
}

/// Error handling for logging a meal, written for the user using the app,
/// `errorDescription` says what went wrong; 
/// `recoverySuggestion` says what to do next.
enum LogMealError: LocalizedError, Equatable {
    case unnamedMeal
    case emptyPortion
    case implausiblePortion(grams: Double)
    case mealInTheFuture

    var errorDescription: String? {
        switch self {
        case .unnamedMeal:
            return "This meal doesn't have a name yet."
        case .emptyPortion:
            return "This meal has no carbohydrate recorded."
        case .implausiblePortion(let grams):
            return "\(Int(grams)) g of carbohydrate looks higher than a real portion."
        case .mealInTheFuture:
            return "This meal is set at a time that hasn't happened yet."
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .unnamedMeal:
            return "Add what you ate, then save."
        case .emptyPortion:
            return "Enter how many grams of carbohydrate it had, then save."
        case .implausiblePortion:
            return "Check the amount and try again."
        case .mealInTheFuture:
            return "Pick the time you actually ate it."
        }
    }
}
