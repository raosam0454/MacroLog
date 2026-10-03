//
//  LogMealView.swift
//  MacroLog
//
//  Created by Sumangala Rao on 24/9/2026.
//
import SwiftUI

/// The form for logging a meal. Every label is in the woman's vocabulary, and
/// the date picker won't let her pick a time in the future, which matches the
/// rule the use case enforces.
struct LogMealView: View {

    @Environment(\.dismiss) private var dismiss
    @State private var model: LogMealViewModel
    private let onSaved: () -> Void

    init(repository: NourishmentRepository, onSaved: @escaping () -> Void) {
        _model = State(initialValue: LogMealViewModel(repository: repository))
        self.onSaved = onSaved
    }

    var body: some View {
        Form {
            Section("What did you eat?") {
                TextField("Meal name", text: $model.name)
                Picker("Occasion", selection: $model.occasion) {
                    ForEach(MealOccasion.allCases) { occasion in
                        Text(occasion.displayName).tag(occasion)
                    }
                }
            }

            Section("How much, and how fast?") {
                TextField("Carbohydrate (grams)", text: $model.carbohydrateText)
                    .keyboardType(.numberPad)
                Picker("Glycaemic index", selection: $model.glycaemicIndexBand) {
                    ForEach(GlycaemicIndexBand.allCases, id: \.self) { band in
                        Text(band.displayName).tag(band)
                    }
                }
            }

            Section("When did you eat it?") {
                DatePicker("Eaten at", selection: $model.eatenAt, in: ...Date())
            }
        }
        .navigationTitle("Log a meal")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") { model.save() }
            }
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
        }
        .alert("Can't save this meal", isPresented: errorBinding) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(model.errorMessage ?? "")
        }
        .onChange(of: model.didSave) { _, saved in
            if saved {
                onSaved()
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

#Preview {
    NavigationStack {
        LogMealView(repository: InMemoryNourishmentRepository()) { }
    }
}
