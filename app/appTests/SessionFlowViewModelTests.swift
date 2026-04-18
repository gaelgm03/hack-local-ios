import XCTest
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

        sut.startCrisisFlow()

        XCTAssertTrue(sut.isCrisisFlowActive)
        XCTAssertTrue(sut.crisisPath.isEmpty)
        XCTAssertNil(sut.latestResponse)
        XCTAssertNil(sut.lastErrorMessage)
        XCTAssertNil(sut.context.userText)
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

    // MARK: - skipCapture

    func test_skipCapture_navigatesToInterpreting() {
        sut.skipCapture()

        XCTAssertEqual(sut.crisisPath, [.interpreting])
    }

    // MARK: - interpretCurrentContext (demo mode)

    func test_interpretCurrentContext_demoMode_setsResponseAndNavigates() async {
        sut.demoModeEnabled = true

        await sut.interpretCurrentContext()

        XCTAssertNotNil(sut.latestResponse)
        XCTAssertEqual(sut.latestResponse?.type, .breathing)
        XCTAssertTrue(sut.crisisPath.contains(.response))
        XCTAssertFalse(sut.isInterpreting)
        XCTAssertNil(sut.lastErrorMessage)
    }

    func test_interpretCurrentContext_demoMode_withUserText_usesPersonalizedEmpathy() async {
        sut.demoModeEnabled = true
        sut.context.userText = "Estoy muy estresado"

        await sut.interpretCurrentContext()

        XCTAssertEqual(sut.latestResponse?.empathy, "Gracias por contarme esto. Estoy contigo y vamos un paso a la vez.")
    }

    func test_interpretCurrentContext_demoMode_withoutUserText_usesGenericEmpathy() async {
        sut.demoModeEnabled = true
        sut.context.userText = nil

        await sut.interpretCurrentContext()

        XCTAssertEqual(sut.latestResponse?.empathy, "Parece que este momento se siente intenso. Estoy aquí contigo.")
    }

    func test_interpretCurrentContext_preventsDoubleCall() async {
        sut.demoModeEnabled = true
        sut.isInterpreting = true

        await sut.interpretCurrentContext()

        // Should not have navigated because guard blocked it
        XCTAssertFalse(sut.crisisPath.contains(.response))
    }

    // MARK: - interpretCurrentContext (no API key)

    func test_interpretCurrentContext_noAPIKey_returnsFallback() async {
        sut.demoModeEnabled = false
        // APIConfig.openAIKey is empty by default → hasValidKey == false

        await sut.interpretCurrentContext()

        XCTAssertNotNil(sut.latestResponse)
        XCTAssertEqual(sut.latestResponse?.empathy, "Estoy aquí contigo. Vamos a hacer una pausa juntos.")
        XCTAssertTrue(sut.crisisPath.contains(.response))
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

    func test_startSession_reframe_fallsBackToBreathing() {
        sut.latestResponse = AIResponse(empathy: "test", type: .reframe, script: "test")

        sut.startSession()

        XCTAssertEqual(sut.crisisPath, [.breathing])
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

    // MARK: - completeFlow

    func test_completeFlow_resetsEverything() {
        sut.isCrisisFlowActive = true
        sut.crisisPath = [.capture, .interpreting, .response, .breathing, .checkIn]
        sut.latestResponse = AIResponse(empathy: "test", type: .breathing, script: "test")
        sut.lastErrorMessage = "error"
        sut.context.userText = "something"

        sut.completeFlow()

        XCTAssertFalse(sut.isCrisisFlowActive)
        XCTAssertTrue(sut.crisisPath.isEmpty)
        XCTAssertNil(sut.latestResponse)
        XCTAssertNil(sut.lastErrorMessage)
        XCTAssertNil(sut.context.userText)
    }

    // MARK: - Full flow integration

    func test_fullHappyPath_demoMode() async {
        // 1. Start flow
        sut.startCrisisFlow()
        XCTAssertTrue(sut.isCrisisFlowActive)
        XCTAssertTrue(sut.crisisPath.isEmpty)

        // 2. Submit capture
        sut.submitCapture(text: "Me siento abrumado")
        XCTAssertEqual(sut.crisisPath, [.interpreting])

        // 3. AI interprets
        await sut.interpretCurrentContext()
        XCTAssertEqual(sut.crisisPath, [.interpreting, .response])
        XCTAssertNotNil(sut.latestResponse)

        // 4. Start session (breathing)
        sut.startSession()
        XCTAssertEqual(sut.crisisPath, [.interpreting, .response, .breathing])

        // 5. Finish session → check-in
        sut.finishSession()
        XCTAssertEqual(sut.crisisPath, [.interpreting, .response, .breathing, .checkIn])

        // 6. Complete flow
        sut.completeFlow()
        XCTAssertFalse(sut.isCrisisFlowActive)
        XCTAssertTrue(sut.crisisPath.isEmpty)
    }

    func test_fullSkipPath_demoMode() async {
        // 1. Start flow
        sut.startCrisisFlow()

        // 2. Skip capture
        sut.skipCapture()
        XCTAssertEqual(sut.crisisPath, [.interpreting])
        XCTAssertNil(sut.context.userText)

        // 3. AI interprets without text
        await sut.interpretCurrentContext()
        XCTAssertEqual(sut.crisisPath, [.interpreting, .response])

        // 4. Start session → breathing
        sut.startSession()
        XCTAssertEqual(sut.crisisPath.last, .breathing)

        // 5. Finish → check-in
        sut.finishSession()
        XCTAssertEqual(sut.crisisPath.last, .checkIn)

        // 6. Complete
        sut.completeFlow()
        XCTAssertFalse(sut.isCrisisFlowActive)
    }

    func test_closeFlowMidway_resetsAll() async {
        sut.startCrisisFlow()
        sut.submitCapture(text: "test")
        await sut.interpretCurrentContext()

        // User taps X mid-flow
        sut.completeFlow()

        XCTAssertFalse(sut.isCrisisFlowActive)
        XCTAssertTrue(sut.crisisPath.isEmpty)
        XCTAssertNil(sut.latestResponse)
    }

    // MARK: - AppRoute

    func test_appRoute_isHashable() {
        let set: Set<AppRoute> = [.capture, .interpreting, .response, .breathing, .grounding, .checkIn]
        XCTAssertEqual(set.count, 6)
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
