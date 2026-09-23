//
//  Meal.swift
//  MacroLog
//
//  Created by Sumangala Rao on 23/9/2026.
//
import Foundation

/// A single eating occasion the woman logs: what she ate, roughly how much
/// carbohydrate it held, and how fast-acting it was. This is the core entity
/// on the food side of the domain.
struct Meal: Identifiable, Hashable, Codable {
    let id: UUID
    var name: String
    var occasion: MealOccasion
    var carbohydrateGrams: Double
    var glycaemicIndexBand: GlycaemicIndexBand
    var eatenAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        occasion: MealOccasion,
        carbohydrateGrams: Double,
        glycaemicIndexBand: GlycaemicIndexBand,
        eatenAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.occasion = occasion
        self.carbohydrateGrams = carbohydrateGrams
        self.glycaemicIndexBand = glycaemicIndexBand
        self.eatenAt = eatenAt
    }

    /// The estimated glycaemic load of this one meal. Computed from the meal's
    /// own data, so it is always consistent with what was logged.
    var glycaemicLoad: GlycaemicLoad {
        GlycaemicLoad(
            value: glycaemicIndexBand.representativeIndex * carbohydrateGrams / 100
        )
    }
}
