//
//  TodayViewModel.swift
//  MacroLog
//
//  Created by Sumangala Rao on 24/9/2026.
//
import Foundation
import Observation

/// The view model behind the Today screen. It holds the day, exposes the few
/// numbers the screen shows, and turns user actions into use case calls. It is
/// `@MainActor` because it drives the UI; it talks only to the repository
/// protocol, never to Core Data.
@MainActor
@Observable
final class TodayViewModel {

    private let repository: NourishmentRepository
    private(set) var day: NourishmentDay

    init(repository: NourishmentRepository) {
        self.repository = repository
        self.day = NourishmentDay(date: Date())
    }

    var meals: [Meal] { day.meals }
    var isWithinTarget: Bool { day.isWithinTarget }
    var remainingLoad: Int { Int(day.remainingGlycaemicLoad.rounded()) }
    var loadSoFar: Int { Int(day.glycaemicLoadSoFar.value.rounded()) }
    var targetLoad: Int { Int(day.target.maximumGlycaemicLoad.rounded()) }

    /// Reloads today from the repository. Called when the screen appears and
    /// after anything changes the day.
    func load() {
        do {
            day = try repository.day(on: Date())
        } catch {
            day = NourishmentDay(date: Date())
        }
    }

    /// Removes a meal she swiped away, then refreshes.
    func remove(_ meal: Meal) {
        try? RemoveMealUseCase(repository: repository)
            .execute(mealID: meal.id, on: meal.eatenAt)
        load()
    }
}
