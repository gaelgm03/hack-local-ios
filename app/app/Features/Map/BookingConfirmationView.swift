import SwiftUI

struct BookingConfirmationView: View {
    @Environment(SessionFlowViewModel.self) private var flow
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            CalmlyColors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Button(flow.confirmedBooking == nil ? "Cambiar" : "Cerrar") {
                        if flow.confirmedBooking == nil {
                            dismiss()
                        } else {
                            flow.completeFlow()
                        }
                    }
                    .font(CalmlyTypography.body)
                    .foregroundStyle(CalmlyColors.textSecondary)

                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)

                Spacer()

                if let booking = flow.confirmedBooking ?? flow.pendingBooking {
                    VStack(spacing: 22) {
                        Text(flow.confirmedBooking == nil ? "Confirma tu cita" : "Cita apartada")
                            .font(CalmlyTypography.largeTitle)
                            .foregroundStyle(CalmlyColors.textPrimary)
                            .multilineTextAlignment(.center)

                        Text(flow.confirmedBooking == nil
                             ? "Ya resolvimos quien y cuando. Solo falta confirmar."
                             : "Tu siguiente paso ya quedo agendado. Calmly te acompa\u{00F1}a hasta aqui.")
                            .font(CalmlyTypography.body)
                            .foregroundStyle(CalmlyColors.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 28)

                        CalmlyCard {
                            Text(booking.specialistName)
                                .font(CalmlyTypography.title)
                                .foregroundStyle(CalmlyColors.textPrimary)

                            Text(booking.specialty)
                                .font(CalmlyTypography.body)
                                .foregroundStyle(CalmlyColors.textSecondary)
                                .padding(.top, 2)

                            Text("\(booking.modeTitle) - \(booking.location)")
                                .font(CalmlyTypography.caption)
                                .foregroundStyle(CalmlyColors.textSecondary)
                                .padding(.top, 6)

                            Text("Horario: \(booking.slot)")
                                .font(CalmlyTypography.body)
                                .foregroundStyle(CalmlyColors.textPrimary)
                                .padding(.top, 12)

                            Text("Costo: \(booking.price)")
                                .font(CalmlyTypography.caption)
                                .foregroundStyle(CalmlyColors.textSecondary)
                                .padding(.top, 4)
                        }
                        .padding(.horizontal, 24)
                    }
                }

                Spacer()

                if flow.confirmedBooking == nil {
                    CalmlyPrimaryButton(title: "Confirmar cita") {
                        flow.confirmBooking()
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 14)

                    Button("Volver a especialistas") {
                        dismiss()
                    }
                    .font(CalmlyTypography.body)
                    .foregroundStyle(CalmlyColors.textSecondary)
                    .buttonStyle(.plain)
                    .padding(.bottom, 40)
                } else {
                    CalmlyPrimaryButton(title: "Volver al inicio") {
                        flow.completeFlow()
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    let flow = SessionFlowViewModel()
    flow.pendingBooking = SpecialistBookingSelection(
        specialistName: "Dra. Elena Ruiz",
        specialty: "Ansiedad y regulacion emocional",
        modeTitle: "Online",
        location: "Online en todo Mexico",
        price: "$650 MXN",
        slot: "Hoy 6:30 PM"
    )

    return BookingConfirmationView()
        .environment(flow)
}
