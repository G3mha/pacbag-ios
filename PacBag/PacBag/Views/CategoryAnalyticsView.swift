import SwiftUI
import Charts

struct CategoryAnalyticsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var categoryManager = CategoryManager.shared
    
    @State private var selectedTab = 0
    @State private var usageAnalytics: CategoryUsageAnalytics?
    @State private var trends: CategoryTrends?
    @State private var packingInsights: PackingInsights?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Tab Picker
                Picker("Analytics Type", selection: $selectedTab) {
                    Text("Usage").tag(0)
                    Text("Trends").tag(1)
                    Text("Insights").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Content
                TabView(selection: $selectedTab) {
                    UsageAnalyticsView(analytics: usageAnalytics)
                        .tag(0)
                    
                    TrendsAnalyticsView(trends: trends)
                        .tag(1)
                    
                    PackingInsightsView(insights: packingInsights)
                        .tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .navigationTitle("Category Analytics")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Refresh") {
                        refreshAnalytics()
                    }
                    .foregroundColor(.blue)
                }
            }
        }
        .onAppear {
            refreshAnalytics()
        }
    }
    
    private func refreshAnalytics() {
        usageAnalytics = categoryManager.getCategoryUsageAnalytics()
        trends = categoryManager.getCategoryTrends()
        packingInsights = categoryManager.getPackingInsights()
    }
}

struct UsageAnalyticsView: View {
    let analytics: CategoryUsageAnalytics?
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                if let analytics = analytics {
                    // Overview Cards
                    OverviewCardsView(analytics: analytics)
                    
                    // Usage Distribution Chart
                    UsageDistributionChart(analytics: analytics)
                    
                    // Top Categories
                    TopCategoriesView(analytics: analytics)
                    
                    // Unused Categories
                    if !analytics.unusedCategories.isEmpty {
                        UnusedCategoriesView(categories: analytics.unusedCategories)
                    }
                } else {
                    ProgressView("Loading analytics...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .padding()
        }
    }
}

struct OverviewCardsView: View {
    let analytics: CategoryUsageAnalytics
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Overview")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                AnalyticsCard(
                    title: "Total Categories",
                    value: "\(analytics.totalCategories)",
                    icon: "folder.fill",
                    color: .blue
                )
                
                AnalyticsCard(
                    title: "Subcategories",
                    value: "\(analytics.totalSubcategories)",
                    icon: "folder.badge.plus",
                    color: .green
                )
                
                AnalyticsCard(
                    title: "Total Usage",
                    value: "\(analytics.totalUsage)",
                    icon: "chart.bar.fill",
                    color: .orange
                )
                
                AnalyticsCard(
                    title: "Average Usage",
                    value: String(format: "%.1f", analytics.averageUsagePerCategory),
                    icon: "chart.line.uptrend.xyaxis",
                    color: .purple
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct UsageDistributionChart: View {
    let analytics: CategoryUsageAnalytics
    
    var chartData: [CategoryChartData] {
        analytics.categoryUsageDistribution
            .prefix(8)  // Show top 8 categories
            .map { CategoryChartData(name: $0.category.name, count: Int($0.category.usageCount), percentage: $0.usagePercentage) }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Usage Distribution")
                .font(.headline)
                .fontWeight(.semibold)
            
            if #available(iOS 16.0, *) {
                Chart(chartData, id: \.name) { data in
                    BarMark(
                        x: .value("Category", data.name),
                        y: .value("Usage", data.count)
                    )
                    .foregroundStyle(Color.blue.gradient)
                }
                .frame(height: 200)
                .chartXAxis {
                    AxisMarks(values: .automatic) { _ in
                        AxisValueLabel()
                            .font(.caption2)
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
            } else {
                // Fallback for iOS 15
                VStack(spacing: 8) {
                    ForEach(chartData.prefix(5), id: \.name) { data in
                        HStack {
                            Text(data.name)
                                .font(.caption)
                                .frame(width: 80, alignment: .leading)
                            
                            GeometryReader { geometry in
                                HStack(spacing: 0) {
                                    Rectangle()
                                        .fill(Color.blue)
                                        .frame(width: geometry.size.width * (data.percentage / 100))
                                    
                                    Spacer(minLength: 0)
                                }
                            }
                            .frame(height: 8)
                            
                            Text("\(data.count)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .frame(width: 30, alignment: .trailing)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct CategoryChartData {
    let name: String
    let count: Int
    let percentage: Double
}

struct TopCategoriesView: View {
    let analytics: CategoryUsageAnalytics
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Top Categories")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 8) {
                if let mostUsed = analytics.mostUsedCategory {
                    CategoryStatsRow(
                        category: mostUsed,
                        label: "Most Used",
                        icon: "crown.fill",
                        color: .yellow
                    )
                }
                
                if let leastUsed = analytics.leastUsedCategory {
                    CategoryStatsRow(
                        category: leastUsed,
                        label: "Least Used",
                        icon: "tortoise.fill",
                        color: .gray
                    )
                }
                
                // Top 3 by usage
                ForEach(Array(analytics.categoryUsageDistribution.prefix(3).enumerated()), id: \.offset) { index, data in
                    CategoryStatsRow(
                        category: data.category,
                        label: "#\(index + 1) by Usage",
                        icon: "\(index + 1).circle.fill",
                        color: [.blue, .green, .orange][index]
                    )
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct CategoryStatsRow: View {
    let category: Category
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title2)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack {
                    Image(systemName: category.icon)
                        .foregroundColor(category.color)
                    Text(category.name)
                        .fontWeight(.medium)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(category.usageCount)")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Text("uses")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct UnusedCategoriesView: View {
    let categories: [Category]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Unused Categories")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text("Consider removing these categories to keep your list organized:")
                .font(.caption)
                .foregroundColor(.secondary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                ForEach(categories.prefix(6), id: \.id) { category in
                    HStack {
                        Image(systemName: category.icon)
                            .foregroundColor(category.color)
                        Text(category.name)
                            .font(.caption)
                        Spacer()
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(6)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct TrendsAnalyticsView: View {
    let trends: CategoryTrends?
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                if let trends = trends {
                    // Recently Created Categories
                    if !trends.recentlyCreated.isEmpty {
                        TrendSectionView(
                            title: "Recently Created",
                            subtitle: "Categories added in the last 7 days",
                            categories: trends.recentlyCreated,
                            icon: "plus.circle.fill",
                            color: .green
                        )
                    }
                    
                    // Recently Used Categories
                    if !trends.recentlyUsed.isEmpty {
                        TrendSectionView(
                            title: "Recently Active",
                            subtitle: "Categories used in the last 7 days",
                            categories: trends.recentlyUsed,
                            icon: "clock.fill",
                            color: .blue
                        )
                    }
                    
                    // Emerging Categories
                    if !trends.emergingCategories.isEmpty {
                        TrendSectionView(
                            title: "Trending Up",
                            subtitle: "Categories gaining popularity",
                            categories: trends.emergingCategories,
                            icon: "chart.line.uptrend.xyaxis",
                            color: .orange
                        )
                    }
                    
                    if trends.recentlyCreated.isEmpty && trends.recentlyUsed.isEmpty && trends.emergingCategories.isEmpty {
                        EmptyTrendsView()
                    }
                } else {
                    ProgressView("Loading trends...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .padding()
        }
    }
}

struct TrendSectionView: View {
    let title: String
    let subtitle: String
    let categories: [Category]
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                ForEach(categories.prefix(6), id: \.id) { category in
                    CategoryTrendCard(category: category)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct CategoryTrendCard: View {
    let category: Category
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: category.icon)
                .foregroundColor(category.color)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(category.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                if let lastUsed = category.lastUsedDate {
                    Text(lastUsed, style: .relative)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                } else {
                    Text("Never used")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(category.color.opacity(0.1))
        .cornerRadius(8)
    }
}

struct EmptyTrendsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.line.flattrend.xyaxis")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text("No Recent Trends")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text("Start using categories to see trends and insights")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

struct PackingInsightsView: View {
    let insights: PackingInsights?
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                if let insights = insights {
                    // Heaviest Category
                    if let heaviest = insights.heaviestCategory {
                        InsightCard(
                            title: "Heaviest Category",
                            value: "\(heaviest.key)",
                            subtitle: String(format: "%.1f kg total weight", heaviest.value),
                            icon: "scalemass.fill",
                            color: .red
                        )
                    }
                    
                    // Most Items Category
                    if let mostItems = insights.mostItemsCategory {
                        InsightCard(
                            title: "Most Items",
                            value: "\(mostItems.key)",
                            subtitle: "\(mostItems.value) items",
                            icon: "cube.box.fill",
                            color: .blue
                        )
                    }
                    
                    // Packing Efficiency
                    PackingEfficiencyView(efficiency: insights.packingEfficiency)
                    
                    // Category Weight Distribution
                    WeightDistributionView(distribution: insights.categoryWeightDistribution)
                    
                } else {
                    ProgressView("Loading insights...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .padding()
        }
    }
}

struct InsightCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.system(size: 30))
                .frame(width: 50)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.headline)
                    .fontWeight(.bold)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

struct PackingEfficiencyView: View {
    let efficiency: [String: Double]
    
    var sortedEfficiency: [(String, Double)] {
        efficiency.sorted { $0.value > $1.value }.prefix(10).map { ($0.key, $0.value) }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Packing Efficiency")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text("Percentage of items packed by category")
                .font(.caption)
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                ForEach(sortedEfficiency, id: \.0) { category, efficiency in
                    HStack {
                        Text(category)
                            .font(.caption)
                            .frame(width: 80, alignment: .leading)
                        
                        GeometryReader { geometry in
                            HStack(spacing: 0) {
                                Rectangle()
                                    .fill(efficiencyColor(efficiency))
                                    .frame(width: geometry.size.width * (efficiency / 100))
                                
                                Spacer(minLength: 0)
                            }
                        }
                        .frame(height: 8)
                        
                        Text(String(format: "%.0f%%", efficiency))
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(width: 40, alignment: .trailing)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func efficiencyColor(_ efficiency: Double) -> Color {
        switch efficiency {
        case 80...:
            return .green
        case 50..<80:
            return .orange
        default:
            return .red
        }
    }
}

struct WeightDistributionView: View {
    let distribution: [String: Double]
    
    var sortedDistribution: [(String, Double)] {
        distribution.sorted { $0.value > $1.value }.prefix(8).map { ($0.key, $0.value) }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Weight Distribution")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text("Total weight by category")
                .font(.caption)
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                ForEach(sortedDistribution, id: \.0) { category, weight in
                    HStack {
                        Text(category)
                            .font(.caption)
                            .frame(width: 80, alignment: .leading)
                        
                        Spacer()
                        
                        Text(String(format: "%.1f kg", weight))
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                    }
                    .padding(.vertical, 2)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    CategoryAnalyticsView()
        .environment(\.managedObjectContext, CoreDataManager.shared.context)
}