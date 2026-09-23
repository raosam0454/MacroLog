//
//  DilyNourishmentTarget.swift
//  MacroLog
//
//  Created by Sumangala Rao on 23/9/2026.
//
import Foundation

/// The daily ceiling the user is aiming to stay under, expressed as a total
/// glycaemic load for the day.
///
/// A low-GI eating pattern is the frontline dietary approach for the insulin
/// resistance that sits behind PCOS, so "how much low-GI intake  do I have left
/// today" is the main use case  this  app solves.
struct DailyNourishmentTarget: Hashable, Codable {
    var maximumGlycaemicLoad: Double

    init(maximumGlycaemicLoad: Double) {
        self.maximumGlycaemicLoad = max(0, maximumGlycaemicLoad)
    }

    /// A gentle starting ceiling for a low-GI day, used when the user has not
    /// set her own. A daily glycaemic load under roughly 100 is widely
    /// described as a "low" glycaemic-load day.
    static let gentleDefault = DailyNourishmentTarget(maximumGlycaemicLoad: 100)
}
