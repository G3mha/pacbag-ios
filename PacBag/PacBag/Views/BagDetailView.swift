import SwiftUI
import CoreData

struct BagDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var bag: Bag
    
    @State private var showingAddItem = false
    @State private var showingEditBag = false
    @State private var showingTemplates = false
    @State private var showingShareView = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Bag Header with visual representation
                BagHeaderView(bag: bag)
                
                // Packing Progress
                PackingProgressView(bag: bag, showDetails: true)
                
                // Quick Stats
                BagStatsView(bag: bag)
                
                // Sub-bags Section (only for main bags)
                if bag.isMainBag {
                    SubBagView(parentBag: bag)
                }
                
                // Items Section
                ItemsListView(bag: bag, showingAddItem: $showingAddItem)
            }
            .padding()
        }
        .navigationTitle(bag.name.isEmpty ? "Unnamed Bag" : bag.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button("Edit Bag", systemImage: "pencil") {
                        showingEditBag = true
                    }
                    
                    Button("Add Item", systemImage: "plus") {
                        showingAddItem = true
                    }
                    
                    Button("Use Template", systemImage: "doc.text") {
                        showingTemplates = true
                    }
                    
                    Button("Share Bag", systemImage: "square.and.arrow.up") {
                        showingShareView = true
                    }
                    
                    Divider()
                    
                    Button("Mark All Packed", systemImage: "checkmark.circle") {
                        markAllPacked()
                    }
                    
                    Button("Mark All Unpacked", systemImage: "circle") {
                        markAllUnpacked()
                    }
                    
                    Divider()
                    
                    Menu("Bulk Actions", systemImage: "checklist") {
                        Button("Pack by Category", systemImage: "folder") {
                            // Will implement category-based packing
                        }
                        
                        Button("Pack Essentials Only", systemImage: "star") {
                            // Will implement essential items packing
                        }
                        
                        Button("Pack Lightest Items", systemImage: "feather") {
                            packLightestItems()
                        }
                        
                        Button("Unpack Everything", systemImage: "arrow.counterclockwise") {
                            markAllUnpacked()
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingAddItem) {
            AddItemView(bag: bag)
        }
        .sheet(isPresented: $showingEditBag) {
            EditBagView(bag: bag)
        }
        .sheet(isPresented: $showingTemplates) {
            PackingTemplatesView(bag: bag)
        }
        .sheet(isPresented: $showingShareView) {
            ShareView(shareableItem: .bag(bag))
        }
    }
    
    private func markAllPacked() {
        withAnimation {
            for item in bag.itemsArray {
                item.isPacked = true
            }
            updateBagWeight()
            saveContext()
        }
    }
    
    private func markAllUnpacked() {
        withAnimation {
            for item in bag.itemsArray {
                item.isPacked = false
            }
            saveContext()
        }
    }
    
    private func packLightestItems() {
        withAnimation {
            let sortedItems = bag.itemsArray.sorted { $0.totalWeight < $1.totalWeight }
            let halfCount = max(1, sortedItems.count / 2)
            
            // First unpack all
            for item in bag.itemsArray {
                item.isPacked = false
            }
            
            // Then pack the lightest half
            for item in sortedItems.prefix(halfCount) {
                item.isPacked = true
            }
            
            updateBagWeight()
            saveContext()
        }
    }
    
    private func updateBagWeight() {
        bag.currentWeight = bag.itemsArray.reduce(0) { $0 + $1.totalWeight }
    }
    
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

struct BagHeaderView: View {
    @ObservedObject var bag: Bag
    
    var body: some View {
        VStack(spacing: 16) {
            // Visual bag representation
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [bagColor.opacity(0.3), bagColor.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 150)
                
                VStack(spacing: 12) {
                    Image(systemName: bagIcon)
                        .font(.system(size: 50))
                        .foregroundColor(bagColor)
                    
                    VStack(spacing: 4) {
                        Text("\(bag.totalWeight, specifier: "%.1f") / \(bag.maxWeight, specifier: "%.1f") kg")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        ProgressView(value: bag.weightUtilization)
                            .progressViewStyle(LinearProgressViewStyle(tint: progressColor))
                            .frame(width: 120)
                    }
                }
            }
        }
    }
    
    private var bagColor: Color {
        switch bag.weightUtilization {
        case 0.0..<0.3:
            return .green
        case 0.3..<0.7:
            return .orange
        case 0.7..<0.9:
            return .red
        default:
            return .purple
        }
    }
    
    private var progressColor: Color {
        switch bag.weightUtilization {
        case 0.0..<0.7:
            return .green
        case 0.7..<0.9:
            return .orange
        default:
            return .red
        }
    }
    
    private var bagIcon: String {
        switch bag.weightUtilization {
        case 0.0..<0.3:
            return "suitcase"
        case 0.3..<0.7:
            return "suitcase.fill"
        default:
            return "suitcase.rolling.fill"
        }
    }
}

struct BagStatsView: View {
    @ObservedObject var bag: Bag
    
    var body: some View {
        VStack(spacing: 12) {
            // Main stats row
            HStack(spacing: 16) {
                StatCard(
                    title: "Items",
                    value: "\(bag.totalItemsCount)",
                    icon: "cube.box",
                    color: .blue
                )
                
                StatCard(
                    title: "Packed",
                    value: "\(bag.packedItemsCount)",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
                
                StatCard(
                    title: "Remaining",
                    value: "\(bag.totalItemsCount - bag.packedItemsCount)",
                    icon: "circle",
                    color: .orange
                )
            }
            
            // Sub-bags stats row (only for main bags with sub-bags)
            if bag.isMainBag && bag.totalSubBagsCount > 0 {
                HStack(spacing: 16) {
                    StatCard(
                        title: "Sub-bags",
                        value: "\(bag.totalSubBagsCount)",
                        icon: "bag.fill",
                        color: .purple
                    )
                    
                    StatCard(
                        title: "Direct Items",
                        value: "\(bag.itemsArray.count)",
                        icon: "cube",
                        color: .indigo
                    )
                    
                    StatCard(
                        title: "Total Weight",
                        value: String(format: "%.1fkg", bag.totalWeight),
                        icon: "scalemass.fill",
                        color: .brown
                    )
                }
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
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
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct ItemsListView: View {
    @ObservedObject var bag: Bag
    @Binding var showingAddItem: Bool
    @State private var showingTemplates = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Items")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button("Add Item") {
                    showingAddItem = true
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
            }
            
            if bag.itemsArray.isEmpty {
                EmptyItemsView(
                    onUseTemplate: { showingTemplates = true },
                    onAddManually: { showingAddItem = true }
                )
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(bag.itemsArray) { item in
                        ItemRowView(item: item) {
                            toggleItemPacked(item)
                        }
                    }
                }
                
                // Quick Actions Footer
                if bag.itemsArray.count > 3 {
                    QuickPackingActionsView(
                        packedCount: bag.packedItemsCount,
                        totalCount: bag.totalItemsCount,
                        onPackAll: {
                            withAnimation(.easeInOut(duration: 0.6)) {
                                for item in bag.itemsArray {
                                    item.isPacked = true
                                }
                                updateBagWeight()
                                saveContext()
                            }
                        },
                        onUnpackAll: {
                            withAnimation(.easeInOut(duration: 0.6)) {
                                for item in bag.itemsArray {
                                    item.isPacked = false
                                }
                                saveContext()
                            }
                        }
                    )
                    .padding(.top, 16)
                }
            }
        }
        .sheet(isPresented: $showingTemplates) {
            PackingTemplatesView(bag: bag)
        }
    }
    
    private func toggleItemPacked(_ item: Item) {
        withAnimation(.spring(response: 0.3)) {
            item.isPacked.toggle()
            updateBagWeight()
            saveContext()
        }
    }
    
    private func updateBagWeight() {
        bag.currentWeight = bag.itemsArray.reduce(0) { $0 + $1.totalWeight }
    }
    
    private func saveContext() {
        do {
            try bag.managedObjectContext?.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

struct EmptyItemsView: View {
    let onUseTemplate: () -> Void
    let onAddManually: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "cube.box")
                .font(.system(size: 40))
                .foregroundColor(.gray)
            
            Text("No items yet")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Add items to start packing your bag")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            HStack(spacing: 12) {
                Button("Use Template") {
                    onUseTemplate()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
                
                Button("Add Manually") {
                    onAddManually()
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct ItemRowView: View {
    @ObservedObject var item: Item
    let onToggle: () -> Void
    
    var body: some View {
        NavigationLink(destination: ItemDetailView(item: item)) {
            HStack(spacing: 12) {
                Button(action: onToggle) {
                    ZStack {
                        Circle()
                            .fill(item.isPacked ? Color.green.opacity(0.2) : Color.clear)
                            .frame(width: 30, height: 30)
                            .scaleEffect(item.isPacked ? 1.2 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: item.isPacked)
                        
                        Image(systemName: item.isPacked ? "checkmark.circle.fill" : "circle")
                            .font(.title3)
                            .foregroundColor(item.isPacked ? .green : .gray)
                            .scaleEffect(item.isPacked ? 1.1 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: item.isPacked)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                // Photo thumbnail
                Group {
                    if let photo = item.photo {
                        Image(uiImage: photo)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 40, height: 40)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    } else {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color(.systemGray5))
                            .frame(width: 40, height: 40)
                            .overlay(
                                Image(systemName: "photo")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            )
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(item.name.isEmpty ? "Unnamed Item" : item.name)
                            .font(.body)
                            .strikethrough(item.isPacked)
                            .foregroundColor(item.isPacked ? .secondary : .primary)
                        
                        Spacer()
                        
                        if item.quantity > 1 {
                            Text("×\(item.quantity)")
                                .font(.caption)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.orange.opacity(0.3))
                                .cornerRadius(4)
                        }
                    }
                    
                    if let description = item.itemDescription, !description.isEmpty {
                        Text(description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    
                    HStack {
                        if let category = item.category, !category.isEmpty {
                            Text(category)
                                .font(.caption)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.blue.opacity(0.2))
                                .cornerRadius(4)
                        }
                        
                        Spacer()
                        
                        if item.quantity > 1 {
                            Text("\(item.weight, specifier: "%.1f")kg each")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            
                            Text("= \(item.totalWeight, specifier: "%.1f")kg")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                        } else {
                            Text("\(item.weight, specifier: "%.1f")kg")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(item.isPacked ? Color(.systemGray6) : Color(.systemBackground))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(.systemGray4), lineWidth: 0.5)
        )
    }
}

struct QuickPackingActionsView: View {
    let packedCount: Int
    let totalCount: Int
    let onPackAll: () -> Void
    let onUnpackAll: () -> Void
    
    private var progressPercentage: Int {
        guard totalCount > 0 else { return 0 }
        return Int((Double(packedCount) / Double(totalCount)) * 100)
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Progress Summary
            HStack {
                Text("Progress: \(packedCount)/\(totalCount) items (\(progressPercentage)%)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                if progressPercentage == 100 {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Complete!")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                    }
                }
            }
            
            // Quick Action Buttons
            HStack(spacing: 12) {
                Button(action: onPackAll) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Pack All")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.green.opacity(0.1))
                    .foregroundColor(.green)
                    .cornerRadius(8)
                }
                .disabled(progressPercentage == 100)
                
                Button(action: onUnpackAll) {
                    HStack {
                        Image(systemName: "circle")
                        Text("Unpack All")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.orange.opacity(0.1))
                    .foregroundColor(.orange)
                    .cornerRadius(8)
                }
                .disabled(progressPercentage == 0)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    NavigationView {
        BagDetailView(bag: {
            let context = CoreDataManager.shared.context
            let bag = Bag(context: context)
            bag.id = UUID()
            bag.name = "Sample Bag"
            bag.maxWeight = 20.0
            bag.currentWeight = 5.0
            return bag
        }())
    }
    .environment(\.managedObjectContext, CoreDataManager.shared.context)
}