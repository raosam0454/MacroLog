//
//  MealDetailViewModel.swift
//  MacroLog
//
//  Created by Sumangala Rao on 1/10/2026.
//
import Foundation
import Observation

/// The view model behind the Meal detail screen. It holds the meal being viewed
/// and turns "remove this meal" into a `RemoveMealUseCase` call.
@MainActor
@Observable
final class MealDetailViewModel {

    let meal: Meal
    private let repository: NourishmentRepository

    var errorMessage: String?
    private(set) var didRemove = false

    init(meal: Meal, repository: NourishmentRepository) {
        self.meal = meal
        self.repository = repository
    }

    var glycaemicLoad: Int { Int(meal.glycaemicLoad.value.rounded()) }

    func remove() {
        errorMessage = nil
        do {
            try RemoveMealUseCase(repository: repository)
                .execute(mealID: meal.id, on: meal.eatenAt)
            didRemove = true
        } catch {
            let localized = error as? LocalizedError
            errorMessage = localized?.errorDescription ?? "Couldn't remove this meal."
        }
    }
}
