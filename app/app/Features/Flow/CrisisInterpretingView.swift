import SwiftUI

/// Loading screen while AI interprets context. Shows pulsing orb + subtitle.
struct CrisisInterpretingView: View {
    @Environment(SessionFlowViewModel.self) private var flow
    @State private var orbScale: CGFloat = 0.85
    @State private var orbOpacity: Double = 0.6

    var body: some View {
        ZStack {
            CalmlyColors.background.ignoresSafeArea()

            VStack(spacing: 36) {
                Spacer()

                ZStack {
                    Circle()
                        .fill(CalmlyColors.primaryGradient)
                        .frame(width: 180, height: 180)
                        .scaleEffect(orbScale)
                        .opacity(orbOpacity)
                        .blur(radius: 8)

                    Circle()
                        .fill(CalmlyColors.primaryGradient)
                        .frame(width: 120, height: 120)
                        .scaleEffect(orbScale * 0.9)
                }

                Text("Entendiendo tu momento...")
                    .font(CalmlyTypography.title)
                    .foregroundStyle(CalmlyColors.textPrimary)

                if let error = flow.lastErrorMessage {
                    VStack(spacing: 16) {
                        Text(error)
                            .font(CalmlyTypography.body)
                            .foregroundStyle(.red.opacity(0.8))
                            .multilineTextAlignment(.center)

                        CalmlyPrimaryButton(title: "Reintentar") {
                            Task { await flow.interpretCurrentContext() }
                        }
                        .frame(width: 200)
                    }
                }

                Spacer()
            }
            .padding(.horizontal, 32)
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                orbScale = 1.15
                orbOpacity = 1.0
            }
            Task { await flow.interpretCurrentContext() }
        }
    }
}

#Preview {
    CrisisInterpretingView()
        .environment(SessionFlowViewModel())
}
