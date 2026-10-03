//
//  NourishmentRepository.swift
//  MacroLog
//
//  Created by Sumangala Rao on 23/9/2026.
//
import Foundation

/// The one door between the app's logic and where the woman's health log is
/// stored: her meals, her symptoms, and her cycle markers.
///
/// Everything above this line (use cases, view models, views) depends only on
/// this protocol, never on Core Data. That single rule is what lets the tests
/// swap in an in-memory fake instead of a real database, and it is why the
/// database could be replaced later without touching a single screen.
protocol NourishmentRepository {

    // MARK: Meals and the day

    /// The day for a given calendar date: its meals and its target. If nothing
    /// has been logged yet, an empty day with the default target is returned.
    func day(on date: Date) throws -> NourishmentDay

    /// Records a meal. The meal is filed under the calendar date it was eaten.
    func record(_ meal: Meal) throws

    /// Removes a previously logged meal by its identity.
    func removeMeal(id: UUID) throws

    /// Sets the daily low-GI target for a given calendar date.
    func setTarget(_ target: DailyNourishmentTarget, on date: Date) throws

    /// The most recent days that have any record, newest first, up to `count`.
    func recentDays(endingOn date: Date, count: Int) throws -> [NourishmentDay]

    // MARK: Symptoms

    /// Records how the woman felt at a moment in time.
    func record(_ symptom: SymptomObservation) throws

    /// The symptoms she noted on a given calendar day, newest first.
    func symptoms(on date: Date) throws -> [SymptomObservation]

    // MARK: Cycle

    /// Records a cycle marker (period started/ended, spotting).
    func record(_ marker: CycleMarker) throws

    /// The cycle markers on a given calendar day.
    func cycleMarkers(on date: Date) throws -> [CycleMarker]

    /// The most recent cycle markers, newest first, up to `limit`.
    func recentCycleMarkers(limit: Int) throws -> [CycleMarker]
}
