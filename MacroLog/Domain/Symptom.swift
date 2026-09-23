//
//  Symptom.swift
//  MacroLog
//
//  Created by Sumangala Rao on 23/9/2026.
//
import Foundation

/// The kinds of symptom the app tracks, drawn from those women with PCOS most
/// often report and are asked to keep an eye on. A closed set again, so the
/// interface can offer a fixed, familiar list rather than free text.
enum SymptomKind: String, Codable, CaseIterable, Hashable, Identifiable {
    case fatigue
    case sugarCravings
    case bloating
    case acne
    case moodChange
    case irregularBleeding
    case pelvicPain

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .fatigue: return "Fatigue"
        case .sugarCravings: return "Sugar cravings"
        case .bloating: return "Bloating"
        case .acne: return "Acne"
        case .moodChange: return "Mood change"
        case .irregularBleeding: return "Irregular bleeding"
        case .pelvicPain: return "Pelvic pain"
        }
    }
}

/// How strongly a symptom was felt, on the simple 1-to-5 scale that is easy to
/// answer honestly in the moment. Comparable so we can ask "was today worse
/// than yesterday".
enum SymptomSeverity: Int, Codable, CaseIterable, Hashable, Comparable {
    case barely = 1
    case mild = 2
    case moderate = 3
    case strong = 4
    case severe = 5

    static func < (lhs: SymptomSeverity, rhs: SymptomSeverity) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    var displayName: String {
        switch self {
        case .barely: return "Barely there"
        case .mild: return "Mild"
        case .moderate: return "Moderate"
        case .strong: return "Strong"
        case .severe: return "Severe"
        }
    }
}

/// A moment when the woman noticed a symptom. Kept as its own entity, tied to a
/// time, so symptoms can later be lined up against how she ate and where she is
/// in her cycle.
struct SymptomObservation: Identifiable, Hashable, Codable {
    let id: UUID
    var kind: SymptomKind
    var severity: SymptomSeverity
    var observedAt: Date

    init(
        id: UUID = UUID(),
        kind: SymptomKind,
        severity: SymptomSeverity,
        observedAt: Date = Date()
    ) {
        self.id = id
        self.kind = kind
        self.severity = severity
        self.observedAt = observedAt
    }
}
