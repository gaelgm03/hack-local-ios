import SwiftUI

struct HomeView: View {
    @Environment(SessionFlowViewModel.self) private var flow
    @State private var lightMode = false
    @State private var homeVM = HomeViewModel()

    var body: some View {
        @Bindable var flow = flow

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
                        Button {
                            flow.startCrisisFlow()
                        } label: {
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
                            .padding(.top, 8)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 56)
                }
            }
            .navigationBarHidden(true)
            .overlay(alignment: .bottom) {
                if homeVM.showAmbientBanner {
                    HStack(spacing: 14) {
                        Image(systemName: "waveform")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundStyle(Color(hex: "B8A9E8"))

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Parece ruidoso aquí.")
                                .font(CalmlyTypography.body)
                                .foregroundStyle(.white)
                            Text("¿Pausa de 30s?")
                                .font(CalmlyTypography.caption)
                                .foregroundStyle(.white.opacity(0.7))
                        }

                        Spacer()

                        Button {
                            withAnimation(.easeOut(duration: 0.3)) {
                                homeVM.showAmbientBanner = false
                            }
                            flow.startCrisisFlow()
                        } label: {
                            Text("Sí")
                                .font(CalmlyTypography.title)
                                .foregroundStyle(.black.opacity(0.8))
                                .padding(.horizontal, 20)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule(style: .continuous)
                                        .fill(
                                            LinearGradient(
                                                colors: [Color(hex: "B8A9E8"), Color(hex: "F5C6AA")],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                )
                        }
                        .buttonStyle(CalmlyPressStyle())

                        Button {
                            withAnimation(.easeOut(duration: 0.3)) {
                                homeVM.showAmbientBanner = false
                            }
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(.white.opacity(0.5))
                                .frame(width: 30, height: 30)
                        }
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Color(hex: "25253D").opacity(0.95))
                            .shadow(color: Color(hex: "B8A9E8").opacity(0.25), radius: 20, y: -4)
                    )
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .fullScreenCover(isPresented: $flow.isCrisisFlowActive) {
            CrisisFlowView()
                .environment(flow)
        }
    }
}

#Preview {
    HomeView()
        .environment(SessionFlowViewModel())
}
