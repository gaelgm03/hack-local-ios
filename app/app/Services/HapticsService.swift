import CoreHaptics
import Foundation
import UIKit

/// Provides haptic feedback patterns for breathing exercises.
final class HapticsService {
    private var engine: CHHapticEngine?
    private var supportsHaptics = CHHapticEngine.capabilitiesForHardware().supportsHaptics
    private let fallbackGenerator = UIImpactFeedbackGenerator(style: .soft)

    func prepareEngine() {
        fallbackGenerator.prepare()

        guard supportsHaptics else { return }
        if engine != nil { return }

        do {
            let hapticEngine = try CHHapticEngine()
            hapticEngine.resetHandler = { [weak self] in
                Task { @MainActor [weak self] in
                    self?.engine = nil
                    self?.prepareEngine()
                }
            }
            hapticEngine.stoppedHandler = { _ in }
            try hapticEngine.start()
            engine = hapticEngine
        } catch {
            engine = nil
            supportsHaptics = false
        }
    }

    func playInhale() {
        playContinuousPattern(
            duration: 4,
            startIntensity: 0.25,
            endIntensity: 0.7,
            sharpness: 0.1
        )
    }

    func playHold() {
        playContinuousPattern(
            duration: 4,
            startIntensity: 0.4,
            endIntensity: 0.4,
            sharpness: 0.05
        )
    }

    func playExhale() {
        playContinuousPattern(
            duration: 6,
            startIntensity: 0.7,
            endIntensity: 0.2,
            sharpness: 0.1
        )
    }

    func playConfirmationTap() {
        guard supportsHaptics, let engine else {
            fallbackGenerator.impactOccurred(intensity: 0.8)
            fallbackGenerator.prepare()
            return
        }

        do {
            let event = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    .init(parameterID: .hapticIntensity, value: 0.5),
                    .init(parameterID: .hapticSharpness, value: 0.3)
                ],
                relativeTime: 0
            )
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try engine.start()
            try player.start(atTime: 0)
        } catch {
            fallbackGenerator.impactOccurred(intensity: 0.8)
        }
    }

    func stopAll() {
        guard let engine else { return }
        do {
            engine.stop(completionHandler: nil)
            try engine.start()
        } catch {
            // Ignore stop failures; the next phase will restart the engine if needed.
        }
    }

    private func playContinuousPattern(
        duration: TimeInterval,
        startIntensity: Float,
        endIntensity: Float,
        sharpness: Float
    ) {
        guard supportsHaptics, let engine else {
            fallbackGenerator.impactOccurred(intensity: 0.55)
            fallbackGenerator.prepare()
            return
        }

        do {
            let event = CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [
                    .init(parameterID: .hapticIntensity, value: startIntensity),
                    .init(parameterID: .hapticSharpness, value: sharpness)
                ],
                relativeTime: 0,
                duration: duration
            )

            let intensityCurve = CHHapticParameterCurve(
                parameterID: .hapticIntensityControl,
                controlPoints: [
                    .init(relativeTime: 0, value: startIntensity),
                    .init(relativeTime: duration, value: endIntensity)
                ],
                relativeTime: 0
            )

            let pattern = try CHHapticPattern(events: [event], parameterCurves: [intensityCurve])
            let player = try engine.makeAdvancedPlayer(with: pattern)
            try engine.start()
            try player.start(atTime: 0)
        } catch {
            fallbackGenerator.impactOccurred(intensity: 0.55)
        }
    }
}
