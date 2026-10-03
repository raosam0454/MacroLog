//
//  RecordSymptomUseCaseTests.swift
//  MacroLogTests
//
//  Created by Sumangala Rao on 1/10/2026.
//
import XCTest
@testable import MacroLog

final class RecordSymptomUseCaseTests: XCTestCase {

    // Happy path
    func test_notesASymptomFeltNow() throws {
        let repository = InMemoryNourishmentRepository()
        let useCase = RecordSymptomUseCase(repository: repository)

        try useCase.execute(
            SymptomObservation(kind: .bloating, severity: .moderate, observedAt: Date())
        )

        let today = try repository.symptoms(on: Date())
        XCTAssertEqual(today.count, 1)
        XCTAssertEqual(today.first?.kind, .bloating)
    }

    // Boundary: a symptom noted in the future
    func test_refusesASymptomNotedInTheFuture() {
        let repository = InMemoryNourishmentRepository()
        let fixedNow = Date()
        let useCase = RecordSymptomUseCase(repository: repository, now: { fixedNow })

        let future = SymptomObservation(
            kind: .fatigue,
            severity: .mild,
            observedAt: fixedNow.addingTimeInterval(60 * 60)
        )

        XCTAssertThrowsError(try useCase.execute(future)) { error in
            XCTAssertEqual(error as? RecordSymptomError, .observationInTheFuture)
        }
    }
}
