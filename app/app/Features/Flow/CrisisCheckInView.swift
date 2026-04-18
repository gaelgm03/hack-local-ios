import SwiftUI

/// Post-session check-in: "¿Cómo te sientes ahora?" with 3-emoji scale.
struct CrisisCheckInView: View {
    @Environment(SessionFlowViewModel.self) private var flow
    @State private var selected: Int? = nil
    @State private var showConfirmation = false
    @State private var hapticsService = HapticsService()

    private let emojis = ["😔", "😐", "😊"]
    private let labels = ["Igual", "Un poco mejor", "Mejor"]

    var body: some View {
        ZStack {
            CalmlyColors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                if showConfirmation {
                    VStack(spacing: 20) {
                        Text("💜")
                            .font(.system(size: 64))

                        Text("Gracias por hacer esta pausa.")
                            .font(CalmlyTypography.title)
                            .foregroundStyle(CalmlyColors.textPrimary)

                        Text("Aquí sigo contigo.")
                            .font(CalmlyTypography.body)
                            .foregroundStyle(CalmlyColors.textSecondary)
                    }
                    .transition(.opacity.combined(with: .scale(scale: 0.9)))
                } else {
                    VStack(spacing: 36) {
                        Text("¿Cómo te sientes ahora?")
                            .font(CalmlyTypography.largeTitle)
                            .foregroundStyle(CalmlyColors.textPrimary)
                            .multilineTextAlignment(.center)

                        HStack(spacing: 32) {
                            ForEach(0..<emojis.count, id: \.self) { index in
                                Button {
                                    withAnimation(.spring(response: 0.4)) {
                                        selected = index
                                    }
                                    onSelect()
                                } label: {
                                    VStack(spacing: 8) {
                                        Text(emojis[index])
                                            .font(.system(size: 56))
                                            .scaleEffect(selected == index ? 1.2 : 1.0)

                                        Text(labels[index])
                                            .font(CalmlyTypography.caption)
                                            .foregroundStyle(CalmlyColors.textSecondary)
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.horizontal, 32)
                }

                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            hapticsService.prepareEngine()
        }
    }

    private func onSelect() {
        hapticsService.playConfirmationTap()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.easeOut(duration: 0.5)) {
                showConfirmation = true
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            flow.completeFlow()
        }
    }
}

#Preview {
    CrisisCheckInView()
        .environment(SessionFlowViewModel())
}
