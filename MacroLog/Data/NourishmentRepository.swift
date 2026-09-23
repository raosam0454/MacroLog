//
//  NourishmentRepository.swift
//  MacroLog
//
//  Created by Sumangala Rao on 23/9/2026.
//
import Foundation

/// The one door between the app's logic and where meals are stored.
///
/// Everything above this line (use cases, view models, views) depends only on
/// this protocol, never on Core Data. That single rule is what lets the tests
/// swap in an in-memory fake instead of a real database, and it is why the
/// database could be replaced later without touching a single screen.
protocol NourishmentRepository {

    /// The day for a given calendar date: its meals and its target. If nothing
    /// has been logged yet, an empty day with the default target is returned.
    func day(on date: Date) throws -> NourishmentDay

    /// Records a meal. The meal is filed under the calendar date it was eaten.
    func record(_ meal: Meal) throws

    /// Removes a previously logged meal by its identity.
    func removeMeal(id: UUID) throws

    /// Sets the daily low-GI target for a given calendar date.
    func setTarget(_ target: DailyNourishmentTarget, on date: Date) throws
}
