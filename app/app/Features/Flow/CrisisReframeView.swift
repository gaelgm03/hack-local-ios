import SwiftUI

struct CrisisReframeView: View {
    @Environment(SessionFlowViewModel.self) private var flow
    @State private var hapticsService = HapticsService()
    @State private var ttsService = TTSService()
    @State private var hasSpoken = false

    var body: some View {
        ZStack {
            CalmlyColors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button("Saltar") {
                        finishSession()
                    }
                    .font(CalmlyTypography.body)
                    .foregroundStyle(CalmlyColors.textSecondary)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)

                Spacer()

                VStack(spacing: 22) {
                    Image(systemName: "sparkles.rectangle.stack")
                        .font(.system(size: 40, weight: .medium))
                        .foregroundStyle(CalmlyColors.accent)

                    Text("Cambiemos el ángulo")
                        .font(CalmlyTypography.largeTitle)
                        .foregroundStyle(CalmlyColors.textPrimary)
                        .multilineTextAlignment(.center)

                    if let script = flow.latestResponse?.script {
                        Text(script)
                            .font(CalmlyTypography.empathyMessage)
                            .foregroundStyle(CalmlyColors.textSecondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(6)
                            .padding(.horizontal, 28)
                    }

                    CalmlyCard {
                        Text("Di esto en voz baja:")
                            .font(CalmlyTypography.caption)
                            .foregroundStyle(CalmlyColors.textSecondary)

                        Text("Puedo ir paso a paso. No necesito resolver todo en este instante.")
                            .font(CalmlyTypography.body)
                            .foregroundStyle(CalmlyColors.textPrimary)
                            .padding(.top, 6)
                    }
                    .padding(.horizontal, 24)
                }

                Spacer()

                CalmlyPrimaryButton(title: "Seguir") {
                    finishSession()
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            hapticsService.prepareEngine()
            hapticsService.playConfirmationTap()

            guard !hasSpoken, let script = flow.latestResponse?.script else { return }
            hasSpoken = true
            ttsService.speak(script)
        }
        .onDisappear {
            ttsService.stop()
        }
    }

    private func finishSession() {
        ttsService.stop()
        flow.finishSession()
    }
}
