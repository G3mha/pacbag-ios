import XCTest

/// Checks the arithmetic behind the empty-bag weight, which is the change 1.0.1
/// is built around: a bag's total is its own weight plus its contents, and the
/// capacity left for items is the limit minus the bag.
@MainActor
final class WeightTests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        // The launch tests also run in landscape, and the simulator keeps
        // whatever orientation the last test left it in.
        XCUIDevice.shared.orientation = .portrait
        app = XCUIApplication()
        // CloudKit cannot resolve its container on a simulator with no iCloud
        // account and takes the app down with it. See CoreDataManager.
        app.launchArguments += ["-PacBagDisableCloudKit"]
        // These tests look for "4.5 kg", which is "4,5 kg" in a region with decimal commas.
        app.launchArguments += ["-AppleLocale", "en_US"]
        app.launch()
    }

    func testAvailableCapacityIsLimitMinusBagWeight() throws {
        dismissOnboardingIfPresent()
        createTrip(name: "Weight Check", destination: "Nowhere")
        openTrip("Weight Check")
        openAddBag()

        // Defaults for a suitcase: 4.5 kg empty against a 23.0 kg limit.
        XCTAssertTrue(app.staticTexts["4.5 kg"].firstMatch.waitForExistence(timeout: 10),
                      "empty bag weight did not default to 4.5 kg")
        XCTAssertTrue(app.staticTexts["23.0 kg"].firstMatch.exists,
                      "maximum total weight did not default to 23.0 kg")
        XCTAssertTrue(app.staticTexts["18.5 kg"].firstMatch.exists,
                      "available capacity should be 23.0 - 4.5 = 18.5 kg")
    }

    func testBagTypeChangesTheEmptyWeight() throws {
        dismissOnboardingIfPresent()
        createTrip(name: "Type Check", destination: "Nowhere")
        openTrip("Type Check")
        openAddBag()

        // A tote is 0.5 kg empty where a suitcase is 4.5, so picking one has to
        // move both the bag weight and what is left for items.
        let type = app.buttons["Type, Suitcase"].firstMatch
        XCTAssertTrue(type.waitForExistence(timeout: 10), "the bag type menu never appeared")
        type.tap()
        let backpack = app.buttons["Backpack"].firstMatch
        XCTAssertTrue(backpack.waitForExistence(timeout: 5), "the type menu never opened")
        backpack.tap()
        XCTAssertTrue(app.staticTexts["1.5 kg"].firstMatch.waitForExistence(timeout: 5),
                      "a backpack should default to 1.5 kg empty")
    }

    // MARK: - Steps

    private func dismissOnboardingIfPresent() {
        let start = app.buttons["Get started"].firstMatch
        if start.waitForExistence(timeout: 10) { start.tap() }
    }

    /// Not every keyboard has this key, and swiping down instead would close the sheet.
    private func dismissKeyboard() {
        let returnKey = app.keyboards.buttons["return"].firstMatch
        if returnKey.exists { returnKey.tap() }
    }

    private func createTrip(name: String, destination: String) {
        let first = app.buttons["Create Your First Trip"].firstMatch
        if first.waitForExistence(timeout: 5) {
            first.tap()
        } else {
            app.buttons["Add"].firstMatch.tap()
        }
        let nameField = app.textFields["Trip Name"].firstMatch
        XCTAssertTrue(nameField.waitForExistence(timeout: 10))
        nameField.tap(); nameField.typeText(name)
        let dest = app.textFields["Destination"].firstMatch
        dest.tap(); dest.typeText(destination)
        dismissKeyboard()
        app.buttons["Create"].firstMatch.tap()
    }

    private func openTrip(_ name: String) {
        let trip = app.staticTexts[name].firstMatch
        XCTAssertTrue(app.scrollUntilExists(trip))
        trip.tap()
    }

    private func openAddBag() {
        let addFirst = app.buttons["Add Your First Bag"].firstMatch
        if addFirst.waitForExistence(timeout: 10) {
            addFirst.tap()
        } else {
            app.buttons["Add Bag"].firstMatch.tap()
        }
    }
}
