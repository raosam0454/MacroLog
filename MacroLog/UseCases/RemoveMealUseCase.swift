//
//  RemoveMealUseCase.swift
//  MacroLog
//
//  Created by Sumangala Rao on 24/9/2026.
//
import Foundation

/// Removes a meal the user logged by mistake or wants to take back.
///
/// The one rule here is honesty about what happened: the app only reports a
/// removal when there was really something to remove. If the meal has already
/// gone (say it was deleted on another screen), the user is told so,
/// vs a silent no-op.
struct RemoveMealUseCase {

    let repository: NourishmentRepository

    func execute(mealID: UUID, on date: Date) throws {
        let day = try repository.day(on: date)

        guard day.meals.contains(where: { $0.id == mealID }) else {
            throw RemoveMealError.mealNoLongerThere
        }

        try repository.removeMeal(id: mealID)
    }
}

/// Error handling when removing a meal.
enum RemoveMealError: LocalizedError, Equatable {
    case mealNoLongerThere

    var errorDescription: String? {
        switch self {
        case .mealNoLongerThere:
            return "That meal isn't in your day anymore, so there's nothing to remove."
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .mealNoLongerThere:
            return "Refresh your list to see what's currently logged."
        }
    }
}
