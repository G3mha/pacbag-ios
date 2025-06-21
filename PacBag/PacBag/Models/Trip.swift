import Foundation
import CoreData
import CloudKit

@objc(Trip)
public class Trip: NSManagedObject {
    
}

extension Trip {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Trip> {
        return NSFetchRequest<Trip>(entityName: "Trip")
    }
    
    @NSManaged public var name: String
    @NSManaged public var startDate: Date
    @NSManaged public var endDate: Date
    @NSManaged public var destination: String
    @NSManaged public var bags: NSSet?
}

// MARK: Generated accessors for bags
extension Trip {
    @objc(addBagsObject:)
    @NSManaged public func addToBags(_ value: Bag)
    
    @objc(removeBagsObject:)
    @NSManaged public func removeFromBags(_ value: Bag)
    
    @objc(addBags:)
    @NSManaged public func addToBags(_ values: NSSet)
    
    @objc(removeBags:)
    @NSManaged public func removeFromBags(_ values: NSSet)
}