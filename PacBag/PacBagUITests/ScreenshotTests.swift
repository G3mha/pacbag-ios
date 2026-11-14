import XCTest

/// Drives the app through one full pass and captures the App Store screenshots.
///
/// Run it with `fastlane screenshots`, not from Xcode -- fastlane sets the
/// language and device list and collects the images afterwards.
@MainActor
final class ScreenshotTests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        // The launch tests also run in landscape, and the simulator keeps
        // whatever orientation the last test left it in.
        XCUIDevice.shared.orientation = .portrait
        app = XCUIApplication()
        setupSnapshot(app)
        // CloudKit cannot resolve its container on a simulator with no iCloud
        // account, and takes the app down with it. See CoreDataManager.
        app.launchArguments += ["-PacBagDisableCloudKit"]
        app.launch()
    }

    func testCaptureScreenshots() throws {
        dismissOnboardingIfPresent()

        createTrip(name: "Tokyo, March", destination: "Tokyo, Japan")
        snapshot("01-Trips")

        openFirstTrip()
        snapshot("02-TripOverview")

        addBagFromTemplate()
        snapshot("03-BagWeight")

        openFirstBag()
        snapshot("04-BagContents")
    }

    // MARK: - Steps

    /// Not every keyboard has this key, and swiping down instead would close the sheet.
    /// Any keyboard left up goes with the sheet, before the next screen is captured.
    private func dismissKeyboard() {
        let returnKey = app.keyboards.buttons["return"].firstMatch
        if returnKey.exists {
            returnKey.tap()
        }
    }

    private func dismissOnboardingIfPresent() {
        let start = app.buttons["Get started"].firstMatch
        if start.waitForExistence(timeout: 10) {
            start.tap()
        }
    }

    private func createTrip(name: String, destination: String) {
        let create = app.buttons["Create Your First Trip"].firstMatch
        if create.waitForExistence(timeout: 10) {
            create.tap()
        } else {
            app.buttons["Add"].firstMatch.tap()
        }

        let nameField = app.textFields["Trip Name"].firstMatch
        XCTAssertTrue(nameField.waitForExistence(timeout: 10), "Trip Name field never appeared")
        nameField.tap()
        nameField.typeText(name)

        let destinationField = app.textFields["Destination"].firstMatch
        destinationField.tap()
        destinationField.typeText(destination)
        dismissKeyboard()

        app.buttons["Create"].firstMatch.tap()
    }

    private func openFirstTrip() {
        let trip = app.staticTexts["Tokyo, March"].firstMatch
        XCTAssertTrue(app.scrollUntilExists(trip), "trip row never appeared")
        trip.tap()
    }

    private func addBagFromTemplate() {
        let addFirst = app.buttons["Add Your First Bag"].firstMatch
        if addFirst.waitForExistence(timeout: 10) {
            addFirst.tap()
        } else {
            app.buttons["Add Bag"].firstMatch.tap()
        }

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
