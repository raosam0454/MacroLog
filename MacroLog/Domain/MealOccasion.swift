//
//  MealOccasion.swift
//  MacroLog
//
//  Created by Sumangala Rao on 23/9/2026.
//
import Foundation

/// The eating occasion a meal belongs to. Modelling this as a named case rather
/// than a free-text string means the rest of the app can group and reason about
/// meals by occasion without guessing at spelling or capitalisation.
enum MealOccasion: String, Codable, CaseIterable, Hashable, Identifiable {
    case breakfast
    case lunch
    case dinner
    case snack

    var id: String { rawValue }

    var displayName: String {
        rawValue.capitalized
    }
}
