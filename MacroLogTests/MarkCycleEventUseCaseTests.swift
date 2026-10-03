//
//  MarkCycleEventUseCaseTests.swift
//  MacroLogTests
//
//  Created by Sumangala Rao on 1/10/2026.
//
import XCTest
@testable import MacroLog

final class MarkCycleEventUseCaseTests: XCTestCase {

    // Happy path
    func test_marksAPeriodStart() throws {
        let repository = InMemoryNourishmentRepository()
        let useCase = MarkCycleEventUseCase(repository: repository)

        try useCase.execute(CycleMarker(kind: .periodStarted, markedOn: Date()))

        let today = try repository.cycleMarkers(on: Date())
        XCTAssertEqual(today.count, 1)
        XCTAssertEqual(today.first?.kind, .periodStarted)
    }

    // Domain error: the same marker twice in one day
    func test_refusesTheSameMarkerTwiceInADay() throws {
        let repository = InMemoryNourishmentRepository()
        let useCase = MarkCycleEventUseCase(repository: repository)

        try useCase.execute(CycleMarker(kind: .spotting, markedOn: Date()))

        XCTAssertThrowsError(
            try useCase.execute(CycleMarker(kind: .spotting, markedOn: Date()))
        ) { error in
            XCTAssertEqual(error as? MarkCycleEventError, .alreadyMarkedToday(kind: .spotting))
        }
    }

    // Boundary: a cycle event in the future
    func test_refusesACycleEventInTheFuture() {
        let repository = InMemoryNourishmentRepository()
        let fixedNow = Date()
        let useCase = MarkCycleEventUseCase(repository: repository, now: { fixedNow })

        let future = CycleMarker(kind: .periodEnded, markedOn: fixedNow.addingTimeInterval(60 * 60))

        XCTAssertThrowsError(try useCase.execute(future)) { error in
            XCTAssertEqual(error as? MarkCycleEventError, .eventInTheFuture)
        }
    }
}
