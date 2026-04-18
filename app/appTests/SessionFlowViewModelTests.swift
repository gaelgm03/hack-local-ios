import XCTest
import UIKit
@testable import app

@MainActor
final class SessionFlowViewModelTests: XCTestCase {

    private var sut: SessionFlowViewModel!

    override func setUp() {
        super.setUp()
        sut = SessionFlowViewModel()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - startCrisisFlow

    func test_startCrisisFlow_setsActiveAndClearsState() {
        sut.latestResponse = AIResponse(empathy: "test", type: .breathing, script: "test")
        sut.lastErrorMessage = "error"
        sut.crisisPath = [.capture, .interpreting]
        sut.crisisRoot = .breathing

        sut.startCrisisFlow()

        XCTAssertTrue(sut.isCrisisFlowActive)
        XCTAssertEqual(sut.crisisRoot, .capture)
        XCTAssertTrue(sut.crisisPath.isEmpty)
        XCTAssertNil(sut.latestResponse)
        XCTAssertNil(sut.lastErrorMessage)
        XCTAssertNil(sut.context.userText)
    }

    func test_startImmediatePauseFlow_startsInBreathing() {
        sut.startImmediatePauseFlow()

        XCTAssertTrue(sut.isCrisisFlowActive)
        XCTAssertEqual(sut.crisisRoot, .breathing)
        XCTAssertTrue(sut.crisisPath.isEmpty)
        XCTAssertEqual(sut.latestResponse?.type, .breathing)
    }

    // MARK: - submitCapture

    func test_submitCapture_withText_setsContextAndNavigates() {
        sut.submitCapture(text: "Me siento mal")

        XCTAssertEqual(sut.context.userText, "Me siento mal")
        XCTAssertEqual(sut.crisisPath, [.interpreting])
    }

    func test_submitCapture_withEmptyText_setsNilContext() {
        sut.submitCapture(text: "")

        XCTAssertNil(sut.context.userText)
        XCTAssertEqual(sut.crisisPath, [.interpreting])
    }

    func test_submitCapture_withNil_setsNilContext() {
        sut.submitCapture(text: nil)

        XCTAssertNil(sut.context.userText)
        XCTAssertEqual(sut.crisisPath, [.interpreting])
    }

    func test_submitCapture_withVoiceAndImage_setsFullContext() {
        let image = UIImage()

        sut.submitCapture(text: " Estoy mal ", transcript: " Respira conmigo ", image: image)

        XCTAssertEqual(sut.context.userText, "Estoy mal")
        XCTAssertEqual(sut.context.transcript, "Respira conmigo")
        XCTAssertNotNil(sut.context.image)
        XCTAssertEqual(sut.crisisPath, [.interpreting])
    }

    // MARK: - skipCapture

    func test_skipCapture_navigatesToInterpreting() {
        sut.skipCapture()

        XCTAssertEqual(sut.crisisPath, [.interpreting])
    }

    // MARK: - interpretCurrentContext (demo mode)

    func test_interpretCurrentContext_demoMode_setsResponseAndNavigatesDirectlyToSession() async {
        sut.demoModeEnabled = true

        await sut.interpretCurrentContext()

        XCTAssertNotNil(sut.latestResponse)
        XCTAssertEqual(sut.latestResponse?.type, .grounding)
        XCTAssertEqual(sut.crisisPath.last, .grounding)
        XCTAssertFalse(sut.isInterpreting)
        XCTAssertNil(sut.lastErrorMessage)
    }

    func test_interpretCurrentContext_demoMode_withUserText_usesCurrentDemoEmpathy() async {
        sut.demoModeEnabled = true
        sut.context.userText = "Estoy muy estresado"

        await sut.interpretCurrentContext()

        XCTAssertEqual(sut.latestResponse?.empathy, "Tu entorno se siente cargado. Vamos a volver al presente juntos.")
    }

    func test_interpretCurrentContext_demoMode_withoutUserText_usesCurrentDemoEmpathy() async {
        sut.demoModeEnabled = true
        sut.context.userText = nil

        await sut.interpretCurrentContext()

        XCTAssertEqual(sut.latestResponse?.empathy, "Tu entorno se siente cargado. Vamos a volver al presente juntos.")
    }

    func test_interpretCurrentContext_preventsDoubleCall() async {
        sut.demoModeEnabled = true
        sut.isInterpreting = true

        await sut.interpretCurrentContext()

        XCTAssertTrue(sut.crisisPath.isEmpty)
    }

    // MARK: - interpretCurrentContext (no API key)

    func test_interpretCurrentContext_noAPIKey_returnsFallback() async {
        sut.demoModeEnabled = false

        await sut.interpretCurrentContext()

        XCTAssertNotNil(sut.latestResponse)
        XCTAssertEqual(sut.latestResponse?.empathy, "Este momento se siente intenso. Vamos a conectar con lo que te rodea.")
        XCTAssertEqual(sut.crisisPath.last, .grounding)
    }

    // MARK: - startSession

    func test_startSession_breathing_navigatesToBreathing() {
        sut.latestResponse = AIResponse(empathy: "test", type: .breathing, script: "test")

        sut.startSession()

        XCTAssertEqual(sut.crisisPath, [.breathing])
    }

    func test_startSession_grounding_navigatesToGrounding() {
        sut.latestResponse = AIResponse(empathy: "test", type: .grounding, script: "test")

        sut.startSession()

        XCTAssertEqual(sut.crisisPath, [.grounding])
    }

    func test_startSession_reframe_navigatesToReframe() {
        sut.latestResponse = AIResponse(empathy: "test", type: .reframe, script: "test")

        sut.startSession()

        XCTAssertEqual(sut.crisisPath, [.reframe])
    }

    func test_startSession_noResponse_doesNothing() {
        sut.latestResponse = nil

        sut.startSession()

        XCTAssertTrue(sut.crisisPath.isEmpty)
    }

    // MARK: - finishSession

    func test_finishSession_navigatesToCheckIn() {
        sut.finishSession()

        XCTAssertEqual(sut.crisisPath, [.checkIn])
    }

    func test_showSpecialistBridge_navigatesToSpecialists() {
        sut.showSpecialistBridge()

        XCTAssertEqual(sut.crisisPath, [.specialists])
    }

    func test_selectBooking_storesPendingBooking() {
        let booking = SpecialistBookingSelection(
            specialistName: "Dra. Elena Ruiz",
            specialty: "Ansiedad y regulacion emocional",
            modeTitle: "Online",
            location: "Online en todo Mexico",
            price: "$650 MXN",
            slot: "Hoy 6:30 PM"
        )

        sut.selectBooking(booking)

        XCTAssertEqual(sut.pendingBooking, booking)
        XCTAssertNil(sut.confirmedBooking)
    }

    func test_showBookingConfirmation_requiresPendingBooking() {
        sut.showBookingConfirmation()
        XCTAssertTrue(sut.crisisPath.isEmpty)

        let booking = SpecialistBookingSelection(
            specialistName: "Dra. Elena Ruiz",
            specialty: "Ansiedad y regulacion emocional",
            modeTitle: "Online",
            location: "Online en todo Mexico",
            price: "$650 MXN",
            slot: "Hoy 6:30 PM"
        )
        sut.selectBooking(booking)

        sut.showBookingConfirmation()

        XCTAssertEqual(sut.crisisPath, [.bookingConfirmation])
    }

    func test_confirmBooking_movesPendingBookingToConfirmed() {
        let booking = SpecialistBookingSelection(
            specialistName: "Dra. Elena Ruiz",
            specialty: "Ansiedad y regulacion emocional",
            modeTitle: "Online",
            location: "Online en todo Mexico",
            price: "$650 MXN",
            slot: "Hoy 6:30 PM"
        )
        sut.selectBooking(booking)

        sut.confirmBooking()

        XCTAssertEqual(sut.confirmedBooking, booking)
    }

    // MARK: - completeFlow

    func test_completeFlow_resetsEverything() {
        sut.isCrisisFlowActive = true
        sut.crisisRoot = .breathing
        sut.crisisPath = [.capture, .interpreting, .response, .breathing, .checkIn]
        sut.latestResponse = AIResponse(empathy: "test", type: .breathing, script: "test")
        sut.lastErrorMessage = "error"
        sut.context.userText = "something"
        sut.pendingBooking = SpecialistBookingSelection(
            specialistName: "Dra. Elena Ruiz",
            specialty: "Ansiedad y regulacion emocional",
            modeTitle: "Online",
            location: "Online en todo Mexico",
            price: "$650 MXN",
            slot: "Hoy 6:30 PM"
        )
        sut.confirmedBooking = sut.pendingBooking

        sut.completeFlow()
        sut.resetDismissedFlow()

        XCTAssertFalse(sut.isCrisisFlowActive)
        XCTAssertEqual(sut.crisisRoot, .capture)
        XCTAssertTrue(sut.crisisPath.isEmpty)
        XCTAssertNil(sut.latestResponse)
        XCTAssertNil(sut.lastErrorMessage)
        XCTAssertNil(sut.context.userText)
        XCTAssertNil(sut.pendingBooking)
        XCTAssertNil(sut.confirmedBooking)
    }

    // MARK: - Full flow integration

    func test_fullHappyPath_demoMode() async {
        sut.startCrisisFlow()
        XCTAssertTrue(sut.isCrisisFlowActive)
        XCTAssertTrue(sut.crisisPath.isEmpty)

        sut.submitCapture(text: "Me siento abrumado")
        XCTAssertEqual(sut.crisisPath, [.interpreting])

        await sut.interpretCurrentContext()
        XCTAssertEqual(sut.crisisPath, [.interpreting, .grounding])
        XCTAssertNotNil(sut.latestResponse)

        sut.finishSession()
        XCTAssertEqual(sut.crisisPath, [.interpreting, .grounding, .checkIn])

        sut.completeFlow()
        sut.resetDismissedFlow()
        XCTAssertFalse(sut.isCrisisFlowActive)
        XCTAssertTrue(sut.crisisPath.isEmpty)
    }

    func test_fullSkipPath_demoMode() async {
        sut.startCrisisFlow()

        sut.skipCapture()
        XCTAssertEqual(sut.crisisPath, [.interpreting])
        XCTAssertNil(sut.context.userText)

        await sut.interpretCurrentContext()
        XCTAssertEqual(sut.crisisPath, [.interpreting, .grounding])

        sut.finishSession()
        XCTAssertEqual(sut.crisisPath.last, .checkIn)

        sut.completeFlow()
        sut.resetDismissedFlow()
        XCTAssertFalse(sut.isCrisisFlowActive)
    }

    func test_closeFlowMidway_resetsAll() async {
        sut.startCrisisFlow()
        sut.submitCapture(text: "test")
        await sut.interpretCurrentContext()

        sut.completeFlow()
        sut.resetDismissedFlow()

        XCTAssertFalse(sut.isCrisisFlowActive)
        XCTAssertTrue(sut.crisisPath.isEmpty)
        XCTAssertNil(sut.latestResponse)
    }

    // MARK: - AppRoute

    func test_appRoute_isHashable() {
        let set: Set<AppRoute> = [.capture, .interpreting, .response, .breathing, .grounding, .reframe, .checkIn, .specialists, .bookingConfirmation]
        XCTAssertEqual(set.count, 9)
    }

    // MARK: - AIResponse Codable

    func test_aiResponse_decodesFromJSON() throws {
        let json = """
        {"empathy":"Estoy contigo.","type":"grounding","script":"Nombra 5 cosas."}
        """.data(using: .utf8)!

        let response = try JSONDecoder().decode(AIResponse.self, from: json)

        XCTAssertEqual(response.empathy, "Estoy contigo.")
        XCTAssertEqual(response.type, .grounding)
        XCTAssertEqual(response.script, "Nombra 5 cosas.")
    }

    func test_aiResponse_decodesBreathingType() throws {
        let json = """
        {"empathy":"test","type":"breathing","script":"test"}
        """.data(using: .utf8)!

        let response = try JSONDecoder().decode(AIResponse.self, from: json)
        XCTAssertEqual(response.type, .breathing)
    }

    func test_aiResponse_decodesReframeType() throws {
        let json = """
        {"empathy":"test","type":"reframe","script":"test"}
        """.data(using: .utf8)!

        let response = try JSONDecoder().decode(AIResponse.self, from: json)
        XCTAssertEqual(response.type, .reframe)
    }

    func test_aiResponse_failsOnInvalidType() {
        let json = """
        {"empathy":"test","type":"meditation","script":"test"}
        """.data(using: .utf8)!

        XCTAssertThrowsError(try JSONDecoder().decode(AIResponse.self, from: json))
    }

    // MARK: - InterventionType

    func test_interventionType_rawValues() {
        XCTAssertEqual(InterventionType.breathing.rawValue, "breathing")
        XCTAssertEqual(InterventionType.grounding.rawValue, "grounding")
        XCTAssertEqual(InterventionType.reframe.rawValue, "reframe")
    }
}
