//
//  CycleView.swift
//  MacroLog
//
//  Created by Sumangala Rao on 1/10/2026.
//
import SwiftUI

/// The Cycle screen: mark today's cycle events and see recent ones. PCOS makes
/// cycles irregular, so keeping this record is what lets symptoms and cravings
/// be read in context.
struct CycleView: View {

    @State private var model: CycleViewModel

    init(repository: NourishmentRepository) {
        _model = State(initialValue: CycleViewModel(repository: repository))
    }

    var body: some View {
        List {
            Section("Mark today") {
                ForEach(CycleMarkerKind.allCases) { kind in
                    Button(kind.displayName) {
                        model.mark(kind)
                    }
                }
            }

            Section("Recent markers") {
                if model.recentMarkers.isEmpty {
                    ContentUnavailableView(
                        "No cycle markers yet",
                        systemImage: "drop",
                        description: Text("Mark your period and spotting so they can line up with your symptoms.")
                    )
                } else {
                    ForEach(model.recentMarkers) { marker in
                        HStack {
                            Text(marker.kind.displayName)
                            Spacer()
                            Text(marker.markedOn.formatted(date: .abbreviated, time: .omitted))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle("Cycle")
        .alert("Can't mark this", isPresented: errorBinding) {
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
        CycleView(repository: InMemoryNourishmentRepository())
    }
}
