import XCTest

/// Checks the arithmetic behind the empty-bag weight, which is the change 1.0.1
/// is built around: a bag's total is its own weight plus its contents, and the
/// capacity left for items is the limit minus the bag.
@MainActor
final class WeightTests: PacBagUITestCase {
    override func setUpWithError() throws {
        try super.setUpWithError()
        launch()
    }

    func testAvailableCapacityIsLimitMinusBagWeight() throws {
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
        createTrip(name: "Type Check", destination: "Nowhere")
        openTrip("Type Check")
        openAddBag()

        // A tote is 0.5 kg empty where a suitcase is 4.5, so picking one has to
        // move both the bag weight and what is left for items.
        app.buttons["Backpack"].firstMatch.tap()
        XCTAssertTrue(app.staticTexts["1.5 kg"].firstMatch.waitForExistence(timeout: 5),
                      "a backpack should default to 1.5 kg empty")
    }
}
