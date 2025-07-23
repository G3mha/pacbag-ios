import SwiftUI
import CoreData

struct PackingProgressView: View {
    @ObservedObject var bag: Bag
    let showDetails: Bool
    
    init(bag: Bag, showDetails: Bool = false) {
        self.bag = bag
        self.showDetails = showDetails
    }
    
    var packingProgress: Double {
        guard bag.totalItemsCount > 0 else { return 0 }
        return Double(bag.packedItemsCount) / Double(bag.totalItemsCount)
    }
    
    var progressColor: Color {
        switch packingProgress {
        case 0.0:
            return .gray
        case 0.0..<0.3:
            return .red
        case 0.3..<0.7:
            return .orange
        case 0.7..<1.0:
            return .blue
        case 1.0:
            return .green
        default:
            return .gray
        }
    }
    
    var progressText: String {
        switch packingProgress {
        case 0.0:
            return "Not started"
        case 0.0..<0.3:
            return "Just started"
        case 0.3..<0.7:
            return "In progress"
        case 0.7..<1.0:
            return "Almost done"
        case 1.0:
            return "Complete!"
        default:
            return "Unknown"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Packing Progress")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("\(bag.packedItemsCount)/\(bag.totalItemsCount)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(progressColor)
            }
            
            // Main Progress Bar
            VStack(alignment: .leading, spacing: 8) {
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray5))
                        .frame(height: 16)
                    
                    // Progress Fill
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [progressColor.opacity(0.8), progressColor],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(0, CGFloat(packingProgress) * 300), height: 16)
                        .animation(.easeInOut(duration: 0.5), value: packingProgress)
                    
                    // Progress Text Overlay
                    HStack {
                        Spacer()
                        Text("\(Int(packingProgress * 100))%")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        Spacer()
                    }
                }
                .frame(maxWidth: 300)
                
                HStack {
                    Text(progressText)
                        .font(.caption)
                        .foregroundColor(progressColor)
                    
                    Spacer()
                    
                    if packingProgress == 1.0 {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Ready to go!")
                                .font(.caption)
                                .foregroundColor(.green)
                                .fontWeight(.medium)
                        }
                    }
                }
            }
            
            if showDetails {
                PackingDetailBreakdown(bag: bag)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(progressColor.opacity(0.3), lineWidth: 2)
        )
    }
}

struct PackingDetailBreakdown: View {
    @ObservedObject var bag: Bag
    
    var categoryStats: [String: (packed: Int, total: Int)] {
        var stats: [String: (packed: Int, total: Int)] = [:]
        
        for item in bag.itemsArray {
            let category = item.category ?? "General"
            let quantity = Int(item.quantity)
            
            if stats[category] == nil {
                stats[category] = (packed: 0, total: 0)
            }
            
            if var categoryStats = stats[category] {
                categoryStats.total += quantity
                if item.isPacked {
                    categoryStats.packed += quantity
                }
                stats[category] = categoryStats
            }
        }
        
        // Add sub-bag items
        for subBag in bag.subBagsArray {
            for item in subBag.itemsArray {
                let category = item.category ?? "General"
                let quantity = Int(item.quantity)
                
                if stats[category] == nil {
                    stats[category] = (packed: 0, total: 0)
                }
                
                if var categoryStats = stats[category] {
                    categoryStats.total += quantity
                    if item.isPacked {
                        categoryStats.packed += quantity
                    }
                    stats[category] = categoryStats
                }
            }
        }
        
        return stats
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Category Breakdown")
                .font(.subheadline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 8) {
                ForEach(categoryStats.keys.sorted(), id: \.self) { category in
                    CategoryProgressCard(
                        category: category,
                        packed: categoryStats[category]?.packed ?? 0,
                        total: categoryStats[category]?.total ?? 0
                    )
                }
            }
            
            if bag.totalSubBagsCount > 0 {
                SubBagProgressSection(bag: bag)
            }
        }
    }
}

struct CategoryProgressCard: View {
    let category: String
    let packed: Int
    let total: Int
    
    private var progress: Double {
        guard total > 0 else { return 0 }
        return Double(packed) / Double(total)
    }
    
    private var categoryColor: Color {
        switch category.lowercased() {
        case "clothes":
            return .blue
        case "electronics":
            return .orange
        case "toiletries":
            return .cyan
        case "documents":
            return .green
        case "shoes":
            return .brown
        case "accessories":
            return .purple
        case "medication":
            return .red
        default:
            return .gray
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(category)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(categoryColor)
                
                Spacer()
                
                Text("\(packed)/\(total)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.systemGray6))
                    .frame(height: 6)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(categoryColor)
                    .frame(width: max(0, progress * 100), height: 6)
                    .animation(.easeInOut(duration: 0.3), value: progress)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(8)
        .background(categoryColor.opacity(0.1))
        .cornerRadius(8)
    }
}

struct SubBagProgressSection: View {
    @ObservedObject var bag: Bag
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Sub-bags Progress")
                .font(.subheadline)
                .fontWeight(.semibold)
            
            ForEach(bag.subBagsArray) { subBag in
                SubBagProgressRow(subBag: subBag)
            }
        }
    }
}

struct SubBagProgressRow: View {
    @ObservedObject var subBag: Bag
    
    private var progress: Double {
        guard subBag.totalItemsCount > 0 else { return 0 }
        return Double(subBag.packedItemsCount) / Double(subBag.totalItemsCount)
    }
    
    private var subBagColor: Color {
        return SubBagType.fromName(subBag.name).color
    }
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: SubBagType.fromName(subBag.name).icon)
                .font(.caption)
                .foregroundColor(subBagColor)
                .frame(width: 16)
            
            Text(subBag.name)
                .font(.caption)
                .fontWeight(.medium)
            
            Spacer()
            
            Text("\(subBag.packedItemsCount)/\(subBag.totalItemsCount)")
                .font(.caption2)
                .foregroundColor(.secondary)
            
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color(.systemGray6))
                    .frame(width: 40, height: 4)
                
                RoundedRectangle(cornerRadius: 2)
                    .fill(subBagColor)
                    .frame(width: max(0, progress * 40), height: 4)
                    .animation(.easeInOut(duration: 0.3), value: progress)
            }
            
            if progress == 1.0 {
                Image(systemName: "checkmark.circle.fill")
                    .font(.caption)
                    .foregroundColor(.green)
            }
        }
        .padding(.vertical, 4)
    }
}

struct PackingStatsView: View {
    @ObservedObject var bag: Bag
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Packing Statistics")
                .font(.title2)
                .fontWeight(.bold)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                PackingStatCard(
                    title: "Items Packed",
                    value: "\(bag.packedItemsCount)",
                    subtitle: "of \(bag.totalItemsCount)",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
                
                PackingStatCard(
                    title: "Remaining",
                    value: "\(bag.totalItemsCount - bag.packedItemsCount)",
                    subtitle: "items left",
                    icon: "circle",
                    color: .orange
                )
                
                PackingStatCard(
                    title: "Progress",
                    value: "\(Int((Double(bag.packedItemsCount) / max(1, Double(bag.totalItemsCount))) * 100))%",
                    subtitle: "complete",
                    icon: "chart.line.uptrend.xyaxis",
                    color: .blue
                )
            }
            
            if bag.totalSubBagsCount > 0 {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Sub-bags Status")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    ForEach(bag.subBagsArray) { subBag in
                        let progress = subBag.totalItemsCount > 0 ? Double(subBag.packedItemsCount) / Double(subBag.totalItemsCount) : 0
                        
                        HStack {
                            Image(systemName: SubBagType.fromName(subBag.name).icon)
                                .foregroundColor(SubBagType.fromName(subBag.name).color)
                            
                            Text(subBag.name)
                                .fontWeight(.medium)
                            
                            Spacer()
                            
                            Text("\(subBag.packedItemsCount)/\(subBag.totalItemsCount)")
                                .foregroundColor(.secondary)
                            
                            if progress == 1.0 {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
            }
        }
    }
}

struct PackingStatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            VStack(spacing: 2) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                
                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(color.opacity(0.1))
        .cornerRadius(10)
    }
}

#Preview {
    VStack(spacing: 20) {
        PackingProgressView(bag: {
            let context = CoreDataManager.shared.context
            let bag = Bag(context: context)
            bag.id = UUID()
            bag.name = "Sample Bag"
            bag.maxWeight = 20.0
            bag.currentWeight = 5.0
            return bag
        }(), showDetails: true)
        
        PackingStatsView(bag: {
            let context = CoreDataManager.shared.context
            let bag = Bag(context: context)
            bag.id = UUID()
            bag.name = "Sample Bag"
            bag.maxWeight = 20.0
            bag.currentWeight = 5.0
            return bag
        }())
    }
    .padding()
    .environment(\.managedObjectContext, CoreDataManager.shared.context)
}