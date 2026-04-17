import SwiftUI

/// Calendar screen inspired by the local Figma PDF.
struct GroundingSessionView: View {
    private let week = ["L", "M", "M", "J", "V", "S", "D"]
    private let accentDays: [Int: Color] = [
        1: Color(hex: "E8C36C"),
        2: Color(hex: "B7D3D8"),
        3: Color(hex: "B7D3D8"),
        4: Color(hex: "C2B8ED"),
        5: Color(hex: "E0A6E6"),
        6: Color(hex: "E0A6E6"),
        7: Color(hex: "CFC851"),
        8: Color(hex: "A9C0E4")
    ]

    var body: some View {
        ZStack {
            Color(hex: "E8E8E8").ignoresSafeArea()
            FigmaScreenLayout {
                VStack(alignment: .leading, spacing: 18) {
                    HStack {
                        Image(systemName: "9.circle.fill")
                            .font(.system(size: 96))
                            .foregroundStyle(Color(hex: "252525"))
                        Spacer()
                        VStack(alignment: .leading) {
                            Text("Hoy")
                                .font(.system(size: 42, weight: .bold, design: .rounded))
                            Text("9 abril 2026")
                                .font(.system(size: 34, weight: .medium, design: .rounded))
                                .minimumScaleFactor(0.8)
                        }
                        Spacer()
                        FigmaCloseButton()
                    }
                    .foregroundStyle(Color(hex: "242424"))
                    .padding(.top, 6)

                    HStack {
                        ForEach(week, id: \.self) { letter in
                            Text(letter)
                                .font(.system(size: 24, weight: .medium, design: .rounded))
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color(hex: "D1D1D6"))
                    )

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 14), count: 7), spacing: 18) {
                        ForEach(1...30, id: \.self) { day in
                            VStack(spacing: 2) {
                                ZStack {
                                    Circle()
                                        .stroke(day == 9 ? Color.black : Color(hex: "2D2D2D"), lineWidth: day == 9 ? 4 : 2)
                                        .frame(width: 42, height: 42)
                                    if let accent = accentDays[day] {
                                        Circle()
                                            .fill(accent.opacity(0.95))
                                            .frame(width: 42, height: 42)
                                    }
                                    if day == 9 {
                                        Image(systemName: "plus")
                                            .font(.system(size: 20, weight: .bold))
                                    }
                                }
                                Text("\(day)")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                            }
                        }
                    }

                    Spacer(minLength: 8)

                    Text("¿Cómo te sientes el día de hoy?")
                        .font(.system(size: 42, weight: .medium, design: .rounded))
                        .foregroundStyle(Color(hex: "242424"))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.75)
                        .padding(.bottom, 12)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    GroundingSessionView()
}
