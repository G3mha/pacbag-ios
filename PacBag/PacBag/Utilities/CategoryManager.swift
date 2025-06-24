import Foundation
import CoreData
import SwiftUI

class CategoryManager: ObservableObject {
    static let shared = CategoryManager()
    
    @Published var categories: [Category] = []
    @Published var recentCategories: [Category] = []
    @Published var popularCategories: [Category] = []
    
    private let context = CoreDataManager.shared.context
    private let userDefaultsKey = "CustomPackingCategories"
    
    // Default categories structure for seeding
    private let defaultCategoryData: [String: [String]] = [
        "General": [],
        "Clothes": ["Tops", "Bottoms", "Underwear", "Outerwear", "Sleepwear", "Socks"],
        "Electronics": ["Chargers", "Cables", "Devices", "Batteries", "Adapters"],
        "Toiletries": ["Skincare", "Haircare", "Dental", "Makeup", "Personal Care"],
        "Documents": ["ID", "Travel", "Insurance", "Medical", "Tickets"],
        "Shoes": ["Casual", "Formal", "Athletic", "Outdoor", "Special"],
        "Accessories": ["Jewelry", "Bags", "Belts", "Hats", "Glasses"],
        "Medication": ["Prescription", "Over-the-counter", "Vitamins", "First Aid"]
    ]
    
    private let categoryIcons: [String: String] = [
        "General": "folder.fill",
        "Clothes": "tshirt.fill",
        "Electronics": "iphone",
        "Toiletries": "drop.fill",
        "Documents": "doc.fill",
        "Shoes": "shoe.fill",
        "Accessories": "eyeglasses",
        "Medication": "cross.fill"
    ]
    
    private let categoryColors: [String: String] = [
        "General": "808080",
        "Clothes": "FF6B6B",
        "Electronics": "4ECDC4",
        "Toiletries": "45B7D1",
        "Documents": "96CEB4",
        "Shoes": "FFEAA7",
        "Accessories": "DDA0DD",
        "Medication": "FF7675"
    ]
    
    init() {
        setupCategories()
    }
    
    // MARK: - Setup and Migration
    
    private func setupCategories() {
        loadCategories()
        
        // Check if we need to seed default categories
        if categories.isEmpty {
            migrateFromUserDefaults()
            
            // If still empty, seed defaults
            if categories.isEmpty {
                seedDefaultCategories()
            }
        }
        
        updatePublishedArrays()
    }
    
    func seedDefaultCategories() {
        for (categoryName, subcategoryNames) in defaultCategoryData {
            let category = createCategory(
                categoryName,
                icon: categoryIcons[categoryName],
                color: categoryColors[categoryName],
                isDefault: true
            )
            
            for subcategoryName in subcategoryNames {
                createSubcategory(subcategoryName, in: category, isDefault: true)
            }
        }
        
        saveContext()
        loadCategories()
    }
    
    func migrateFromUserDefaults() {
        // Migrate from old UserDefaults system
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let oldCategories = try? JSONDecoder().decode([String: [String]].self, from: data) {
            
            for (categoryName, subcategoryNames) in oldCategories {
                // Skip if this category already exists (default or custom)
                if !categories.contains(where: { $0.name == categoryName }) {
                    let category = createCategory(categoryName, isDefault: false)
                    
                    for subcategoryName in subcategoryNames {
                        createSubcategory(subcategoryName, in: category, isDefault: false)
                    }
                }
            }
            
            saveContext()
            
            // Remove old UserDefaults data after successful migration
            UserDefaults.standard.removeObject(forKey: userDefaultsKey)
        }
    }
    
    // MARK: - Core Data Operations
    
    private func loadCategories() {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        request.predicate = NSPredicate(format: "isArchived == NO")
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Category.isDefault, ascending: false),
            NSSortDescriptor(keyPath: \Category.usageCount, ascending: false),
            NSSortDescriptor(keyPath: \Category.name, ascending: true)
        ]
        
        do {
            categories = try context.fetch(request)
        } catch {
            print("Error loading categories: \(error)")
            categories = []
        }
    }
    
    private func updatePublishedArrays() {
        // Update recent categories (used in last 7 days)
        recentCategories = categories
            .filter { $0.isRecentlyUsed }
            .sorted { $0.lastUsedDate ?? Date.distantPast > $1.lastUsedDate ?? Date.distantPast }
            .prefix(5)
            .map { $0 }
        
        // Update popular categories (usage count >= 5)
        popularCategories = categories
            .filter { $0.isPopular }
            .sorted { $0.usageCount > $1.usageCount }
            .prefix(10)
            .map { $0 }
    }
    
    private func saveContext() {
        do {
            try context.save()
        } catch {
            print("Error saving category context: \(error)")
        }
    }
    
    // MARK: - Category CRUD Operations
    
    @discardableResult
    func createCategory(_ name: String, icon: String? = nil, color: String? = nil, isDefault: Bool = false) -> Category {
        let category = Category(context: context)
        category.id = UUID()
        category.name = name
        category.isDefault = isDefault
        category.usageCount = 0
        category.iconName = icon
        category.colorHex = color
        category.isArchived = false
        category.createdDate = Date()
        category.lastUsedDate = nil
        
        return category
    }
    
    @discardableResult
    func createSubcategory(_ name: String, in category: Category, isDefault: Bool = false) -> SubCategory {
        let subcategory = SubCategory(context: context)
        subcategory.id = UUID()
        subcategory.name = name
        subcategory.isDefault = isDefault
        subcategory.usageCount = 0
        subcategory.isArchived = false
        subcategory.createdDate = Date()
        subcategory.lastUsedDate = nil
        subcategory.category = category
        
        return subcategory
    }
    
    func updateCategory(_ category: Category, name: String, icon: String? = nil, color: String? = nil) {
        category.name = name
        category.iconName = icon
        category.colorHex = color
        saveContext()
        loadCategories()
    }
    
    func deleteCategory(_ category: Category, moveItemsTo newCategory: Category? = nil) {
        // Move items to new category if specified
        if let newCategory = newCategory {
            for item in category.itemsArray {
                item.categoryEntity = newCategory
            }
        } else {
            // Clear category from items
            for item in category.itemsArray {
                item.categoryEntity = nil
            }
        }
        
        context.delete(category)
        saveContext()
        loadCategories()
    }
    
    func archiveCategory(_ category: Category) {
        category.isArchived = true
        saveContext()
        loadCategories()
    }
    
    // MARK: - Usage Tracking
    
    func incrementUsage(for category: Category) {
        category.usageCount += 1
        category.lastUsedDate = Date()
        saveContext()
        updatePublishedArrays()
    }
    
    func incrementUsage(for subcategory: SubCategory) {
        subcategory.usageCount += 1
        subcategory.lastUsedDate = Date()
        
        // Also increment parent category usage
        incrementUsage(for: subcategory.category)
    }
    
    // MARK: - Convenience Methods
    
    var sortedCategoryNames: [String] {
        return categories.map { $0.name }.sorted()
    }
    
    func category(named name: String) -> Category? {
        return categories.first { $0.name == name }
    }
    
    func subcategories(for categoryName: String) -> [SubCategory] {
        guard let category = category(named: categoryName) else { return [] }
        return category.subcategoriesArray
    }
    
    func subcategories(for category: Category) -> [SubCategory] {
        return category.subcategoriesArray
    }
    
    // Legacy compatibility methods
    func addCategory(_ categoryName: String, subcategory: String = "") {
        let category: Category
        
        if let existingCategory = self.category(named: categoryName) {
            category = existingCategory
        } else {
            category = createCategory(categoryName)
        }
        
        if !subcategory.isEmpty {
            // Check if subcategory already exists
            if !category.subcategoriesArray.contains(where: { $0.name == subcategory }) {
                createSubcategory(subcategory, in: category)
            }
        }
        
        saveContext()
        loadCategories()
    }
    
    // MARK: - Search and Suggestions
    
    func searchCategories(_ query: String) -> [Category] {
        let lowercaseQuery = query.lowercased()
        return categories.filter { 
            $0.name.lowercased().contains(lowercaseQuery) ||
            $0.subcategoriesArray.contains { $0.name.lowercased().contains(lowercaseQuery) }
        }
    }
    
    func suggestCategory(for itemName: String) -> Category? {
        let lowercaseItemName = itemName.lowercased()
        
        // Simple keyword matching for suggestions
        let categoryKeywords: [String: [String]] = [
            "Clothes": ["shirt", "pants", "dress", "jacket", "sweater", "jeans", "top"],
            "Electronics": ["charger", "cable", "phone", "laptop", "tablet", "battery", "adapter"],
            "Toiletries": ["toothbrush", "shampoo", "soap", "lotion", "perfume", "cream"],
            "Documents": ["passport", "ticket", "license", "id", "card", "document"],
            "Shoes": ["shoes", "sneakers", "boots", "sandals", "heels"],
            "Accessories": ["watch", "jewelry", "belt", "hat", "glasses", "bag"],
            "Medication": ["medicine", "pills", "vitamin", "tablet", "capsule"]
        ]
        
        for (categoryName, keywords) in categoryKeywords {
            if keywords.contains(where: { lowercaseItemName.contains($0) }) {
                return category(named: categoryName)
            }
        }
        
        return nil
    }
    
    // MARK: - Data Export/Import
    
    func exportCategories() -> Data? {
        let exportData = categories.map { category in
            [
                "name": category.name,
                "icon": category.iconName ?? "",
                "color": category.colorHex ?? "",
                "subcategories": category.subcategoriesArray.map { $0.name }
            ]
        }
        
        return try? JSONSerialization.data(withJSONObject: exportData, options: .prettyPrinted)
    }
    
    func importCategories(from data: Data) throws {
        let importData = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]]
        
        guard let categoriesData = importData else {
            throw NSError(domain: "CategoryManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid category data format"])
        }
        
        for categoryData in categoriesData {
            guard let name = categoryData["name"] as? String else { continue }
            
            // Skip if category already exists
            if category(named: name) != nil { continue }
            
            let icon = categoryData["icon"] as? String
            let color = categoryData["color"] as? String
            let subcategoryNames = categoryData["subcategories"] as? [String] ?? []
            
            let category = createCategory(name, icon: icon, color: color)
            
            for subcategoryName in subcategoryNames {
                createSubcategory(subcategoryName, in: category)
            }
        }
        
        saveContext()
        loadCategories()
    }
}