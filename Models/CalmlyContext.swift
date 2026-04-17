import Foundation
import UIKit

/// Context data gathered from the user's environment and input,
/// sent to the AI service for interpretation.
struct CalmlyContext {
    var image: UIImage?
    var transcript: String?
    var ambientNoiseLevel: Double?
    var userText: String?
}
