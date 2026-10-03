//
//  WidgetSync.swift
//  MacroLog
//
//  Created by Sumangala Rao on 2/10/2026.
//
import WidgetKit

/// The main app's side of the widget relationship. After today changes, the app
/// turns the day into a `TodaySnapshot`, writes it to the shared container, and
/// asks WidgetKit to reload. This file belongs to the app target only; the
/// widget never imports it.
enum WidgetSync {

    static func publish(_ day: NourishmentDay) {
        let snapshot = TodaySnapshot(
            remainingLoad: Int(day.remainingGlycaemicLoad.rounded()),
            targetLoad: Int(day.target.maximumGlycaemicLoad.rounded()),
            loadUsed: Int(day.glycaemicLoadSoFar.value.rounded()),
            isWithinTarget: day.isWithinTarget,
            mealCount: day.meals.count,
            updatedAt: Date()
        )
        SnapshotStore.save(snapshot)
        WidgetCenter.shared.reloadAllTimelines()
    }
}
