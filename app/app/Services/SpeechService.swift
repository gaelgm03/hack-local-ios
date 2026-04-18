import AVFoundation
import Foundation
import Speech

/// Short voice-to-text transcription (5 seconds) for optional user input.
final class SpeechService {
    enum SpeechServiceError: Error {
        case recognizerUnavailable
        case permissionsMissing
        case audioEngineFailed
        case invalidAudioFormat
    }

    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "es-MX"))
    private let audioEngine = AVAudioEngine()
    private let audioSession = AVAudioSession.sharedInstance()

    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var transcript = ""
    private var autoStopTask: Task<Void, Never>?
    private var isListening = false

    func requestPermissionsIfNeeded() async -> Bool {
        let speechAuthorized = await requestSpeechAuthorizationIfNeeded()
        guard speechAuthorized else { return false }
        return await requestMicrophoneAuthorizationIfNeeded()
    }

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
        request.requiresOnDeviceRecognition = recognizer?.supportsOnDeviceRecognition == true
        recognitionRequest = request
        isListening = true
        transcript = ""

        do {
            try audioSession.setCategory(.record, mode: .measurement, options: [.duckOthers])
            try audioSession.setActive(true, options: [])
        } catch {
            throw SpeechServiceError.audioEngineFailed
        }

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        guard recordingFormat.sampleRate > 0, recordingFormat.channelCount > 0 else {
            throw SpeechServiceError.invalidAudioFormat
        }

        inputNode.removeTap(onBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            guard let self else { return }
            guard self.isListening, self.recognitionRequest === request else { return }
            guard Self.hasNonEmptyAudioData(buffer) else { return }
            request.append(buffer)
        }

        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            inputNode.removeTap(onBus: 0)
            throw SpeechServiceError.audioEngineFailed
        }

        recognitionTask = recognizer?.recognitionTask(with: request) { [weak self] result, error in
            guard let self else { return }
            if let result {
                self.transcript = result.bestTranscription.formattedString
            }
            if result?.isFinal == true || error != nil {
                self.isListening = false
            }
        }

        autoStopTask = Task { [weak self] in
            do {
                try await Task.sleep(nanoseconds: 5_000_000_000)
            } catch {
                return
            }
            guard !Task.isCancelled else { return }
            _ = self?.stopListening()
        }
    }

    @discardableResult
    func stopListening() -> String? {
        autoStopTask?.cancel()
        autoStopTask = nil
        isListening = false

        if audioEngine.isRunning {
            audioEngine.inputNode.removeTap(onBus: 0)
            audioEngine.stop()
        }

        let activeRequest = recognitionRequest
        let activeTask = recognitionTask
        recognitionRequest = nil
        recognitionTask = nil

        activeRequest?.endAudio()
        activeTask?.cancel()

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
        return speechStatus == .authorized && microphonePermission == .granted
    }

    private func requestSpeechAuthorizationIfNeeded() async -> Bool {
        switch SFSpeechRecognizer.authorizationStatus() {
        case .authorized:
            return true
        case .notDetermined:
            return await withCheckedContinuation { continuation in
                SFSpeechRecognizer.requestAuthorization { status in
                    continuation.resume(returning: status == .authorized)
                }
            }
        default:
            return false
        }
    }

    private func requestMicrophoneAuthorizationIfNeeded() async -> Bool {
        switch microphonePermission {
        case .granted:
            return true
        case .undetermined:
            return await withCheckedContinuation { continuation in
                requestMicrophonePermission { granted in
                    continuation.resume(returning: granted)
                }
            }
        default:
            return false
        }
    }

    private var microphonePermission: MicrophonePermission {
        switch AVAudioApplication.shared.recordPermission {
        case .granted:
            return .granted
        case .undetermined:
            return .undetermined
        default:
            return .denied
        }
    }

    private func requestMicrophonePermission(_ completion: @escaping (Bool) -> Void) {
        AVAudioApplication.requestRecordPermission(completionHandler: completion)
    }

    private static func hasNonEmptyAudioData(_ buffer: AVAudioPCMBuffer) -> Bool {
        let audioBuffers = UnsafeMutableAudioBufferListPointer(buffer.mutableAudioBufferList)
        return audioBuffers.contains { audioBuffer in
            audioBuffer.mData != nil && audioBuffer.mDataByteSize > 0
        }
    }
}

private enum MicrophonePermission {
    case granted
    case undetermined
    case denied
}
