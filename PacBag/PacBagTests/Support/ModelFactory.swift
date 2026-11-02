import CoreData
@testable import PacBag

/// Builds rows directly on a context, as they'd sit in a store, with no `ItemStore`.
/// Each suite keeps its own `CoreDataManager(inMemory: true)`, so nothing leaks between tests.
@MainActor
struct ModelFactory {
    let context: NSManagedObjectContext

    func trip(_ name: String = "Trip", destination: String = "Lisbon") -> Trip {
        let trip = Trip(context: context)
        trip.id = UUID()
        trip.name = name
        trip.destination = destination
        return trip
    }

    func bag(_ name: String = "Bag", in trip: Trip? = nil, parent: Bag? = nil, bagWeight: Double = 0, maxWeight: Double = 0) -> Bag {
        let bag = Bag(context: context)
        bag.id = UUID()
        bag.name = name
        bag.bagWeight = bagWeight
        bag.maxWeight = maxWeight
        bag.trip = trip
        bag.parentBag = parent
        return bag
    }

    @discardableResult
    func item(_ name: String = "Item", in bag: Bag? = nil, weight: Double = 0, quantity: Int32 = 1, isPacked: Bool = false, category: String? = nil, subcategory: String? = nil, description: String? = nil) -> Item {
        let item = Item(context: context)
        item.id = UUID()
        item.name = name
        item.weight = weight
        item.quantity = quantity
        item.isPacked = isPacked
        item.category = category
        item.subcategory = subcategory
        item.itemDescription = description
        item.bag = bag
        return item
    }

    func category(_ name: String) -> PacBag.Category {
        let category = PacBag.Category(context: context)
        category.id = UUID()
        category.name = name
        return category
    }

    func subcategory(_ name: String, in category: PacBag.Category) -> SubCategory {
        let subcategory = SubCategory(context: context)
        subcategory.id = UUID()
        subcategory.name = name
        subcategory.category = category
        return subcategory
    }
}
