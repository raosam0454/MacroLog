//
//  MealEntity.swift
//  MacroLog
//
//  Created by Sumangala Rao on 23/9/2026.
//
import CoreData

/// Translation between the stored `MealEntity` (Core Data) and the clean domain
/// `Meal`. Keeping this in one small file means the mapping rules live in a
/// single, testable place.
extension MealEntity{

    /// Fills this managed object from a domain meal.
    func apply(_ meal: Meal) {
        id = meal.id
        name = meal.name
        occasion = meal.occasion.rawValue
        carbohydrateGrams = meal.carbohydrateGrams
        glycaemicIndexBand = meal.glycaemicIndexBand.rawValue
        eatenAt = meal.eatenAt
    }

    /// Rebuilds a domain meal from this managed object. If a stored raw value is
    /// ever unexpected, it falls back to a safe default rather than crashing.
    func toDomain() -> Meal {
        Meal(
            id: id ?? UUID(),
            name: name ?? "",
            occasion: MealOccasion(rawValue: occasion ?? "") ?? .snack,
            carbohydrateGrams: carbohydrateGrams,
            glycaemicIndexBand: GlycaemicIndexBand(rawValue: glycaemicIndexBand ?? "") ?? .medium,
            eatenAt: eatenAt ?? Date()
        )
    }
}
