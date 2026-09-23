//
//  InMemoryNourishmentRepository.swift
//  MacroLog
//
//  Created by Sumangala Rao on 23/9/2026.
//
import Foundation

/// An in-memory repository used by unit tests and SwiftUI previews.
///
/// It behaves exactly like the real Core Data repository, but keeps everything
/// in dictionaries instead of a database. This is the "mock" the assessment
/// asks for: tests exercise the use cases against this, so they never spin up a
/// Core Data stack and never leave a file behind.
final class InMemoryNourishmentRepository: NourishmentRepository {

    private var mealsByDay: [Date: [Meal]] = [:]
    private var targetsByDay: [Date: DailyNourishmentTarget] = [:]

    init(seed: [Meal] = []) {
        for meal in seed {
            try? record(meal)
        }
    }

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
}
