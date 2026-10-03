//
//  MacroLogWidget.swift
//  MacroLogWidget
//
//  Created by Sumangala Rao on 3/10/2026.
//
import WidgetKit
import SwiftUI

/// What the widget shows for a point in time: today's snapshot, read from the
/// shared App Group container that the app keeps up to date.
struct TodayBudgetEntry: TimelineEntry {
    let date: Date
    let snapshot: TodaySnapshot
}

/// Supplies entries to the widget. It never touches Core Data; it only reads the
/// small snapshot the app publishes.
struct TodayBudgetProvider: TimelineProvider {

    func placeholder(in context: Context) -> TodayBudgetEntry {
        TodayBudgetEntry(date: Date(), snapshot: .placeholder)
    }

    func getSnapshot(in context: Context, completion: @escaping (TodayBudgetEntry) -> Void) {
        completion(TodayBudgetEntry(date: Date(), snapshot: SnapshotStore.load() ?? .placeholder))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TodayBudgetEntry>) -> Void) {
        let entry = TodayBudgetEntry(date: Date(), snapshot: SnapshotStore.load() ?? .placeholder)
        // Refresh about hourly as a fallback. The app also forces an immediate
        // reload whenever today changes, so this is just a safety net.
        let nextRefresh = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date().addingTimeInterval(3600)
        completion(Timeline(entries: [entry], policy: .after(nextRefresh)))
    }
}

/// The widget's view, which adapts to each family it supports.
struct MacroLogWidgetEntryView: View {
    @Environment(\.widgetFamily) private var family
    let entry: TodayBudgetEntry

    private var tint: Color { entry.snapshot.isWithinTarget ? .green : .orange }

    var body: some View {
        switch family {
        case .accessoryRectangular:
            lockScreen
        case .systemMedium:
            medium
        default:
            small
        }
    }

    private var small: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Low-GI left")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text("\(entry.snapshot.remainingLoad)")
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundStyle(tint)
            Text("\(entry.snapshot.loadUsed) of \(entry.snapshot.targetLoad) used")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    private var medium: some View {
        HStack {
            small
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Image(systemName: entry.snapshot.isWithinTarget ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                    .font(.title)
                    .foregroundStyle(tint)
                Text("\(entry.snapshot.mealCount) meals logged")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var lockScreen: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Low-GI budget")
                .font(.headline)
            Text("\(entry.snapshot.remainingLoad) of \(entry.snapshot.targetLoad) left")
                .font(.caption)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// The widget itself: one definition, three families (a Home Screen small and
/// medium tile, and a Lock Screen rectangle).
struct MacroLogWidget: Widget {
    let kind = "MacroLogWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TodayBudgetProvider()) { entry in
            MacroLogWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Low-GI budget")
        .description("How much low-GI budget you have left today.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryRectangular])
    }
}

#Preview(as: .systemSmall) {
    MacroLogWidget()
} timeline: {
    TodayBudgetEntry(date: .now, snapshot: .placeholder)
    TodayBudgetEntry(date: .now, snapshot: TodaySnapshot(remainingLoad: 18, targetLoad: 100, loadUsed: 82, isWithinTarget: true, mealCount: 3, updatedAt: .now))
}
