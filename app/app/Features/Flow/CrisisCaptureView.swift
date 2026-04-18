import SwiftUI
import UIKit

/// Context capture screen: user can type, record a short voice note, or attach one photo.
struct CrisisCaptureView: View {
    @Environment(SessionFlowViewModel.self) private var flow
    @State private var userText = ""
    @State private var capturedImage: UIImage?
    @State private var transcript: String?
    @State private var isCapturingPhoto = false
    @State private var isRecordingVoice = false
    @State private var cameraError: String?
    @State private var speechError: String?
    @State private var cameraService = CameraService()
    @State private var speechService = SpeechService()
    @FocusState private var isFocused: Bool
    @State private var isSubmitting = false
    @State private var recordingTask: Task<Void, Never>?

    var body: some View {
        ZStack {
            CalmlyColors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Button {
                        flow.completeFlow()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundStyle(CalmlyColors.textSecondary)
                            .frame(width: 44, height: 44)
                    }

                    Spacer()

                    Button("Omitir") {
                        flow.skipCapture()
                    }
                    .font(CalmlyTypography.body)
                    .foregroundStyle(CalmlyColors.textSecondary)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)

                Spacer()

                VStack(spacing: 24) {
                    Text("Agregar contexto opcional")
                        .font(CalmlyTypography.largeTitle)
                        .foregroundStyle(CalmlyColors.textPrimary)
                        .multilineTextAlignment(.center)

                    Text("Si te ayuda, puedes escribir, grabar 5 segundos o tomar una foto del entorno. Si no, seguimos sin esto.")
                        .font(CalmlyTypography.body)
                        .foregroundStyle(CalmlyColors.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 32)

                Spacer()

                VStack(spacing: 20) {
                    HStack(spacing: 12) {
                        Button {
                            dismissTextInput()
                            Task { await capturePhoto() }
                        } label: {
                            Label(isCapturingPhoto ? "Tomando foto..." : photoButtonTitle, systemImage: "camera")
                                .font(CalmlyTypography.body)
                                .foregroundStyle(CalmlyColors.textPrimary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(CalmlyColors.surface)
                                )
                        }
                        .buttonStyle(.plain)
                        .disabled(isCapturingPhoto || isSubmitting)

                        Button {
                            dismissTextInput()
                            Task { await toggleVoiceCapture() }
                        } label: {
                            Label(
                                isRecordingVoice ? "Grabando..." : voiceButtonTitle,
                                systemImage: isRecordingVoice ? "waveform.circle.fill" : "mic"
                            )
                            .font(CalmlyTypography.body)
                            .foregroundStyle(CalmlyColors.textPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(CalmlyColors.surface)
                            )
                        }
                        .buttonStyle(.plain)
                        .disabled(isSubmitting)
                    }

                    if let image = capturedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity)
                            .frame(height: 132)
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    }

                    if let transcript, !transcript.isEmpty {
                        CalmlyCard {
                            Text("Transcripción")
                                .font(CalmlyTypography.caption)
                                .foregroundStyle(CalmlyColors.textSecondary)

                            Text(transcript)
                                .font(CalmlyTypography.body)
                                .foregroundStyle(CalmlyColors.textPrimary)
                                .padding(.top, 4)
                        }
                    }

                    if let cameraError {
                        Text(cameraError)
                            .font(CalmlyTypography.caption)
                            .foregroundStyle(.red.opacity(0.85))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    if let speechError {
                        Text(speechError)
                            .font(CalmlyTypography.caption)
                            .foregroundStyle(.red.opacity(0.85))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    ZStack(alignment: .topLeading) {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(CalmlyColors.surface)

                        if userText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            Text("Estoy...")
                                .font(CalmlyTypography.empathyMessage)
                                .foregroundStyle(CalmlyColors.textSecondary)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 24)
                                .allowsHitTesting(false)
                        }

                        TextEditor(text: $userText)
                            .font(CalmlyTypography.empathyMessage)
                            .foregroundStyle(CalmlyColors.textPrimary)
                            .scrollContentBackground(.hidden)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 14)
                            .frame(minHeight: 120)
                            .focused($isFocused)
                            .autocorrectionDisabled(true)
                            .textInputAutocapitalization(.sentences)
                            .disabled(isRecordingVoice)
                    }

                    CalmlyPrimaryButton(title: "Continuar con guía") {
                        submitCapture()
                    }
                    .opacity(isSubmitting ? 0.7 : 1.0)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .navigationBarBackButtonHidden(true)
        .onDisappear {
            dismissTextInput()
            recordingTask?.cancel()
            recordingTask = nil

            if isRecordingVoice {
                transcript = speechService.stopListening()
                isRecordingVoice = false
            }
        }
    }

    private var photoButtonTitle: String {
        capturedImage == nil ? "Tomar foto" : "Actualizar foto"
    }

    private var voiceButtonTitle: String {
        transcript == nil ? "Grabar voz" : "Volver a grabar"
    }

    private func capturePhoto() async {
        isCapturingPhoto = true
        cameraError = nil

        let image = await cameraService.capturePhoto()
        if let image {
            capturedImage = image
        } else {
            cameraError = "No pude usar la cámara. Puedes seguir con texto o voz."
        }

        isCapturingPhoto = false
    }

    private func toggleVoiceCapture() async {
        speechError = nil

        if isRecordingVoice {
            recordingTask?.cancel()
            recordingTask = nil
            transcript = speechService.stopListening()
            isRecordingVoice = false
            return
        }

        let permissionsGranted = await speechService.requestPermissionsIfNeeded()
        guard permissionsGranted else {
            speechError = "No pude acceder al micrófono o al reconocimiento de voz."
            return
        }

        do {
            try speechService.startListening()
            isRecordingVoice = true

            recordingTask?.cancel()
            recordingTask = Task { @MainActor in
                do {
                    try await Task.sleep(nanoseconds: 5_200_000_000)
                } catch {
                    return
                }

                guard isRecordingVoice else { return }
                transcript = speechService.stopListening()
                isRecordingVoice = false
                recordingTask = nil
            }
        } catch SpeechService.SpeechServiceError.invalidAudioFormat {
            speechError = "No encontré una entrada de audio válida. Prueba en un dispositivo físico."
            isRecordingVoice = false
        } catch {
            speechError = "No pude iniciar la grabación. Puedes continuar con texto."
            isRecordingVoice = false
        }
    }

    private func submitCapture() {
        guard !isSubmitting else { return }
        isSubmitting = true
        dismissTextInput()

        if isRecordingVoice {
            recordingTask?.cancel()
            recordingTask = nil
            transcript = speechService.stopListening()
            isRecordingVoice = false
        }

        let textToSubmit = userText
        let transcriptToSubmit = transcript
        let imageToSubmit = capturedImage

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 200_000_000)
            flow.submitCapture(text: textToSubmit, transcript: transcriptToSubmit, image: imageToSubmit)
            isSubmitting = false
        }
    }

    private func dismissTextInput() {
        isFocused = false
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    CrisisCaptureView()
        .environment(SessionFlowViewModel())
}
