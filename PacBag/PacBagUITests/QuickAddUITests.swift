import XCTest

@MainActor
final class QuickAddUITests: PacBagUITestCase {
    func testReturnAddsARowAndKeepsTheFieldReady() throws {
        launch()
        createTrip(name: "Quick", destination: "Nowhere")
        openTrip("Quick")
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
        XCTAssertTrue(field.waitForExistence(timeout: 20), "quick add field missing")
        field.tap()
        field.typeText("2 socks\n")
        XCTAssertTrue(app.staticTexts["Added socks ×2, Clothes"].waitForExistence(timeout: 20))
        XCTAssertEqual(field.value(forKey: "hasKeyboardFocus") as? Bool, true, "Return should keep the field focused")

        field.typeText("laptop charger\n")
        XCTAssertTrue(app.staticTexts["Added laptop charger, Electronics"].waitForExistence(timeout: 20))
        field.typeText("snorkel gizmo\n")
        XCTAssertTrue(app.staticTexts["Added snorkel gizmo, not sorted"].waitForExistence(timeout: 20))
        XCTAssertTrue(app.staticTexts["not weighed"].firstMatch.waitForExistence(timeout: 20))

        app.buttons[AccessibilityID.quickAddUndo].firstMatch.tap()
        let gone = NSPredicate(format: "exists == false")
        XCTAssertEqual(XCTWaiter().wait(for: [expectation(for: gone, evaluatedWith: app.staticTexts["not weighed"].firstMatch)], timeout: 20), .completed, "Undo should remove the row")
        XCTAssertEqual(app.state, .runningForeground, "the app should still be up after Undo")

        // Opening an item with the field focused, then coming back, used to leave the keyboard up
        // with the field hidden under it.
        field.tap()
        XCTAssertEqual(field.value(forKey: "hasKeyboardFocus") as? Bool, true)
        app.staticTexts["socks"].firstMatch.tap()
        let detail = app.navigationBars["socks"]
        XCTAssertTrue(detail.waitForExistence(timeout: 10), "the item should open")
        detail.buttons.element(boundBy: 0).tap()
        XCTAssertTrue(detail.waitForNonExistence(timeout: 10))
        XCTAssertTrue(field.waitForExistence(timeout: 10))
        Thread.sleep(forTimeInterval: 1)
        XCTAssertEqual(field.value(forKey: "hasKeyboardFocus") as? Bool, false,
                       "the field should let go of the keyboard after coming back from an item")
    }
}
