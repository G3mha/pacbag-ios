import XCTest
@testable import PacBag

/// Pack counts count rows, never quantity. Nothing flips these.
@MainActor
final class PackCountTests: XCTestCase {
    private var coreData: CoreDataManager!
    private var make: ModelFactory!

    override func setUp() async throws {
        coreData = CoreDataManager(inMemory: true)
        make = ModelFactory(context: coreData.context)
    }

    func testCountsAreRowsNotQuantity() {
        let bag = make.bag()
        make.item("Socks", in: bag, quantity: 5, isPacked: true)
        make.item("Shirt", in: bag, quantity: 3)

        XCTAssertEqual(bag.totalItemsCount, 2)
        XCTAssertEqual(bag.packedItemsCount, 1)
    }

    func testCountsWalkNestedSubBags() {
        let main = make.bag("Main")
        make.item("A", in: main, isPacked: true)
        let sub = make.bag("Sub", parent: main)
        make.item("B", in: sub, isPacked: true)
        let nested = make.bag("Nested", parent: sub)
        make.item("C", in: nested)

        XCTAssertEqual(main.totalItemsCount, 3)
        XCTAssertEqual(main.packedItemsCount, 2)
        XCTAssertEqual(main.totalSubBagsCount, 1, "only the direct sub-bags count here")
    }

    func testPackingProgressIsZeroWhenEmptyAndAFractionOfRows() {
        let bag = make.bag()
        XCTAssertEqual(bag.packingProgress, 0)

        make.item("A", in: bag, quantity: 9, isPacked: true)
        make.item("B", in: bag)
        make.item("C", in: bag)
        make.item("D", in: bag)
        XCTAssertEqual(bag.packingProgress, 0.25, accuracy: 0.0001)
    }

    func testTripTotalsAddTheirBags() {
        let trip = make.trip()
        XCTAssertEqual(trip.packingProgress, 0)

        let first = make.bag("A", in: trip)
        make.item("A1", in: first, isPacked: true)
        let second = make.bag("B", in: trip)
        make.item("B1", in: second)
        let sub = make.bag("Sub", parent: second)
        make.item("S1", in: sub, isPacked: true)
        make.item("S2", in: sub)

        XCTAssertEqual(trip.totalBags, 2, "a sub-bag has no trip, so it isn't one of the trip's bags")
        XCTAssertEqual(trip.totalItems, 4)
        XCTAssertEqual(trip.packedItems, 2)
        XCTAssertEqual(trip.packingProgress, 0.5, accuracy: 0.0001)
    }
}
