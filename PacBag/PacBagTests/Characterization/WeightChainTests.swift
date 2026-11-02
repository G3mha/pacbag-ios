import XCTest
@testable import PacBag

/// Pins the weight chain as it stands today. Nothing flips these, so they stay forever.
@MainActor
final class WeightChainTests: XCTestCase {
    private var coreData: CoreDataManager!
    private var make: ModelFactory!

    override func setUp() async throws {
        coreData = CoreDataManager(inMemory: true)
        make = ModelFactory(context: coreData.context)
    }

    func testItemTotalIsWeightTimesQuantity() {
        XCTAssertEqual(make.item(weight: 0.25, quantity: 4).totalWeight, 1.0, accuracy: 0.0001)
    }

    func testItemsWeightWalksNestedSubBagsAndCountsTheirOwnWeight() {
        let main = make.bag("Main", bagWeight: 3)
        make.item(in: main, weight: 1, quantity: 2)
        let sub = make.bag("Sub", parent: main, bagWeight: 0.5)
        make.item(in: sub, weight: 0.25)
        let nested = make.bag("Nested", parent: sub, bagWeight: 0.1)
        make.item(in: nested, weight: 0.5, quantity: 3)

        XCTAssertEqual(nested.itemsWeight, 1.5, accuracy: 0.0001)
        XCTAssertEqual(nested.totalWeight, 1.6, accuracy: 0.0001)
        XCTAssertEqual(sub.itemsWeight, 1.85, accuracy: 0.0001)
        XCTAssertEqual(sub.totalWeight, 2.35, accuracy: 0.0001)
        XCTAssertEqual(main.itemsWeight, 4.35, accuracy: 0.0001)
    }

    func testBagTotalAddsTheEmptyBagWeight() {
        let bag = make.bag(bagWeight: 3)
        make.item(in: bag, weight: 2)

        XCTAssertEqual(bag.itemsWeight, 2, accuracy: 0.0001)
        XCTAssertEqual(bag.totalWeight, 5, accuracy: 0.0001)
    }

    func testTripTotalAddsItsBagsWithBagWeights() {
        let trip = make.trip()
        let first = make.bag("A", in: trip, bagWeight: 1)
        make.item(in: first, weight: 2)
        let second = make.bag("B", in: trip, bagWeight: 0.5)
        make.item(in: second, weight: 0.5, quantity: 2)

        XCTAssertEqual(trip.totalWeight, 4.5, accuracy: 0.0001)
    }

    func testSubBagWithNoTripIsNotCountedTwice() {
        let trip = make.trip()
        let main = make.bag("Main", in: trip, bagWeight: 1)
        let sub = make.bag("Sub", parent: main, bagWeight: 0.5)
        make.item(in: sub, weight: 2)

        XCTAssertNil(sub.trip)
        XCTAssertEqual(trip.bagsArray.count, 1)
        XCTAssertEqual(trip.totalWeight, 3.5, accuracy: 0.0001)
    }

    func testWeightUtilizationIncludesTheBagAndGuardsAZeroLimit() {
        let bag = make.bag(bagWeight: 2, maxWeight: 10)
        make.item(in: bag, weight: 3)
        XCTAssertEqual(bag.weightUtilization, 0.5, accuracy: 0.0001)

        let noLimit = make.bag(bagWeight: 2, maxWeight: 0)
        XCTAssertEqual(noLimit.weightUtilization, 0)
    }

    func testWeightUtilizationCanGoOverOne() {
        let bag = make.bag(bagWeight: 2, maxWeight: 4)
        make.item(in: bag, weight: 4)
        XCTAssertEqual(bag.weightUtilization, 1.5, accuracy: 0.0001)
    }
}
