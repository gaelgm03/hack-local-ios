import Foundation
import Observation

/// Manages home screen state: ambient detection status, navigation triggers.
@Observable
final class HomeViewModel {
    var isAmbientLoud = false
    var showAmbientBanner = false
    var currentDB: Double = 0
    var ambientNoiseLevel: Double = 0
    var demoForceAmbientBanner: Bool

    private let ambientSensorService: AmbientSensorService

    init(
        ambientSensorService: AmbientSensorService = AmbientSensorService(),
        demoForceAmbientBanner: Bool = false
    ) {
        self.ambientSensorService = ambientSensorService
        self.demoForceAmbientBanner = demoForceAmbientBanner

        ambientSensorService.onUpdate = { [weak self] currentDB, ambientNoiseLevel, isLoud in
            self?.handleAmbientUpdate(
                currentDB: currentDB,
                ambientNoiseLevel: ambientNoiseLevel,
                isLoud: isLoud
            )
        }
    }

    func startMonitoring() async {
        if demoForceAmbientBanner {
            ambientSensorService.forceLoudDemoReading()
        }
        await ambientSensorService.startMonitoring()
    }

    func stopMonitoring() {
        ambientSensorService.stopMonitoring()
    }

    func dismissAmbientBanner() {
        showAmbientBanner = false
    }

    private func handleAmbientUpdate(currentDB: Double, ambientNoiseLevel: Double, isLoud: Bool) {
        let wasLoud = isAmbientLoud

        self.currentDB = currentDB
        self.ambientNoiseLevel = ambientNoiseLevel
        self.isAmbientLoud = isLoud

        if isLoud && !wasLoud {
            showAmbientBanner = true
        }
    }
}
