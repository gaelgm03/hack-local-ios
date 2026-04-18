import Foundation
import UIKit
import Observation

@Observable
final class SessionFlowViewModel {
    // MARK: - Navigation
    var crisisRoot: AppRoute = .capture
    var crisisPath: [AppRoute] = []
    var isCrisisFlowActive = false

    // MARK: - State
    var demoModeEnabled = true
    var context = CalmlyContext()
    var latestResponse: AIResponse?
    var isInterpreting = false
    var lastErrorMessage: String?
    var pendingBooking: SpecialistBookingSelection?
    var confirmedBooking: SpecialistBookingSelection?

    private let aiService = AIService()
    private static let immediatePauseResponse = AIResponse(
        empathy: "Estoy contigo. Vamos a hacer una pausa ahora mismo.",
        type: .breathing,
        script: "Inhala 4 segundos, sostén 4 y exhala 6. Repite conmigo."
    )

    // MARK: - Flow control

    func startCrisisFlow() {
        context = CalmlyContext()
        latestResponse = nil
        lastErrorMessage = nil
        pendingBooking = nil
        confirmedBooking = nil
        crisisRoot = .capture
        crisisPath = []
        isCrisisFlowActive = true
    }

    func startImmediatePauseFlow() {
        startCrisisFlow()
        latestResponse = Self.immediatePauseResponse
        crisisRoot = .breathing
    }

    func startAmbientCrisisFlow(noiseLevel: Double) {
        startCrisisFlow()
        context.ambientNoiseLevel = noiseLevel
        crisisRoot = .interpreting
    }

    func submitCapture(text: String?) {
        context.userText = text?.isEmpty == true ? nil : text
        crisisPath.append(.interpreting)
    }

    func submitCapture(text: String?, transcript: String?, image: UIImage?) {
        let cleanText = text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanTranscript = transcript?.trimmingCharacters(in: .whitespacesAndNewlines)

        context.userText = cleanText?.isEmpty == false ? cleanText : nil
        context.transcript = cleanTranscript?.isEmpty == false ? cleanTranscript : nil
        context.image = image
        crisisPath.append(.interpreting)
    }

    func skipCapture() {
        crisisPath.append(.interpreting)
    }

    @MainActor
    func interpretCurrentContext() async {
        guard !isInterpreting else { return }
        isInterpreting = true
        lastErrorMessage = nil

        do {
            latestResponse = try await aiService.interpret(context: context, demoMode: demoModeEnabled)
            navigateToIntervention()
        } catch {
            lastErrorMessage = "No pude conectar. Intentemos con algo que siempre funciona."
        }

        isInterpreting = false
    }

    func startSession() {
        navigateToIntervention()
    }

    private func navigateToIntervention() {
        guard let response = latestResponse else { return }

        switch response.type {
        case .breathing:
            crisisPath.append(.breathing)
        case .grounding:
            crisisPath.append(.grounding)
        case .reframe:
            crisisPath.append(.reframe)
        }
    }

    func finishSession() {
        crisisPath.append(.checkIn)
    }

    func showSpecialistBridge() {
        pendingBooking = nil
        confirmedBooking = nil
        crisisPath.append(.specialists)
    }

    func selectBooking(_ booking: SpecialistBookingSelection) {
        pendingBooking = booking
        confirmedBooking = nil
    }

    func showBookingConfirmation() {
        guard pendingBooking != nil else { return }
        crisisPath.append(.bookingConfirmation)
    }

    func confirmBooking() {
        guard let pendingBooking else { return }
        confirmedBooking = pendingBooking
    }

    func completeFlow() {
        isCrisisFlowActive = false
        crisisRoot = .capture
        crisisPath = []
        context = CalmlyContext()
        latestResponse = nil
        lastErrorMessage = nil
        pendingBooking = nil
        confirmedBooking = nil
    }

    // MARK: - Legacy helpers

    func updateContext(text: String, useVoice: Bool, useCamera: Bool) {
        context.userText = text.isEmpty ? nil : text
        context.transcript = useVoice ? text : nil
        if !useCamera {
            context.image = nil
        }
    }
}
