import Foundation

/// Wraps the LLM API call. Sends context, returns structured AIResponse.
final class AIService {
    /// Hardcoded fallback path for hackathon demos.
    /// Replace this with your real LLM request once backend fetch is ready.
    func interpret(context: CalmlyContext, demoMode: Bool) async throws -> AIResponse {
        if demoMode {
            try await Task.sleep(nanoseconds: 1_300_000_000)

            let baseEmpathy = context.userText?.isEmpty == false
                ? "Gracias por contarme esto. Estoy contigo y vamos un paso a la vez."
                : "Parece que este momento se siente intenso. Estoy aquí contigo."

            return AIResponse(
                empathy: baseEmpathy,
                type: .breathing,
                script: "Inhala 4 segundos, sostén 4 y exhala 6. Repite conmigo por 30 segundos."
            )
        }

        // Keep this explicit so you remember where to wire your LLM call.
        throw URLError(.badServerResponse)
    }
}
