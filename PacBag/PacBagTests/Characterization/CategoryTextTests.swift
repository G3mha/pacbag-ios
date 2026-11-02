import XCTest
@testable import PacBag

/// `fullCategory` today. The category display commit flips "Uncategorized" to "Not sorted".
@MainActor
final class CategoryTextTests: XCTestCase {
    private var coreData: CoreDataManager!
    private var make: ModelFactory!

    override func setUp() async throws {
        coreData = CoreDataManager(inMemory: true)
        make = ModelFactory(context: coreData.context)
    }

    func testEntityWinsOverStrings() {
        let item = make.item(category: "Old String", subcategory: "Old Sub")
        item.categoryEntity = make.category("Clothes")
        XCTAssertEqual(item.fullCategory, "Clothes", "with no subcategory entity, the string subcategory is ignored")
    }

    func testEntityWithSubcategoryJoinsBoth() {
        let item = make.item()
        let clothes = make.category("Clothes")
        item.categoryEntity = clothes
        item.subcategoryEntity = make.subcategory("Tops", in: clothes)
        XCTAssertEqual(item.fullCategory, "Clothes > Tops")
    }

    func testStringOnlyRowFallsBackToItsStrings() {
        XCTAssertEqual(make.item(category: "Clothes").fullCategory, "Clothes")
        XCTAssertEqual(make.item(category: "Clothes", subcategory: "Tops").fullCategory, "Clothes > Tops")
        XCTAssertEqual(make.item(category: "Clothes", subcategory: "").fullCategory, "Clothes")
    }

    func testNeitherReadsUncategorized() {
        XCTAssertEqual(make.item().fullCategory, "Uncategorized")
    }

    func testEmptyStringCategoryReadsAsAnEmptyLabel() {
        XCTAssertEqual(make.item(category: "").fullCategory, "", "pinned as it stands: an empty string isn't treated as no category")
    }
}
