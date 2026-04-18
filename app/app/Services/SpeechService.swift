import AVFoundation
import Foundation
import Speech

/// Short voice-to-text transcription (5 seconds) for optional user input.
final class SpeechService {
    enum SpeechServiceError: Error {
        case recognizerUnavailable
        case permissionsMissing
        case audioEngineFailed
    }

    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "es-MX"))
    private let audioEngine = AVAudioEngine()
    private let audioSession = AVAudioSession.sharedInstance()

    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var transcript = ""
    private var autoStopTask: Task<Void, Never>?

    func startListening() throws {
        guard recognizer?.isAvailable == true else {
            throw SpeechServiceError.recognizerUnavailable
        }

        guard hasSpeechPermissions else {
            throw SpeechServiceError.permissionsMissing
        }

        stopListening()

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        request.requiresOnDeviceRecognition = false
        recognitionRequest = request
        transcript = ""

        do {
            try audioSession.setCategory(.record, mode: .measurement, options: [.duckOthers])
            try audioSession.setActive(true, options: [])
        } catch {
            throw SpeechServiceError.audioEngineFailed
        }

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.removeTap(onBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
        }

        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            inputNode.removeTap(onBus: 0)
            throw SpeechServiceError.audioEngineFailed
        }

        recognitionTask = recognizer?.recognitionTask(with: request) { [weak self] result, _ in
            guard let self else { return }
            if let result {
                self.transcript = result.bestTranscription.formattedString
            }
        }

        autoStopTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 5_000_000_000)
            _ = self?.stopListening()
        }
    }

    @discardableResult
    func stopListening() -> String? {
        autoStopTask?.cancel()
        autoStopTask = nil

        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }

        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = nil

        do {
            try audioSession.setActive(false, options: [.notifyOthersOnDeactivation])
        } catch {
            // Ignore deactivation failures; the transcript has already been captured.
        }

        let finalTranscript = transcript.trimmingCharacters(in: .whitespacesAndNewlines)
        transcript = ""
        return finalTranscript.isEmpty ? nil : finalTranscript
    }

    private var hasSpeechPermissions: Bool {
        let speechStatus = SFSpeechRecognizer.authorizationStatus()
        let micStatus = audioSession.recordPermission
        return speechStatus == .authorized && micStatus == .granted
    }
}
