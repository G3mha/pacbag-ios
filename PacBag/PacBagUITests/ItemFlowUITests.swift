import XCTest

/// The item flow, pinned before anything moves. Controls are found by `AccessibilityID`,
/// so these keep passing when `AddItemView` goes away.
@MainActor
final class ItemFlowUITests: PacBagUITestCase {
    private let bagName = "Carry-on"

    override func setUpWithError() throws {
        try super.setUpWithError()
        launch()
        createTrip(name: "Item Flow", destination: "Nowhere")
        openTrip("Item Flow")
        openAddBag()

        let name = app.textFields["Bag Name"].firstMatch
        XCTAssertTrue(name.waitForExistence(timeout: 10), "Bag Name field never appeared")
        name.tap()
        name.typeText(bagName)
        dismissKeyboard()
        app.buttons["Save"].firstMatch.tap()

        let bag = app.staticTexts[bagName].firstMatch
        XCTAssertTrue(bag.waitForExistence(timeout: 10), "the new bag never appeared on the trip")
        bag.tap()
    }

    func testAddAndPackAnItem() throws {
        addItem("Socks")

        XCTAssertTrue(row("Socks").waitForExistence(timeout: 10), "the new row never appeared")
        XCTAssertTrue(app.staticTexts["0/1"].firstMatch.exists, "the header should count one row, none packed")

        app.buttons[AccessibilityID.itemRowToggle].firstMatch.tap()
        XCTAssertTrue(app.staticTexts["1/1"].firstMatch.waitForExistence(timeout: 5), "the checkbox should update the header's packed count")
    }

    /// Pinned crash, which 1.0.1 has too. Delete from the context menu takes the app down, with one row or
    /// several. `ItemsListView` keeps the deleted row in `cachedSortedItems` until `onChange` runs, and its
    /// `ForEach` reads the non-optional `Item.id` from that row. The commit that keys rows by `objectID`
    /// and hides deleted rows flips this: the wait below then fails. Replace everything from the
    /// expectation on with the delete, a wait for the row to go, and a check for "0/0" in the header.
    func testDeleteFromTheContextMenu() throws {
        addItem("Socks")
        XCTAssertTrue(row("Socks").waitForExistence(timeout: 10), "the new row never appeared")

        row("Socks").press(forDuration: 1.2)
        let delete = app.buttons["Delete Item"].firstMatch
        XCTAssertTrue(delete.waitForExistence(timeout: 5), "the context menu should offer Delete Item")

        // XCTest files its own "crashed" issue only if the crash report turns up in time, so that issue is
        // allowed but not required. The wait is the pin.
        let crash = XCTExpectedFailure.Options()
        crash.issueMatcher = { $0.compactDescription.contains("crashed") }
        crash.isStrict = false
        XCTExpectFailure("Deleting a row reads Item.id from the deleted row", options: crash)
        delete.tap()
        XCTAssertTrue(app.wait(for: .notRunning, timeout: 15), "the delete no longer crashes, so this pin can flip")
    }

    /// Today's Edit and Save, found by label. The live form commit removes those steps, and the
    /// `WeightField` commit moves the weight step to typing.
    func testEditingAWeightChangesTheTotal() throws {
        addItem("Socks")
        XCTAssertTrue(row("Socks").waitForExistence(timeout: 10), "the new row never appeared")
        let before = try bagTotal()

        // The row's plain button style leaves the gaps between its texts untappable, and that includes its center.
        row("Socks").staticTexts["Socks"].firstMatch.tap()
        let edit = app.navigationBars.buttons["Edit"].firstMatch
        XCTAssertTrue(edit.waitForExistence(timeout: 10), "the item screen should offer Edit")
        edit.tap()

        let slider = app.sliders[AccessibilityID.itemDetailWeightField].firstMatch
        XCTAssertTrue(slider.waitForExistence(timeout: 5), "editing should show the weight slider")
        slider.adjust(toNormalizedSliderPosition: 0.5)
        app.navigationBars.buttons["Save"].firstMatch.tap()
        XCTAssertTrue(edit.waitForExistence(timeout: 5), "Save should end editing")

        app.navigationBars.buttons.element(boundBy: 0).tap()
        XCTAssertTrue(row("Socks").waitForExistence(timeout: 10), "Back should return to the bag")
        XCTAssertGreaterThan(try bagTotal(), before + 1, "the new weight should reach the bag's total")
    }

    /// The total's number from the header, "3.1 / 20.0 kg".
    private func bagTotal() throws -> Double {
        let total = app.staticTexts[AccessibilityID.bagDetailTotal].firstMatch
        XCTAssertTrue(total.waitForExistence(timeout: 5), "the bag header's total never appeared")
        let number = try XCTUnwrap(total.label.split(separator: " ").first)
        return try XCTUnwrap(Double(number), "couldn't read a number from \(total.label)")
    }

    private func row(_ name: String) -> XCUIElement {
        app.buttons[AccessibilityID.itemRow(name)].firstMatch
    }

    private func addItem(_ name: String) {
        let add = app.buttons[AccessibilityID.bagDetailAddItem].firstMatch
        XCTAssertTrue(add.waitForExistence(timeout: 10), "the header Add Item button never appeared")
        add.tap()

        let field = app.textFields[AccessibilityID.itemDetailNameField].firstMatch
        XCTAssertTrue(field.waitForExistence(timeout: 10), "the name field never appeared")
        field.tap()
        field.typeText(name)
        app.buttons[AccessibilityID.itemDetailSave].firstMatch.tap()
    }
}
