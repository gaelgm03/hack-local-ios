import SwiftUI

/// Crisis instruction screen with soft animated glow.
struct BreathingSessionView: View {
    var body: some View {
        ZStack {
            Color(hex: "E8E8E8").ignoresSafeArea()

            FigmaScreenLayout {
                VStack(spacing: 20) {
                    HStack {
                        Spacer()
                        FigmaCloseButton()
                    }
                    .padding(.top, 6)

                    Text("instrucción")
                        .font(.system(size: 66, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(hex: "232323"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .minimumScaleFactor(0.7)
                        .padding(.top, 58)

                    ZStack {
                        Circle()
                            .fill(Color(hex: "B8CBEA").opacity(0.45))
                            .blur(radius: 28)
                            .frame(width: 260, height: 260)
                        Circle()
                            .fill(Color(hex: "D2DF95").opacity(0.6))
                            .blur(radius: 20)
                            .frame(width: 120, height: 120)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 90)

                    Spacer(minLength: 16)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    BreathingSessionView()
}
