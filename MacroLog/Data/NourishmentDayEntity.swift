//
//  NourishmentDayEntity.swift
//  MacroLog
//
//  Created by Sumangala Rao on 23/9/2026.
//
import CoreData

/// Translation between the stored `NourishmentDayEntity` (Core Data) and the
/// clean domain `NourishmentDay`.
extension NourishmentDayEntity {

    /// The day's target as a domain value.
    var domainTarget: DailyNourishmentTarget {
        DailyNourishmentTarget(maximumGlycaemicLoad: maximumGlycaemicLoad)
    }

    /// Rebuilds a full domain day, with its meals sorted by the time they were
    /// eaten so the app always sees them in order.
    func toDomain() -> NourishmentDay {
        let mealModels = (meals as? Set<MealEntity> ?? [])
            .map { $0.toDomain() }
            .sorted { $0.eatenAt < $1.eatenAt }

        return NourishmentDay(
            date: date ?? Date(),
            meals: mealModels,
            target: domainTarget
        )
    }
}
