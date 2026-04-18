import Foundation
import Observation

@Observable
final class SessionFlowViewModel {
    // MARK: - Navigation
    var crisisPath: [AppRoute] = []
    var isCrisisFlowActive = false

    // MARK: - State
    var demoModeEnabled = true
    var context = CalmlyContext()
    var latestResponse: AIResponse?
    var isInterpreting = false
    var lastErrorMessage: String?

    private let aiService = AIService()

    // MARK: - Flow control

    func startCrisisFlow() {
        context = CalmlyContext()
        latestResponse = nil
        lastErrorMessage = nil
        crisisPath = []
        isCrisisFlowActive = true
    }

    func startAmbientCrisisFlow(noiseLevel: Double) {
        startCrisisFlow()
        context.ambientNoiseLevel = noiseLevel
        crisisPath.append(.interpreting)
    }

    func submitCapture(text: String?) {
        context.userText = text?.isEmpty == true ? nil : text
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
            crisisPath.append(.response)
        } catch {
            lastErrorMessage = "No pude conectar. Intentemos con algo que siempre funciona."
        }

        isInterpreting = false
    }

    func startSession() {
        guard let response = latestResponse else { return }
        switch response.type {
        case .breathing:
            crisisPath.append(.breathing)
        case .grounding:
            crisisPath.append(.grounding)
        case .reframe:
            crisisPath.append(.breathing)
        }
    }

    func finishSession() {
        crisisPath.append(.checkIn)
    }

    func completeFlow() {
        isCrisisFlowActive = false
        crisisPath = []
        context = CalmlyContext()
        latestResponse = nil
        lastErrorMessage = nil
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
