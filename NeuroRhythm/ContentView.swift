import SwiftUI

struct ContentView: View {
    @Environment(NeuroRhythmViewModel.self) private var viewModel

    var body: some View {
        @Bindable var vm = viewModel
        TabView(selection: $vm.selectedTab) {
            TodayView()
                .tabItem {
                    Label("今日", systemImage: "brain.head.profile")
                }
                .tag(0)

            TasksTabView()
                .tabItem {
                    Label("任务", systemImage: "list.bullet.rectangle")
                }
                .tag(1)

            AlertsView()
                .tabItem {
                    Label("提醒", systemImage: "waveform.path.ecg")
                }
                .tag(2)

            ProfileView()
                .tabItem {
                    Label("我的", systemImage: "gearshape.fill")
                }
                .tag(3)
        }
        .tint(NeuroDesign.accentSage)
    }
}
