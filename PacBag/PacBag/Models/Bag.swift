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
    
    // Computed properties for convenience
    var itemsArray: [Item] {
        return (items?.allObjects as? [Item]) ?? []
    }
    
    var packedItemsCount: Int {
        return itemsArray.filter { $0.isPacked }.count
    }
    
    var totalItemsCount: Int {
        return itemsArray.count
    }
    
    var weightUtilization: Double {
        guard maxWeight > 0 else { return 0 }
        return currentWeight / maxWeight
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