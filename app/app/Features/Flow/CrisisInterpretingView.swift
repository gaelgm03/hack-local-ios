import SwiftUI

/// Loading screen while AI interprets context. Shows pulsing orb + subtitle.
struct CrisisInterpretingView: View {
    @Environment(SessionFlowViewModel.self) private var flow
    @State private var glowOpacity: Double = 0.06

    var body: some View {
        ZStack {
            CalmlyColors.background.ignoresSafeArea()

            RadialGradient(
                colors: [
                    Color(hex: "B8A9E8").opacity(glowOpacity),
                    Color(hex: "F5C6AA").opacity(glowOpacity * 0.5),
                    Color.clear
                ],
                center: .center,
                startRadius: 30,
                endRadius: 260
            )
            .ignoresSafeArea()

            VStack(spacing: 36) {
                Spacer()

                OrbView(size: 160, pulse: true)

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
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                glowOpacity = 0.14
            }
            Task { await flow.interpretCurrentContext() }
        }
    }
}

#Preview {
    CrisisInterpretingView()
        .environment(SessionFlowViewModel())
}
