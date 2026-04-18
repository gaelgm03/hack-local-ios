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
        VStack(spacing: 18) {
            Text("calmly")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundStyle(primaryTextColor.opacity(0.9))
                .tracking(0.8)

            Text("30 segundos")
                .font(CalmlyTypography.caption)
                .foregroundStyle(primaryTextColor.opacity(0.72))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    Capsule(style: .continuous)
                        .fill(lightMode ? .white.opacity(0.72) : .white.opacity(0.08))
                )

            Text("Una pausa clara en el peor minuto.")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundStyle(primaryTextColor)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 28)

            Text("Entra, respira y vuelve a tomar control sin convertir la ayuda en otra tarea.")
                .font(CalmlyTypography.body)
                .foregroundStyle(primaryTextColor.opacity(0.72))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            if flow.demoModeEnabled {
                Text("Modo demo activo")
                    .font(CalmlyTypography.caption)
                    .foregroundStyle(primaryTextColor)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        Capsule(style: .continuous)
                            .fill(Color(hex: "F5C6AA").opacity(lightMode ? 0.5 : 0.24))
                    )
            }
        }
        .padding(.top, 34)
    }

    private var actionPanel: some View {
        VStack(spacing: 16) {
            Button {
                flow.startImmediatePauseFlow()
            } label: {
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(lightMode ? 0.86 : 0.12))
                            .frame(width: 68, height: 68)

                        Image(systemName: "wind")
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundStyle(primaryTextColor)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Necesito una pausa")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.black.opacity(0.82))
                            .lineLimit(2)
                            .minimumScaleFactor(0.84)

                        Text("Empieza ahora")
                            .font(CalmlyTypography.body)
                            .foregroundStyle(Color.black.opacity(0.62))
                    }

                    Spacer()

                    Image(systemName: "arrow.right")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color.black.opacity(0.62))
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
                .background(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "EAA8EE"), Color(hex: "F5C6AA")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .shadow(color: Color(hex: "B8A9E8").opacity(lightMode ? 0.14 : 0.24), radius: 24, y: 10)
            }
            .buttonStyle(.plain)

            Button {
                flow.startCrisisFlow()
            } label: {
                HStack(alignment: .center, spacing: 14) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Agregar contexto opcional")
                            .font(CalmlyTypography.body)
                            .foregroundStyle(primaryTextColor)

                        Text("Texto, voz o imagen si ayuda a personalizar")
                            .font(CalmlyTypography.caption)
                            .foregroundStyle(primaryTextColor.opacity(0.62))
                    }

                    Spacer()

                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(primaryTextColor.opacity(0.8))
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(lightMode ? .white.opacity(0.74) : .white.opacity(0.06))
                        .overlay(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .stroke(primaryTextColor.opacity(0.12), lineWidth: 1)
                        )
                )
            }
            .buttonStyle(.plain)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(lightMode ? .white.opacity(0.18) : .white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .stroke(primaryTextColor.opacity(0.08), lineWidth: 1)
                )
        )
    }

    private var primaryTextColor: Color {
        lightMode ? Color(hex: "222222") : .white
    }
}

#Preview {
    HomeView()
        .environment(SessionFlowViewModel())
}
