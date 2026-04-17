import SwiftUI

struct MapPlaceholderView: View {
    var body: some View {
        ZStack {
            Color(hex: "E8E8E8").ignoresSafeArea()
            VStack(spacing: 16) {
                Text("mapa")
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(hex: "222222"))
                Text("Pendiente de implementar según el diseño.")
                    .font(.system(size: 20, weight: .medium, design: .rounded))
                    .foregroundStyle(Color(hex: "343434"))
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        MapPlaceholderView()
    }
}
