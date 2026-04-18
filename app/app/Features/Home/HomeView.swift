import SwiftUI

struct HomeView: View {
    @Environment(SessionFlowViewModel.self) private var flow
    @State private var lightMode = false
    @State private var homeVM = HomeViewModel()
    @State private var showSettings = false

    var body: some View {
        @Bindable var flow = flow

        NavigationStack {
            ZStack {
                (lightMode ? Color(hex: "E8E8E8") : Color(hex: "262626"))
                    .ignoresSafeArea()

                VStack(alignment: .leading) {
                    HStack {
                        Button {
                            showSettings = true
                        } label: {
                            Label("Demo", systemImage: "slider.horizontal.3")
                                .font(CalmlyTypography.body)
                                .foregroundStyle(lightMode ? Color(hex: "222222") : .white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(
                                    Capsule(style: .continuous)
                                        .fill(lightMode ? .white : .white.opacity(0.08))
                                )
                        }
                        .buttonStyle(.plain)

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

                    VStack(alignment: .leading, spacing: 18) {
                        Text("calmly")
                            .font(.system(size: 62, weight: .bold, design: .rounded))
                            .foregroundStyle(lightMode ? Color(hex: "222222") : .white)

                        Text("Una pausa guiada en el momento en que lo necesitas.")
                            .font(CalmlyTypography.body)
                            .foregroundStyle((lightMode ? Color(hex: "222222") : .white).opacity(0.72))
                            .frame(maxWidth: 260, alignment: .leading)

                        if flow.demoModeEnabled {
                            Text("Modo demo activo")
                                .font(CalmlyTypography.caption)
                                .foregroundStyle(lightMode ? Color(hex: "222222") : .white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule(style: .continuous)
                                        .fill(Color(hex: "F5C6AA").opacity(lightMode ? 0.55 : 0.28))
                                )
                        }
                    }
                    .padding(.leading, 36)
                    .padding(.top, 90)

                    Spacer()

                    VStack(spacing: 16) {
                        Button {
                            homeVM.dismissAmbientBanner()
                            flow.startImmediatePauseFlow()
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

                        Text("Necesito una pausa")
                            .font(.system(size: 42, weight: .bold, design: .rounded))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(Color(hex: "F09AF3"))
                            .padding(.horizontal, 32)

                        Text("Empieza ahora. Si quieres, luego la personalizamos.")
                            .font(CalmlyTypography.body)
                            .foregroundStyle((lightMode ? Color(hex: "222222") : .white).opacity(0.68))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 36)

                        Button {
                            homeVM.dismissAmbientBanner()
                            flow.startCrisisFlow()
                        } label: {
                            Text("Agregar contexto opcional")
                                .font(CalmlyTypography.body)
                                .foregroundStyle(lightMode ? Color(hex: "222222") : .white)
                                .padding(.horizontal, 18)
                                .padding(.vertical, 12)
                                .background(
                                    Capsule(style: .continuous)
                                        .stroke((lightMode ? Color(hex: "222222") : .white).opacity(0.22), lineWidth: 1)
                                        .background(
                                            Capsule(style: .continuous)
                                                .fill(lightMode ? .white.opacity(0.72) : .white.opacity(0.07))
                                        )
                                )
                        }
                        .buttonStyle(.plain)
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

                        Text("Parece ruidoso aquí. ¿Pausa de 30s?")
                            .font(CalmlyTypography.body)
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.leading)

                        Spacer()

                        Button {
                            withAnimation(.easeOut(duration: 0.3)) {
                                homeVM.dismissAmbientBanner()
                            }
                            flow.startAmbientCrisisFlow(noiseLevel: homeVM.ambientNoiseLevel)
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
                                homeVM.dismissAmbientBanner()
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
        .task {
            await homeVM.startMonitoring()
        }
        .onDisappear {
            homeVM.stopMonitoring()
        }
        .onChange(of: flow.isCrisisFlowActive) { _, isActive in
            if isActive {
                homeVM.stopMonitoring()
            } else {
                Task {
                    await homeVM.startMonitoring()
                }
            }
        }
        .fullScreenCover(isPresented: $flow.isCrisisFlowActive, onDismiss: {
            flow.resetDismissedFlow()
        }) {
            CrisisFlowView()
                .environment(flow)
        }
        .sheet(isPresented: $showSettings) {
            SettingsSheet()
                .presentationDetents([.fraction(0.45)])
                .presentationDragIndicator(.visible)
                .environment(flow)
        }
    }
}

#Preview {
    HomeView()
        .environment(SessionFlowViewModel())
}
