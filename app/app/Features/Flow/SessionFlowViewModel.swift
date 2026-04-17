import Foundation
import Observation

@Observable
final class SessionFlowViewModel {
    var demoModeEnabled = true
    var context = CalmlyContext()
    var latestResponse: AIResponse?
    var isInterpreting = false
    var lastErrorMessage: String?

    private let aiService = AIService()

    func updateContext(text: String, useVoice: Bool, useCamera: Bool) {
        context.userText = text.isEmpty ? nil : text
        context.transcript = useVoice ? text : nil
        if !useCamera {
            context.image = nil
        }
    }

    @MainActor
    func interpretCurrentContext() async {
        guard !isInterpreting else { return }
        isInterpreting = true
        lastErrorMessage = nil

        do {
            latestResponse = try await aiService.interpret(context: context, demoMode: demoModeEnabled)
        } catch {
            lastErrorMessage = "No pude interpretar este momento. Intentemos de nuevo."
        }

        isInterpreting = false
    }
}
