//
//  TodayView.swift
//  MacroLog
//
//  Created by Sumangala Rao on 24/9/2026.
//
import SwiftUI

/// The home screen: how much low-GI budget is left today, anything shared in
/// waiting to be logged, and the meals logged so far.
struct TodayView: View {

    private let repository: NourishmentRepository
    @State private var model: TodayViewModel
    @State private var isLoggingMeal = false
    @State private var shareToLog: SharedItem?

    init(repository: NourishmentRepository) {
        self.repository = repository
        _model = State(initialValue: TodayViewModel(repository: repository))
    }

    var body: some View {
        List {
            Section {
                budgetHeader
            }

            if !model.pendingShares.isEmpty {
                Section("Shared to log") {
                    ForEach(model.pendingShares) { item in
                        Button {
                            shareToLog = item
                        } label: {
                            Label(item.text, systemImage: "tray.and.arrow.down")
                                .lineLimit(2)
                        }
                    }
                }
            }

            Section("Today's meals") {
                if model.meals.isEmpty {
                    ContentUnavailableView(
                        "Nothing logged yet",
                        systemImage: "fork.knife",
                        description: Text("Log your first meal to start tracking today's glycaemic load.")
                    )
                } else {
                    ForEach(model.meals) { meal in
                        NavigationLink(value: meal) {
                            MealRow(meal: meal)
                        }
                        .swipeActions {
                            Button(role: .destructive) {
                                model.remove(meal)
                            } label: {
                                Label("Remove", systemImage: "trash")
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Today")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    isLoggingMeal = true
                } label: {
                    Label("Log a meal", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $isLoggingMeal) {
            NavigationStack {
                LogMealView(repository: repository) {
                    model.load()
                }
            }
        }
        .sheet(item: $shareToLog) { item in
            NavigationStack {
                LogMealView(repository: repository, initialName: item.text) {
                    model.clearShare(item)
                    model.load()
                }
            }
        }
        .navigationDestination(for: Meal.self) { meal in
            MealDetailView(meal: meal, repository: repository) {
                model.load()
            }
        }
        .task {
            model.load()
        }
    }

    private var budgetHeader: some View {
        VStack(spacing: 6) {
            Text("\(model.remainingLoad)")
                .font(.system(size: 52, weight: .bold, design: .rounded))
                .foregroundStyle(model.isWithinTarget ? Color.green : Color.orange)
            Text(model.isWithinTarget ? "low-GI budget left today" : "over today's target")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("\(model.loadSoFar) of \(model.targetLoad) glycaemic load used")
                .font(.footnote)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
}

/// One meal in the Today list.
private struct MealRow: View {
    let meal: Meal

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(meal.name)
                Text("\(meal.occasion.displayName) · \(meal.glycaemicIndexBand.displayName)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text("\(Int(meal.glycaemicLoad.value.rounded())) GL")
                .font(.callout.monospacedDigit())
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    NavigationStack {
        TodayView(repository: InMemoryNourishmentRepository(seed: [
            Meal(name: "Steel-cut oats", occasion: .breakfast, carbohydrateGrams: 30, glycaemicIndexBand: .low),
            Meal(name: "Banana", occasion: .snack, carbohydrateGrams: 27, glycaemicIndexBand: .medium)
        ]))
    }
}
