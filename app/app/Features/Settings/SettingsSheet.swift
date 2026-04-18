import SwiftUI

struct SettingsSheet: View {
    @Environment(SessionFlowViewModel.self) private var flow
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section("Experiencia") {
                    Toggle("Modo demo offline", isOn: binding(\.demoModeEnabled))

                    Text(flow.demoModeEnabled
                         ? "Usa respuestas predefinidas para no depender de internet"
                         : "Usa el modelo real cuando haya API key y conexion.")
                        .font(CalmlyTypography.caption)
                        .foregroundStyle(.secondary)
                }

                Section("Producto") {
                    Text("Calmly prioriza una pausa inmediata y deja el contexto como paso opcional.")
                        .font(CalmlyTypography.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Ajustes")
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
