import XCTest
@testable import PacBag

final class DestinationTextTests: XCTestCase {
    func testEndsWithTheCountrysFlag() {
        XCTAssertEqual(CitySearch.destinationText(title: "Lisbon", subtitle: "Portugal"), "Lisbon 🇵🇹")
        XCTAssertEqual(CitySearch.destinationText(title: "Austin", subtitle: "TX, United States"), "Austin, TX 🇺🇸")
    }

    func testDropsARegionThatRepeatsTheCity() {
        XCTAssertEqual(CitySearch.destinationText(title: "Kyoto", subtitle: "Kyoto, Japan"), "Kyoto 🇯🇵")
    }

    func testFlagsACityStateByItsOwnName() {
        XCTAssertEqual(CitySearch.destinationText(title: "Singapore", subtitle: " "), "Singapore 🇸🇬")
        XCTAssertEqual(CitySearch.flag(title: "Singapore", subtitle: ""), "🇸🇬")
    }

    func testWritesOutACountryWithoutAFlag() {
        XCTAssertEqual(CitySearch.destinationText(title: "Somewhere", subtitle: "Atlantis"), "Somewhere, Atlantis")
        XCTAssertEqual(CitySearch.flag(title: "Somewhere", subtitle: "Atlantis"), "📍")
    }

    func testFlagsACountryNamedTheWayMapsNamesIt() {
        XCTAssertEqual(CitySearch.destinationText(title: "Saint Vincent and the Grenadines", subtitle: ""),
                       "Saint Vincent and the Grenadines 🇻🇨")
        XCTAssertEqual(CitySearch.flag(title: "Trinidad and Tobago", subtitle: ""), "🇹🇹")
        XCTAssertEqual(CitySearch.flag(title: "Kingstown", subtitle: "Saint Vincent and the Grenadines"), "🇻🇨")
        XCTAssertEqual(CitySearch.flag(title: "Yangon", subtitle: "Myanmar"), "🇲🇲")
        XCTAssertEqual(CitySearch.flag(title: "Nassau", subtitle: "The Bahamas"), "🇧🇸")
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
