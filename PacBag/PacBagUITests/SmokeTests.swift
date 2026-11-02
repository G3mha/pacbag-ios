import XCTest

/// The flows `scripts/test.sh matrix` runs on every simulator. Keep this at 8 flows or fewer.
@MainActor
final class SmokeTests: PacBagUITestCase {
    /// U4, the automated guard for the iOS 18.5 crash risk in `CategoryAnalyticsView`.
    /// It runs with no usage data, because `-PacBagSeed smoke` lands with `DebugSeed`.
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

        let chartTitle = app.staticTexts["Usage Distribution"].firstMatch
        XCTAssertTrue(app.navigationBars["Category Analytics"].waitForExistence(timeout: 10), "the analytics sheet never opened")
        for _ in 0..<4 where !chartTitle.isHittable {
            app.swipeUp()
        }
        XCTAssertTrue(chartTitle.isHittable, "the chart should scroll into view")
        app.swipeUp()

        // The page TabView, by swipe.
        app.swipeLeft()
        XCTAssertTrue(app.buttons["Trends"].firstMatch.waitForExistence(timeout: 5))
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 5), "the app should still be up")
    }
}
