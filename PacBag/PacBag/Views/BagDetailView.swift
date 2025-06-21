import SwiftUI
import CoreData

struct BagDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var bag: Bag
    
    @State private var showingAddItem = false
    @State private var showingEditBag = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Bag Header with visual representation
                BagHeaderView(bag: bag)
                
                // Quick Stats
                BagStatsView(bag: bag)
                
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
                    
                    Divider()
                    
                    Button("Mark All Packed", systemImage: "checkmark.circle") {
                        markAllPacked()
                    }
                    
                    Button("Mark All Unpacked", systemImage: "circle") {
                        markAllUnpacked()
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
    
    private func updateBagWeight() {
        bag.currentWeight = bag.itemsArray.reduce(0) { $0 + $1.weight }
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
                        Text("\(bag.currentWeight, specifier: "%.1f") / \(bag.maxWeight, specifier: "%.1f") kg")
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
        HStack(spacing: 20) {
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
                EmptyItemsView()
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(bag.itemsArray) { item in
                        ItemRowView(item: item) {
                            toggleItemPacked(item)
                        }
                    }
                }
            }
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
        bag.currentWeight = bag.itemsArray.reduce(0) { $0 + $1.weight }
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
        HStack(spacing: 12) {
            Button(action: onToggle) {
                Image(systemName: item.isPacked ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(item.isPacked ? .green : .gray)
            }
            .buttonStyle(PlainButtonStyle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name.isEmpty ? "Unnamed Item" : item.name)
                    .font(.body)
                    .strikethrough(item.isPacked)
                    .foregroundColor(item.isPacked ? .secondary : .primary)
                
                HStack {
                    if let category = item.category, !category.isEmpty {
                        Text(category)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(4)
                    }
                    
                    Text("\(item.weight, specifier: "%.1f")kg")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
            }
        }
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