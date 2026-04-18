import AVFoundation
import Foundation
import UIKit

/// Captures a single camera frame for context analysis.
final class CameraService {
    private let sessionQueue = DispatchQueue(label: "calmly.camera.session")
    private var captureSession: AVCaptureSession?
    private var photoOutput: AVCapturePhotoOutput?
    private var activeProcessor: PhotoCaptureProcessor?

    func capturePhoto() async -> UIImage? {
        let hasPermission = await requestCameraPermission()
        guard hasPermission else { return nil }

        return await withCheckedContinuation { continuation in
            sessionQueue.async { [weak self] in
                self?.captureSingleFrame(continuation: continuation)
            }
        }
    }

    private func captureSingleFrame(continuation: CheckedContinuation<UIImage?, Never>) {
        let session = AVCaptureSession()
        session.beginConfiguration()
        session.sessionPreset = .photo

        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: camera),
              session.canAddInput(input) else {
            session.commitConfiguration()
            continuation.resume(returning: nil)
            return
        }

        let output = AVCapturePhotoOutput()
        guard session.canAddOutput(output) else {
            session.commitConfiguration()
            continuation.resume(returning: nil)
            return
        }

        session.addInput(input)
        session.addOutput(output)
        session.commitConfiguration()

        captureSession = session
        photoOutput = output

        let processor = PhotoCaptureProcessor { [weak self] image in
            self?.sessionQueue.async {
                self?.captureSession?.stopRunning()
                self?.captureSession = nil
                self?.photoOutput = nil
                self?.activeProcessor = nil
                continuation.resume(returning: image)
            }
        }

        activeProcessor = processor
        session.startRunning()
        output.capturePhoto(with: AVCapturePhotoSettings(), delegate: processor)
    }

    private func requestCameraPermission() async -> Bool {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            return true
        case .notDetermined:
            return await withCheckedContinuation { continuation in
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    continuation.resume(returning: granted)
                }
            }
        default:
            return false
        }
    }
}

private final class PhotoCaptureProcessor: NSObject, AVCapturePhotoCaptureDelegate {
    private let completion: (UIImage?) -> Void

    init(completion: @escaping (UIImage?) -> Void) {
        self.completion = completion
    }

    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        guard error == nil,
              let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else {
            completion(nil)
            return
        }

        completion(image)
    }
}
