//
//  TodayViewModel.swift
//  MacroLog
//
//  Created by Sumangala Rao on 24/9/2026.
//
import Foundation
import Observation

/// The view model behind the Today screen. It holds the day, exposes the few
/// numbers the screen shows, surfaces anything shared in from other apps, and
/// turns user actions into use case calls. It is `@MainActor` because it drives
/// the UI; it talks only to the repository protocol, never to Core Data.
@MainActor
@Observable
final class TodayViewModel {

    private let repository: NourishmentRepository
    private(set) var day: NourishmentDay
    private(set) var pendingShares: [SharedItem] = []

    init(repository: NourishmentRepository) {
        self.repository = repository
        self.day = NourishmentDay(date: Date())
    }

    var meals: [Meal] { day.meals }
    var isWithinTarget: Bool { day.isWithinTarget }
    var remainingLoad: Int { Int(day.remainingGlycaemicLoad.rounded()) }
    var loadSoFar: Int { Int(day.glycaemicLoadSoFar.value.rounded()) }
    var targetLoad: Int { Int(day.target.maximumGlycaemicLoad.rounded()) }

    /// Reloads today and the share inbox, then publishes a fresh snapshot so the
    /// widget shows the same numbers the app does.
    func load() {
        do {
            day = try repository.day(on: Date())
        } catch {
            day = NourishmentDay(date: Date())
        }
        pendingShares = SharedInboxStore.all()
        WidgetSync.publish(day)
    }

    /// Removes a meal she swiped away, then refreshes.
    func remove(_ meal: Meal) {
        try? RemoveMealUseCase(repository: repository)
            .execute(mealID: meal.id, on: meal.eatenAt)
        load()
    }

    /// Clears a shared item once it has been turned into a meal.
    func clearShare(_ item: SharedItem) {
        SharedInboxStore.remove(id: item.id)
        pendingShares = SharedInboxStore.all()
    }
}
