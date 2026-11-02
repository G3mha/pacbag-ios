import XCTest

/// Launch setup and the steps every flow shares. Each launch starts on an empty
/// in-memory store with onboarding skipped, in portrait and on `en_US`.
@MainActor
class PacBagUITestCase: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
    }

    /// `pinLocale: false` is for fastlane's screenshots, which set their own language.
    func launch(pinLocale: Bool = true) {
        XCUIDevice.shared.orientation = .portrait
        if pinLocale {
            app.launchArguments += ["-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        }
        // CloudKit cannot resolve its container on a simulator with no iCloud
        // account and takes the app down with it. See LaunchOption.
        app.launchArguments += [LaunchOption.disableCloudKit, LaunchOption.inMemoryStore, LaunchOption.skipOnboarding]
        app.launch()
    }

    /// Typing leaves the keyboard up. Return closes a text field's keyboard.
    func dismissKeyboard() {
        if app.keyboards.element.exists {
            // Typing it, because tapping the key sometimes fails with "scroll to visible" under load.
            app.typeText("\n")
        }
    }

    func createTrip(name: String, destination: String) {
        let first = app.buttons["Create Your First Trip"].firstMatch
        XCTAssertTrue(first.waitForExistence(timeout: 10), "an empty store should offer the first trip")
        first.tap()

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

    func openTrip(_ name: String) {
        let trip = app.staticTexts[name].firstMatch
        XCTAssertTrue(trip.waitForExistence(timeout: 10), "trip row never appeared")
        trip.tap()
    }

    func openAddBag() {
        let addFirst = app.buttons["Add Your First Bag"].firstMatch
        if addFirst.waitForExistence(timeout: 10) {
            addFirst.tap()
        } else {
            app.buttons["Add Bag"].firstMatch.tap()
        }
    }
}
