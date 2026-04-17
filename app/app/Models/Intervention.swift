import Foundation

/// Types of micro-interventions the AI can recommend.
enum InterventionType: String, Codable {
    case breathing
    case grounding
    case reframe
}

/// A single step within a grounding exercise (5-4-3-2-1).
struct GroundingStep: Identifiable {
    let id: Int
    let sense: String
    let prompt: String
}
