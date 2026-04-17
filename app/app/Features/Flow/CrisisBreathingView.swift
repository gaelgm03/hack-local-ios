import SwiftUI

/// Animated breathing session: expanding/contracting orb with timer and haptics.
struct CrisisBreathingView: View {
    @Environment(SessionFlowViewModel.self) private var flow

    @State private var phase: BreathPhase = .inhale
    @State private var orbScale: CGFloat = 0.6
    @State private var secondsRemaining = 30
    @State private var timerActive = true

    private let inhaleDuration: Double = 4
    private let holdDuration: Double = 4
    private let exhaleDuration: Double = 6

    enum BreathPhase: String {
        case inhale = "Inhala..."
        case hold = "Sostén..."
        case exhale = "Exhala..."
    }

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

                ZStack {
                    Circle()
                        .fill(CalmlyColors.primaryGradient)
                        .frame(width: 200, height: 200)
                        .scaleEffect(orbScale)
                        .opacity(0.3)
                        .blur(radius: 20)

                    Circle()
                        .fill(CalmlyColors.primaryGradient)
                        .frame(width: 160, height: 160)
                        .scaleEffect(orbScale)
                        .opacity(0.6)
                        .blur(radius: 6)

                    Circle()
                        .fill(CalmlyColors.primaryGradient)
                        .frame(width: 120, height: 120)
                        .scaleEffect(orbScale)
                }

                Text(phase.rawValue)
                    .font(CalmlyTypography.title)
                    .foregroundStyle(CalmlyColors.textPrimary)
                    .padding(.top, 32)
                    .animation(.easeInOut(duration: 0.3), value: phase)

                if let script = flow.latestResponse?.script {
                    Text(script)
                        .font(CalmlyTypography.body)
                        .foregroundStyle(CalmlyColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.top, 12)
                        .padding(.horizontal, 40)
                }

                Spacer()

                Text("\(secondsRemaining)s")
                    .font(.system(size: 48, weight: .light, design: .rounded))
                    .foregroundStyle(CalmlyColors.textSecondary)
                    .monospacedDigit()
                    .padding(.bottom, 60)
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear { startBreathingCycle() }
        .task { await countDown() }
    }

    private func startBreathingCycle() {
        breathCycle()
    }

    private func breathCycle() {
        guard timerActive else { return }

        // Inhale
        phase = .inhale
        withAnimation(.easeInOut(duration: inhaleDuration)) {
            orbScale = 1.2
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + inhaleDuration) {
            guard timerActive else { return }
            // Hold
            phase = .hold

            DispatchQueue.main.asyncAfter(deadline: .now() + holdDuration) {
                guard timerActive else { return }
                // Exhale
                phase = .exhale
                withAnimation(.easeInOut(duration: exhaleDuration)) {
                    orbScale = 0.6
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + exhaleDuration) {
                    breathCycle()
                }
            }
        }
    }

    private func countDown() async {
        while secondsRemaining > 0 && timerActive {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            secondsRemaining -= 1
        }
        if secondsRemaining <= 0 {
            timerActive = false
            flow.finishSession()
        }
    }
}

#Preview {
    CrisisBreathingView()
        .environment(SessionFlowViewModel())
}
