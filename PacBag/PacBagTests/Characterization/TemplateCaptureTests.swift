import XCTest
@testable import PacBag

/// Pinned bugs: a captured template stores the display text as its category, so a
/// subcategory comes back as "Clothes > Tops" and no category as "Uncategorized".
/// The `TemplateItem(item:)` commit flips both.
@MainActor
final class TemplateCaptureTests: XCTestCase {
    private var coreData: CoreDataManager!
    private var make: ModelFactory!

    override func setUp() async throws {
        coreData = CoreDataManager(inMemory: true)
        make = ModelFactory(context: coreData.context)
    }

    private func capture(_ bag: Bag) -> PackingTemplate {
        PackingTemplateManager.shared.createCustomTemplate(from: bag, name: "Captured", description: "", tripType: .business, duration: .weekend, season: .allSeason)
    }

    func testCaptureStoresDisplayTextAsCategory() {
        let bag = make.bag()
        let clothes = make.category("Clothes")
        let shirt = make.item("Shirt", in: bag)
        shirt.categoryEntity = clothes
        shirt.subcategoryEntity = make.subcategory("Tops", in: clothes)
        make.item("Loose", in: bag)

        let byName = Dictionary(uniqueKeysWithValues: capture(bag).items.map { ($0.name, $0.category) })

        XCTAssertEqual(byName["Shirt"], "Clothes > Tops")
        XCTAssertEqual(byName["Loose"], "Uncategorized")
    }

    func testCaptureWalksSubBagsAndCopiesWeightQuantityAndDescription() {
        let bag = make.bag()
        let sub = make.bag("Sub", parent: bag)
        make.item("Deep", in: sub, weight: 0.4, quantity: 2, isPacked: true, description: "note")

        let items = capture(bag).items

        XCTAssertEqual(items.count, 1)
        XCTAssertEqual(items[0].weight, 0.4, accuracy: 0.0001)
        XCTAssertEqual(items[0].quantity, 2)
        XCTAssertEqual(items[0].description, "note")
        XCTAssertTrue(items[0].isEssential, "packed state is used as the essential flag")
    }
}
