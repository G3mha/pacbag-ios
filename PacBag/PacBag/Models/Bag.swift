import Foundation
import CoreData
import CloudKit

@objc(Bag)
public class Bag: NSManagedObject {
    
}

extension Bag {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Bag> {
        return NSFetchRequest<Bag>(entityName: "Bag")
    }
    
    @NSManaged public var name: String
    @NSManaged public var maxWeight: Double
    @NSManaged public var currentWeight: Double
    @NSManaged public var trip: Trip?
    @NSManaged public var items: NSSet?
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