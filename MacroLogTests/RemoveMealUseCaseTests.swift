//
//  RemoveMealUseCaseTests.swift
//  MacroLog
//
//  Created by Sumangala Rao on 24/9/2026.
//
import XCTest
@testable import MacroLog

final class RemoveMealUseCaseTests: XCTestCase {

    // Happy path
    func test_removesAMealThatIsInTheDay() throws {
        let repository = InMemoryNourishmentRepository()
        let dinner = Meal(
            name: "Basmati rice",
            occasion: .dinner,
            carbohydrateGrams: 40,
            glycaemicIndexBand: .high
        )
        try repository.record(dinner)

        let useCase = RemoveMealUseCase(repository: repository)
        try useCase.execute(mealID: dinner.id, on: dinner.eatenAt)

        let day = try repository.day(on: dinner.eatenAt)
        XCTAssertTrue(day.meals.isEmpty)
    }

    // Domain error: removing something that isn't there
    func test_refusesToRemoveAMealThatIsNotThere() {
        let repository = InMemoryNourishmentRepository()
        let useCase = RemoveMealUseCase(repository: repository)

        XCTAssertThrowsError(
            try useCase.execute(mealID: UUID(), on: Date())
        ) { error in
            XCTAssertEqual(error as? RemoveMealError, .mealNoLongerThere)
        }
    }
}
