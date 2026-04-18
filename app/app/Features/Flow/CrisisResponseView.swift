import SwiftUI

/// Displays the AI's empathetic message and a CTA to begin the micro-session.
struct CrisisResponseView: View {
    @Environment(SessionFlowViewModel.self) private var flow
    @State private var showEmpathy = false
    @State private var showWave = false
    @State private var showLabel = false
    @State private var showButton = false

    var body: some View {
        ZStack {
            CalmlyColors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button {
                        flow.completeFlow()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundStyle(CalmlyColors.textSecondary)
                            .frame(width: 44, height: 44)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)

                Spacer()

                if let response = flow.latestResponse {
                    VStack(spacing: 32) {
                        Text(response.empathy)
                            .font(CalmlyTypography.empathyMessage)
                            .foregroundStyle(CalmlyColors.textPrimary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(6)
                            .opacity(showEmpathy ? 1 : 0)
                            .offset(y: showEmpathy ? 0 : 20)

                        SiriWaveView()
                            .frame(height: 64)
                            .opacity(showWave ? 1 : 0)
                            .scaleEffect(showWave ? 1 : 0.8)

                        sessionLabel(for: response.type)
                            .font(CalmlyTypography.caption)
                            .foregroundStyle(CalmlyColors.textSecondary)
                            .opacity(showLabel ? 1 : 0)
                            .offset(y: showLabel ? 0 : 10)
                    }
                    .padding(.horizontal, 32)
                }

                Spacer()

                CalmlyPrimaryButton(title: sessionButtonTitle) {
                    flow.startSession()
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
                .opacity(showButton ? 1 : 0)
                .offset(y: showButton ? 0 : 16)
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            withAnimation(.easeOut(duration: 0.8).delay(0.3)) {
                showEmpathy = true
            }
            withAnimation(.easeOut(duration: 0.7).delay(0.7)) {
                showWave = true
            }
            withAnimation(.easeOut(duration: 0.6).delay(1.0)) {
                showLabel = true
            }
            withAnimation(.easeOut(duration: 0.7).delay(1.3)) {
                showButton = true
            }
        }
    }

    private var sessionButtonTitle: String {
        guard let response = flow.latestResponse else { return "Comenzar" }
        switch response.type {
        case .breathing: return "Respira conmigo 30s"
        case .grounding: return "Grounding 5-4-3-2-1"
        case .reframe: return "Reflexionemos juntos"
        }
    }

    @ViewBuilder
    private func sessionLabel(for type: InterventionType) -> some View {
        switch type {
        case .breathing:
            Label("Respiración guiada", systemImage: "wind")
        case .grounding:
            Label("Grounding 5-4-3-2-1", systemImage: "hand.raised")
        case .reframe:
            Label("Reencuadre", systemImage: "lightbulb")
        }
    }
}

#Preview {
    let vm = SessionFlowViewModel()
    CrisisResponseView()
        .environment(vm)
        .onAppear {
            vm.latestResponse = AIResponse(
                empathy: "Parece que este momento se siente intenso. Estoy aquí contigo.",
                type: .breathing,
                script: "Inhala 4 segundos, sostén 4 y exhala 6."
            )
        }
}
