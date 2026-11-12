//
//  PacBagUITestsLaunchTests.swift
//  PacBagUITests
//
//  Created by Enricco Gemha on 18/06/25.
//

import XCTest

final class PacBagUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    /// Each run sets its own orientation, and the last one can be landscape.
    /// Put the simulator back so later tests and people find it upright.
    override func tearDownWithError() throws {
        MainActor.assumeIsolated {
            XCUIDevice.shared.orientation = .portrait
        }
    }

    @MainActor
    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        // Insert steps here to perform after app launch but before taking a screenshot,
        // such as logging into a test account or navigating somewhere in the app

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
