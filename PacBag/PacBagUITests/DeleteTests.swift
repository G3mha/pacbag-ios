import XCTest

/// Deleting something while a screen still holds it. A deleted managed object
/// traps when its non-optional `UUID` or `Date` is read, so these tests check
/// that the app is still running after each delete.
@MainActor
final class DeleteTests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        // CloudKit cannot resolve its container on a simulator with no iCloud
        // account and takes the app down with it. See CoreDataManager.
        app.launchArguments += ["-PacBagDisableCloudKit"]
        app.launch()
        dismissOnboardingIfPresent()
    }

    func testDeleteTripFromTheList() throws {
        let doomed = uniqueName("List Delete")
        let survivor = uniqueName("List Survivor")
        createTrip(name: doomed)
        createTrip(name: survivor)

        pressAndChoose(app.staticTexts[doomed].firstMatch, menuItem: "Delete Trip")
        tap(app.alerts.buttons["Delete"].firstMatch)

        assertGone(doomed)
        XCTAssertTrue(app.staticTexts[survivor].firstMatch.exists, "the other trip should stay listed")
    }

    func testDeleteTripFromItsOwnScreen() throws {
        let doomed = uniqueName("Screen Delete")
        let survivor = uniqueName("Screen Survivor")
        // With a bag, so the screen's bag list loses a row to the cascade too.
        createTrip(name: doomed, withBag: true)
        createTrip(name: survivor)

        tap(app.staticTexts[doomed].firstMatch)
        tap(app.navigationBars.buttons["More"].firstMatch)
        tap(app.buttons["Delete Trip"].firstMatch)
        tap(app.alerts.buttons["Delete"].firstMatch)

        assertGone(doomed)
        XCTAssertTrue(app.staticTexts[survivor].firstMatch.waitForExistence(timeout: 5),
                      "deleting from the trip's screen should return to the list")
    }

    func testDeleteBagFromTheTrip() throws {
        let trip = uniqueName("Bag Delete")
        createTrip(name: trip, withBag: true)
        tap(app.staticTexts[trip].firstMatch)

        pressAndChoose(app.staticTexts["Main Suitcase"].firstMatch, menuItem: "Delete Bag")
        tap(app.alerts.buttons["Delete"].firstMatch)

        assertGone("Main Suitcase")
        XCTAssertTrue(app.buttons["Add Your First Bag"].firstMatch.waitForExistence(timeout: 5),
                      "the trip should show its empty bag list")
    }

    func testDeleteItemFromItsOwnScreen() throws {
        let trip = uniqueName("Item Screen")
        let doomed = uniqueName("Doomed Item")
        let survivor = uniqueName("Surviving Item")
        createTrip(name: trip, withBag: true)
        tap(app.staticTexts[trip].firstMatch)
        tap(app.staticTexts["Main Suitcase"].firstMatch)
        addItem(name: doomed)
        addItem(name: survivor)

        tap(app.staticTexts[doomed].firstMatch)
        // Its label also includes the trash icon's name.
        let delete = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Delete Item'")).firstMatch
        for _ in 0..<6 where !(delete.exists && delete.isHittable) {
            app.swipeUp(velocity: .slow)
        }
        tap(delete)
        tap(app.alerts.buttons["Delete"].firstMatch)

        assertGone(doomed)
        XCTAssertTrue(app.staticTexts[survivor].firstMatch.waitForExistence(timeout: 5),
                      "deleting from the item's screen should return to the bag")
    }

    func testDeleteItemFromTheBag() throws {
        let trip = uniqueName("Item Delete")
        let doomed = uniqueName("Doomed Item")
        let survivor = uniqueName("Surviving Item")
        createTrip(name: trip, withBag: true)
        tap(app.staticTexts[trip].firstMatch)
        tap(app.staticTexts["Main Suitcase"].firstMatch)
        addItem(name: doomed)
        addItem(name: survivor)

        pressAndChoose(app.staticTexts[doomed].firstMatch, menuItem: "Delete Item")

        assertGone(doomed)
        XCTAssertTrue(app.staticTexts[survivor].firstMatch.exists, "the other item should stay listed")
    }

    // MARK: - Steps

    /// A crashed run leaves its data on the simulator, so names can't repeat.
    private func uniqueName(_ prefix: String) -> String {
        "\(prefix) \(UUID().uuidString.prefix(6))"
    }

    private func dismissOnboardingIfPresent() {
        let start = app.buttons["Get started"].firstMatch
        if start.waitForExistence(timeout: 10) { start.tap() }
    }

    private func tap(_ element: XCUIElement, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertTrue(element.waitForExistence(timeout: 10), "\(element) never appeared", file: file, line: line)
        element.tap()
    }

    private func pressAndChoose(_ element: XCUIElement, menuItem: String) {
        XCTAssertTrue(element.waitForExistence(timeout: 10), "\(element) never appeared")
        element.press(forDuration: 1.2)
        tap(app.buttons[menuItem].firstMatch)
    }

    /// The toolbar buttons stay reachable with the keyboard up, so there's no
    /// need to dismiss it before tapping Create or Save.
    private func createTrip(name: String, withBag: Bool = false) {
        let first = app.buttons["Create Your First Trip"].firstMatch
        tap(first.waitForExistence(timeout: 3) ? first : app.navigationBars.buttons["Add"].firstMatch)

        let nameField = app.textFields["Trip Name"].firstMatch
        tap(nameField)
        nameField.typeText(name)
        let destination = app.textFields["Destination"].firstMatch
        tap(destination)
        destination.typeText("Nowhere")

        if withBag {
            let toggle = app.switches["Create with first bag"].firstMatch
            for _ in 0..<6 where !(toggle.exists && toggle.isHittable) {
                app.swipeUp(velocity: .slow)
            }
            toggle.switches.firstMatch.tap()
        }

        tap(app.buttons["Create"].firstMatch)
        XCTAssertTrue(app.staticTexts[name].firstMatch.waitForExistence(timeout: 10), "\(name) was not created")
    }

    private func addItem(name: String) {
        let add = app.buttons["Add Manually"].firstMatch
        tap(add.waitForExistence(timeout: 3) ? add : app.buttons["Add Item"].firstMatch)

        let nameField = app.textFields["Item Name"].firstMatch
        tap(nameField)
        nameField.typeText(name)

        tap(app.buttons["Save"].firstMatch)
        XCTAssertTrue(app.staticTexts[name].firstMatch.waitForExistence(timeout: 10), "\(name) was not added")
    }

    /// The traps land on a later run loop turn than the tap, so give them time
    /// to fire before checking the app is still up.
    private func assertGone(_ name: String, file: StaticString = #filePath, line: UInt = #line) {
        let gone = NSPredicate(format: "exists == false")
        let expectation = XCTNSPredicateExpectation(predicate: gone, object: app.staticTexts[name].firstMatch)
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 10), .completed,
                       "\(name) is still on screen", file: file, line: line)
        Thread.sleep(forTimeInterval: 2)
        XCTAssertEqual(app.state, .runningForeground, "the app crashed after deleting \(name)", file: file, line: line)
    }
}
