//
//  SummariseRecentPatternsUseCaseTests.swift
//  MacroLogTests
//
//  Created by Sumangala Rao on 5/10/2026.
//
import XCTest
@testable import MacroLog

final class SummariseRecentPatternsUseCaseTests: XCTestCase {

    // Happy path: more symptoms show up on the over-budget day
    func test_countsMoreSymptomsOnOverBudgetDays() throws {
        let repository = InMemoryNourishmentRepository()
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        // Today: a big high-GI meal pushes over budget, with two symptoms noted.
        try repository.record(Meal(name: "Large white rice", occasion: .dinner, carbohydrateGrams: 200, glycaemicIndexBand: .high, eatenAt: today))
        try repository.record(SymptomObservation(kind: .sugarCravings, severity: .strong, observedAt: today))
        try repository.record(SymptomObservation(kind: .fatigue, severity: .moderate, observedAt: today))

        // Yesterday: a small low-GI meal stays within budget, no symptoms.
        try repository.record(Meal(name: "Oats", occasion: .breakfast, carbohydrateGrams: 20, glycaemicIndexBand: .low, eatenAt: yesterday))

        let summary = try SummariseRecentPatternsUseCase(repository: repository).execute(endingOn: today, days: 14)

        XCTAssertEqual(summary.overBudgetDays, 1)
        XCTAssertEqual(summary.withinBudgetDays, 1)
        XCTAssertEqual(summary.symptomsOnOverBudgetDays, 2)
        XCTAssertEqual(summary.symptomsOnWithinBudgetDays, 0)
        XCTAssertGreaterThan(summary.averageSymptomsOverBudget, summary.averageSymptomsWithinBudget)
    }

    // Domain rule: refuse to invent a pattern from nothing
    func test_refusesWhenThereIsNothingLogged() {
        let repository = InMemoryNourishmentRepository()

        XCTAssertThrowsError(try SummariseRecentPatternsUseCase(repository: repository).execute()) { error in
            XCTAssertEqual(error as? InsightError, .notEnoughData)
        }
    }
}
