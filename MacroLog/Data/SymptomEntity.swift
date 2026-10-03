//
//  SymptomEntity.swift
//  MacroLog
//
//  Created by Sumangala Rao on 1/10/2026.
//
import CoreData

/// Translation between the stored `SymptomEntity` (Core Data) and the clean
/// domain `SymptomObservation`.
extension SymptomEntity {

    func apply(_ symptom: SymptomObservation) {
        id = symptom.id
        kind = symptom.kind.rawValue
        severity = Int16(symptom.severity.rawValue)
        observedAt = symptom.observedAt
    }

    func toDomain() -> SymptomObservation {
        SymptomObservation(
            id: id ?? UUID(),
            kind: SymptomKind(rawValue: kind ?? "") ?? .fatigue,
            severity: SymptomSeverity(rawValue: Int(severity)) ?? .moderate,
            observedAt: observedAt ?? Date()
        )
    }
}
