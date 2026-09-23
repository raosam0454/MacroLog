//
//  GlycaemicIndexBand.swift
//  MacroLog
//
//  Created by Sumangala Rao on 23/9/2026.
//
import Foundation

/// How quickly a food raises blood glucose, expressed in the three bands that
/// clinicians and PCOS dietary guidelines actually use when they tell someone
/// to "eat low GI".
///
/// Using a named band instead of a bare number keeps the vocabulary the woman
/// recognises, and gives us a safe, closed set of values to reason about.
enum GlycaemicIndexBand: String, Codable, CaseIterable, Hashable {
    case low
    case medium
    case high

    /// A representative glycaemic-index value for the band, used to estimate
    /// glycaemic load. The midpoints follow the standard GI cut-offs
    /// (low is 55 or under, medium is 56 to 69, high is 70 or over).
    var representativeIndex: Double {
        switch self {
        case .low: return 45
        case .medium: return 62
        case .high: return 80
        }
    }

    /// A short label to show the woman in the interface.
    var displayName: String {
        switch self {
        case .low: return "Low GI"
        case .medium: return "Medium GI"
        case .high: return "High GI"
        }
    }
}
