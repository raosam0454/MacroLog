import SwiftUI

/// A temporary placeholder so the app builds and launches while the data layer
/// is in place. The real stakeholder screens replace this in the UI step.
struct ContentView: View {
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "leaf.fill")
                .font(.largeTitle)
                .foregroundStyle(.green)
            Text("MacroLog")
                .font(.title2).bold()
            Text("Data layer ready. Screens arrive in the next step.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
