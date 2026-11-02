import Foundation

// MARK: - Category Analytics

struct CategoryUsageAnalytics {
    let totalCategories: Int
    let totalSubcategories: Int
    let totalUsage: Int
    let totalItems: Int
    let mostUsedCategory: Category?
    let leastUsedCategory: Category?
    let unusedCategories: [Category]
    let categoryUsageDistribution: [CategoryUsageData]
    let averageUsagePerCategory: Double
}

struct CategoryUsageData {
    let category: Category
    let usagePercentage: Double
    let itemCount: Int
}

// MARK: - Category Trends

struct CategoryTrends {
    let recentlyCreated: [Category]
    let recentlyUsed: [Category]
    let emergingCategories: [Category]
}

// MARK: - Packing Insights

struct PackingInsights {
    let categoryItemDistribution: [String: Int]
    let categoryWeightDistribution: [String: Double]
    let heaviestCategory: (key: String, value: Double)?
    let mostItemsCategory: (key: String, value: Int)?
    let packingEfficiency: [String: Double]
}

// MARK: - Trip-Specific Analytics

// MARK: - Seasonal Analytics