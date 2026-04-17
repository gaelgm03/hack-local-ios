import Foundation

/// Structured response returned by the AI service.
struct AIResponse: Codable {
    let empathy: String
    let type: InterventionType
    let script: String
}
