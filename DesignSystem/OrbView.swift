import SwiftUI

/// Reusable animated orb — the visual mascot of Calmly.
/// Used on Home, Interpreting, and Breathing screens with different animation states.
struct OrbView: View {
    var body: some View {
        // TODO: Gradient circle with scale/opacity animation
        Circle()
            .fill(.purple.opacity(0.3))
            .frame(width: 200, height: 200)
    }
}

#Preview {
    OrbView()
}
