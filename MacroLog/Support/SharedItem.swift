//
//  SharedItem.swift
//  MacroLog
//
//  Created by Sumangala Rao on 3/10/2026.
//
import Foundation

/// Something the woman shared into MacroLog from another app (a recipe link, a
/// nutrition panel's text). The Share Extension writes these into the App Group
/// inbox; the app reads them and offers to turn each into a meal.
struct SharedItem: Codable, Identifiable, Equatable {
    let id: UUID
    let text: String
    let receivedAt: Date

    init(id: UUID = UUID(), text: String, receivedAt: Date = Date()) {
        self.id = id
        self.text = text
        self.receivedAt = receivedAt
    }
}
