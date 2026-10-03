//
//  CycleMarkerEntity.swift
//  MacroLog
//
//  Created by Sumangala Rao on 1/10/2026.
//
import CoreData

/// Translation between the stored `CycleMarkerEntity` (Core Data) and the clean
/// domain `CycleMarker`.
extension CycleMarkerEntity {

    func apply(_ marker: CycleMarker) {
        id = marker.id
        kind = marker.kind.rawValue
        markedOn = marker.markedOn
    }

    func toDomain() -> CycleMarker {
        CycleMarker(
            id: id ?? UUID(),
            kind: CycleMarkerKind(rawValue: kind ?? "") ?? .spotting,
            markedOn: markedOn ?? Date()
        )
    }
}
