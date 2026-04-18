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
    - Choose "grounding" when the context suggests crowds, concerts, public spaces, too many people, social pressure, overstimulation, busy environments, classrooms, offices, presentations, or feeling overloaded by the surroundings.
    - Choose "reframe" when the context is mostly about thoughts, self-judgment, frustration, future worries, rumination, pressure to succeed, body image, or mental spiraling.
    - Choose "breathing" when the context is mostly intense body activation, loud sensory input, urgency, or when a fast body reset is the safest first step.
    - If ambient noise is above 70 dB, strongly prefer "breathing" unless the user is clearly describing social overwhelm or rumination.
    - Do not default to "breathing" just because the user feels overwhelmed.
    - If the context mentions many people, a crowd, a concert, a party, a busy room, or social pressure, prefer "grounding".
    """

    private static let groundingKeywords = [
        "gente", "personas", "mucha gente", "demasiada gente", "amigos", "familia", "salón", "salon",
        "reunión", "reunion", "clase", "oficina", "presentación", "presentacion", "hablar", "multitud",
        "concierto", "festival", "fiesta", "social", "presión social", "presion social", "lugar lleno",
        "crowd", "crowded", "concert", "festival", "party", "too many people", "a lot of people", "people",
        "social pressure", "busy room", "presentation", "classroom", "office", "audience", "stage",
        "overstimulated", "overstimulating", "public", "packed"
    ]

    private static let reframeKeywords = [
        "pienso", "pensando", "preocupa", "preocupada", "preocupado", "miedo", "futuro", "mañana", "manana",
        "y si", "no dejo de pensar", "darle vueltas", "fracaso", "frustrada", "frustrado", "culpa", "culpable",
        "peso", "bajar de peso", "cuerpo", "imagen", "comparo", "compararme", "no soy suficiente",
        "presión", "presion", "exigencia", "expectativas", "todo me sale mal",
        "thinking", "overthinking", "worried", "worry", "future", "what if", "can't stop thinking",
        "ruminating", "spiraling", "spiralling", "frustrated", "failure", "pressure", "expectations",
        "body", "weight", "lose weight", "not enough", "self-esteem", "self worth", "judging myself"
    ]

    private static let breathingKeywords = [
        "no puedo respirar", "respirar", "me falta el aire", "agitado", "agitada", "tiemblo", "temblando",
        "muy intenso", "muy rápido", "muy rapido", "ruido fuerte", "pánico", "panico", "colapsar",
        "can't breathe", "breathing", "shaking", "heart racing", "panic", "too loud", "loud noise",
        "urgent", "intense", "hyperventilating", "short of breath"
    ]

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

        switch Self.preferredIntervention(for: context) {
        case .breathing:
            return AIResponse(
                empathy: "Gracias por contarme esto. Vamos un paso a la vez.",
                type: .breathing,
                script: "Inhala 4 segundos, sostén 4 y exhala 6. Repite conmigo."
            )
        case .grounding:
            return AIResponse(
                empathy: "Tu entorno se siente cargado. Vamos a volver al presente juntos.",
                type: .grounding,
                script: "Nombra 5 cosas que ves, 4 que tocas y 3 que escuchas."
            )
        case .reframe:
            return AIResponse(
                empathy: "Se nota que esto te pesa por dentro. Vamos a aflojar un poco esa idea.",
                type: .reframe,
                script: "Piensa: qué hecho real tengo ahora, y qué presión estoy agregando yo."
            )
        }
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
            "temperature": 0.35,
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
        let combinedText = "\(context.userText ?? "") \(context.transcript ?? "")".lowercased()
        let breathingScore = score(for: combinedText, words: breathingKeywords) + ((context.ambientNoiseLevel ?? 0) > 70 ? 3 : 0)
        let groundingScore = score(for: combinedText, words: groundingKeywords)
        let reframeScore = score(for: combinedText, words: reframeKeywords)

        if max(groundingScore, reframeScore, breathingScore) == 0 {
            return (context.ambientNoiseLevel ?? 0) > 70 ? .breathing : .grounding
        }

        if groundingScore >= reframeScore && groundingScore >= breathingScore {
            return .grounding
        }

        if reframeScore >= groundingScore && reframeScore >= breathingScore {
            return .reframe
        }

        return .breathing
    }

    private static func score(for text: String, words: [String]) -> Int {
        words.reduce(into: 0) { score, word in
            if text.contains(word) {
                score += 1
            }
        }
    }

    private func debugSummary(for context: CalmlyContext) -> String {
        let text = context.userText?.isEmpty == false ? "text=yes" : "text=no"
        let transcript = context.transcript?.isEmpty == false ? "transcript=yes" : "transcript=no"
        let image = context.image != nil ? "image=yes" : "image=no"
        let noise = context.ambientNoiseLevel.map { "noise=\(Int($0))dB" } ?? "noise=none"
        return [text, transcript, image, noise].joined(separator: " ")
    }
}
