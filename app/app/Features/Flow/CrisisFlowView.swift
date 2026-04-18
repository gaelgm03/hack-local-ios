import SwiftUI

/// Root container for the crisis flow. Presented as fullScreenCover from HomeView.
/// Owns a NavigationStack driven by SessionFlowViewModel.crisisPath.
struct CrisisFlowView: View {
    @Environment(SessionFlowViewModel.self) private var flow

    var body: some View {
        @Bindable var flow = flow

        NavigationStack(path: $flow.crisisPath) {
            destinationView(for: flow.crisisRoot)
                .navigationDestination(for: AppRoute.self) { route in
                    destinationView(for: route)
                }
        }
    }

    @ViewBuilder
    private func destinationView(for route: AppRoute) -> some View {
        switch route {
        case .capture:
            CrisisCaptureView()
        case .interpreting:
            CrisisInterpretingView()
        case .response:
            CrisisResponseView()
        case .breathing:
            CrisisBreathingView()
        case .grounding:
            CrisisGroundingView()
        case .reframe:
            CrisisReframeView()
        case .checkIn:
            CrisisCheckInView()
        case .specialists:
            MapPlaceholderView()
        case .bookingConfirmation:
            BookingConfirmationView()
        }
    }
}
