import SwiftUI

/// Siri-like animated bars for AI "thinking/speaking" states.
struct SiriWaveView: View {
    @State private var phase: CGFloat = 0
    let barCount = 9

    var body: some View {
        HStack(alignment: .center, spacing: 6) {
            ForEach(0..<barCount, id: \.self) { index in
                Capsule(style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "B8A9E8"), Color(hex: "F5C6AA")],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 7, height: barHeight(at: index))
                    .animation(.easeInOut(duration: 0.35), value: phase)
            }
        }
        .frame(height: 64)
        .onAppear {
            withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                phase = .pi * 2
            }
        }
    }

    private func barHeight(at index: Int) -> CGFloat {
        let normalized = (sin(phase + CGFloat(index) * 0.72) + 1) / 2
        return 14 + (normalized * 42)
    }
}

#Preview {
    SiriWaveView()
        .padding()
        .background(.black)
}
