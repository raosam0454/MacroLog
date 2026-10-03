//
//  InMemoryNourishmentRepository.swift
//  MacroLog
//
//  Created by Sumangala Rao on 23/9/2026.
//
import Foundation

/// An in-memory repository used by unit tests and SwiftUI previews.
///
/// It behaves like the real Core Data repository, but keeps everything in
/// arrays and dictionaries instead of a database. This is the "mock" the
/// assessment asks for: tests exercise the use cases against this, so they never
/// spin up a Core Data stack and never leave a file behind.
///
/// Marked `nonisolated` so it is plain, main-actor-free storage, which is what a
/// data type should be.
nonisolated final class InMemoryNourishmentRepository: NourishmentRepository {

    private var mealsByDay: [Date: [Meal]] = [:]
    private var targetsByDay: [Date: DailyNourishmentTarget] = [:]
    private var symptomLog: [SymptomObservation] = []
    private var cycleMarkerLog: [CycleMarker] = []

    init(seed: [Meal] = []) {
        for meal in seed {
            try? record(meal)
        }
    }

    // MARK: - Meals and the day

    func day(on date: Date) throws -> NourishmentDay {
        let start = Calendar.current.startOfDay(for: date)
        return NourishmentDay(
            date: start,
            meals: (mealsByDay[start] ?? []).sorted { $0.eatenAt < $1.eatenAt },
            target: targetsByDay[start] ?? .gentleDefault
        )
    }

    func record(_ meal: Meal) throws {
        let start = Calendar.current.startOfDay(for: meal.eatenAt)
        mealsByDay[start, default: []].append(meal)
    }

    func removeMeal(id: UUID) throws {
        for (day, meals) in mealsByDay {
            mealsByDay[day] = meals.filter { $0.id != id }
        }
    }

    func setTarget(_ target: DailyNourishmentTarget, on date: Date) throws {
        let start = Calendar.current.startOfDay(for: date)
        targetsByDay[start] = target
    }

    func recentDays(endingOn date: Date, count: Int) throws -> [NourishmentDay] {
        let start = Calendar.current.startOfDay(for: date)
        let dayKeys = Set(mealsByDay.keys).union(targetsByDay.keys)
        let recent = dayKeys
            .filter { $0 <= start }
            .sorted(by: >)
            .prefix(count)
        return try recent.map { try day(on: $0) }
    }

    // MARK: - Symptoms

    func record(_ symptom: SymptomObservation) throws {
        symptomLog.append(symptom)
    }

    func symptoms(on date: Date) throws -> [SymptomObservation] {
        symptomLog
            .filter { Calendar.current.isDate($0.observedAt, inSameDayAs: date) }
            .sorted { $0.observedAt > $1.observedAt }
    }

    // MARK: - Cycle

    func record(_ marker: CycleMarker) throws {
        cycleMarkerLog.append(marker)
    }

    func cycleMarkers(on date: Date) throws -> [CycleMarker] {
        cycleMarkerLog.filter { Calendar.current.isDate($0.markedOn, inSameDayAs: date) }
    }

    func recentCycleMarkers(limit: Int) throws -> [CycleMarker] {
        Array(cycleMarkerLog.sorted { $0.markedOn > $1.markedOn }.prefix(limit))
    }
}
