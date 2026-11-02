import CoreData
import XCTest
@testable import PacBag

/// These never load a store: they read `storeDescription`, which is built before anything opens.
final class CoreDataManagerTests: XCTestCase {
    func testDefaultStoreMatchesTheContainersDefaultAndKeepsItsOptions() {
        let description = CoreDataManager(inMemory: false).storeDescription
        let unloaded = NSPersistentCloudKitContainer(name: "PacBagModel", managedObjectModel: CoreDataManager.model)

        XCTAssertEqual(description.url, unloaded.persistentStoreDescriptions.first?.url)
        assertSyncKeysAreSet(description)
    }

    func testInMemoryStoreIsDevNullWithNoCloudKit() {
        let description = CoreDataManager(inMemory: true).storeDescription

        XCTAssertEqual(description.url?.path, "/dev/null")
        XCTAssertNil(description.cloudKitContainerOptions)
    }

    func testStoreURLWithoutCloudKitKeepsItsKeys() {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID()).sqlite")
        let description = CoreDataManager(storeURL: url, cloudKit: false).storeDescription

        XCTAssertEqual(description.url, url)
        XCTAssertNil(description.cloudKitContainerOptions)
        assertSyncKeysAreSet(description)
    }

    func testCloudKitStoreUsesTheOneContainerID() {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID()).sqlite")
        let description = CoreDataManager(storeURL: url, cloudKit: true).storeDescription

        XCTAssertEqual(description.cloudKitContainerOptions?.containerIdentifier, CoreDataManager.cloudKitContainerID)
    }

    func testHostedTestsUseTheInMemoryStore() {
        XCTAssertTrue(LaunchOption.usesInMemoryStore)
        XCTAssertEqual(CoreDataManager.shared.storeDescription.url?.path, "/dev/null")
    }

    private func assertSyncKeysAreSet(_ description: NSPersistentStoreDescription, line: UInt = #line) {
        XCTAssertEqual(description.options[NSPersistentHistoryTrackingKey] as? NSNumber, true, line: line)
        XCTAssertEqual(description.options[NSPersistentStoreRemoteChangeNotificationPostOptionKey] as? NSNumber, true, line: line)
    }
}
