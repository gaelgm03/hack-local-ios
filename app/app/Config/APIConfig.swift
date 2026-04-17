import Foundation

/// Local developer config.
/// Keep this file out of git and set your real key locally.
enum APIConfig {
    static let openAIKey = ""
    static let baseURL = "https://api.openai.com/v1"
    static let model = "gpt-4o-mini"

    static var hasValidKey: Bool {
        !openAIKey.isEmpty && openAIKey != "sk-your-key-here"
    }
}
