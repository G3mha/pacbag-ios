import Foundation
import CoreData
import CloudKit

@objc(Item)
public class Item: NSManagedObject {
    
}

extension Item {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Item> {
        return NSFetchRequest<Item>(entityName: "Item")
    }
    
    @NSManaged public var name: String
    @NSManaged public var weight: Double
    @NSManaged public var isPacked: Bool
    @NSManaged public var category: String?
    @NSManaged public var bag: Bag?
}