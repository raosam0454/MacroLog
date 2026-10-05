//
//  HistoryViewModel.swift
//  MacroLog
//
//  Created by Sumangala Rao on 1/10/2026.
//
import Foundation
import Observation

/// The view model behind the History screen: it asks the repository for the
/// most recent days so the woman can see how the last week went, and for the
/// gentle meals-versus-symptoms pattern shown at the top.
@MainActor
@Observable
final class HistoryViewModel {

    private let repository: NourishmentRepository
    private(set) var days: [NourishmentDay] = []
    private(set) var patternMessage: String?

    init(repository: NourishmentRepository) {
        self.repository = repository
    }

    func load() {
        days = (try? repository.recentDays(endingOn: Date(), count: 7)) ?? []
        patternMessage = makePatternMessage()
    }

    /// Turns the recent-pattern summary into one plain sentence. Always framed as
    /// something to watch, not a clinical claim.
    private func makePatternMessage() -> String? {
        do {
            let summary = try SummariseRecentPatternsUseCase(repository: repository).execute()
            if summary.averageSymptomsOverBudget > summary.averageSymptomsWithinBudget {
                return "You tended to note more symptoms on the \(summary.overBudgetDays) day(s) you went over your low-GI budget than on the \(summary.withinBudgetDays) day(s) within it. A pattern to watch with your clinician, not a diagnosis."
            } else if summary.averageSymptomsWithinBudget > summary.averageSymptomsOverBudget {
                return "So far you've noted more symptoms on within-budget days than over-budget ones. Keep logging to see if that holds."
            } else {
                return "Your symptoms have been about the same on over- and within-budget days so far."
            }
        } catch let error as LocalizedError {
            return [error.errorDescription, error.recoverySuggestion].compactMap { $0 }.joined(separator: " ")
        } catch {
            return nil
        }
    }
}
