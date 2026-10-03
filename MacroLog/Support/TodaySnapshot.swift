//
//  TodaySnapshot.swift
//  MacroLog
//
//  Created by Sumangala Rao on 2/10/2026.
//
import Foundation

/// A tiny, flat summary of today that the widget can read without any knowledge
/// of Core Data or the repository. The main app writes this into the shared App
/// Group container after anything changes today; the widget reads it back.
///
/// Keeping the widget on a small snapshot, rather than the whole Core Data
/// stack, is deliberate: a widget must render fast and cheaply, and it should
/// never reach into the app's database directly.
struct TodaySnapshot: Codable, Equatable {
    let remainingLoad: Int
    let targetLoad: Int
    let loadUsed: Int
    let isWithinTarget: Bool
    let mealCount: Int
    let updatedAt: Date

    /// Shown in the widget gallery and before the app has written anything.
    static let placeholder = TodaySnapshot(
        remainingLoad: 100,
        targetLoad: 100,
        loadUsed: 0,
        isWithinTarget: true,
        mealCount: 0,
        updatedAt: Date()
    )
}
