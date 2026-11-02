import Foundation
import CoreData
import CloudKit
import UIKit

/// Where a weight came from. An item with no source and a weight above 0 was typed before this
/// field existed, so it counts as entered.
enum WeightSource: String {
    case entered, catalog, ai, photo
    /// AI was asked and had no answer, so the row stays not weighed and isn't asked about again.
    case skipped
}

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
    @NSManaged public var subcategory: String?
    @NSManaged public var itemDescription: String?
    @NSManaged public var quantity: Int32
    @NSManaged public var photoData: Data?
    @NSManaged public var weightSource: String?
    @NSManaged public var bag: Bag?
    @NSManaged public var categoryEntity: Category?
    @NSManaged public var subcategoryEntity: SubCategory?
    
    /// A deleted item's `id` and `name` read as nil, which traps in these non-optional properties.
    var isGone: Bool {
        return isDeleted || managedObjectContext == nil
    }
    
    // Computed properties for convenience
    var totalWeight: Double {
        return weight * Double(quantity)
    }
    
    var isWeighed: Bool {
        return weight > 0
    }
    
    var isWeightEstimated: Bool {
        guard isWeighed, let weightSource else { return false }
        return weightSource != WeightSource.entered.rawValue && weightSource != WeightSource.skipped.rawValue
    }
    
    var hasPhoto: Bool {
        return photoData != nil
    }
    
    var photo: UIImage? {
        guard let photoData = photoData else { return nil }
        return UIImage(data: photoData)
    }
    
    // Hierarchical category helpers
    var fullCategory: String {
        // Use entity relationships if available (new system)
        if let categoryEntity = categoryEntity {
            if let subcategoryEntity = subcategoryEntity {
                return "\(categoryEntity.name) > \(subcategoryEntity.name)"
            }
            return categoryEntity.name
        }
        
        // Fallback to string properties (legacy system)
        if let category = category {
            if let subcategory = subcategory, !subcategory.isEmpty {
                return "\(category) > \(subcategory)"
            }
            return category
        }
        
        return "Uncategorized"
    }
}