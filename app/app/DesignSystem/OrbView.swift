import SwiftUI

/// Reusable animated orb — the visual mascot of Calmly.
/// Used on Home, Interpreting, and Breathing screens with different animation states.
struct OrbView: View {
    var size: CGFloat = 200
    var pulse: Bool = false

    @State private var isAnimating = false

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(0.9),
                            Color(hex: "B8A9E8").opacity(0.85),
                            Color(hex: "F5C6AA").opacity(0.7)
                        ],
                        center: .center,
                        startRadius: size * 0.08,
                        endRadius: size * 0.55
                    )
                )
                .blur(radius: 0.4)
                .frame(width: size, height: size)
                .scaleEffect(pulse ? (isAnimating ? 1.06 : 0.92) : 1.0)

            Circle()
                .stroke(Color.white.opacity(0.22), lineWidth: 1.5)
                .frame(width: size * 1.14, height: size * 1.14)
                .scaleEffect(pulse ? (isAnimating ? 1.04 : 0.96) : 1.0)
        }
        .shadow(color: Color(hex: "B8A9E8").opacity(0.35), radius: 36, y: 8)
        .onAppear {
            guard pulse else { return }
            withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}

#Preview {
    OrbView()
}
