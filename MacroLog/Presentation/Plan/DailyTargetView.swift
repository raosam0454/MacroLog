//
//  DailyTargetView.swift
//  MacroLog
//
//  Created by Sumangala Rao on 1/10/2026.
//
import SwiftUI

/// The Plan screen: where the woman sets the daily low-GI target that every
/// other screen measures against.
struct DailyTargetView: View {

    @State private var model: DailyTargetViewModel

    init(repository: NourishmentRepository) {
        _model = State(initialValue: DailyTargetViewModel(repository: repository))
    }

    var body: some View {
        Form {
            Section("Your daily low-GI target") {
                TextField("Glycaemic load ceiling", text: $model.targetText)
                    .keyboardType(.numberPad)
                Text("A lower number keeps your day gentler on blood sugar. A common low-GI day sits around 100.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Section {
                Button("Save target") {
                    model.save()
                }
            }

            if let message = model.message {
                Section {
                    Text(message)
                        .foregroundStyle(model.isError ? Color.orange : Color.green)
                }
            }
        }
        .navigationTitle("Plan")
        .task {
            model.load()
        }
    }
}

#Preview {
    NavigationStack {
        DailyTargetView(repository: InMemoryNourishmentRepository())
    }
}
