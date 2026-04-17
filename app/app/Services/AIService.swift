import Foundation
import UIKit

/// Wraps the LLM API call. Sends context, returns structured AIResponse.
final class AIService {

    private static let fallbackResponse = AIResponse(
        empathy: "Estoy aquí contigo. Vamos a hacer una pausa juntos.",
        type: .breathing,
        script: "Inhala 4 segundos, sostén 4 y exhala 6. Repite conmigo por 30 segundos."
    )

    private static let systemPrompt = """
    You are a warm, human companion (NOT a therapist). The user is likely overwhelmed.
    Given their context (text and/or noise level), respond with:
    1. One empathetic sentence acknowledging what you notice.
    2. One gentle invitation to a 30s practice.
    Output ONLY valid JSON: { "empathy": "...", "type": "breathing|grounding|reframe", "script": "..." }
    Tone: como un amigo cercano. Always respond in Spanish. Never clinical. Never use the word "ansiedad" or "trastorno".
    The "script" field should contain the instructions for the chosen intervention in 1-2 sentences.
    """

    // MARK: - Public

    func interpret(context: CalmlyContext, demoMode: Bool) async throws -> AIResponse {
        if demoMode {
            return try await demoInterpret(context: context)
        }

        guard APIConfig.hasValidKey else {
            return Self.fallbackResponse
        }

        return await realInterpret(context: context)
    }

    // MARK: - Demo mode

    private func demoInterpret(context: CalmlyContext) async throws -> AIResponse {
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

    // MARK: - Real API call

    private func realInterpret(context: CalmlyContext) async -> AIResponse {
        do {
            let result = try await withThrowingTaskGroup(of: AIResponse.self) { group in
                group.addTask { try await self.callOpenAI(context: context) }
                group.addTask {
                    try await Task.sleep(nanoseconds: 5_000_000_000)
                    throw URLError(.timedOut)
                }

                guard let first = try await group.next() else {
                    throw URLError(.timedOut)
                }
                group.cancelAll()
                return first
            }
            return result
        } catch {
            return Self.fallbackResponse
        }
    }

    private func callOpenAI(context: CalmlyContext) async throws -> AIResponse {
        let url = URL(string: "\(APIConfig.baseURL)/chat/completions")!

        var userContent = ""
        if let text = context.userText, !text.isEmpty {
            userContent += "El usuario escribió: \"\(text)\"\n"
        }
        if let transcript = context.transcript, !transcript.isEmpty {
            userContent += "Transcripción de voz: \"\(transcript)\"\n"
        }
        if let noise = context.ambientNoiseLevel {
            userContent += "Nivel de ruido ambiental: \(Int(noise)) dB\n"
        }
        if userContent.isEmpty {
            userContent = "El usuario presionó el botón de crisis sin dar contexto adicional."
        }

        var messages: [[String: Any]] = [
            ["role": "system", "content": Self.systemPrompt],
            ["role": "user", "content": userContent]
        ]

        // If there's an image, add it as a vision message
        if let image = context.image,
           let jpegData = image.jpegData(compressionQuality: 0.5) {
            let base64 = jpegData.base64EncodedString()
            messages[1] = [
                "role": "user",
                "content": [
                    ["type": "text", "text": userContent],
                    ["type": "image_url", "image_url": ["url": "data:image/jpeg;base64,\(base64)"]]
                ] as [Any]
            ]
        }

        let body: [String: Any] = [
            "model": APIConfig.model,
            "messages": messages,
            "temperature": 0.7,
            "max_tokens": 300,
            "response_format": ["type": "json_object"]
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(APIConfig.openAIKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let choices = json?["choices"] as? [[String: Any]],
              let message = choices.first?["message"] as? [String: Any],
              let content = message["content"] as? String,
              let contentData = content.data(using: .utf8) else {
            throw URLError(.cannotParseResponse)
        }

        return try JSONDecoder().decode(AIResponse.self, from: contentData)
    }
}
