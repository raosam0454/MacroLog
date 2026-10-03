//
//  SymptomsView.swift
//  MacroLog
//
//  Created by Sumangala Rao on 1/10/2026.
//
import SwiftUI

/// The Symptoms screen: note how she's feeling, and see what she's noted today.
/// This is the side of the app that connects eating to how her body responds.
struct SymptomsView: View {

    @State private var model: SymptomsViewModel

    init(repository: NourishmentRepository) {
        _model = State(initialValue: SymptomsViewModel(repository: repository))
    }

    var body: some View {
        List {
            Section("How are you feeling?") {
                Picker("Symptom", selection: $model.selectedKind) {
                    ForEach(SymptomKind.allCases) { kind in
                        Text(kind.displayName).tag(kind)
                    }
                }
                Picker("How strong?", selection: $model.selectedSeverity) {
                    ForEach(SymptomSeverity.allCases, id: \.self) { severity in
                        Text(severity.displayName).tag(severity)
                    }
                }
                Button("Note this symptom") {
                    model.noteSymptom()
                }
            }

            Section("Noted today") {
                if model.todaysSymptoms.isEmpty {
                    ContentUnavailableView(
                        "Nothing noted yet",
                        systemImage: "heart.text.square",
                        description: Text("Note how you're feeling to start seeing patterns alongside your meals.")
                    )
                } else {
                    ForEach(model.todaysSymptoms) { symptom in
                        HStack {
                            Text(symptom.kind.displayName)
                            Spacer()
                            Text(symptom.severity.displayName)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle("Symptoms")
        .alert("Can't note this", isPresented: errorBinding) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(model.errorMessage ?? "")
        }
        .task {
            model.load()
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
        SymptomsView(repository: InMemoryNourishmentRepository())
    }
}
