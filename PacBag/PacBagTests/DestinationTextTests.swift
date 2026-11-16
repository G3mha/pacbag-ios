import XCTest
@testable import PacBag

final class DestinationTextTests: XCTestCase {
    func testJoinsCityAndPlace() {
        XCTAssertEqual(CitySearch.destinationText(title: "Austin", subtitle: "TX, United States"), "Austin, TX, United States")
    }

    func testDropsARegionThatRepeatsTheCity() {
        XCTAssertEqual(CitySearch.destinationText(title: "Kyoto", subtitle: "Kyoto, Japan"), "Kyoto, Japan")
    }

    func testDropsAnEmptySubtitle() {
        XCTAssertEqual(CitySearch.destinationText(title: "Singapore", subtitle: " "), "Singapore")
    }
}
