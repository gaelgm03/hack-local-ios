import Foundation
import UIKit

/// Wraps the LLM API call. Sends context, returns structured AIResponse.
final class AIService: Sendable {

    private static let breathingFallback = AIResponse(
        empathy: "Estoy aquí contigo. Vamos a hacer una pausa juntos.",
        type: .breathing,
        script: "Inhala 4 segundos, sostén 4 y exhala 6. Repite conmigo."
    )

    private static let groundingFallback = AIResponse(
        empathy: "Este momento se siente intenso. Vamos a conectar con lo que te rodea.",
        type: .grounding,
        script: "Nombra 5 cosas que puedes ver, 4 que puedes tocar y 3 que puedes oír."
    )

    private static let reframeFallback = AIResponse(
        empathy: "Lo que sientes es válido. Vamos a verlo desde otro ángulo.",
        type: .reframe,
        script: "Piensa: ¿qué le dirías a un amigo en este momento? Ahora dilo para ti."
    )

    private static let systemPrompt = """
    You are Calmly: a warm, human companion, never a therapist and never a bot.
    The user is likely overwhelmed.

    Given their context (text and/or ambient noise and/or image), respond with:
    1. One empathetic sentence acknowledging what you notice. Be specific to the context.
    2. One gentle invitation to a 30-second practice.

    Output ONLY valid JSON:
    { "empathy": "...", "type": "breathing|grounding|reframe", "script": "..." }

    Rules:
    - Always respond in Spanish.
    - Use tuteo, present tense, warm and familiar language.
    - Sound like a close friend who notices what is happening and stays with the user.
    - Never use clinical words like ansiedad, trastorno, síntoma, diagnóstico, terapia or pánico.
    - Prefer words like momento, pausa, respira, contigo, juntos.
    - "empathy" must be max 2 short sentences and readable in under 5 seconds.
    - "script" must be 1-2 short sentences with concrete instructions.
    - If ambient noise is above 70 dB, always choose "breathing".
    - If the text mentions people or social pressure, prefer "grounding".
    - If the text mentions worry, thoughts or the future, prefer "reframe".
    - Default to "breathing" when unsure.
    """

    // MARK: - Public

    func interpret(context: CalmlyContext, demoMode: Bool) async throws -> AIResponse {
        print("[AIService] interpret called. demoMode=\(demoMode) hasValidKey=\(APIConfig.hasValidKey)")

        if demoMode {
            print("[AIService] Using demo mode response.")
            return try await demoInterpret(context: context)
        }

        guard APIConfig.hasValidKey else {
            print("[AIService] Missing API key. Using fallback response.")
            return Self.fallbackResponse(for: context)
        }

        print("[AIService] Using real OpenAI request.")
        return await realInterpret(context: context)
    }

    // MARK: - Demo mode

    private func demoInterpret(context: CalmlyContext) async throws -> AIResponse {
        print("[AIService] demoInterpret context: \(debugSummary(for: context))")
        try await Task.sleep(nanoseconds: 1_300_000_000)

        if (context.ambientNoiseLevel ?? 0) > 70 {
            return AIResponse(
                empathy: "Hay mucho ruido a tu alrededor. Estoy aquí contigo.",
                type: .breathing,
                script: "Inhala 4 segundos, sostén 4 y exhala 6. Repite conmigo."
            )
        }

        if context.userText?.isEmpty == false || context.transcript?.isEmpty == false {
            return AIResponse(
                empathy: "Gracias por contarme esto. Vamos un paso a la vez.",
                type: .breathing,
                script: "Inhala 4 segundos, sostén 4 y exhala 6. Repite conmigo."
            )
        }

        return Self.fallbackResponse(for: context)
    }

    // MARK: - Real API call

    private func realInterpret(context: CalmlyContext) async -> AIResponse {
        do {
            print("[AIService] realInterpret context: \(debugSummary(for: context))")
            return try await callOpenAI(context: context)
        } catch {
            print("[AIService] OpenAI call failed: \(error.localizedDescription)")
            print("[AIService] Falling back to local response.")
            return Self.fallbackResponse(for: context)
        }
    }

    private func callOpenAI(context: CalmlyContext) async throws -> AIResponse {
        print("[AIService] Calling OpenAI /chat/completions")
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
        if context.image != nil {
            userContent += "Hay una imagen del entorno adjunta.\n"
        }
        if userContent.isEmpty {
            userContent = "El usuario presionó el botón de pausa sin dar contexto adicional."
        }

        var messages: [[String: Any]] = [
            ["role": "system", "content": Self.systemPrompt],
            ["role": "user", "content": userContent]
        ]

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
            "temperature": 0.5,
            "max_tokens": 300,
            "response_format": ["type": "json_object"]
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 5
        request.setValue("Bearer \(APIConfig.openAIKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            if let httpResponse = response as? HTTPURLResponse {
                let body = String(data: data, encoding: .utf8) ?? "<non-utf8 body>"
                print("[AIService] OpenAI HTTP error: \(httpResponse.statusCode)")
                print("[AIService] Response body: \(body)")
            }
            throw URLError(.badServerResponse)
        }

        print("[AIService] OpenAI HTTP success: \((response as? HTTPURLResponse)?.statusCode ?? -1)")
        print("[AIService] Raw response body: \(String(data: data, encoding: .utf8) ?? "<non-utf8 body>")")

        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let choices = json?["choices"] as? [[String: Any]],
              let message = choices.first?["message"] as? [String: Any],
              let content = message["content"] as? String,
              let contentData = content.data(using: .utf8) else {
            print("[AIService] Could not parse OpenAI response body.")
            throw URLError(.cannotParseResponse)
        }

        let decoded = try JSONDecoder().decode(AIResponse.self, from: contentData)
        print("[AIService] Decoded AI response: empathy='\(decoded.empathy)' type='\(decoded.type.rawValue)'")
        return decoded
    }

    private static func fallbackResponse(for context: CalmlyContext) -> AIResponse {
        switch preferredIntervention(for: context) {
        case .breathing:
            breathingFallback
        case .grounding:
            groundingFallback
        case .reframe:
            reframeFallback
        }
    }

    private static func preferredIntervention(for context: CalmlyContext) -> InterventionType {
        if (context.ambientNoiseLevel ?? 0) > 70 {
            return .breathing
        }

        let combinedText = "\(context.userText ?? "") \(context.transcript ?? "")".lowercased()
        if combinedText.isEmpty {
            return .breathing
        }

        if containsAny(
            in: combinedText,
            words: ["gente", "personas", "amigos", "familia", "salón", "salon", "reunión", "reunion", "clase", "oficina", "presentación", "presentacion", "hablar"]
        ) {
            return .grounding
        }

        if containsAny(
            in: combinedText,
            words: ["pienso", "pensando", "preocupa", "preocupada", "preocupado", "miedo", "futuro", "mañana", "manana", "y si", "no dejo de pensar", "darle vueltas"]
        ) {
            return .reframe
        }

        return .breathing
    }

    private static func containsAny(in text: String, words: [String]) -> Bool {
        words.contains(where: text.contains)
    }

    private func debugSummary(for context: CalmlyContext) -> String {
        let text = context.userText?.isEmpty == false ? "text=yes" : "text=no"
        let transcript = context.transcript?.isEmpty == false ? "transcript=yes" : "transcript=no"
        let image = context.image != nil ? "image=yes" : "image=no"
        let noise = context.ambientNoiseLevel.map { "noise=\(Int($0))dB" } ?? "noise=none"
        return [text, transcript, image, noise].joined(separator: " ")
    }
}
