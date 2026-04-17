import SwiftUI

/// Config options: colores, sonidos, estrategias.
struct ResponseView: View {
    var body: some View {
        ZStack {
            Color(hex: "E8E8E8").ignoresSafeArea()
            FigmaScreenLayout {
                VStack(alignment: .leading) {
                    HStack {
                        Spacer()
                        FigmaCloseButton()
                    }
                    .padding(.top, 6)

                    VStack(alignment: .leading, spacing: 24) {
                        NavigationLink(destination: CaptureView()) {
                            Text("colores")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .contentShape(Rectangle())
                        }
                        NavigationLink(destination: InterpretingView()) {
                            Text("sonidos")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .contentShape(Rectangle())
                        }
                        NavigationLink(destination: StrategyView()) {
                            Text("estrategias")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .contentShape(Rectangle())
                        }
                    }
                    .font(.system(size: 62, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(hex: "222222"))
                    .padding(.top, 150)

                    Spacer(minLength: 16)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    NavigationStack {
        ResponseView()
    }
}
