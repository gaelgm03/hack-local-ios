import SwiftUI

struct StrategyView: View {
    var body: some View {
        ZStack {
            Color(hex: "E8E8E8").ignoresSafeArea()
            FigmaScreenLayout {
                VStack(alignment: .leading, spacing: 26) {
                    FigmaBackButton()

                    Text("estrategias")
                        .font(.system(size: 64, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(hex: "222222"))
                        .minimumScaleFactor(0.7)
                        .padding(.top, 30)

                    ForEach(1...3, id: \.self) { row in
                        Text("\(row).")
                            .font(.system(size: 52, weight: .bold, design: .rounded))
                            .foregroundStyle(.black)
                            .padding(.top, row == 1 ? 12 : 42)
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
        StrategyView()
    }
}
