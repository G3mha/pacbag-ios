import CoreData
import XCTest
@testable import PacBag

/// Two devices each seed "Clothes". After the first sync, one has to remain with everything on it.
@MainActor
final class CategoryMergeTests: XCTestCase {
    func testDuplicatesMergeOntoTheLowestIDAndKeepTheirItems() throws {
        let store = CoreDataManager(inMemory: true)
        let manager = CategoryManager(coreData: store)
        let context = store.context
        let first = manager.createCategory("Trekking")
        let second = manager.createCategory("trekking ")
        let keeper = first.id.uuidString < second.id.uuidString ? first : second
        let other = keeper === first ? second : first

        let keeperSub = manager.createSubcategory("Poles", in: keeper)
        let otherSub = manager.createSubcategory("Poles", in: other)
        let uniqueSub = manager.createSubcategory("Maps", in: other)

        let item = Item(context: context)
        item.id = UUID()
        item.name = "Pole"
        item.quantity = 1
        item.categoryEntity = other
        item.subcategoryEntity = otherSub
        try context.save()

        let lowestSub = keeperSub.id.uuidString < otherSub.id.uuidString ? keeperSub : otherSub
        manager.mergeDuplicates()

        let matches = try context.fetch(Category.fetchRequest()).filter { $0.name.lowercased().hasPrefix("trekking") }
        XCTAssertEqual(matches.count, 1)
        XCTAssertEqual(matches.first?.objectID, keeper.objectID)
        XCTAssertEqual(item.categoryEntity?.objectID, keeper.objectID)
        XCTAssertEqual(item.subcategoryEntity?.objectID, lowestSub.objectID)
        XCTAssertEqual(keeper.subcategoriesArray.map(\.name), ["Maps", "Poles"], "only one Poles should remain")
        XCTAssertEqual(uniqueSub.category.objectID, keeper.objectID)
    }

    func testMergingTwiceChangesNothing() throws {
        let store = CoreDataManager(inMemory: true)
        let manager = CategoryManager(coreData: store)
        let before = try store.context.count(for: Category.fetchRequest())
        manager.mergeDuplicates()
        XCTAssertEqual(try store.context.count(for: Category.fetchRequest()), before)
    }
}
