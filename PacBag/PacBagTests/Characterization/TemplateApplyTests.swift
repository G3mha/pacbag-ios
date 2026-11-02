import CoreData
import XCTest
@testable import PacBag

/// `applyTemplate` today. The template apply commit flips the string-only category and the untrimmed name.
@MainActor
final class TemplateApplyTests: XCTestCase {
    private var coreData: CoreDataManager!
    private var make: ModelFactory!

    override func setUp() async throws {
        coreData = CoreDataManager(inMemory: true)
        make = ModelFactory(context: coreData.context)
    }

    private func template(_ items: [TemplateItem]) -> PackingTemplate {
        PackingTemplate(name: "T", description: "", tripType: .business, duration: .weekend, season: .allSeason, items: items, icon: "bag", color: "blue", isDefault: false)
    }

    func testAddsOneRowPerTemplateItem() {
        let bag = make.bag()
        make.item("Already here", in: bag)

        PackingTemplateManager.shared.applyTemplate(template([
            TemplateItem(name: "A", category: "Clothes"),
            TemplateItem(name: "B", category: "Clothes"),
        ]), to: bag, context: coreData.context)

        XCTAssertEqual(bag.itemsArray.count, 3)
    }

    func testStoresTheStringCategoryWithNoEntity() {
        let bag = make.bag()
        _ = make.category("Clothes")

        PackingTemplateManager.shared.applyTemplate(template([
            TemplateItem(name: "Shirt", category: "Clothes"),
        ]), to: bag, context: coreData.context)

        let item = bag.itemsArray[0]
        XCTAssertEqual(item.category, "Clothes")
        XCTAssertNil(item.categoryEntity, "a category with that name exists, and apply still doesn't link it")
        XCTAssertNil(item.subcategory)
        XCTAssertNil(item.subcategoryEntity)
    }

    func testKeepsTheNameUntrimmedAndCopiesTheOtherFields() {
        let bag = make.bag()

        PackingTemplateManager.shared.applyTemplate(template([
            TemplateItem(name: "  Shirt ", category: "Clothes", weight: 0.3, quantity: 4, isEssential: true, description: "note"),
        ]), to: bag, context: coreData.context)

        let item = bag.itemsArray[0]
        XCTAssertEqual(item.name, "  Shirt ")
        XCTAssertEqual(item.weight, 0.3, accuracy: 0.0001)
        XCTAssertEqual(item.quantity, 4)
        XCTAssertEqual(item.itemDescription, "note")
    }

    func testIsPackedStartsFalseEvenForAnEssentialItem() {
        let bag = make.bag()

        PackingTemplateManager.shared.applyTemplate(template([
            TemplateItem(name: "Shirt", category: "Clothes", isEssential: true),
        ]), to: bag, context: coreData.context)

        XCTAssertFalse(bag.itemsArray[0].isPacked)
    }

    func testSavesTheContext() {
        let bag = make.bag()

        PackingTemplateManager.shared.applyTemplate(template([
            TemplateItem(name: "Shirt", category: "Clothes"),
        ]), to: bag, context: coreData.context)

        XCTAssertFalse(coreData.context.hasChanges)
    }
}
