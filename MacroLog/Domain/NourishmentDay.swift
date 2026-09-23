//
//  NourishmentDay.swift
//  MacroLog
//
//  Created by Sumangala Rao on 23/9/2026.
//
import Foundation

/// A single day of eating seen as one whole thing: every meal logged that day,
/// and the target those meals are measured against.
///
/// This is the "aggregate" of the domain. It is the one entity that *owns* a
/// collection of `Meal`s, which is exactly the two-related-entity relationship
/// the persistence layer will store (one `NourishmentDay` has many `Meal`s).
/// All of the day's arithmetic lives here, in one place, close to the data it
/// depends on, so no screen or view model ever has to re-derive it.
struct NourishmentDay: Identifiable, Hashable {
    /// One calendar day is one day-identity, so the normalised date *is* the id.
    var id: Date { date }

    /// Normalised to the start of the day (midnight) so all of a day's meals
    /// share the same key.
    let date: Date
    var meals: [Meal]
    var target: DailyNourishmentTarget

    init(date: Date, meals: [Meal] = [], target: DailyNourishmentTarget = .gentleDefault) {
        self.date = Calendar.current.startOfDay(for: date)
        self.meals = meals
        self.target = target
    }

    /// The total estimated glycaemic load eaten so far today.
    var glycaemicLoadSoFar: GlycaemicLoad {
        meals.reduce(GlycaemicLoad.none) { running, meal in
            running + meal.glycaemicLoad
        }
    }

    /// How much low-GI budget is left before she crosses her target today.
    /// Can go negative, which is the signal that she is over for the day.
    var remainingGlycaemicLoad: Double {
        target.maximumGlycaemicLoad - glycaemicLoadSoFar.value
    }

    /// Whether the day is still within the target she set.
    var isWithinTarget: Bool {
        glycaemicLoadSoFar.value <= target.maximumGlycaemicLoad
    }
}
