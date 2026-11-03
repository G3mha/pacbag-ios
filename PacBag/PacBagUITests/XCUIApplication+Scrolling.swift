import XCTest

extension XCUIApplication {
    /// The trip list runs soonest first, so a new trip can land below the fold,
    /// and a list only exposes the rows it has drawn.
    func scrollUntilExists(_ element: XCUIElement, maxSwipes: Int = 6) -> Bool {
        for _ in 0..<maxSwipes {
            if element.waitForExistence(timeout: 2) { return true }
            swipeUp()
        }
        return element.waitForExistence(timeout: 2)
    }
}
