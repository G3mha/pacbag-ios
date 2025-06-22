import Foundation
import CoreData
import CloudKit
import UIKit

@objc(Item)
public class Item: NSManagedObject, Identifiable {
    
}

extension Item {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Item> {
        return NSFetchRequest<Item>(entityName: "Item")
    }
    
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var weight: Double
    @NSManaged public var isPacked: Bool
    @NSManaged public var category: String?
    @NSManaged public var itemDescription: String?
    @NSManaged public var quantity: Int32
    @NSManaged public var photoData: Data?
    @NSManaged public var bag: Bag?
    
    // Computed properties for convenience
    var totalWeight: Double {
        return weight * Double(quantity)
    }
    
    var hasPhoto: Bool {
        return photoData != nil
    }
    
    var photo: UIImage? {
        guard let photoData = photoData else { return nil }
        return UIImage(data: photoData)
    }
}