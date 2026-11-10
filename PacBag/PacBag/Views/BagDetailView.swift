import SwiftUI
import CoreData

struct BagDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var bag: Bag
    @StateObject private var settingsManager = SettingsManager.shared

    @State private var showingAddItem = false
    @State private var showingAddSubBag = false
    @State private var showingEditBag = false
    @State private var showingTemplates = false
    @State private var showingShareView = false
    @State private var showingCreateTemplate = false

    private var sortOrder: ItemSortOrder {
        settingsManager.defaultItemSortOrder
    }

    private var sortAscending: Bool {
        settingsManager.sortAscending
    }

    private var sortedItems: [Item] {
        bag.itemsArray.sorted { first, second in
            switch sortOrder {
            case .name:
                break
            case .category:
                if first.fullCategory != second.fullCategory {
                    return inSortOrder(first.fullCategory.localizedCaseInsensitiveCompare(second.fullCategory))
                }
            case .weight:
                if first.totalWeight != second.totalWeight {
                    return sortAscending ? first.totalWeight < second.totalWeight : first.totalWeight > second.totalWeight
                }
            case .packed:
                if first.isPacked != second.isPacked {
                    return sortAscending ? second.isPacked : first.isPacked
                }
            case .dateAdded:
                return inSortOrder(first.id.uuidString.compare(second.id.uuidString))
            }
            return inSortOrder(first.name.localizedCaseInsensitiveCompare(second.name))
        }
    }

    /// One untitled group, or one group per category when sorting by category.
    private var itemGroups: [(title: String?, items: [Item])] {
        guard sortOrder == .category else { return [(nil, sortedItems)] }

        var groups: [(title: String?, items: [Item])] = []
        for item in sortedItems {
            if let last = groups.indices.last, groups[last].title == item.fullCategory {
                groups[last].items.append(item)
            } else {
                groups.append((item.fullCategory, [item]))
            }
        }
        return groups
    }

    var body: some View {
        List {
            Section {
                PackingProgressView(
                    packed: bag.packedItemsCount,
                    total: bag.totalItemsCount,
                    weight: bag.totalWeight,
                    maxWeight: bag.maxWeight
                )
            }

            if !bag.subBagsArray.isEmpty {
                Section(header: Text("Sub-bags").solidSectionHeader()) {
                    ForEach(bag.subBagsArray.sorted { $0.name < $1.name }, id: \.objectID) { subBag in
                        NavigationLink(destination: SubBagDetailView(subBag: subBag)) {
                            BagRowView(bag: subBag)
                        }
                    }
                }
            }

            if bag.itemsArray.isEmpty {
                EmptyItemsView(
                    onUseTemplate: { showingTemplates = true },
                    onAddManually: { showingAddItem = true }
                )
                .listRowSeparator(.hidden)
            } else {
                ForEach(itemGroups, id: \.title) { group in
                    Section {
                        ForEach(group.items, id: \.objectID) { item in
                            itemRow(item)
                        }
                    } header: {
                        // Untitled items need a heading to read apart from the sub-bags above them.
                        if let title = group.title ?? (bag.subBagsArray.isEmpty ? nil : "Items") {
                            Text(title)
                                .solidSectionHeader()
                        }
                    }
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle(bag.name.isEmpty ? "Unnamed Bag" : bag.name)
        .navigationBarTitleDisplayMode(.large)
        .refreshesOnContextChange(bag)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddItem = true }) {
                    Label("Add Item", systemImage: "plus")
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                menu
            }
        }
        .sheet(isPresented: $showingAddItem) {
            AddItemView(bag: bag)
        }
        .sheet(isPresented: $showingAddSubBag) {
            AddSubBagView(parentBag: bag)
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
        .sheet(isPresented: $showingCreateTemplate) {
            CustomTemplateCreationView(sourceTrip: nil, sourceBag: bag)
        }
    }

    private var menu: some View {
        Menu {
            Button("Edit Bag", systemImage: "pencil") {
                showingEditBag = true
            }

            Button("Use Template", systemImage: "doc.text") {
                showingTemplates = true
            }

            if bag.isMainBag {
                Button("Add Sub-bag", systemImage: "bag.badge.plus") {
                    showingAddSubBag = true
                }
            }

            Divider()

            Button("Mark All Packed", systemImage: "checkmark.circle") {
                setAllPacked(true)
            }
            .disabled(bag.totalItemsCount == 0 || bag.packingProgress == 1.0)

            Button("Mark All Unpacked", systemImage: "circle") {
                setAllPacked(false)
            }
            .disabled(bag.packedItemsCount == 0)

            Divider()

            Menu("Sort By", systemImage: "arrow.up.arrow.down") {
                Picker("Sort By", selection: $settingsManager.defaultItemSortOrder) {
                    ForEach(ItemSortOrder.allCases, id: \.self) { order in
                        Label(order.displayName, systemImage: order.systemImage).tag(order)
                    }
                }

                Picker("Direction", selection: $settingsManager.sortAscending) {
                    Label("Ascending", systemImage: "arrow.up").tag(true)
                    Label("Descending", systemImage: "arrow.down").tag(false)
                }
            }

            Divider()

            Button("Share Bag", systemImage: "square.and.arrow.up") {
                showingShareView = true
            }

            Button("Create Template", systemImage: "doc.badge.plus") {
                showingCreateTemplate = true
            }
        } label: {
            Image(systemName: "ellipsis.circle")
        }
    }

    private func itemRow(_ item: Item) -> some View {
        ItemRowView(item: item) {
            toggleItemPacked(item)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button("Delete", role: .destructive) {
                deleteItem(item)
            }

            Button(item.isPacked ? "Unpack" : "Pack") {
                toggleItemPacked(item)
            }
        }
        .contextMenu {
            Button(item.isPacked ? "Mark as Unpacked" : "Mark as Packed",
                   systemImage: item.isPacked ? "circle" : "checkmark.circle") {
                toggleItemPacked(item)
            }

            Divider()

            Button("Delete Item", systemImage: "trash", role: .destructive) {
                deleteItem(item)
            }
        }
    }

    private func inSortOrder(_ comparison: ComparisonResult) -> Bool {
        sortAscending ? comparison == .orderedAscending : comparison == .orderedDescending
    }

    private func setAllPacked(_ isPacked: Bool) {
        withAnimation {
            bag.setAllItemsPacked(isPacked)
            saveContext()
        }
    }

    private func toggleItemPacked(_ item: Item) {
        withAnimation {
            item.isPacked.toggle()
            bag.currentWeight = bag.itemsArray.reduce(0) { $0 + $1.totalWeight }
            saveContext()
        }
    }

    private func deleteItem(_ item: Item) {
        withAnimation {
            // Update bag weight before deleting the item
            if let itemBag = item.bag {
                // Ensure we don't go negative
                let weightToSubtract = item.totalWeight
                itemBag.currentWeight = max(0, itemBag.currentWeight - weightToSubtract)
            }

            viewContext.delete(item)
            saveContext()
        }
    }

    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
}

struct EmptyItemsView: View {
    let onUseTemplate: () -> Void
    let onAddManually: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Text("No items yet")
                .font(.headline)

            Text("Start from a template or add your own.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            HStack(spacing: 12) {
                Button("Use Template") {
                    onUseTemplate()
                }
                .buttonStyle(.borderedProminent)

                Button("Add Manually") {
                    onAddManually()
                }
                .buttonStyle(.bordered)
            }
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
    }
}

struct ItemRowView: View {
    @ObservedObject var item: Item
    let onToggle: () -> Void
    @State private var cachedPhoto: UIImage?

    private var name: String {
        item.name.isEmpty ? "Unnamed Item" : item.name
    }

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onToggle) {
                Image(systemName: item.isPacked ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(item.isPacked ? .accentColor : .secondary)
                    .frame(width: 32, height: 32)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(item.isPacked ? "Mark \(name) as unpacked" : "Mark \(name) as packed")

            if let cachedPhoto {
                Image(uiImage: cachedPhoto)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 32, height: 32)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }

            Text(name)
                .strikethrough(item.isPacked)
                .foregroundColor(item.isPacked ? .secondary : .primary)

            if item.quantity > 1 {
                Text("×\(item.quantity)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text("\(item.totalWeight.oneDecimal) kg")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        // A link in the background opens the item without drawing a chevron on every row.
        .background(
            NavigationLink(destination: ItemDetailView(item: item)) {
                EmptyView()
            }
            .opacity(0)
        )
        .onAppear {
            if item.hasPhoto && cachedPhoto == nil {
                cachedPhoto = item.photo
            }
        }
    }
}

#Preview {
    NavigationStack {
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
