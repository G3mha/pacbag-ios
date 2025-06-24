import Foundation
import CoreData
import CloudKit
import SwiftUI

@objc(Category)
public class Category: NSManagedObject, Identifiable {
    
}

extension Category {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Category> {
        return NSFetchRequest<Category>(entityName: "Category")
    }
    
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var isDefault: Bool
    @NSManaged public var usageCount: Int32
    @NSManaged public var iconName: String?
    @NSManaged public var colorHex: String?
    @NSManaged public var isArchived: Bool
    @NSManaged public var createdDate: Date
    @NSManaged public var lastUsedDate: Date?
    @NSManaged public var subcategories: NSSet?
    @NSManaged public var items: NSSet?
}

// MARK: - Computed Properties
extension Category {
    var subcategoriesArray: [SubCategory] {
        return (subcategories?.allObjects as? [SubCategory])?.sorted { $0.name < $1.name } ?? []
    }
    
    var itemsArray: [Item] {
        return (items?.allObjects as? [Item]) ?? []
    }
    
    var color: Color {
        if let colorHex = colorHex {
            return Color(hex: colorHex)
        }
        return .blue // Default color
    }
    
    var icon: String {
        return iconName ?? "folder.fill"
    }
    
    var isRecentlyUsed: Bool {
        guard let lastUsed = lastUsedDate else { return false }
        return Date().timeIntervalSince(lastUsed) < 7 * 24 * 60 * 60 // 7 days
    }
    
    var isPopular: Bool {
        return usageCount >= 5
    }
}

// MARK: - Core Data Generated accessors for subcategories
extension Category {
    @objc(addSubcategoriesObject:)
    @NSManaged public func addToSubcategories(_ value: SubCategory)

    @objc(removeSubcategoriesObject:)
    @NSManaged public func removeFromSubcategories(_ value: SubCategory)

    @objc(addSubcategories:)
    @NSManaged public func addToSubcategories(_ values: NSSet)

    @objc(removeSubcategories:)
    @NSManaged public func removeFromSubcategories(_ values: NSSet)
}

// MARK: - Core Data Generated accessors for items
extension Category {
    @objc(addItemsObject:)
    @NSManaged public func addToItems(_ value: Item)

    @objc(removeItemsObject:)
    @NSManaged public func removeFromItems(_ value: Item)

    @objc(addItems:)
    @NSManaged public func addToItems(_ values: NSSet)

    @objc(removeItems:)
    @NSManaged public func removeFromItems(_ values: NSSet)
}

// MARK: - Helper Extensions
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    var hexString: String {
        let components = self.cgColor?.components
        let r: CGFloat = components?[0] ?? 0.0
        let g: CGFloat = components?[1] ?? 0.0
        let b: CGFloat = components?[2] ?? 0.0

        let hexString = String.init(format: "%02lX%02lX%02lX", lroundf(Float(r * 255)), lroundf(Float(g * 255)), lroundf(Float(b * 255)))
        return hexString
    }
}