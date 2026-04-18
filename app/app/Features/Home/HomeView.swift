import SwiftUI

struct HomeView: View {
    @Environment(SessionFlowViewModel.self) private var flow
    @State private var lightMode = false
    @State private var showSettings = false

    var body: some View {
        @Bindable var flow = flow

        NavigationStack {
            ZStack {
                backgroundLayer

                VStack(spacing: 0) {
                    topBar

                    Spacer(minLength: 24)

                    hero

                    Spacer()

                    actionPanel
                        .padding(.horizontal, 20)
                        .padding(.bottom, 44)
                }
            }
            .navigationBarHidden(true)
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

    private var backgroundLayer: some View {
        ZStack {
            (lightMode ? Color(hex: "ECE9E4") : Color(hex: "171727"))
                .ignoresSafeArea()

            RadialGradient(
                colors: [
                    Color(hex: "F5C6AA").opacity(lightMode ? 0.22 : 0.12),
                    Color.clear
                ],
                center: .topLeading,
                startRadius: 20,
                endRadius: 320
            )
            .ignoresSafeArea()

            RadialGradient(
                colors: [
                    Color(hex: "B8A9E8").opacity(lightMode ? 0.28 : 0.18),
                    Color.clear
                ],
                center: .bottomTrailing,
                startRadius: 10,
                endRadius: 360
            )
            .ignoresSafeArea()
        }
    }

    private var topBar: some View {
        HStack {
            Button {
                showSettings = true
            } label: {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(primaryTextColor)
                    .frame(width: 46, height: 46)
                    .background(
                        Circle()
                            .fill(lightMode ? .white.opacity(0.82) : .white.opacity(0.08))
                    )
            }
            .buttonStyle(.plain)

            Spacer()

            Circle()
                .fill(lightMode ? Color(hex: "3A383B") : Color(hex: "D9D9D9"))
                .frame(width: 54, height: 54)
                .overlay {
                    Image(systemName: lightMode ? "moon.stars.fill" : "sun.max.fill")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(lightMode ? .white : Color(hex: "262626"))
                }
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        lightMode.toggle()
                    }
                }
        }
        .padding(.horizontal, 24)
        .padding(.top, 18)
    }

    private var hero: some View {
        VStack(spacing: 10) {
            Text("calmly")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(primaryTextColor.opacity(0.9))
                .tracking(0.8)

            Text("Recupera control en 30 segundos.")
                .font(CalmlyTypography.body)
                .foregroundStyle(primaryTextColor.opacity(0.72))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 56)
        }
        .padding(.top, 34)
    }

    private var actionPanel: some View {
        VStack(spacing: 24) {
            Button {
                flow.startImmediatePauseFlow()
            } label: {
                VStack(spacing: 18) {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "EAA8EE"), Color(hex: "F5C6AA")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 220, height: 220)
                        .overlay {
                            Image(lightMode ? "CalmlyMascotDark" : "CalmlyMascotLight")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 176, height: 176)
                                .clipShape(Circle())
                        }
                        .overlay {
                            Circle()
                                .stroke(Color.white.opacity(lightMode ? 0.42 : 0.18), lineWidth: 1)
                        }
                        .shadow(color: Color(hex: "B8A9E8").opacity(lightMode ? 0.12 : 0.22), radius: 30, y: 14)

                    Text("Necesito una pausa")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(primaryTextColor)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Button {
                flow.startCrisisFlow()
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(primaryTextColor.opacity(0.8))

                    Text("Agregar contexto")
                        .font(CalmlyTypography.body)
                        .foregroundStyle(primaryTextColor)
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 14)
                .background(
                    Capsule(style: .continuous)
                        .fill(lightMode ? .white.opacity(0.74) : .white.opacity(0.06))
                        .overlay(
                            Capsule(style: .continuous)
                                .stroke(primaryTextColor.opacity(0.12), lineWidth: 1)
                        )
                )
            }
            .buttonStyle(.plain)
        }
    }

    private var primaryTextColor: Color {
        lightMode ? Color(hex: "222222") : .white
    }
}

#Preview {
    HomeView()
        .environment(SessionFlowViewModel())
}
