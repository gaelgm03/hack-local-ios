import SwiftUI

struct HomeView: View {
    @State private var lightMode = false

    var body: some View {
        NavigationStack {
            ZStack {
                (lightMode ? Color(hex: "E8E8E8") : Color(hex: "262626"))
                    .ignoresSafeArea()

                VStack(alignment: .leading) {
                    HStack {
                        Spacer()
                        Circle()
                            .fill(lightMode ? Color(hex: "3A383B") : Color(hex: "D9D9D9"))
                            .frame(width: 54, height: 54)
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    lightMode.toggle()
                                }
                            }
                    }
                    .padding(.horizontal, 28)
                    .padding(.top, 18)

                    VStack(alignment: .leading, spacing: 22) {
                        NavigationLink(destination: CheckInView()) {
                            Text("notas")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .contentShape(Rectangle())
                        }
                        NavigationLink(destination: GroundingSessionView()) {
                            Text("calendario")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .contentShape(Rectangle())
                        }
                        NavigationLink(destination: MapPlaceholderView()) {
                            Text("mapa")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .contentShape(Rectangle())
                        }
                        NavigationLink(destination: ResponseView()) {
                            Text("config.")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .contentShape(Rectangle())
                        }
                    }
                    .font(.system(size: 62, weight: .bold, design: .rounded))
                    .foregroundStyle(lightMode ? Color(hex: "222222") : .white)
                    .minimumScaleFactor(0.7)
                    .padding(.leading, 36)
                    .padding(.top, 90)

                    Spacer()

                    VStack(spacing: 12) {
                        NavigationLink(destination: BreathingSessionView()) {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: "EAA8EE"))
                                    .frame(width: 126, height: 126)
                                Image(systemName: "hare.fill")
                                    .font(.system(size: 40))
                                    .foregroundStyle(lightMode ? Color(hex: "222222") : .white)
                            }
                        }
                        .buttonStyle(.plain)

                        Text("crisis?")
                            .font(.system(size: 62, weight: .bold, design: .rounded))
                            .foregroundStyle(Color(hex: "F09AF3"))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 56)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    HomeView()
}
