//
//  HistoryViewModel.swift
//  MacroLog
//
//  Created by Sumangala Rao on 1/10/2026.
//
import Foundation
import Observation

/// The view model behind the History screen: it asks the repository for the
/// most recent days so the woman can see how the last week went.
@MainActor
@Observable
final class HistoryViewModel {

    private let repository: NourishmentRepository
    private(set) var days: [NourishmentDay] = []

    init(repository: NourishmentRepository) {
        self.repository = repository
    }

    func load() {
        days = (try? repository.recentDays(endingOn: Date(), count: 7)) ?? []
    }
}
