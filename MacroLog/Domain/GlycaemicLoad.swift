//
//  GlycaemicLoad.swift
//  MacroLog
//
//  Created by Sumangala Rao on 23/9/2026.
//
import Foundation

/// The estimated glycaemic load of some food: how much it is likely to push
/// blood glucose up, combining *how fast* it acts (its GI band) with *how much*
/// carbohydrate it carries.
///
/// Glycaemic load is a real clinical measure, defined as
/// `glycaemic index x available carbohydrate / 100`. Wrapping it in its own
/// small value type (rather than passing a bare `Double` around) means a number
/// that represents a glycaemic load can never be accidentally mixed up with,
/// say, a number of grams. This is a "value object": it has no identity, two
/// loads with the same value are the same thing.
struct GlycaemicLoad: Hashable, Comparable, Codable {
    let value: Double

    init(value: Double) {
        self.value = max(0, value)
    }

    static func < (lhs: GlycaemicLoad, rhs: GlycaemicLoad) -> Bool {
        lhs.value < rhs.value
    }

    /// Adds two glycaemic loads together, e.g. to total up a day.
    static func + (lhs: GlycaemicLoad, rhs: GlycaemicLoad) -> GlycaemicLoad {
        GlycaemicLoad(value: lhs.value + rhs.value)
    }

    static let none = GlycaemicLoad(value: 0)
}
