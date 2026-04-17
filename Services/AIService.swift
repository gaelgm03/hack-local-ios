import Foundation

/// Wraps the LLM API call. Sends context, returns structured AIResponse.
final class AIService {
    // TODO: Implement real API call to OpenAI / Claude
    // TODO: Add demo-mode toggle with pre-baked responses

    func interpret(context: CalmlyContext) async throws -> AIResponse {
        // Placeholder — replace with real implementation on Day 2
        fatalError("AIService.interpret() not yet implemented")
    }
}
