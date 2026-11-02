import XCTest

/// Drives the app through one full pass and captures the App Store screenshots.
///
/// Run it with `fastlane screenshots`, not from Xcode -- fastlane sets the
/// language and device list and collects the images afterwards.
@MainActor
final class ScreenshotTests: PacBagUITestCase {
    override func setUpWithError() throws {
        try super.setUpWithError()
        setupSnapshot(app)
        launch(pinLocale: false)
    }

    func testCaptureScreenshots() throws {
        createTrip(name: "Tokyo, March", destination: "Tokyo, Japan")
        snapshot("01-Trips")

        openTrip("Tokyo, March")
        snapshot("02-TripOverview")

        addBagFromTemplate()
        snapshot("03-BagWeight")

        openFirstBag()
        snapshot("04-BagContents")
    }

    // MARK: - Steps

    private func addBagFromTemplate() {
        openAddBag()

        let bagName = app.textFields["Bag Name"].firstMatch
        XCTAssertTrue(bagName.waitForExistence(timeout: 10), "Bag Name field never appeared")
        bagName.tap()
        bagName.typeText("Carry-on")
        dismissKeyboard()
    }

    private func openFirstBag() {
        app.buttons["Save"].firstMatch.tap()
        let bag = app.staticTexts["Carry-on"].firstMatch
        if bag.waitForExistence(timeout: 10) {
            bag.tap()
        }
    }
}
