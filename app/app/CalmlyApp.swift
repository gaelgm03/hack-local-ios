import SwiftUI

@main
struct CalmlyApp: App {
    @State private var flow = SessionFlowViewModel()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(flow)
        }
    }
}
