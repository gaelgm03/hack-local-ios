import AVFoundation
import Foundation

/// Monitors ambient noise level using AVAudioEngine.
/// Publishes dB readings; triggers a threshold alert when sustained noise is detected.
final class AmbientSensorService {
    var currentDB: Double = 0
    var isLoud = false
    var ambientNoiseLevel: Double = 0
    var onUpdate: ((Double, Double, Bool) -> Void)?

    private let audioEngine: AVAudioEngine
    private let audioSession: AVAudioSession
    private let loudThreshold: Double
    private let rollingWindowSize: Int
    private var rollingWindow: [Double] = []
    private var isMonitoring = false
    private var hasTapInstalled = false

    init(
        audioEngine: AVAudioEngine = AVAudioEngine(),
        audioSession: AVAudioSession = .sharedInstance(),
        loudThreshold: Double = 75,
        sustainedSeconds: Double = 3,
        samplesPerSecond: Double = 10
    ) {
        self.audioEngine = audioEngine
        self.audioSession = audioSession
        self.loudThreshold = loudThreshold
        self.rollingWindowSize = max(1, Int(sustainedSeconds * samplesPerSecond))
    }

    func startMonitoring() async {
        guard !isMonitoring else { return }

        let hasPermission = await requestMicrophonePermission()
        guard hasPermission else { return }

        do {
            try audioSession.setCategory(.record, mode: .measurement, options: [.mixWithOthers])
            try audioSession.setPreferredIOBufferDuration(0.1)
            try audioSession.setActive(true, options: [])
            installTapIfNeeded()
            audioEngine.prepare()
            try audioEngine.start()
            isMonitoring = true
        } catch {
            stopMonitoring()
        }
    }

    func stopMonitoring() {
        guard isMonitoring || hasTapInstalled else { return }

        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        hasTapInstalled = false
        isMonitoring = false
        rollingWindow.removeAll(keepingCapacity: true)
        currentDB = 0
        ambientNoiseLevel = 0
        isLoud = false
        onUpdate?(currentDB, ambientNoiseLevel, isLoud)

        do {
            try audioSession.setActive(false, options: [.notifyOthersOnDeactivation])
        } catch {
            // Ignore deactivation failures after monitoring has stopped.
        }
    }

    func forceLoudDemoReading(_ value: Double = 82) {
        currentDB = value
        ambientNoiseLevel = value
        isLoud = true
        rollingWindow = Array(repeating: value, count: rollingWindowSize)
        onUpdate?(currentDB, ambientNoiseLevel, isLoud)
    }

    private func installTapIfNeeded() {
        guard !hasTapInstalled else { return }

        let inputNode = audioEngine.inputNode
        let tapFormat = inputNode.outputFormat(forBus: 0)
        guard tapFormat.sampleRate > 0, tapFormat.channelCount > 0 else { return }

        let preferredBufferSize = max(1024, Int(tapFormat.sampleRate / 10))

        inputNode.installTap(
            onBus: 0,
            bufferSize: AVAudioFrameCount(preferredBufferSize),
            format: tapFormat
        ) { [weak self] buffer, _ in
            guard let self else { return }
            guard buffer.frameLength > 0 else { return }
            let decibels = Self.decibels(from: buffer)
            Task { @MainActor [weak self] in
                self?.applyMeterReading(decibels)
            }
        }

        hasTapInstalled = true
    }

    private func applyMeterReading(_ value: Double) {
        currentDB = value
        rollingWindow.append(value)
        if rollingWindow.count > rollingWindowSize {
            rollingWindow.removeFirst(rollingWindow.count - rollingWindowSize)
        }

        ambientNoiseLevel = rollingWindow.isEmpty
            ? value
            : rollingWindow.reduce(0, +) / Double(rollingWindow.count)
        isLoud = rollingWindow.count == rollingWindowSize && ambientNoiseLevel >= loudThreshold
        onUpdate?(currentDB, ambientNoiseLevel, isLoud)
    }

    private func requestMicrophonePermission() async -> Bool {
        await withCheckedContinuation { continuation in
            audioSession.requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
    }

    nonisolated private static func decibels(from buffer: AVAudioPCMBuffer) -> Double {
        guard let channelData = buffer.floatChannelData?[0] else { return 0 }
        let frameCount = Int(buffer.frameLength)
        guard frameCount > 0 else { return 0 }

        var sumSquares: Float = 0
        for frame in 0..<frameCount {
            let sample = channelData[frame]
            sumSquares += sample * sample
        }

        let rms = sqrt(sumSquares / Float(frameCount))
        let dbFS = 20 * log10(max(rms, 0.000_01))
        return max(0, min(120, Double(dbFS + 100)))
    }
}
