import SwiftUI

/// Typography styles using SF Pro Rounded.
enum CalmlyTypography {
    static let largeTitle = Font.system(.largeTitle, design: .rounded, weight: .bold)
    static let title = Font.system(.title2, design: .rounded, weight: .semibold)
    static let body = Font.system(.body, design: .rounded, weight: .regular)
    static let caption = Font.system(.caption, design: .rounded, weight: .medium)
    static let empathyMessage = Font.system(.title3, design: .rounded, weight: .medium)
}
