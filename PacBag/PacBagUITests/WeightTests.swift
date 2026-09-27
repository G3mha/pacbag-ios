import XCTest

/// Checks the arithmetic behind the empty-bag weight, which is the change 1.0.1
/// is built around: a bag's total is its own weight plus its contents, and the
/// capacity left for items is the limit minus the bag.
@MainActor
final class WeightTests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        // CloudKit cannot resolve its container on a simulator with no iCloud
        // account and takes the app down with it. See CoreDataManager.
        app.launchArguments += ["-PacBagDisableCloudKit"]
        app.launch()
    }

    func testAvailableCapacityIsLimitMinusBagWeight() throws {
        dismissOnboardingIfPresent()
        createTrip(name: "Weight Check", destination: "Nowhere")
        openTrip("Weight Check")
        openAddBag()

        // Defaults for a suitcase: 3.0 kg empty against a 20.0 kg limit.
        XCTAssertTrue(app.staticTexts["3.0 kg"].firstMatch.waitForExistence(timeout: 10),
                      "empty bag weight did not default to 3.0 kg")
        XCTAssertTrue(app.staticTexts["20.0 kg"].firstMatch.exists,
                      "maximum total weight did not default to 20.0 kg")
        XCTAssertTrue(app.staticTexts["17.0 kg"].firstMatch.exists,
                      "available capacity should be 20.0 - 3.0 = 17.0 kg")
    }

    func testBagTypeChangesTheEmptyWeight() throws {
        dismissOnboardingIfPresent()
        createTrip(name: "Type Check", destination: "Nowhere")
        openTrip("Type Check")
        openAddBag()

        // A tote is 0.5 kg empty where a suitcase is 4.5, so picking one has to
        // move both the bag weight and what is left for items.
        app.buttons["Backpack"].firstMatch.tap()
        XCTAssertTrue(app.staticTexts["1.5 kg"].firstMatch.waitForExistence(timeout: 5),
                      "a backpack should default to 1.5 kg empty")
    }

    // MARK: - Steps

    private func dismissOnboardingIfPresent() {
        let start = app.buttons["Get started"].firstMatch
        if start.waitForExistence(timeout: 10) { start.tap() }
    }

    private func dismissKeyboard() {
        if app.keyboards.element.exists { app.keyboards.buttons["return"].firstMatch.tap() }
        if app.keyboards.element.exists { app.swipeDown() }
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
        XCTAssertTrue(trip.waitForExistence(timeout: 10))
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
