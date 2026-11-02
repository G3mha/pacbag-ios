import XCTest
@testable import PacBag

final class EntryParserTests: XCTestCase {
    func testQuantities() {
        let cases: [(String, String, Int)] = [
            ("a pair of socks", "socks", 1), ("2x chargers", "chargers", 2), ("2 pairs of jeans", "jeans", 2),
            ("3 tshirts", "tshirts", 3), ("socks x5", "socks", 5), ("sneakers (2 pairs)", "sneakers", 2),
            ("three shirts", "shirts", 3), ("2 USB-C cables", "USB-C cables", 2), ("3 tablets", "tablets", 3),
        ]
        for (text, name, quantity) in cases {
            XCTAssertEqual(EntryParser.parse(text), ParsedEntry(name: name, quantity: quantity, quantityWasParsed: true), text)
        }
    }

    func testLiteralNames() {
        for text in ["2 person tent", "iPhone 15", "Socks 3", "4 x 6 photos", "4x6 photos", "200 socks", "24 pack batteries"] {
            XCTAssertEqual(EntryParser.parse(text), ParsedEntry(name: text, quantity: 1, quantityWasParsed: false), text)
        }
    }

    func testCatalogMatchesThePluralAndTheEndOfAName() {
        XCTAssertEqual(ItemCatalog.lookup("Socks")?.category, "Clothes")
        XCTAssertEqual(ItemCatalog.lookup("wool socks")?.key, "socks")
        XCTAssertNil(ItemCatalog.lookup("zzzz"))
    }
}
