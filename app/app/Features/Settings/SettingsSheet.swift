import SwiftUI

struct SettingsSheet: View {
    @Environment(SessionFlowViewModel.self) private var flow
    @Environment(\.dismiss) private var dismiss
    @State private var ambientDetectionEnabled = true

    var body: some View {
        NavigationStack {
            List {
                Section("Demo") {
                    Toggle("Modo demo offline", isOn: binding(\.demoModeEnabled))

                    Text(flow.demoModeEnabled
                         ? "Usa respuestas predefinidas para no depender de internet en escenario."
                         : "Usa el modelo real cuando haya API key y conexión.")
                        .font(CalmlyTypography.caption)
                        .foregroundStyle(.secondary)
                }

                Section("Escenario") {
                    Toggle("Detección ambiental", isOn: $ambientDetectionEnabled)
                        .disabled(true)

                    Text("La escucha ambiental sigue activa en Home y queda visible aquí para el pitch.")
                        .font(CalmlyTypography.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Demo y ajustes")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func binding<Value>(_ keyPath: ReferenceWritableKeyPath<SessionFlowViewModel, Value>) -> Binding<Value> {
        Binding(
            get: { flow[keyPath: keyPath] },
            set: { flow[keyPath: keyPath] = $0 }
        )
    }
}
