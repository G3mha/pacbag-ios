import XCTest

/// Runs only against a local server started with FAKE_CLAUDE=1, so it never costs anything:
/// TEST_RUNNER_PACBAG_API_URL=http://localhost:8787 xcodebuild test ...
@MainActor
final class AIFillUITests: PacBagUITestCase {
    func testAUnknownItemStaysLocalUntilConsentThenFills() throws {
        let url = ProcessInfo.processInfo.environment["PACBAG_API_URL"] ?? ""
        try XCTSkipIf(url.isEmpty, "needs a local server")
        app.launchEnvironment["PACBAG_API_URL"] = url
        app.launchArguments += ["-ai_consent", ""]
        launch()
        createTrip(name: "AI", destination: "Nowhere")
        openTrip("AI")
        openAddBag()
        let bagName = app.textFields["Bag Name"].firstMatch
        XCTAssertTrue(bagName.waitForExistence(timeout: 20))
        bagName.tap()
        bagName.typeText("Carry-on")
        dismissKeyboard()
        app.buttons["Save"].firstMatch.tap()
        let bag = app.staticTexts["Carry-on"].firstMatch
        XCTAssertTrue(bag.waitForExistence(timeout: 20))
        bag.tap()

        let field = app.descendants(matching: .any)[AccessibilityID.quickAddField].firstMatch
        XCTAssertTrue(field.waitForExistence(timeout: 20))
        field.tap()
        field.typeText("snorkel gizmo\n")
        XCTAssertTrue(app.staticTexts["not weighed"].firstMatch.waitForExistence(timeout: 20), "nothing should go out before consent")

        let offer = app.buttons[AccessibilityID.quickAddOffer].firstMatch
        XCTAssertTrue(offer.waitForExistence(timeout: 20))
        offer.tap()
        let accept = app.buttons[AccessibilityID.consentAccept].firstMatch
        XCTAssertTrue(accept.waitForExistence(timeout: 20))
        accept.tap()

        let estimate = app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'estimate'")).firstMatch
        XCTAssertTrue(estimate.waitForExistence(timeout: 30), "the fake server's weight should land")

        field.tap()
        field.typeText("I want to die\n")
        XCTAssertTrue(app.alerts["You're not alone"].waitForExistence(timeout: 30), "the crisis text should show")
        XCTAssertTrue(app.alerts.staticTexts.containing(NSPredicate(format: "label CONTAINS '988'")).firstMatch.exists)
    }
}
