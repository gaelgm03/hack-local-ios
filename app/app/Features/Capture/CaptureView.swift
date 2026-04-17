import SwiftUI

/// Palette editor placeholder screen.
struct CaptureView: View {
    var body: some View {
        ZStack {
            Color(hex: "E8E8E8").ignoresSafeArea()
            FigmaScreenLayout {
                VStack(alignment: .leading, spacing: 24) {
                    FigmaBackButton()

                    Text("paletas")
                        .font(.system(size: 64, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(hex: "222222"))
                        .minimumScaleFactor(0.7)
                        .padding(.top, 34)

                    ForEach(1...3, id: \.self) { row in
                        VStack(alignment: .leading, spacing: 14) {
                            Text("\(row).")
                                .font(.system(size: 52, weight: .bold, design: .rounded))
                                .foregroundStyle(.black)
                            HStack(spacing: 12) {
                                ForEach(0..<5, id: \.self) { _ in
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .fill(Color(hex: "D3D3D6"))
                                        .frame(width: 66, height: 66)
                                }
                            }
                        }
                        .padding(.top, row == 1 ? 8 : 16)
                    }

                    Spacer(minLength: 16)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    NavigationStack {
        CaptureView()
    }
}
