import Foundation

/// Manages home screen state: ambient detection status, navigation triggers.
@Observable
final class HomeViewModel {
    var isAmbientLoud = false
    var showAmbientBanner = false

    // TODO: Wire AmbientSensorService
    // TODO: Navigation to CaptureView
}
