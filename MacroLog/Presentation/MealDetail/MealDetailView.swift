//
//  MealDetailView.swift
//  MacroLog
//
//  Created by Sumangala Rao on 1/10/2026.
//
import SwiftUI

/// A single meal in full, with the option to remove it. Reached by tapping a
/// meal in the Today list.
struct MealDetailView: View {

    @Environment(\.dismiss) private var dismiss
    @State private var model: MealDetailViewModel
    private let onRemoved: () -> Void

    init(meal: Meal, repository: NourishmentRepository, onRemoved: @escaping () -> Void) {
        _model = State(initialValue: MealDetailViewModel(meal: meal, repository: repository))
        self.onRemoved = onRemoved
    }

    var body: some View {
        List {
            Section {
                LabeledContent("Meal", value: model.meal.name)
                LabeledContent("Occasion", value: model.meal.occasion.displayName)
                LabeledContent("Glycaemic index", value: model.meal.glycaemicIndexBand.displayName)
                LabeledContent("Carbohydrate", value: "\(Int(model.meal.carbohydrateGrams)) g")
                LabeledContent("Glycaemic load", value: "\(model.glycaemicLoad) GL")
                LabeledContent("Eaten", value: model.meal.eatenAt.formatted(date: .abbreviated, time: .shortened))
            }

            Section {
                Button(role: .destructive) {
                    model.remove()
                } label: {
                    Label("Remove this meal", systemImage: "trash")
                }
            }
        }
        .navigationTitle(model.meal.name)
        .navigationBarTitleDisplayMode(.inline)
        .alert("Couldn't remove", isPresented: errorBinding) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(model.errorMessage ?? "")
        }
        .onChange(of: model.didRemove) { _, removed in
            if removed {
                onRemoved()
                dismiss()
            }
        }
    }

    private var errorBinding: Binding<Bool> {
        Binding(
            get: { model.errorMessage != nil },
            set: { showing in if !showing { model.errorMessage = nil } }
        )
    }
}
