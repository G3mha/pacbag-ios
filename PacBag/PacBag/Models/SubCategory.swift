import Foundation
import CoreData
import CloudKit

@objc(SubCategory)
public class SubCategory: NSManagedObject, Identifiable {
    
}

extension SubCategory {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<SubCategory> {
        return NSFetchRequest<SubCategory>(entityName: "SubCategory")
    }
    
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var isDefault: Bool
    @NSManaged public var usageCount: Int32
    @NSManaged public var isArchived: Bool
    @NSManaged public var createdDate: Date
    @NSManaged public var lastUsedDate: Date?
    @NSManaged public var category: Category
    @NSManaged public var items: NSSet?
}

// MARK: - Computed Properties
extension SubCategory {
    var itemsArray: [Item] {
        return (items?.allObjects as? [Item]) ?? []
    }
    
    var fullName: String {
        return "\(category.name) > \(name)"
    }
    
    var isRecentlyUsed: Bool {
        guard let lastUsed = lastUsedDate else { return false }
        return Date().timeIntervalSince(lastUsed) < 7 * 24 * 60 * 60 // 7 days
    }
    
    var isPopular: Bool {
        return usageCount >= 3
    }
}

// MARK: - Core Data Generated accessors for items
extension SubCategory {
    @objc(addItemsObject:)
    @NSManaged public func addToItems(_ value: Item)

    @objc(removeItemsObject:)
    @NSManaged public func removeFromItems(_ value: Item)

    @objc(addItems:)
    @NSManaged public func addToItems(_ values: NSSet)

    @objc(removeItems:)
    @NSManaged public func removeFromItems(_ values: NSSet)
}