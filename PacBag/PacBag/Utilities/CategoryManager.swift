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
    
    func loadCategories() {
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
    
    func saveContext() {
        do {
            try context.save()
        } catch {
            print("Failed to save context: \(error)")
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
        
        // Ensure the object is properly registered with Core Data
        do {
            try context.obtainPermanentIDs(for: [category])
        } catch {
            print("Failed to save context: \(error)")
        }
        
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
        
        // Ensure the object is properly registered with Core Data
        do {
            try context.obtainPermanentIDs(for: [subcategory])
        } catch {
            print("Failed to save context: \(error)")
        }
        
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
        // Instead of actually deleting, mark as archived and remove from UI immediately
        // This prevents UUID bridging crashes while still removing from user view
        
        // First, handle all items before archiving
        let itemsToUpdate = Array(category.itemsArray) // Create a copy to avoid collection mutation
        
        // Move items to new category if specified
        if let newCategory = newCategory {
            for item in itemsToUpdate {
                item.categoryEntity = newCategory
                // Also update the legacy string category for compatibility
                item.category = newCategory.name
            }
        } else {
            // Clear category from items
            for item in itemsToUpdate {
                item.categoryEntity = nil
                // Also clear the legacy string category
                item.category = nil
            }
        }
        
        // Handle subcategories - archive them too
        let subcategoriesToArchive = Array(category.subcategoriesArray)
        for subcategory in subcategoriesToArchive {
            // Clear subcategory from items that use it
            let itemsWithSubcategory = Array(subcategory.itemsArray)
            for item in itemsWithSubcategory {
                item.subcategoryEntity = nil
                item.subcategory = nil
            }
            subcategory.isArchived = true
        }
        
        // Mark category as archived instead of deleting
        category.isArchived = true
        
        // Save changes
        do {
            try context.save()
            
            // Remove from UI immediately by updating local arrays
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                // Remove the archived category from our local array immediately
                self.categories.removeAll { $0.objectID == category.objectID }
                self.updatePublishedArrays()
            }
        } catch {
            // If save fails, reload to get back to a consistent state
            DispatchQueue.main.async { [weak self] in
                self?.loadCategories()
            }
        }
    }
    
    func archiveCategory(_ category: Category) {
        category.isArchived = true
        saveContext()
        loadCategories()
    }
    
    // Permanently delete archived categories (can be called during app cleanup)
    func permanentlyDeleteArchivedCategories() {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        request.predicate = NSPredicate(format: "isArchived == YES")
        
        do {
            let archivedCategories = try context.fetch(request)
            for category in archivedCategories {
                context.delete(category)
            }
            try context.save()
        } catch {
            print("Failed to save context: \(error)")
        }
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
        return categories.first { $0.name.lowercased() == name.lowercased() }
    }
    
    func ensureGeneralCategoryExists() -> Category {
        if let general = category(named: "General") {
            return general
        }
        
        // Create General category if it doesn't exist
        let general = createCategory("General", icon: "folder.fill", color: "#007AFF", isDefault: true)
        saveContext()
        loadCategories()
        return general
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
    
    // MARK: - Analytics Methods
    
    func getCategoryUsageAnalytics() -> CategoryUsageAnalytics {
        let totalCategories = categories.count
        let totalSubcategories = categories.reduce(0) { $0 + $1.subcategoriesArray.count }
        let totalUsage = categories.reduce(0) { $0 + $1.usageCount }
        let totalItems = categories.reduce(0) { $0 + $1.itemsArray.count }
        
        let mostUsedCategory = categories.max { $0.usageCount < $1.usageCount }
        let leastUsedCategory = categories.filter { $0.usageCount > 0 }.min { $0.usageCount < $1.usageCount }
        let unusedCategories = categories.filter { $0.usageCount == 0 && !$0.isDefault }
        
        let categoryUsageDistribution = categories.map { category in
            CategoryUsageData(
                category: category,
                usagePercentage: totalUsage > 0 ? Double(category.usageCount) / Double(totalUsage) * 100 : 0,
                itemCount: category.itemsArray.count
            )
        }.sorted { $0.usagePercentage > $1.usagePercentage }
        
        return CategoryUsageAnalytics(
            totalCategories: totalCategories,
            totalSubcategories: totalSubcategories,
            totalUsage: Int(totalUsage),
            totalItems: totalItems,
            mostUsedCategory: mostUsedCategory,
            leastUsedCategory: leastUsedCategory,
            unusedCategories: unusedCategories,
            categoryUsageDistribution: categoryUsageDistribution,
            averageUsagePerCategory: totalCategories > 0 ? Double(totalUsage) / Double(totalCategories) : 0
        )
    }
    
    func getCategoryTrends() -> CategoryTrends {
        let now = Date()
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: now) ?? now
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: now) ?? now
        
        let recentlyCreated = categories.filter { $0.createdDate >= sevenDaysAgo }
        let recentlyUsed = categories.filter { 
            guard let lastUsed = $0.lastUsedDate else { return false }
            return lastUsed >= sevenDaysAgo
        }
        
        let emergingCategories = categories.filter { category in
            guard let lastUsed = category.lastUsedDate else { return false }
            return lastUsed >= thirtyDaysAgo && category.usageCount >= 3 && !category.isDefault
        }.sorted { $0.usageCount > $1.usageCount }
        
        return CategoryTrends(
            recentlyCreated: recentlyCreated,
            recentlyUsed: recentlyUsed,
            emergingCategories: Array(emergingCategories.prefix(5))
        )
    }
    
    func getPackingInsights() -> PackingInsights {
        var categoryItemDistribution: [String: Int] = [:]
        var categoryWeightDistribution: [String: Double] = [:]
        
        for category in categories {
            let items = category.itemsArray
            categoryItemDistribution[category.name] = items.count
            categoryWeightDistribution[category.name] = items.reduce(0) { $0 + $1.totalWeight }
        }
        
        let heaviestCategory = categoryWeightDistribution.max { $0.value < $1.value }
        let mostItemsCategory = categoryItemDistribution.max { $0.value < $1.value }
        
        // Calculate packing efficiency (packed vs unpacked items by category)
        var packingEfficiency: [String: Double] = [:]
        for category in categories {
            let items = category.itemsArray
            guard !items.isEmpty else { continue }
            let packedItems = items.filter { $0.isPacked }.count
            packingEfficiency[category.name] = Double(packedItems) / Double(items.count) * 100
        }
        
        return PackingInsights(
            categoryItemDistribution: categoryItemDistribution,
            categoryWeightDistribution: categoryWeightDistribution,
            heaviestCategory: heaviestCategory,
            mostItemsCategory: mostItemsCategory,
            packingEfficiency: packingEfficiency
        )
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
    
    // MARK: - Reset
    
    func resetToDefaults() {
        // Delete all existing categories
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        if let existingCategories = try? context.fetch(fetchRequest) {
            for category in existingCategories {
                context.delete(category)
            }
        }
        
        // Save to clear the database
        saveContext()
        
        // Clear in-memory arrays
        categories = []
        recentCategories = []
        popularCategories = []
        
        // Seed default categories
        seedDefaultCategories()
        
        // Reload categories
        loadCategories()
    }
}