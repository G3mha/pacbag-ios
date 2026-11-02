import CoreData
import XCTest
@testable import PacBag

/// Someone on 1.0.1 has a store without `weightSource`. Their items have to survive opening it.
final class StoreUpgradeTests: XCTestCase {
    func testAStoreFromBeforeWeightSourceKeepsItsItems() throws {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("upgrade-\(UUID()).sqlite")
        defer { try? FileManager.default.removeItem(at: url) }

        let oldModel = CoreDataManager.model.copy() as! NSManagedObjectModel
        let itemEntity = try XCTUnwrap(oldModel.entitiesByName["Item"])
        itemEntity.properties = itemEntity.properties.filter { $0.name != "weightSource" }

        let old = NSPersistentContainer(name: "PacBagModel", managedObjectModel: oldModel)
        let description = NSPersistentStoreDescription(url: url)
        description.shouldAddStoreAsynchronously = false
        old.persistentStoreDescriptions = [description]
        var loadError: Error?
        old.loadPersistentStores { _, error in loadError = error }
        XCTAssertNil(loadError)
        let row = NSEntityDescription.insertNewObject(forEntityName: "Item", into: old.viewContext)
        row.setValue(UUID(), forKey: "id")
        row.setValue("Old socks", forKey: "name")
        row.setValue(0.2, forKey: "weight")
        row.setValue(Int32(3), forKey: "quantity")
        try old.viewContext.save()
        for store in old.persistentStoreCoordinator.persistentStores {
            try old.persistentStoreCoordinator.remove(store)
        }

        let upgraded = CoreDataManager(storeURL: url, cloudKit: false)
        let items = try upgraded.context.fetch(Item.fetchRequest())
        XCTAssertEqual(items.count, 1)
        XCTAssertEqual(items.first?.name, "Old socks")
        XCTAssertEqual(items.first?.weight, 0.2)
        XCTAssertEqual(items.first?.quantity, 3)
        XCTAssertNil(items.first?.weightSource)
        XCTAssertEqual(items.first?.isWeightEstimated, false, "an old typed weight stays a typed weight")
    }
}
