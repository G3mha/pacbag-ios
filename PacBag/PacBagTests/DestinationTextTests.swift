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

    func testShowsTheCountrysFlag() {
        XCTAssertEqual(CitySearch.flag(title: "Lisbon", subtitle: "Portugal"), "🇵🇹")
        XCTAssertEqual(CitySearch.flag(title: "Singapore", subtitle: ""), "🇸🇬")
        XCTAssertEqual(CitySearch.flag(title: "Somewhere", subtitle: "Atlantis"), "📍")
    }

    func testFlagsMatchIgnoringAccents() {
        XCTAssertEqual(CitySearch.flag(title: "São Paulo", subtitle: "São Paulo, Brazil"), "🇧🇷")
    }

    func testSpellsFlagsOutForSearching() {
        XCTAssertEqual(CountryFlag.withNames("Lisbon 🇵🇹"), "Lisbon Portugal")
        XCTAssertEqual(CountryFlag.removed("Lisbon 🇵🇹"), "Lisbon")
        XCTAssertEqual(CountryFlag.withNames("Grandma's house"), "Grandma's house")
    }

    func testBoldsOnlyTheMatchedLetters() {
        let text = CitySearch.highlighted("Kyoto", ranges: [NSValue(range: NSRange(location: 0, length: 3))])
        let bold = text.runs.filter { $0.font != nil }.map { String(text[$0.range].characters) }
        XCTAssertEqual(bold, ["Kyo"])
    }
}
