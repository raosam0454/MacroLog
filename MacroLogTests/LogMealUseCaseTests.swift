//
//  LogMealUseCaseTests.swift
//  MacroLog
//
//  Created by Sumangala Rao on 24/9/2026.
//
import XCTest
@testable import MacroLog

/// Tests for the app's primary operation. Named in domain terms: each test says
/// what the woman is trying to do and what the app should decide.
final class LogMealUseCaseTests: XCTestCase {

    // Happy path
    func test_logsMeal_whenItHasANameAPortionAndAPastTime() throws {
        let repository = InMemoryNourishmentRepository()
        let useCase = LogMealUseCase(repository: repository)

        let breakfast = Meal(
            name: "Steel-cut oats",
            occasion: .breakfast,
            carbohydrateGrams: 30,
            glycaemicIndexBand: .low,
            eatenAt: Date()
        )

        try useCase.execute(breakfast)

        let today = try repository.day(on: Date())
        XCTAssertEqual(today.meals.count, 1)
        XCTAssertEqual(today.meals.first?.name, "Steel-cut oats")
    }

    // Domain error: a meal with no name
    func test_refusesToLogAMealWithNoName() {
        let repository = InMemoryNourishmentRepository()
        let useCase = LogMealUseCase(repository: repository)

        let nameless = Meal(
            name: "   ",
            occasion: .snack,
            carbohydrateGrams: 15,
            glycaemicIndexBand: .low
        )

        XCTAssertThrowsError(try useCase.execute(nameless)) { error in
            XCTAssertEqual(error as? LogMealError, .unnamedMeal)
        }
    }

    // Boundary: a meal timed in the future
    func test_refusesToLogAMealEatenInTheFuture() {
        let repository = InMemoryNourishmentRepository()
        let fixedNow = Date()
        let useCase = LogMealUseCase(repository: repository, now: { fixedNow })

        let laterToday = fixedNow.addingTimeInterval(60 * 60)
        let futureMeal = Meal(
            name: "Planned dinner",
            occasion: .dinner,
            carbohydrateGrams: 45,
            glycaemicIndexBand: .medium,
            eatenAt: laterToday
        )

        XCTAssertThrowsError(try useCase.execute(futureMeal)) { error in
            XCTAssertEqual(error as? LogMealError, .mealInTheFuture)
        }
    }

    // Boundary: an implausibly large portion is treated as a typo
    func test_refusesAnImplausiblyLargePortion() {
        let repository = InMemoryNourishmentRepository()
        let useCase = LogMealUseCase(repository: repository)

        let typo = Meal(
            name: "Rice",
            occasion: .lunch,
            carbohydrateGrams: 5000,
            glycaemicIndexBand: .high
        )

        XCTAssertThrowsError(try useCase.execute(typo)) { error in
            XCTAssertEqual(error as? LogMealError, .implausiblePortion(grams: 5000))
        }
    }
}
