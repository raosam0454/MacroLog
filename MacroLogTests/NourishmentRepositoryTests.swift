//
//  NourishmentRepositoryTests.swift
//  MacroLogTests
//
//  Created by Sumangala Rao on 5/10/2026.
//
import XCTest
@testable import MacroLog

/// Tests for the repository layer itself, exercised against the in-memory
/// implementation (the mock), never the Core Data stack. These check the
/// contract every use case relies on: that what is recorded comes back, that
/// removals take effect, and that a day with nothing logged reads sensibly.
final class NourishmentRepositoryTests: XCTestCase {

    func test_recordsAndReturnsAMealForTheDayItWasEaten() throws {
        let repository = InMemoryNourishmentRepository()
        let meal = Meal(name: "Steel-cut oats", occasion: .breakfast, carbohydrateGrams: 30, glycaemicIndexBand: .low)

        try repository.record(meal)

        let day = try repository.day(on: meal.eatenAt)
        XCTAssertEqual(day.meals.count, 1)
        XCTAssertEqual(day.meals.first?.name, "Steel-cut oats")
    }

    func test_removesAMealByItsIdentity() throws {
        let repository = InMemoryNourishmentRepository()
        let meal = Meal(name: "White rice", occasion: .dinner, carbohydrateGrams: 40, glycaemicIndexBand: .high)
        try repository.record(meal)

        try repository.removeMeal(id: meal.id)

        XCTAssertTrue(try repository.day(on: meal.eatenAt).meals.isEmpty)
    }

    func test_storesAndReturnsTheDailyTarget() throws {
        let repository = InMemoryNourishmentRepository()

        try repository.setTarget(DailyNourishmentTarget(maximumGlycaemicLoad: 75), on: Date())

        XCTAssertEqual(try repository.day(on: Date()).target.maximumGlycaemicLoad, 75)
    }

    // Boundary: a day with nothing logged is an empty day on the default target.
    func test_returnsAnEmptyDayOnTheDefaultTargetWhenNothingLogged() throws {
        let repository = InMemoryNourishmentRepository()

        let day = try repository.day(on: Date())

        XCTAssertTrue(day.meals.isEmpty)
        XCTAssertEqual(day.target.maximumGlycaemicLoad, DailyNourishmentTarget.gentleDefault.maximumGlycaemicLoad)
    }

    func test_recentDaysComeBackNewestFirst() throws {
        let repository = InMemoryNourishmentRepository()
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        try repository.record(Meal(name: "Yesterday", occasion: .lunch, carbohydrateGrams: 10, glycaemicIndexBand: .low, eatenAt: yesterday))
        try repository.record(Meal(name: "Today", occasion: .lunch, carbohydrateGrams: 10, glycaemicIndexBand: .low, eatenAt: today))

        let days = try repository.recentDays(endingOn: today, count: 7)
        XCTAssertEqual(days.count, 2)
        XCTAssertEqual(days.first?.date, today)
    }

    func test_keepsSymptomsAndCycleMarkersForTheDay() throws {
        let repository = InMemoryNourishmentRepository()

        try repository.record(SymptomObservation(kind: .bloating, severity: .mild, observedAt: Date()))
        try repository.record(CycleMarker(kind: .periodStarted, markedOn: Date()))

        XCTAssertEqual(try repository.symptoms(on: Date()).count, 1)
        XCTAssertEqual(try repository.cycleMarkers(on: Date()).count, 1)
    }
}
