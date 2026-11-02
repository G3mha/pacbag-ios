import CoreData
import XCTest
@testable import PacBag

/// Seeding, delete and usage today. The `recordUse` commit flips the parent count to 1.
@MainActor
final class CategoryManagerTests: XCTestCase {
    private var coreData: CoreDataManager!
    private var manager: CategoryManager!
    private var make: ModelFactory!

    override func setUp() async throws {
        coreData = CoreDataManager(inMemory: true)
        manager = CategoryManager(coreData: coreData)
        make = ModelFactory(context: coreData.context)
    }

    func testSeedsEightCategoriesWithTheirSubcategories() {
        let counts = Dictionary(uniqueKeysWithValues: manager.categories.map { ($0.name, $0.subcategoriesArray.count) })

        XCTAssertEqual(counts, [
            "General": 0,
            "Clothes": 6,
            "Medication": 4,
            "Electronics": 5,
            "Toiletries": 5,
            "Documents": 5,
            "Shoes": 5,
            "Accessories": 5,
        ])
        XCTAssertTrue(manager.categories.allSatisfy(\.isDefault))
    }

    func testAnInstanceSavesToItsOwnStoreAndLeavesSharedAlone() throws {
        manager.createCategory("Only Here")
        manager.saveContext()

        let request = PacBag.Category.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", "Only Here")
        XCTAssertEqual(try coreData.context.count(for: request), 1)
        XCTAssertEqual(try CoreDataManager.shared.context.count(for: request), 0)
    }

    func testDeleteMovesItemsToTheNewCategoryAndArchives() throws {
        let clothes = try XCTUnwrap(manager.category(named: "Clothes"))
        let general = try XCTUnwrap(manager.category(named: "General"))
        let tops = try XCTUnwrap(clothes.subcategoriesArray.first { $0.name == "Tops" })
        let item = make.item("Shirt", category: "Clothes", subcategory: "Tops")
        item.categoryEntity = clothes
        item.subcategoryEntity = tops

        manager.deleteCategory(clothes, moveItemsTo: general)

        XCTAssertEqual(item.categoryEntity, general)
        XCTAssertEqual(item.category, "General")
        XCTAssertNil(item.subcategoryEntity)
        XCTAssertNil(item.subcategory)
        XCTAssertTrue(clothes.isArchived)
        XCTAssertTrue(tops.isArchived)
    }

    func testDeleteWithNoTargetClearsTheCategory() throws {
        let clothes = try XCTUnwrap(manager.category(named: "Clothes"))
        let item = make.item("Shirt", category: "Clothes")
        item.categoryEntity = clothes

        manager.deleteCategory(clothes)

        XCTAssertNil(item.categoryEntity)
        XCTAssertNil(item.category)
        XCTAssertEqual(item.fullCategory, "Uncategorized")
    }

    func testDeletedCategoryLeavesTheFetchAfterAReload() throws {
        let clothes = try XCTUnwrap(manager.category(named: "Clothes"))

        manager.deleteCategory(clothes)
        manager.loadCategories()

        XCTAssertNil(manager.category(named: "Clothes"))
        XCTAssertEqual(manager.categories.count, 7)
    }

    /// The call pair `AddItemView.saveItem` and `ItemDetailView.saveChanges` make today.
    func testOneSubcategoryUseCountsTheParentTwice() throws {
        let clothes = try XCTUnwrap(manager.category(named: "Clothes"))
        let tops = try XCTUnwrap(clothes.subcategoriesArray.first { $0.name == "Tops" })

        manager.incrementUsage(for: clothes)
        manager.incrementUsage(for: tops)

        XCTAssertEqual(clothes.usageCount, 2, "pinned bug: the recordUse commit flips this to 1")
        XCTAssertEqual(tops.usageCount, 1)
        XCTAssertNotNil(clothes.lastUsedDate)
        XCTAssertNotNil(tops.lastUsedDate)
    }

    func testUsageSavesTheContext() throws {
        let clothes = try XCTUnwrap(manager.category(named: "Clothes"))
        _ = make.item("Dirty", category: "Clothes")
        XCTAssertTrue(coreData.context.hasChanges)

        manager.incrementUsage(for: clothes)

        XCTAssertFalse(coreData.context.hasChanges, "pinned as it stands: the recordUse commit removes this hidden save")
    }
}
