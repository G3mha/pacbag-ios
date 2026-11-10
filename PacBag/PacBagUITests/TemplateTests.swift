import XCTest

/// Applying a template is the end of the template flow, so both sheets have to
/// close together. Cancelling the template's detail only steps back to the list.
@MainActor
final class TemplateTests: XCTestCase {
    var app: XCUIApplication!
    /// Keeps trip names unique, since trips from earlier runs stay in the list.
    /// Digits only, so autocorrect leaves the typed name alone.
    let runID = String(Int(Date().timeIntervalSince1970) % 1_000_000)

    /// Business Weekend has 11 items and 10 of them are essential. Essentials
    /// start out selected, so the two apply buttons add different counts.
    let template = "Business Weekend"
    let allItems = "0 of 11 packed"
    let essentialItems = "0 of 10 packed"

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        // CloudKit cannot resolve its container on a simulator with no iCloud
        // account and takes the app down with it. See CoreDataManager.
        app.launchArguments += ["-PacBagDisableCloudKit"]
        app.launch()
        dismissOnboardingIfPresent()
    }

    func testApplyingATemplateReturnsToTheBag() throws {
        openTemplateListFromEmptyBag(trip: "Apply All Check \(runID)")
        openTemplateDetail()

        tapAfterScrolling(app.buttons["Apply Template to Carry-on"])
        let confirm = app.alerts.buttons["Apply All Items"].firstMatch
        XCTAssertTrue(confirm.waitForExistence(timeout: 5), "applying a whole template should ask first")
        confirm.tap()

        assertBackOnBag(showing: allItems)
    }

    func testApplyingSelectedItemsReturnsToTheBag() throws {
        openTemplateListFromEmptyBag(trip: "Apply Selected Check \(runID)")
        openTemplateDetail()

        tapAfterScrolling(app.buttons["Apply Selected Items Only"])

        assertBackOnBag(showing: essentialItems)
    }

    func testCancellingATemplateReturnsToTheList() throws {
        openTemplateListFromEmptyBag(trip: "Cancel Template Check \(runID)")
        openTemplateDetail()

        app.navigationBars[template].buttons["Cancel"].tap()

        XCTAssertTrue(app.navigationBars[template].waitForNonExistence(timeout: 5),
                      "cancelling should close the template")
        XCTAssertTrue(app.navigationBars["Packing Templates"].waitForExistence(timeout: 5),
                      "cancelling should step back to the template list")
    }

    func testApplyingATemplateToANewBagReturnsToTheTrip() throws {
        createTrip(named: "New Bag Check \(runID)")
        tapAddFirstBag()
        type("Carry-on", into: "Bag Name")
        dismissKeyboard()

        tapAfterScrolling(app.buttons["Create with Template"])
        openTemplateDetail()
        tapAfterScrolling(app.buttons["Apply Selected Items Only"])

        XCTAssertTrue(app.navigationBars["Packing Templates"].waitForNonExistence(timeout: 5),
                      "applying should close the template list")
        XCTAssertTrue(app.navigationBars["Add Bag to Trip"].waitForNonExistence(timeout: 5),
                      "the new bag's form should close with the template list")
        XCTAssertTrue(app.staticTexts[essentialItems].firstMatch.waitForExistence(timeout: 5),
                      "the trip should count the template's items")
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

    private func type(_ text: String, into field: String) {
        let element = app.textFields[field].firstMatch
        XCTAssertTrue(element.waitForExistence(timeout: 10), "\(field) field never appeared")
        element.tap()
        element.typeText(text)
    }

    /// Leaves the app on the trip's screen.
    private func createTrip(named trip: String) {
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
    }

    private func tapAddFirstBag() {
        let addBag = app.buttons["Add Your First Bag"].firstMatch
        XCTAssertTrue(addBag.waitForExistence(timeout: 10), "a new trip should offer to add a bag")
        addBag.tap()
    }

    private func openTemplateListFromEmptyBag(trip: String) {
        createTrip(named: trip)
        tapAddFirstBag()
        type("Carry-on", into: "Bag Name")
        dismissKeyboard()
        app.buttons["Save"].firstMatch.tap()

        let bag = app.staticTexts["Carry-on"].firstMatch
        XCTAssertTrue(bag.waitForExistence(timeout: 10), "bag row never appeared")
        bag.tap()

        let useTemplate = app.buttons["Use Template"].firstMatch
        XCTAssertTrue(useTemplate.waitForExistence(timeout: 10), "an empty bag should offer templates")
        useTemplate.tap()
    }

    private func openTemplateDetail() {
        XCTAssertTrue(app.navigationBars["Packing Templates"].waitForExistence(timeout: 10),
                      "the template list never appeared")
        // The card is one button whose label joins all of its text.
        let card = app.buttons.containing(NSPredicate(format: "label CONTAINS %@", template)).firstMatch
        XCTAssertTrue(card.waitForExistence(timeout: 10), "\(template) card never appeared")
        card.tap()
        XCTAssertTrue(app.navigationBars[template].waitForExistence(timeout: 10),
                      "the template detail never appeared")
    }

    /// These buttons sit at the bottom of long screens that only draw what's on screen.
    private func tapAfterScrolling(_ query: XCUIElement) {
        let element = query.firstMatch
        for _ in 0..<10 where !(element.exists && element.isHittable) {
            app.swipeUp()
        }
        XCTAssertTrue(element.isHittable, "\(element) never came on screen")
        element.tap()
    }

    private func assertBackOnBag(showing packedText: String) {
        XCTAssertTrue(app.navigationBars["Packing Templates"].waitForNonExistence(timeout: 5),
                      "applying should close the template list")
        XCTAssertTrue(app.navigationBars["Carry-on"].waitForExistence(timeout: 5),
                      "applying should land back on the bag")
        XCTAssertTrue(app.staticTexts[packedText].firstMatch.waitForExistence(timeout: 5),
                      "the bag should count the template's items")
    }
}
