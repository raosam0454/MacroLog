//
//  SetDailyTargetUseCaseTests.swift
//  MacroLog
//
//  Created by Sumangala Rao on 24/9/2026.
//
import XCTest
@testable import MacroLog

final class SetDailyTargetUseCaseTests: XCTestCase {

    // Happy path
    func test_setsAReasonableDailyTarget() throws {
        let repository = InMemoryNourishmentRepository()
        let useCase = SetDailyTargetUseCase(repository: repository)

        try useCase.execute(DailyNourishmentTarget(maximumGlycaemicLoad: 90), on: Date())

        let today = try repository.day(on: Date())
        XCTAssertEqual(today.target.maximumGlycaemicLoad, 90)
    }

    // Boundary: a target so low it leaves nothing to eat
    func test_refusesATargetThatIsTooLow() {
        let repository = InMemoryNourishmentRepository()
        let useCase = SetDailyTargetUseCase(repository: repository)

        XCTAssertThrowsError(
            try useCase.execute(DailyNourishmentTarget(maximumGlycaemicLoad: 5), on: Date())
        ) { error in
            XCTAssertEqual(error as? SetTargetError, .targetTooLow(minimum: 20))
        }
    }

    // Boundary: a target so high it stops guiding the day
    func test_refusesATargetThatIsTooHigh() {
        let repository = InMemoryNourishmentRepository()
        let useCase = SetDailyTargetUseCase(repository: repository)

        XCTAssertThrowsError(
            try useCase.execute(DailyNourishmentTarget(maximumGlycaemicLoad: 900), on: Date())
        ) { error in
            XCTAssertEqual(error as? SetTargetError, .targetTooHigh(maximum: 500))
        }
    }
}
