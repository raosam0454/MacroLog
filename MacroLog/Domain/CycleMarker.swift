//
//  CycleMarker.swift
//  MacroLog
//
//  Created by Sumangala Rao on 23/9/2026.
//
import Foundation

/// The cycle events worth marking. PCOS makes menstrual cycles irregular and
/// hard to predict, so knowing where she is in her cycle is part of making
/// sense of the  symptoms and the cravings.
enum CycleMarkerKind: String, Codable, CaseIterable, Hashable, Identifiable {
    case periodStarted
    case periodEnded
    case spotting

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .periodStarted: return "Period started"
        case .periodEnded: return "Period ended"
        case .spotting: return "Spotting"
        }
    }
}

/// A marked point in the woman's menstrual cycle.
struct CycleMarker: Identifiable, Hashable, Codable {
    let id: UUID
    var kind: CycleMarkerKind
    var markedOn: Date

    init(id: UUID = UUID(), kind: CycleMarkerKind, markedOn: Date = Date()) {
        self.id = id
        self.kind = kind
        self.markedOn = markedOn
    }
}
