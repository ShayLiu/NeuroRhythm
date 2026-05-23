import SwiftUI

@main
struct NeuroRhythmApp: App {
    @State private var viewModel = NeuroRhythmViewModel()

    var body: some Scene {
        WindowGroup {
            Group {
                if viewModel.isAuthenticated {
                    ContentView()
                        .environment(viewModel)
                } else {
                    OnboardingView()
                        .environment(viewModel)
                }
            }
            .animation(.easeInOut, value: viewModel.isAuthenticated)
        }
    }
}
