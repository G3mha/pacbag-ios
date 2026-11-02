import CoreData
import XCTest
@testable import PacBag

/// Runs only against a local server started with FAKE_CLAUDE=1, so it never costs anything.
@MainActor
final class PhotoFillTests: XCTestCase {
    func testAPhotoFillsAnEmptyRowButNotATypedWeight() throws {
        try XCTSkipIf(ProcessInfo.processInfo.environment["PACBAG_API_URL"] == nil, "needs a local server")
        AIConsent.shared.grant()
        defer { UserDefaults.standard.removeObject(forKey: DefaultsKey.aiConsent) }

        // The shared stack, which is in memory under tests, because categories live in it.
        let context = CoreDataManager.shared.context
        let bag = Bag(context: context)
        bag.id = UUID()
        bag.name = "Test"
        let image = UIGraphicsImageRenderer(size: CGSize(width: 2000, height: 1000)).image { _ in }
        let jpeg = try XCTUnwrap(image.jpegData(compressionQuality: 0.9))

        let newRow = try XCTUnwrap(QuickAdd.add("Photo item", to: bag, in: context))
        newRow.photoData = jpeg
        fillAndWait(newRow, isNewRow: true, context)
        XCTAssertEqual(newRow.name, "Test backpack")
        XCTAssertEqual(newRow.weight, 0.9)
        XCTAssertEqual(newRow.weightSource, WeightSource.photo.rawValue)

        let typed = Item(context: context)
        typed.id = UUID()
        typed.name = "My pack"
        typed.quantity = 1
        typed.weight = 1.2
        typed.weightSource = WeightSource.entered.rawValue
        typed.bag = bag
        typed.photoData = jpeg
        fillAndWait(typed, isNewRow: false, context)
        XCTAssertEqual(typed.name, "My pack")
        XCTAssertEqual(typed.weight, 1.2)
    }

    // A plain wait, because XCTest's own bridge for async tests aborted in the Swift runtime here.
    private func fillAndWait(_ item: Item, isNewRow: Bool, _ context: NSManagedObjectContext) {
        let done = expectation(description: "photo filled")
        Task { @MainActor in
            await AIFill.shared.fillFromPhoto(item, isNewRow: isNewRow, context: context)
            done.fulfill()
        }
        wait(for: [done], timeout: 60)
    }

    func testUploadsAreSmallAndCarryNoLocation() throws {
        let image = UIGraphicsImageRenderer(size: CGSize(width: 4000, height: 3000)).image { _ in }
        let upload = try XCTUnwrap(AIFill.jpegForUpload(try XCTUnwrap(image.jpegData(compressionQuality: 1))))
        let result = try XCTUnwrap(UIImage(data: upload))
        XCTAssertEqual(max(result.size.width, result.size.height), 1024)
        let source = try XCTUnwrap(CGImageSourceCreateWithData(upload as CFData, nil))
        let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [String: Any]
        XCTAssertNil(properties?[kCGImagePropertyGPSDictionary as String])
    }
}
