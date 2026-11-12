import XCTest

/// Covers what the trip and bag lists have to get right: totals that follow what
/// you pack, and deletes that don't take the app down. A deleted Core Data object
/// traps when its Date or UUID is read, and SwiftUI can still read one mid-update.
@MainActor
final class ChecklistTests: XCTestCase {
    var app: XCUIApplication!
    /// Keeps trip names unique, since trips from earlier runs stay in the list.
    /// Digits only, so autocorrect leaves the typed name alone.
    let runID = String(Int(Date().timeIntervalSince1970) % 1_000_000)

    override func setUpWithError() throws {
        continueAfterFailure = false
        // The launch tests also run in landscape, and the simulator keeps
        // whatever orientation the last test left it in.
        XCUIDevice.shared.orientation = .portrait
        app = XCUIApplication()
        // CloudKit cannot resolve its container on a simulator with no iCloud
        // account and takes the app down with it. See CoreDataManager.
        app.launchArguments += ["-PacBagDisableCloudKit"]
        app.launch()
        dismissOnboardingIfPresent()
    }

    func testPackingAnItemUpdatesTheBagAndTheTrip() throws {
        let trip = "Packing Check \(runID)"
        createTripWithBagAndItem(trip: trip)
        openBag()

        app.buttons["Mark Soap as packed"].firstMatch.tap()
        XCTAssertTrue(app.staticTexts["1 of 1 packed"].firstMatch.waitForExistence(timeout: 5),
                      "the bag should count the packed item")

        goBack()
        XCTAssertTrue(app.staticTexts["1 of 1 packed"].firstMatch.waitForExistence(timeout: 5),
                      "the trip should count the packed item")

        goBack()
        let row = app.cells.containing(.staticText, identifier: trip).firstMatch
        XCTAssertTrue(row.staticTexts["1 of 1 packed"].waitForExistence(timeout: 5),
                      "the trip list should count the packed item")
    }

    func testDeletingAnItemUpdatesTheBag() throws {
        createTripWithBagAndItem(trip: "Item Delete Check \(runID)")
        openBag()

        // The whole row, since a swipe across just the short name doesn't travel far enough.
        app.cells.containing(.staticText, identifier: "Soap").firstMatch.swipeLeft()
        let delete = app.buttons["Delete"].firstMatch
        XCTAssertTrue(delete.waitForExistence(timeout: 5), "swiping an item should offer to delete it")
        delete.tap()

        XCTAssertTrue(app.staticTexts["No items yet"].firstMatch.waitForExistence(timeout: 5),
                      "the bag should be empty once its only item is deleted")
    }

    func testDeletingATripFromItsOwnScreen() throws {
        let trip = "Screen Delete Check \(runID)"
        createTripWithBagAndItem(trip: trip)

        app.buttons["More"].firstMatch.tap()
        app.buttons["Delete Trip"].firstMatch.tap()
        confirmDelete()

        assertBackOnTripList(without: trip)
    }

    func testDeletingATripFromTheList() throws {
        let trip = "List Delete Check \(runID)"
        createTripWithBagAndItem(trip: trip)
        goBack()

        app.cells.containing(.staticText, identifier: trip).firstMatch.swipeLeft()
        app.buttons["Delete"].firstMatch.tap()
        confirmDelete()

        assertBackOnTripList(without: trip)
    }

    // MARK: - Steps

    private func dismissOnboardingIfPresent() {
        let start = app.buttons["Get started"].firstMatch
        if start.waitForExistence(timeout: 5) { start.tap() }
    }

    /// Not every keyboard has this key, and swiping down instead would close the sheet.
    private func dismissKeyboard() {
        let returnKey = app.keyboards.buttons["return"].firstMatch
        if returnKey.exists { returnKey.tap() }
    }

    /// Leaves the app on the trip's screen.
    private func createTripWithBagAndItem(trip: String) {
        let first = app.buttons["Create Your First Trip"].firstMatch
        if first.waitForExistence(timeout: 5) {
            first.tap()
        } else {
            app.buttons["Add"].firstMatch.tap()
        }
        type(trip, into: "Trip Name")
        type("Nowhere", into: "Destination")
        dismissKeyboard()
        app.buttons["Create"].firstMatch.tap()

        let row = app.staticTexts[trip].firstMatch
        XCTAssertTrue(app.scrollUntilExists(row), "trip row never appeared")
        row.tap()

        let addBag = app.buttons["Add Your First Bag"].firstMatch
        XCTAssertTrue(addBag.waitForExistence(timeout: 10), "a new trip should offer to add a bag")
        addBag.tap()
        type("Carry-on", into: "Bag Name")
        dismissKeyboard()
        app.buttons["Save"].firstMatch.tap()

        openBag()
        let addManually = app.buttons["Add Manually"].firstMatch
        XCTAssertTrue(addManually.waitForExistence(timeout: 10), "an empty bag should offer to add an item")
        addManually.tap()
        type("Soap", into: "Item Name")
        dismissKeyboard()
        app.buttons["Save"].firstMatch.tap()

        XCTAssertTrue(app.staticTexts["Soap"].firstMatch.waitForExistence(timeout: 10), "item never appeared")
        goBack()
    }

    private func type(_ text: String, into field: String) {
        let element = app.textFields[field].firstMatch
        XCTAssertTrue(element.waitForExistence(timeout: 10), "\(field) field never appeared")
        element.tap()
        element.typeText(text)
    }

    private func openBag() {
        let bag = app.staticTexts["Carry-on"].firstMatch
        XCTAssertTrue(bag.waitForExistence(timeout: 10), "bag row never appeared")
        bag.tap()
    }

    private func goBack() {
        app.navigationBars.buttons.firstMatch.tap()
    }

    private func confirmDelete() {
        let delete = app.alerts.buttons["Delete"].firstMatch
        XCTAssertTrue(delete.waitForExistence(timeout: 5), "deleting a trip should ask first")
        delete.tap()
    }

    private func assertBackOnTripList(without trip: String) {
        XCTAssertTrue(app.navigationBars["My Trips"].waitForExistence(timeout: 10),
                      "the app should land back on the trip list")
        XCTAssertTrue(app.staticTexts[trip].firstMatch.waitForNonExistence(timeout: 5),
                      "the deleted trip should be gone")
        XCTAssertEqual(app.state, .runningForeground, "the app should survive the delete")
    }
}
