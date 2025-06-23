import Foundation

class CategoryManager: ObservableObject {
    static let shared = CategoryManager()
    
    @Published var customCategories: [String: [String]] = [:]
    
    private let userDefaultsKey = "CustomPackingCategories"
    
    // Default categories
    let defaultCategories: [String: [String]] = [
        "General": [],
        "Clothes": ["Tops", "Bottoms", "Underwear", "Outerwear", "Sleepwear", "Socks"],
        "Electronics": ["Chargers", "Cables", "Devices", "Batteries", "Adapters"],
        "Toiletries": ["Skincare", "Haircare", "Dental", "Makeup", "Personal Care"],
        "Documents": ["ID", "Travel", "Insurance", "Medical", "Tickets"],
        "Shoes": ["Casual", "Formal", "Athletic", "Outdoor", "Special"],
        "Accessories": ["Jewelry", "Bags", "Belts", "Hats", "Glasses"],
        "Medication": ["Prescription", "Over-the-counter", "Vitamins", "First Aid"]
    ]
    
    var allCategories: [String: [String]] {
        var combined = defaultCategories
        for (key, value) in customCategories {
            if combined[key] != nil {
                // Merge subcategories for existing categories
                combined[key] = (combined[key] ?? []) + value
            } else {
                // Add new category
                combined[key] = value
            }
        }
        return combined
    }
    
    var sortedCategoryNames: [String] {
        return Array(allCategories.keys).sorted()
    }
    
    init() {
        loadCustomCategories()
    }
    
    func subcategories(for category: String) -> [String] {
        return allCategories[category] ?? []
    }
    
    func addCategory(_ category: String, subcategory: String = "") {
        var updatedCategories = customCategories
        
        if updatedCategories[category] == nil {
            updatedCategories[category] = []
        }
        
        if !subcategory.isEmpty && !updatedCategories[category]!.contains(subcategory) {
            updatedCategories[category]!.append(subcategory)
        }
        
        customCategories = updatedCategories
        saveCustomCategories()
    }
    
    func addSubcategory(_ subcategory: String, to category: String) {
        guard !subcategory.isEmpty else { return }
        
        var updatedCategories = customCategories
        
        // Check if this is a default category
        if defaultCategories[category] != nil {
            // For default categories, we need to store only the new subcategories
            if updatedCategories[category] == nil {
                updatedCategories[category] = []
            }
            if !updatedCategories[category]!.contains(subcategory) && 
               !(defaultCategories[category] ?? []).contains(subcategory) {
                updatedCategories[category]!.append(subcategory)
            }
        } else {
            // For custom categories
            if updatedCategories[category] == nil {
                updatedCategories[category] = []
            }
            if !updatedCategories[category]!.contains(subcategory) {
                updatedCategories[category]!.append(subcategory)
            }
        }
        
        customCategories = updatedCategories
        saveCustomCategories()
    }
    
    private func loadCustomCategories() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode([String: [String]].self, from: data) {
            customCategories = decoded
        }
    }
    
    private func saveCustomCategories() {
        if let encoded = try? JSONEncoder().encode(customCategories) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    // Check if a category is custom (not in defaults)
    func isCustomCategory(_ category: String) -> Bool {
        return defaultCategories[category] == nil && customCategories[category] != nil
    }
    
    // Check if a subcategory is custom
    func isCustomSubcategory(_ subcategory: String, in category: String) -> Bool {
        if let defaultSubs = defaultCategories[category] {
            return !defaultSubs.contains(subcategory)
        }
        return true
    }
}