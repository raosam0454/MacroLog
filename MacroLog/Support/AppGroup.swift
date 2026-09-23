//
//  AppGroup.swift
//  MacroLog
//
//  Created by Sumangala Rao on 23/9/2026.
//
import Foundation

/// The one place the App Group identifier is written down.
///
/// The app and the widget extension both read and write the same database, and
/// they find it through this shared container identifier. Keeping it in a single
/// constant means the app and the widget can never drift apart on the spelling.
enum AppGroup {
    static let identifier = "group.com.sam.macrolog"
}
