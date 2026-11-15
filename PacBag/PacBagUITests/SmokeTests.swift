import XCTest

/// The flows `scripts/test.sh matrix` runs on every simulator. Keep this at 8 flows or fewer.
@MainActor
final class SmokeTests: PacBagUITestCase {
    /// U4, the automated guard for the iOS 18.5 crash risk in `CategoryAnalyticsView`.
    /// It runs on the default categories with no uses, which is the case TM1 step 4 checks by hand.
    func testCategoryAnalyticsOpensFromSettingsAndScrollsPastTheChart() throws {
        launch()

        let settings = app.navigationBars["My Trips"].buttons.element(boundBy: 0)
        XCTAssertTrue(settings.waitForExistence(timeout: 10), "the trip list should offer Settings")
        settings.tap()

        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 10), "Settings never opened")
        let analytics = app.staticTexts["Category Analytics"].firstMatch
        for _ in 0..<4 where !analytics.exists {
            app.swipeUp()
        }
        XCTAssertTrue(analytics.exists, "Settings should offer Category Analytics")
        analytics.tap()

        XCTAssertTrue(app.navigationBars["Category Analytics"].waitForExistence(timeout: 10), "the analytics sheet never opened")

        // The pages sit behind a segmented picker at the top of the list. Switch
        // before scrolling, so the test never swipes down on the sheet and closes it.
        app.buttons["Trends"].firstMatch.tap()
        // Each launch seeds the default categories fresh, so they all count as recently created.
        XCTAssertTrue(app.staticTexts["Recently Created"].waitForExistence(timeout: 5), "the Trends page never showed")
        app.buttons["Usage"].firstMatch.tap()

        // The chart sits above Top Categories, and is left out when nothing has been used.
        let belowChart = app.staticTexts["Top Categories"].firstMatch
        XCTAssertTrue(belowChart.waitForExistence(timeout: 5), "the Usage page never came back")
        for _ in 0..<4 where !belowChart.isHittable {
            app.swipeUp()
        }
        XCTAssertTrue(belowChart.isHittable, "the Usage page should scroll past the chart")
        app.swipeUp()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 5), "the app should still be up")
    }
}
