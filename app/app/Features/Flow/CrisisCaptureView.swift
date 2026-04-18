import SwiftUI

/// Context capture screen: user types what they're feeling or skips.
struct CrisisCaptureView: View {
    @Environment(SessionFlowViewModel.self) private var flow
    @State private var userText = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        ZStack {
            CalmlyColors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Button {
                        flow.completeFlow()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundStyle(CalmlyColors.textSecondary)
                            .frame(width: 44, height: 44)
                    }
                    Spacer()
                    Button("Saltar") {
                        flow.skipCapture()
                    }
                    .font(CalmlyTypography.body)
                    .foregroundStyle(CalmlyColors.textSecondary)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)

                Spacer()

                VStack(spacing: 24) {
                    Text("¿Quieres contarme algo?")
                        .font(CalmlyTypography.largeTitle)
                        .foregroundStyle(CalmlyColors.textPrimary)
                        .multilineTextAlignment(.center)

                    Text("Escribe lo que sientes, o salta este paso.")
                        .font(CalmlyTypography.body)
                        .foregroundStyle(CalmlyColors.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 32)

                Spacer()

                VStack(spacing: 20) {
                    TextField("Estoy...", text: $userText, axis: .vertical)
                        .lineLimit(3...6)
                        .font(CalmlyTypography.empathyMessage)
                        .foregroundStyle(CalmlyColors.textPrimary)
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(CalmlyColors.surface)
                        )
                        .focused($isFocused)
                        .submitLabel(.done)

                    CalmlyPrimaryButton(title: "Siguiente") {
                        flow.submitCapture(text: userText)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear { isFocused = true }
    }
}

#Preview {
    CrisisCaptureView()
        .environment(SessionFlowViewModel())
}
