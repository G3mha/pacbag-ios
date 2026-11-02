import CoreData
import Foundation

/// Turns a typed line into a row. A weight and category come from the user's own items first,
/// because a correction should stick, then from the catalog. Otherwise the row stays not weighed.
@MainActor
enum QuickAdd {
    @discardableResult
    static func add(_ line: String, to bag: Bag, in context: NSManagedObjectContext) -> Item? {
        let entry = EntryParser.parse(line)
        guard !entry.name.isEmpty else { return nil }

        let item = Item(context: context)
        item.id = UUID()
        item.name = entry.name
        item.quantity = Int32(entry.quantity)
        item.bag = bag
        fill(item, in: context)
        bag.currentWeight += item.totalWeight
        try? context.save()
        return item
    }

    static func remove(_ item: Item, in context: NSManagedObjectContext) {
        if let bag = item.bag {
            bag.currentWeight = max(0, bag.currentWeight - item.totalWeight)
        }
        context.delete(item)
        try? context.save()
    }

    private static func fill(_ item: Item, in context: NSManagedObjectContext) {
        let request = Item.fetchRequest()
        request.predicate = NSPredicate(format: "name ==[c] %@ AND SELF != %@", item.name, item)
        let own = (try? context.fetch(request)) ?? []
        let catalog = ItemCatalog.lookup(item.name)

        if let category = own.lazy.compactMap(\.category).first ?? catalog?.category {
            setCategory(category, on: item)
        }
        if let known = own.first(where: { $0.isWeighed && !$0.isWeightEstimated }) {
            item.weight = known.weight
            item.weightSource = WeightSource.entered.rawValue
        } else if let catalog {
            item.weight = catalog.grams / 1000
            item.weightSource = WeightSource.catalog.rawValue
        }
    }

    static func setCategory(_ name: String, on item: Item) {
        let manager = CategoryManager.shared
        item.category = name
        item.categoryEntity = manager.category(named: name)
        if let entity = item.categoryEntity { manager.incrementUsage(for: entity) }
    }
}
