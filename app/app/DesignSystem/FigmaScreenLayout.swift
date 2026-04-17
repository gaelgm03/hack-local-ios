import SwiftUI

struct FigmaScreenLayout<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        GeometryReader { geometry in
            ScrollView(.vertical, showsIndicators: false) {
                content
                    .frame(maxWidth: 430, alignment: .topLeading)
                    .padding(.horizontal, 20)
                    .frame(width: geometry.size.width, alignment: .top)
                    .padding(.top, 8)
                    .padding(.bottom, 24)
            }
        }
    }
}

struct FigmaBackButton: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Button(action: { dismiss() }) {
            Image(systemName: "chevron.left")
                .font(.system(size: 30, weight: .medium))
                .foregroundStyle(Color(hex: "222222"))
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Regresar")
    }
}

struct FigmaCloseButton: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Button(action: { dismiss() }) {
            Image(systemName: "xmark")
                .font(.system(size: 30, weight: .light))
                .foregroundStyle(Color(hex: "222222"))
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Cerrar")
    }
}
