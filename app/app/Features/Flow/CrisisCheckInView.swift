import SwiftUI

/// Post-session check-in with a decision-oriented next step.
struct CrisisCheckInView: View {
    @Environment(SessionFlowViewModel.self) private var flow
    @State private var selected: Int? = nil
    @State private var showNextStep = false
    @State private var hapticsService = HapticsService()

    private let emojis = [":(", ":|", ":)"]
    private let labels = ["Igual", "Un poco mejor", "Mejor"]

    var body: some View {
        ZStack {
            CalmlyColors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                if showNextStep {
                    VStack(spacing: 22) {
                        Text(nextStepTitle)
                            .font(CalmlyTypography.title)
                            .foregroundStyle(CalmlyColors.textPrimary)
                            .multilineTextAlignment(.center)

                        Text(nextStepCopy)
                            .font(CalmlyTypography.body)
                            .foregroundStyle(CalmlyColors.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 28)

                        CalmlyCard {
                            Text(recommendationLabel)
                                .font(CalmlyTypography.caption)
                                .foregroundStyle(CalmlyColors.textSecondary)

                            Text(recommendationCopy)
                                .font(CalmlyTypography.body)
                                .foregroundStyle(CalmlyColors.textPrimary)
                                .padding(.top, 4)
                        }
                        .padding(.horizontal, 24)

                        CalmlyPrimaryButton(title: primaryActionTitle) {
                            primaryAction()
                        }
                        .padding(.top, 4)
                        .padding(.horizontal, 24)

                        Button(secondaryActionTitle) {
                            secondaryAction()
                        }
                        .font(CalmlyTypography.body)
                        .foregroundStyle(CalmlyColors.textSecondary)
                        .buttonStyle(.plain)
                    }
                    .transition(.opacity.combined(with: .scale(scale: 0.96)))
                } else {
                    VStack(spacing: 36) {
                        Text("Como te sientes ahora?")
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
                                            .font(.system(size: 48, weight: .bold, design: .rounded))
                                            .scaleEffect(selected == index ? 1.15 : 1.0)

                                        Text(labels[index])
                                            .font(CalmlyTypography.caption)
                                            .foregroundStyle(CalmlyColors.textSecondary)
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }

                        Text("Tu respuesta define el siguiente paso. Si esto sigue pesando, te llevamos con ayuda humana.")
                            .font(CalmlyTypography.body)
                            .foregroundStyle(CalmlyColors.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
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

    private var shouldPrioritizeSpecialist: Bool {
        selected != 2
    }

    private var nextStepTitle: String {
        switch selected {
        case 0:
            return "No necesitas cargar esto solo."
        case 1:
            return "Ya hubo un cambio. Vale la pena sostenerlo."
        case 2:
            return "Bien. Recuperaste un poco de control."
        default:
            return "Gracias por hacer esta pausa."
        }
    }

    private var nextStepCopy: String {
        switch selected {
        case 0:
            return "Si te sientes igual, lo mejor es reducir la incertidumbre y pasar a apoyo profesional."
        case 1:
            return "Si ya mejoro un poco, este puede ser un buen momento para pedir apoyo antes de volver a saturarte."
        case 2:
            return "Si por ahora te basta con esta pausa, puedes cerrar. Si quieres mas soporte, tambien te llevamos con un especialista."
        default:
            return "Si quieres, te ayudamos a conectar con apoyo profesional."
        }
    }

    private var recommendationLabel: String {
        shouldPrioritizeSpecialist ? "Recomendacion ahora" : "Siguiente paso opcional"
    }

    private var recommendationCopy: String {
        shouldPrioritizeSpecialist
            ? "Hablar con un especialista es la accion principal en este momento."
            : "Cerrar por ahora esta bien. Hablar con un especialista queda disponible como opcion."
    }

    private var primaryActionTitle: String {
        shouldPrioritizeSpecialist ? "Hablar con un especialista" : "Cerrar por ahora"
    }

    private var secondaryActionTitle: String {
        shouldPrioritizeSpecialist ? "Cerrar por ahora" : "Hablar con un especialista"
    }

    private func primaryAction() {
        if shouldPrioritizeSpecialist {
            flow.showSpecialistBridge()
        } else {
            flow.completeFlow()
        }
    }

    private func secondaryAction() {
        if shouldPrioritizeSpecialist {
            flow.completeFlow()
        } else {
            flow.showSpecialistBridge()
        }
    }

    private func onSelect() {
        hapticsService.playConfirmationTap()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            withAnimation(.easeOut(duration: 0.35)) {
                showNextStep = true
            }
        }
    }
}

#Preview {
    CrisisCheckInView()
        .environment(SessionFlowViewModel())
}
