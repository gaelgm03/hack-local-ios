import SwiftUI

/// Animated breathing session: expanding/contracting orb with timer and haptics.
struct CrisisBreathingView: View {
    @Environment(SessionFlowViewModel.self) private var flow

    @State private var phase: BreathPhase = .inhale
    @State private var orbScale: CGFloat = 0.6
    @State private var glowScale: CGFloat = 0.55
    @State private var secondsRemaining = 30
    @State private var timerActive = true
    @State private var backgroundGlow: Double = 0.08
    @State private var hapticsService = HapticsService()

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

            RadialGradient(
                colors: [
                    Color(hex: "B8A9E8").opacity(backgroundGlow),
                    Color(hex: "F5C6AA").opacity(backgroundGlow * 0.5),
                    Color.clear
                ],
                center: .center,
                startRadius: 40,
                endRadius: 300
            )
            .ignoresSafeArea()

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

                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(hex: "B8A9E8").opacity(0.12),
                                    Color(hex: "F5C6AA").opacity(0.06),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 20,
                                endRadius: 160
                            )
                        )
                        .frame(width: 320, height: 320)
                        .scaleEffect(glowScale)
                        .blur(radius: 30)

                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(hex: "B8A9E8").opacity(0.35),
                                    Color(hex: "F5C6AA").opacity(0.2),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 10,
                                endRadius: 110
                            )
                        )
                        .frame(width: 220, height: 220)
                        .scaleEffect(orbScale)
                        .blur(radius: 14)

                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.white.opacity(0.7),
                                    Color(hex: "B8A9E8").opacity(0.75),
                                    Color(hex: "F5C6AA").opacity(0.5)
                                ],
                                center: .center,
                                startRadius: 8,
                                endRadius: 80
                            )
                        )
                        .frame(width: 160, height: 160)
                        .scaleEffect(orbScale)
                        .blur(radius: 2)

                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.white.opacity(0.92),
                                    Color(hex: "B8A9E8").opacity(0.85),
                                    Color(hex: "F5C6AA").opacity(0.65)
                                ],
                                center: .center,
                                startRadius: 5,
                                endRadius: 55
                            )
                        )
                        .frame(width: 110, height: 110)
                        .scaleEffect(orbScale)

                    Circle()
                        .stroke(Color.white.opacity(0.18), lineWidth: 1.2)
                        .frame(width: 130, height: 130)
                        .scaleEffect(orbScale)
                }
                .shadow(color: Color(hex: "B8A9E8").opacity(0.3), radius: 40, y: 6)

                if let empathy = flow.latestResponse?.empathy {
                    Text(empathy)
                        .font(CalmlyTypography.body)
                        .foregroundStyle(CalmlyColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.top, 28)
                        .padding(.horizontal, 36)
                }

                Text(phase.rawValue)
                    .font(CalmlyTypography.title)
                    .foregroundStyle(CalmlyColors.textPrimary)
                    .padding(.top, 18)
                    .contentTransition(.opacity)
                    .animation(.easeInOut(duration: 0.4), value: phase)

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
        .onAppear {
            hapticsService.prepareEngine()
            startBreathingCycle()
        }
        .onDisappear {
            timerActive = false
            hapticsService.stopAll()
        }
        .task { await countDown() }
    }

    private func startBreathingCycle() {
        breathCycle()
    }

    private func breathCycle() {
        guard timerActive else { return }

        setPhase(.inhale)
        withAnimation(.easeInOut(duration: inhaleDuration)) {
            orbScale = 1.2
            backgroundGlow = 0.14
        }
        withAnimation(.easeInOut(duration: inhaleDuration + 0.3)) {
            glowScale = 1.15
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + inhaleDuration) {
            guard timerActive else { return }

            setPhase(.hold)

            DispatchQueue.main.asyncAfter(deadline: .now() + holdDuration) {
                guard timerActive else { return }

                setPhase(.exhale)
                withAnimation(.easeInOut(duration: exhaleDuration)) {
                    orbScale = 0.6
                    backgroundGlow = 0.08
                }
                withAnimation(.easeInOut(duration: exhaleDuration + 0.3)) {
                    glowScale = 0.55
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + exhaleDuration) {
                    breathCycle()
                }
            }
        }
    }

    private func setPhase(_ newPhase: BreathPhase) {
        phase = newPhase

        switch newPhase {
        case .inhale:
            hapticsService.playInhale()
        case .hold:
            hapticsService.playHold()
        case .exhale:
            hapticsService.playExhale()
        }
    }

    private func countDown() async {
        while secondsRemaining > 0 && timerActive {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            secondsRemaining -= 1
        }

        if secondsRemaining <= 0 {
            finishSession()
        }
    }

    private func finishSession() {
        guard timerActive else { return }
        timerActive = false
        hapticsService.stopAll()
        flow.finishSession()
    }
}

#Preview {
    CrisisBreathingView()
        .environment(SessionFlowViewModel())
}
