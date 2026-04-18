import SwiftUI

struct MapPlaceholderView: View {
    @Environment(SessionFlowViewModel.self) private var flow
    @State private var selectedFilter: SpecialistModeFilter = .all
    @State private var selectedSpecialistID: UUID?
    @State private var selectedSlot: String?

    private let specialists: [SpecialistCardModel] = [
        SpecialistCardModel(
            name: "Dra. Elena Ruiz",
            specialty: "Ansiedad y regulacion emocional",
            mode: .online,
            city: "Online en todo Mexico",
            price: "$650 MXN",
            availability: "Disponible hoy",
            slots: ["Hoy 6:30 PM", "Hoy 8:00 PM", "Manana 9:00 AM"]
        ),
        SpecialistCardModel(
            name: "Lic. Marco Alvarez",
            specialty: "Crisis aguda y primer contacto",
            mode: .inPerson,
            city: "Roma Norte, CDMX",
            price: "$700 MXN",
            availability: "Presencial hoy",
            slots: ["Hoy 5:00 PM", "Hoy 7:15 PM", "Sab 11:00 AM"]
        ),
        SpecialistCardModel(
            name: "Mtra. Sofia Torres",
            specialty: "Burnout, presion y trabajo",
            mode: .online,
            city: "Online con video",
            price: "$620 MXN",
            availability: "Mismo dia",
            slots: ["Hoy 4:45 PM", "Manana 12:30 PM", "Manana 6:00 PM"]
        ),
        SpecialistCardModel(
            name: "Dr. Javier Mena",
            specialty: "Acompa\u{00F1}amiento presencial",
            mode: .inPerson,
            city: "San Pedro, Monterrey",
            price: "$780 MXN",
            availability: "Proximo espacio",
            slots: ["Manana 10:00 AM", "Manana 1:30 PM", "Lun 5:30 PM"]
        )
    ]

    var body: some View {
        ZStack(alignment: .bottom) {
            CalmlyColors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                header

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        intro
                        filterChips

                        ForEach(filteredSpecialists) { specialist in
                            specialistCard(for: specialist)
                        }

                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 120)
                }
            }

            footer
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        HStack {
            Text("Especialistas")
                .font(CalmlyTypography.title)
                .foregroundStyle(CalmlyColors.textPrimary)

            Spacer()

            Button("Cerrar") {
                flow.completeFlow()
            }
            .font(CalmlyTypography.body)
            .foregroundStyle(CalmlyColors.textSecondary)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
    }

    private var intro: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Elige con qui\u{00E9}n hablar ahora")
                .font(CalmlyTypography.largeTitle)
                .foregroundStyle(CalmlyColors.textPrimary)
        }
    }

    private var filterChips: some View {
        HStack(spacing: 10) {
            ForEach(SpecialistModeFilter.allCases, id: \.self) { filter in
                Button {
                    selectedFilter = filter
                } label: {
                    Text(filter.title)
                        .font(CalmlyTypography.caption)
                        .foregroundStyle(selectedFilter == filter ? Color.black.opacity(0.8) : CalmlyColors.textPrimary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(
                            Capsule(style: .continuous)
                                .fill(selectedFilter == filter ? AnyShapeStyle(CalmlyColors.primaryGradient) : AnyShapeStyle(CalmlyColors.surface))
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func specialistCard(for specialist: SpecialistCardModel) -> some View {
        let isSelected = specialist.id == selectedSpecialistID

        return VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 14) {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "B8A9E8"), Color(hex: "F5C6AA")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 52, height: 52)
                    .overlay {
                        Text(specialist.initials)
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.black.opacity(0.75))
                    }

                VStack(alignment: .leading, spacing: 6) {
                    Text(specialist.name)
                        .font(CalmlyTypography.title)
                        .foregroundStyle(CalmlyColors.textPrimary)

                    Text(specialist.specialty)
                        .font(CalmlyTypography.body)
                        .foregroundStyle(CalmlyColors.textSecondary)

                    Text(specialist.city)
                        .font(CalmlyTypography.caption)
                        .foregroundStyle(CalmlyColors.textSecondary.opacity(0.9))
                }

                Spacer()
            }

            HStack(spacing: 10) {
                infoBadge(title: specialist.mode.title)
                infoBadge(title: specialist.availability)
                infoBadge(title: specialist.price)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Horarios cercanos")
                    .font(CalmlyTypography.caption)
                    .foregroundStyle(CalmlyColors.textSecondary)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(specialist.slots, id: \.self) { slot in
                            let isSlotSelected = isSelected && selectedSlot == slot

                            Button {
                                selectedSpecialistID = specialist.id
                                selectedSlot = slot
                            } label: {
                                Text(slot)
                                    .font(CalmlyTypography.caption)
                                    .foregroundStyle(isSlotSelected ? Color.black.opacity(0.8) : CalmlyColors.textPrimary)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 10)
                                    .background(
                                        Capsule(style: .continuous)
                                            .fill(isSlotSelected ? AnyShapeStyle(CalmlyColors.primaryGradient) : AnyShapeStyle(CalmlyColors.background.opacity(0.55)))
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }

            Button {
                selectedSpecialistID = specialist.id
                selectedSlot = selectedSlotForSpecialist(specialist) ?? specialist.slots.first
            } label: {
                Text(isSelected ? "Elegido para reservar" : "Reservar")
                    .font(CalmlyTypography.body)
                    .foregroundStyle(isSelected ? Color.black.opacity(0.8) : CalmlyColors.textPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(isSelected ? AnyShapeStyle(CalmlyColors.primaryGradient) : AnyShapeStyle(CalmlyColors.background.opacity(0.5)))
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(CalmlyColors.surface.opacity(isSelected ? 1.0 : 0.92))
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(
                            isSelected ? Color(hex: "F5C6AA").opacity(0.85) : Color.white.opacity(0.05),
                            lineWidth: isSelected ? 1.4 : 1
                        )
                )
        )
    }

    private func infoBadge(title: String) -> some View {
        Text(title)
            .font(CalmlyTypography.caption)
            .foregroundStyle(CalmlyColors.textPrimary)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(
                Capsule(style: .continuous)
                    .fill(CalmlyColors.background.opacity(0.45))
            )
    }

    private var footer: some View {
        VStack(spacing: 10) {
            if let summary = selectionSummary {
                Text(summary)
                    .font(CalmlyTypography.caption)
                    .foregroundStyle(CalmlyColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 28)
            }

            CalmlyPrimaryButton(title: selectedSpecialistID == nil ? "Volver al inicio" : "Seguir con esta opcion") {
                continueToConfirmation()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .padding(.top, 14)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [Color.clear, CalmlyColors.background.opacity(0.92), CalmlyColors.background],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    private var filteredSpecialists: [SpecialistCardModel] {
        specialists.filter { specialist in
            switch selectedFilter {
            case .all:
                return true
            case .online:
                return specialist.mode == .online
            case .inPerson:
                return specialist.mode == .inPerson
            }
        }
    }

    private var selectionSummary: String? {
        guard let specialist = specialists.first(where: { $0.id == selectedSpecialistID }),
              let slot = selectedSlotForSpecialist(specialist) else {
            return nil
        }

        return "\(specialist.name) - \(slot)"
    }

    private func selectedSlotForSpecialist(_ specialist: SpecialistCardModel) -> String? {
        guard specialist.id == selectedSpecialistID else { return nil }

        if let selectedSlot, specialist.slots.contains(selectedSlot) {
            return selectedSlot
        }

        return specialist.slots.first
    }

    private func continueToConfirmation() {
        guard let specialist = specialists.first(where: { $0.id == selectedSpecialistID }),
              let slot = selectedSlotForSpecialist(specialist) else {
            flow.completeFlow()
            return
        }

        flow.selectBooking(
            SpecialistBookingSelection(
                specialistName: specialist.name,
                specialty: specialist.specialty,
                modeTitle: specialist.mode.title,
                location: specialist.city,
                price: specialist.price,
                slot: slot
            )
        )
        flow.showBookingConfirmation()
    }
}

private enum SpecialistModeFilter: CaseIterable {
    case all
    case online
    case inPerson

    var title: String {
        switch self {
        case .all:
            return "Todos"
        case .online:
            return "Online"
        case .inPerson:
            return "Presencial"
        }
    }
}

private enum SpecialistMode {
    case online
    case inPerson

    var title: String {
        switch self {
        case .online:
            return "Online"
        case .inPerson:
            return "Presencial"
        }
    }
}

private struct SpecialistCardModel: Identifiable {
    let id = UUID()
    let name: String
    let specialty: String
    let mode: SpecialistMode
    let city: String
    let price: String
    let availability: String
    let slots: [String]

    var initials: String {
        name
            .split(separator: " ")
            .prefix(2)
            .compactMap { $0.first }
            .map(String.init)
            .joined()
            .uppercased()
    }
}

#Preview {
    NavigationStack {
        MapPlaceholderView()
            .environment(SessionFlowViewModel())
    }
}
