//
//  HistoryView.swift
//  MacroLog
//
//  Created by Sumangala Rao on 1/10/2026.
//
import SwiftUI

/// The History screen: the last few days at a glance, each marked as within or
/// over its target, so patterns start to show.
struct HistoryView: View {

    @State private var model: HistoryViewModel

    init(repository: NourishmentRepository) {
        _model = State(initialValue: HistoryViewModel(repository: repository))
    }

    var body: some View {
        List {
            if model.days.isEmpty {
                ContentUnavailableView(
                    "No history yet",
                    systemImage: "calendar",
                    description: Text("Once you log meals across a few days, your recent days show up here.")
                )
            } else {
                ForEach(model.days) { day in
                    HistoryRow(day: day)
                }
            }
        }
        .navigationTitle("Recent days")
        .task {
            model.load()
        }
    }
}

/// One day in the History list.
private struct HistoryRow: View {
    let day: NourishmentDay

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(day.date.formatted(date: .abbreviated, time: .omitted))
                Text("\(Int(day.glycaemicLoadSoFar.value.rounded())) of \(Int(day.target.maximumGlycaemicLoad.rounded())) glycaemic load")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: day.isWithinTarget ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                .foregroundStyle(day.isWithinTarget ? Color.green : Color.orange)
        }
    }
}

#Preview {
    NavigationStack {
        HistoryView(repository: InMemoryNourishmentRepository(seed: [
            Meal(name: "Oats", occasion: .breakfast, carbohydrateGrams: 30, glycaemicIndexBand: .low),
            Meal(name: "White rice", occasion: .dinner, carbohydrateGrams: 60, glycaemicIndexBand: .high)
        ]))
    }
}
