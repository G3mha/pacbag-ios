import Foundation
import CoreData
import CloudKit

@objc(Bag)
public class Bag: NSManagedObject, Identifiable {
    
}

extension Bag {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Bag> {
        return NSFetchRequest<Bag>(entityName: "Bag")
    }
    
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var maxWeight: Double
    @NSManaged public var currentWeight: Double
    @NSManaged public var trip: Trip?
    @NSManaged public var items: NSSet?
    @NSManaged public var parentBag: Bag?
    @NSManaged public var subBags: NSSet?
    
    // Computed properties for convenience
    var itemsArray: [Item] {
        return (items?.allObjects as? [Item]) ?? []
    }
    
    var subBagsArray: [Bag] {
        return (subBags?.allObjects as? [Bag]) ?? []
    }
    
    var isSubBag: Bool {
        return parentBag != nil
    }
    
    var isMainBag: Bool {
        return parentBag == nil
    }
    
    var packedItemsCount: Int {
        let directPacked = itemsArray.filter { $0.isPacked }.count
        let subBagsPacked = subBagsArray.reduce(0) { $0 + $1.packedItemsCount }
        return directPacked + subBagsPacked
    }
    
    var totalItemsCount: Int {
        let directItems = itemsArray.count
        let subBagsItems = subBagsArray.reduce(0) { $0 + $1.totalItemsCount }
        return directItems + subBagsItems
    }
    
    var totalSubBagsCount: Int {
        return subBagsArray.count
    }
    
    var packingProgress: Double {
        guard totalItemsCount > 0 else { return 0.0 }
        return Double(packedItemsCount) / Double(totalItemsCount)
    }
    
    // Total weight including sub-bags
    var totalWeight: Double {
        let directWeight = itemsArray.reduce(0) { $0 + $1.totalWeight }
        let subBagsWeight = subBagsArray.reduce(0) { $0 + $1.totalWeight }
        return directWeight + subBagsWeight
    }
    
    var weightUtilization: Double {
        guard maxWeight > 0 else { return 0 }
        return totalWeight / maxWeight
    }
}

// MARK: Generated accessors for items
extension Bag {
    @objc(addItemsObject:)
    @NSManaged public func addToItems(_ value: Item)
    
    @objc(removeItemsObject:)
    @NSManaged public func removeFromItems(_ value: Item)
    
    @objc(addItems:)
    @NSManaged public func addToItems(_ values: NSSet)
    
    @objc(removeItems:)
    @NSManaged public func removeFromItems(_ values: NSSet)
}

// MARK: Generated accessors for subBags
extension Bag {
    @objc(addSubBagsObject:)
    @NSManaged public func addToSubBags(_ value: Bag)
    
    @objc(removeSubBagsObject:)
    @NSManaged public func removeFromSubBags(_ value: Bag)
    
    @objc(addSubBags:)
    @NSManaged public func addToSubBags(_ values: NSSet)
    
    @objc(removeSubBags:)
    @NSManaged public func removeFromSubBags(_ values: NSSet)
}