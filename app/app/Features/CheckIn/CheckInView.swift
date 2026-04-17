import SwiftUI

/// Notes screen based on Figma page "Cuéntame...".
struct CheckInView: View {
    @State private var bestPart = ""
    @State private var avoidRepeat = ""
    @State private var moodIndex = 0

    private let moods: [Color] = [
        Color(hex: "E8C36C"),
        Color(hex: "CFC851"),
        Color(hex: "A9C0E4"),
        Color(hex: "BCB0EA"),
        Color(hex: "E0A6E6")
    ]

    var body: some View {
        ZStack {
            Color(hex: "E8E8E8").ignoresSafeArea()
            FigmaScreenLayout {
                VStack(alignment: .leading, spacing: 26) {
                    HStack {
                        Spacer()
                        FigmaCloseButton()
                    }

                    Text("Cuéntame...")
                        .font(.system(size: 64, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(hex: "232323"))
                        .minimumScaleFactor(0.7)
                        .padding(.top, 4)

                    Text("¿Cómo te sentiste?")
                        .font(.system(size: 22, weight: .medium, design: .rounded))
                        .underline()

                    HStack(spacing: 16) {
                        ForEach(0..<moods.count, id: \.self) { index in
                            Circle()
                                .fill(moods[index])
                                .frame(width: 54, height: 54)
                                .overlay {
                                    if moodIndex == index {
                                        Circle().stroke(Color(hex: "222222"), lineWidth: 3)
                                    }
                                }
                                .onTapGesture {
                                    moodIndex = index
                                }
                        }
                    }

                    Text("¿Cuál fue la mejor parte de tu día?")
                        .font(.system(size: 22, weight: .medium, design: .rounded))
                        .underline()

                    HStack(spacing: 12) {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Color(hex: "D9D897"))
                            .frame(width: 90, height: 90)
                            .overlay {
                                Image(systemName: "hare.fill")
                                    .font(.system(size: 36))
                                    .foregroundStyle(Color(hex: "313131"))
                            }

                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(Color(hex: "D9D897"))
                            .frame(height: 90)
                            .overlay(alignment: .leading) {
                                TextField("Escribe aquí...", text: $bestPart)
                                    .padding(.horizontal, 16)
                                    .foregroundStyle(Color(hex: "333333"))
                                    .font(.system(size: 20, weight: .medium, design: .rounded))
                            }
                    }

                    Text("¿Qué no te gustaría repetir?")
                        .font(.system(size: 22, weight: .medium, design: .rounded))
                        .underline()

                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(Color(hex: "CEC8E8"))
                        .frame(height: 170)
                        .overlay(alignment: .topLeading) {
                            TextField("Escribe aquí...", text: $avoidRepeat, axis: .vertical)
                                .lineLimit(3...5)
                                .padding(18)
                                .foregroundStyle(Color(hex: "2E2E2E"))
                                .font(.system(size: 20, weight: .medium, design: .rounded))
                        }

                    Text("Siempre recuerda: todo estará bien")
                        .font(.system(size: 22, weight: .regular, design: .rounded))
                        .italic()
                        .foregroundStyle(Color(hex: "3A3A3A"))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 42)
                        .padding(.bottom, 20)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    CheckInView()
}
