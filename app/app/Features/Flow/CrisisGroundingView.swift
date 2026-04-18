import SwiftUI

/// 5-4-3-2-1 grounding exercise: step-by-step sensory prompts.
struct CrisisGroundingView: View {
    @Environment(SessionFlowViewModel.self) private var flow
    @State private var currentStep = 0

    private let steps: [GroundingStep] = [
        GroundingStep(id: 5, sense: "👀 Vista", prompt: "Nombra 5 cosas que puedas ver"),
        GroundingStep(id: 4, sense: "✋ Tacto", prompt: "Nombra 4 cosas que puedas tocar"),
        GroundingStep(id: 3, sense: "👂 Oído", prompt: "Nombra 3 cosas que puedas escuchar"),
        GroundingStep(id: 2, sense: "👃 Olfato", prompt: "Nombra 2 cosas que puedas oler"),
        GroundingStep(id: 1, sense: "👅 Gusto", prompt: "Nombra 1 cosa que puedas saborear")
    ]

    var body: some View {
        ZStack {
            CalmlyColors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button("Saltar") {
                        flow.finishSession()
                    }
                    .font(CalmlyTypography.body)
                    .foregroundStyle(CalmlyColors.textSecondary)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)

                Spacer()

                if currentStep < steps.count {
                    let step = steps[currentStep]

                    VStack(spacing: 24) {
                        if let empathy = flow.latestResponse?.empathy {
                            Text(empathy)
                                .font(CalmlyTypography.body)
                                .foregroundStyle(CalmlyColors.textSecondary)
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)
                        }

                        Text("\(step.id)")
                            .font(.system(size: 96, weight: .bold, design: .rounded))
                            .foregroundStyle(CalmlyColors.accent)

                        Text(step.sense)
                            .font(CalmlyTypography.title)
                            .foregroundStyle(CalmlyColors.textPrimary)

                        Text(step.prompt)
                            .font(CalmlyTypography.empathyMessage)
                            .foregroundStyle(CalmlyColors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 32)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
                }

                Spacer()

                // Progress dots
                HStack(spacing: 8) {
                    ForEach(0..<steps.count, id: \.self) { index in
                        Circle()
                            .fill(index <= currentStep ? CalmlyColors.accent : CalmlyColors.surface)
                            .frame(width: 10, height: 10)
                    }
                }
                .padding(.bottom, 24)

                CalmlyPrimaryButton(title: currentStep < steps.count - 1 ? "Siguiente" : "Terminé") {
                    if currentStep < steps.count - 1 {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            currentStep += 1
                        }
                    } else {
                        flow.finishSession()
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    CrisisGroundingView()
        .environment(SessionFlowViewModel())
}
