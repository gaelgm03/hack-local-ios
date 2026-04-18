import SwiftUI

struct CalmlyScreen<Content: View>: View {
    @Environment(SessionFlowViewModel.self) private var flow
    @ViewBuilder var content: Content

    var body: some View {
        ZStack(alignment: .top) {
            CalmlyColors.background.ignoresSafeArea()

            LinearGradient(
                colors: [Color(hex: "6A5AA5").opacity(0.35), .clear],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            content
                .padding(.top, flow.demoModeEnabled ? 42 : 0)

            if flow.demoModeEnabled {
                Text("Demo mode activo (LLM hardcoded)")
                    .font(CalmlyTypography.caption)
                    .foregroundStyle(CalmlyColors.textPrimary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule(style: .continuous)
                            .fill(CalmlyColors.surface.opacity(0.9))
                    )
                    .padding(.top, 8)
            }
        }
    }
}

struct CalmlyCard<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(CalmlyColors.surface.opacity(0.92))
            )
    }
}

struct CalmlyPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

struct CalmlyPrimaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(CalmlyTypography.title)
                .foregroundStyle(.black.opacity(0.8))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(CalmlyColors.primaryGradient)
                )
        }
        .buttonStyle(CalmlyPressStyle())
    }
}
