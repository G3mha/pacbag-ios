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
            List {
                Picker("Analytics Type", selection: $selectedTab) {
                    Text("Usage").tag(0)
                    Text("Trends").tag(1)
                    Text("Insights").tag(2)
                }
                .pickerStyle(.segmented)
                .listRowSeparator(.hidden)

                switch selectedTab {
                case 1:
                    if let trends {
                        TrendsSections(trends: trends)
                    } else {
                        LoadingRow()
                    }
                case 2:
                    if let packingInsights {
                        InsightsSections(insights: packingInsights)
                    } else {
                        LoadingRow()
                    }
                default:
                    if let usageAnalytics {
                        UsageSections(analytics: usageAnalytics)
                    } else {
                        LoadingRow()
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Category Analytics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Refresh") {
                        refreshAnalytics()
                    }
                }
            }
        }
        .plainFormSheet()
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

/// Placeholder rows while the numbers are worked out.
private struct LoadingRow: View {
    var body: some View {
        ForEach(0..<4, id: \.self) { _ in
            HStack {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.systemGray5))
                    .frame(width: 140, height: 14)
                Spacer()
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.systemGray5))
                    .frame(width: 40, height: 14)
            }
            .padding(.vertical, 6)
        }
        .accessibilityLabel("Loading")
    }
}

private func uses(_ count: Int32) -> String {
    count == 1 ? "1 use" : "\(count) uses"
}

// MARK: - Usage

private struct UsageSections: View {
    let analytics: CategoryUsageAnalytics

    private var chartData: [CategoryChartData] {
        analytics.categoryUsageDistribution
            .prefix(8)
            .map { CategoryChartData(name: $0.category.name, count: Int($0.category.usageCount)) }
    }

    var body: some View {
        Section(header: Text("Overview").solidSectionHeader()) {
            LabeledContent("Categories", value: "\(analytics.totalCategories)")
            LabeledContent("Subcategories", value: "\(analytics.totalSubcategories)")
            LabeledContent("Total uses", value: "\(analytics.totalUsage)")
            LabeledContent("Uses per category", value: analytics.averageUsagePerCategory.formatted(.number.precision(.fractionLength(1))))
        }

        if !chartData.isEmpty {
            Section(header: Text("Uses by Category").solidSectionHeader()) {
                Chart(chartData, id: \.name) { data in
                    BarMark(
                        x: .value("Category", data.name),
                        y: .value("Uses", data.count)
                    )
                    .foregroundStyle(Color.accentColor)
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
                .padding(.vertical, 8)
            }
        }

        Section(header: Text("Top Categories").solidSectionHeader()) {
            ForEach(Array(analytics.categoryUsageDistribution.prefix(3).enumerated()), id: \.offset) { index, data in
                LabeledContent("\(index + 1). \(data.category.name)", value: uses(data.category.usageCount))
            }

            if let leastUsed = analytics.leastUsedCategory {
                LabeledContent("Least used: \(leastUsed.name)", value: uses(leastUsed.usageCount))
            }
        }

        if !analytics.unusedCategories.isEmpty {
            Section {
                ForEach(analytics.unusedCategories, id: \.id) { category in
                    Text(category.name)
                }
            } header: {
                Text("Unused").solidSectionHeader()
            } footer: {
                Text("You could remove these to keep your list short.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct CategoryChartData {
    let name: String
    let count: Int
}

// MARK: - Trends

private struct TrendsSections: View {
    let trends: CategoryTrends

    var body: some View {
        if trends.recentlyCreated.isEmpty && trends.recentlyUsed.isEmpty && trends.emergingCategories.isEmpty {
            VStack(spacing: 8) {
                Text("No recent trends")
                    .font(.headline)

                Text("Use categories on your items and trends show up here.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 40)
            .listRowSeparator(.hidden)
        } else {
            TrendSection(title: "Recently Created", footer: "Added in the last 7 days.", categories: trends.recentlyCreated)
            TrendSection(title: "Recently Active", footer: "Used in the last 7 days.", categories: trends.recentlyUsed)
            TrendSection(title: "Trending Up", footer: "Used more often lately.", categories: trends.emergingCategories)
        }
    }
}

private struct TrendSection: View {
    let title: String
    let footer: String
    let categories: [Category]

    var body: some View {
        if !categories.isEmpty {
            Section {
                ForEach(categories, id: \.id) { category in
                    HStack {
                        Text(category.name)
                        Spacer()
                        if let lastUsed = category.lastUsedDate {
                            Text(lastUsed, style: .relative)
                                .foregroundColor(.secondary)
                        } else {
                            Text("Never used")
                                .foregroundColor(.secondary)
                        }
                    }
                }
            } header: {
                Text(title).solidSectionHeader()
            } footer: {
                Text(footer)
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Insights

private struct InsightsSections: View {
    let insights: PackingInsights

    private var packedShare: [(String, Double)] {
        insights.packingEfficiency.sorted { $0.value > $1.value }.prefix(10).map { ($0.key, $0.value) }
    }

    private var weights: [(String, Double)] {
        insights.categoryWeightDistribution.sorted { $0.value > $1.value }.prefix(8).map { ($0.key, $0.value) }
    }

    var body: some View {
        if insights.heaviestCategory != nil || insights.mostItemsCategory != nil {
            Section(header: Text("Highlights").solidSectionHeader()) {
                if let heaviest = insights.heaviestCategory {
                    LabeledContent("Heaviest", value: "\(heaviest.key), \(heaviest.value.oneDecimal) kg")
                }

                if let mostItems = insights.mostItemsCategory {
                    LabeledContent("Most items", value: "\(mostItems.key), \(mostItems.value)")
                }
            }
        }

        if !packedShare.isEmpty {
            Section(header: Text("Packed by Category").solidSectionHeader()) {
                ForEach(packedShare, id: \.0) { category, share in
                    VStack(spacing: 6) {
                        HStack {
                            Text(category)
                            Spacer()
                            Text("\(share.formatted(.number.precision(.fractionLength(0))))%")
                                .foregroundColor(.secondary)
                        }

                        ProgressView(value: min(max(share, 0), 100), total: 100)
                            .accessibilityHidden(true)
                    }
                    .padding(.vertical, 2)
                }
            }
        }

        if !weights.isEmpty {
            Section(header: Text("Weight by Category").solidSectionHeader()) {
                ForEach(weights, id: \.0) { category, weight in
                    LabeledContent(category, value: "\(weight.oneDecimal) kg")
                }
            }
        }
    }
}

#Preview {
    CategoryAnalyticsView()
        .environment(\.managedObjectContext, CoreDataManager.shared.context)
}
