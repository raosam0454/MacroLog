//
//  SummariseRecentPatternsUseCase.swift
//  MacroLog
//
//  Created by Sumangala Rao on 5/10/2026.
//
import Foundation

/// The result of looking back over recent days: how often symptoms were noted
/// on days that went over the low-GI budget versus days within it. This is the
/// observation that connects what she eats to how she feels. It is a pattern
/// aid, never a diagnosis.
struct RecentPatternSummary: Equatable {
    let overBudgetDays: Int
    let withinBudgetDays: Int
    let symptomsOnOverBudgetDays: Int
    let symptomsOnWithinBudgetDays: Int

    var averageSymptomsOverBudget: Double {
        overBudgetDays == 0 ? 0 : Double(symptomsOnOverBudgetDays) / Double(overBudgetDays)
    }

    var averageSymptomsWithinBudget: Double {
        withinBudgetDays == 0 ? 0 : Double(symptomsOnWithinBudgetDays) / Double(withinBudgetDays)
    }
}

/// Looks back over the recent logged days and compares how often symptoms were
/// noted on over-budget versus within-budget days. The one rule: it refuses to
/// invent a pattern when there is nothing logged to compare.
struct SummariseRecentPatternsUseCase {

    let repository: NourishmentRepository

    func execute(endingOn date: Date = Date(), days: Int = 14) throws -> RecentPatternSummary {
        let recent = try repository.recentDays(endingOn: date, count: days)

        var overBudgetDays = 0
        var withinBudgetDays = 0
        var symptomsOnOverBudgetDays = 0
        var symptomsOnWithinBudgetDays = 0

        for day in recent {
            let symptomCount = (try? repository.symptoms(on: day.date))?.count ?? 0
            if day.isWithinTarget {
                withinBudgetDays += 1
                symptomsOnWithinBudgetDays += symptomCount
            } else {
                overBudgetDays += 1
                symptomsOnOverBudgetDays += symptomCount
            }
        }

        let totalSymptoms = symptomsOnOverBudgetDays + symptomsOnWithinBudgetDays
        guard (overBudgetDays + withinBudgetDays) > 0, totalSymptoms > 0 else {
            throw InsightError.notEnoughData
        }

        return RecentPatternSummary(
            overBudgetDays: overBudgetDays,
            withinBudgetDays: withinBudgetDays,
            symptomsOnOverBudgetDays: symptomsOnOverBudgetDays,
            symptomsOnWithinBudgetDays: symptomsOnWithinBudgetDays
        )
    }
}

enum InsightError: LocalizedError, Equatable {
    case notEnoughData

    var errorDescription: String? {
        "There isn't enough logged yet to spot a pattern."
    }

    var recoverySuggestion: String? {
        "Keep logging meals and symptoms for a few days."
    }
}
