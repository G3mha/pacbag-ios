import SwiftUI
import CoreData
import PhotosUI

struct ItemDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var item: Item
    
    @State private var isEditing = false
    @State private var editedName: String
    @State private var editedDescription: String
    @State private var editedWeight: Double
    @State private var editedQuantity: Int
    @State private var editedCategory: Category?
    @State private var editedSubcategory: SubCategory?
    @State private var selectedBag: Bag?
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var showingCustomCategory = false
    @State private var customCategory = ""
    @State private var customSubcategory = ""
    @StateObject private var categoryManager = CategoryManager.shared
    @State private var showingDeleteAlert = false
    
    private var availableCategories: [Category] {
        return categoryManager.categories
    }
    
    private var availableSubcategories: [SubCategory] {
        guard let category = editedCategory else { return [] }
        return categoryManager.subcategories(for: category)
    }
    
    private var availableBags: [Bag] {
        guard let currentTrip = item.bag?.trip else { return [] }
        return getAllBagsInTrip(currentTrip)
    }
    
    private func getAllBagsInTrip(_ trip: Trip) -> [Bag] {
        var allBags: [Bag] = []
        
        // Get all main bags from the trip
        for bag in trip.bagsArray {
            allBags.append(bag)
            
            // Get all sub-bags recursively
            allBags.append(contentsOf: getAllSubBags(bag))
        }
        
        return allBags
    }
    
    private func getAllSubBags(_ parentBag: Bag) -> [Bag] {
        var subBags: [Bag] = []
        
        for subBag in parentBag.subBagsArray {
            subBags.append(subBag)
            // Recursively get nested sub-bags
            subBags.append(contentsOf: getAllSubBags(subBag))
        }
        
        return subBags
    }
    
    init(item: Item) {
        self.item = item
        self._editedName = State(initialValue: item.name)
        self._editedDescription = State(initialValue: item.itemDescription ?? "")
        self._editedWeight = State(initialValue: item.weight)
        self._editedQuantity = State(initialValue: Int(item.quantity))
        self._editedCategory = State(initialValue: item.categoryEntity ?? CategoryManager.shared.category(named: item.category ?? "General"))
        self._editedSubcategory = State(initialValue: item.subcategoryEntity ?? (item.subcategory != nil ? CategoryManager.shared.category(named: item.category ?? "")?.subcategoriesArray.first { $0.name == item.subcategory } : nil))
        self._selectedBag = State(initialValue: item.bag)
    }
    
    var body: some View {
        List {
            if !item.isGone {
                if isEditing {
                    editingSections
                } else {
                    viewingSections
                }

                Section {
                    Toggle("Packed", isOn: $item.isPacked)
                        .onChange(of: item.isPacked) { _, _ in
                            try? viewContext.save()
                        }
                }

                Section {
                    Button("Delete Item", role: .destructive) {
                        showingDeleteAlert = true
                    }
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle(item.name.isEmpty ? "Unnamed Item" : item.name)
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden(isEditing)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(isEditing ? "Save" : "Edit") {
                    if isEditing {
                        saveChanges()
                    } else {
                        isEditing = true
                    }
                }
            }

            if isEditing {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        cancelEditing()
                    }
                }
            }
        }
        .alert("Delete Item", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                deleteItem()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete this item? This action cannot be undone.")
        }
        .onChange(of: selectedPhoto) { _, newValue in
            if isEditing {
                loadPhoto(from: newValue)
            }
        }
        .sheet(isPresented: $showingCustomCategory) {
            CustomCategoryView(
                category: $customCategory,
                subcategory: $customSubcategory,
                onSave: { newCategory, newSubcategory in
                    // Save to CategoryManager
                    if !newCategory.isEmpty {
                        categoryManager.addCategory(newCategory, subcategory: newSubcategory)
                    }
                    
                    // Set as current selection
                    if let category = categoryManager.category(named: newCategory) {
                        editedCategory = category
                        if !newSubcategory.isEmpty {
                            editedSubcategory = category.subcategoriesArray.first { $0.name == newSubcategory }
                        }
                    }
                    showingCustomCategory = false
                }
            )
        }
    }
    
    @ViewBuilder
    private var viewingSections: some View {
        if item.hasPhoto {
            Section {
                photo
            }
        }

        Section {
            if let description = item.itemDescription, !description.isEmpty {
                Text(description)
            }

            detailRow("Category", item.fullCategory)
            detailRow("Quantity", "\(item.quantity)")
            detailRow("Per item", "\(item.weight.oneDecimal) kg")
            detailRow("Total", "\(item.totalWeight.oneDecimal) kg")
            detailRow("Bag", item.bag.map(bagName) ?? "No bag")
        }
    }

    @ViewBuilder
    private var editingSections: some View {
        Section {
            TextField("Item Name", text: $editedName)

            TextField("Description (optional)", text: $editedDescription, axis: .vertical)
                .lineLimit(2...4)
        }

        Section {
            Picker("Category", selection: $editedCategory) {
                Text("Select Category").tag(nil as Category?)
                ForEach(availableCategories, id: \.id) { category in
                    Text(category.name).tag(category as Category?)
                }
            }
            .pickerStyle(.menu)
            .onChange(of: editedCategory) { _, newCategory in
                // Reset subcategory when it doesn't belong to the new category
                if editedSubcategory?.category != newCategory {
                    editedSubcategory = nil
                }
            }

            if !availableSubcategories.isEmpty {
                Picker("Subcategory", selection: $editedSubcategory) {
                    Text("None").tag(nil as SubCategory?)
                    ForEach(availableSubcategories, id: \.id) { subcategory in
                        Text(subcategory.name).tag(subcategory as SubCategory?)
                    }
                }
                .pickerStyle(.menu)
            }

            Button("New Category") {
                showingCustomCategory = true
            }

            if !availableSubcategories.isEmpty {
                Button("New Subcategory") {
                    customCategory = editedCategory?.name ?? ""
                    showingCustomCategory = true
                }
            }
        }

        ItemWeightSection(quantity: $editedQuantity, weight: $editedWeight)

        Section {
            if availableBags.count > 1 {
                Picker("Bag", selection: $selectedBag) {
                    ForEach(availableBags, id: \.objectID) { bag in
                        Text(bag.isSubBag ? "\(bagName(bag)) (sub-bag)" : bagName(bag))
                            .tag(bag as Bag?)
                    }
                }
                .pickerStyle(.menu)
            } else {
                detailRow("Bag", selectedBag.map(bagName) ?? "No bag")
            }
        }

        Section(header: Text("Photo").solidSectionHeader()) {
            photo

            PhotosPicker(item.hasPhoto ? "Change Photo" : "Add Photo", selection: $selectedPhoto, matching: .images)

            if item.hasPhoto {
                Button("Remove Photo", role: .destructive) {
                    item.photoData = nil
                    selectedPhoto = nil
                    try? viewContext.save()
                }
            }
        }
    }

    @ViewBuilder
    private var photo: some View {
        if let photo = item.photo {
            Image(uiImage: photo)
                .resizable()
                .scaledToFill()
                .frame(height: 200)
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }

    private func detailRow(_ title: String, _ value: String) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.trailing)
        }
    }

    private func bagName(_ bag: Bag) -> String {
        bag.name.isEmpty ? "Unnamed Bag" : bag.name
    }

    private func saveChanges() {
        withAnimation {
            let newTotalWeight = editedWeight * Double(editedQuantity)
            
            // Handle bag transfer
            if let oldBag = item.bag, let newBag = selectedBag, newBag != oldBag {
                // Remove weight from old bag
                oldBag.currentWeight -= item.totalWeight
                
                // Add weight to new bag
                newBag.currentWeight += newTotalWeight
                
                // Transfer item to new bag
                item.bag = newBag
            } else if let bag = item.bag {
                // Same bag, just update weight difference
                bag.currentWeight -= item.totalWeight
                bag.currentWeight += newTotalWeight
            }
            
            item.name = editedName.trimmingCharacters(in: .whitespacesAndNewlines)
            item.itemDescription = editedDescription.isEmpty ? nil : editedDescription.trimmingCharacters(in: .whitespacesAndNewlines)
            item.weight = editedWeight
            item.quantity = Int32(editedQuantity)
            // Set both legacy and new category relationships for compatibility
            item.category = editedCategory?.name
            item.subcategory = editedSubcategory?.name
            item.categoryEntity = editedCategory
            item.subcategoryEntity = editedSubcategory
            
            // Track usage
            if let category = editedCategory {
                categoryManager.incrementUsage(for: category)
            }
            if let subcategory = editedSubcategory {
                categoryManager.incrementUsage(for: subcategory)
            }
            
            do {
                try viewContext.save()
                isEditing = false
            } catch {
                print("Failed to save item changes: \(error)")
                fatalError("Unresolved error \(error)")
            }
        }
    }
    
    private func cancelEditing() {
        editedName = item.name
        editedDescription = item.itemDescription ?? ""
        editedWeight = item.weight
        editedQuantity = Int(item.quantity)
        editedCategory = item.categoryEntity ?? categoryManager.category(named: item.category ?? "General")
        editedSubcategory = item.subcategoryEntity ?? (item.subcategory != nil ? categoryManager.category(named: item.category ?? "")?.subcategoriesArray.first { $0.name == item.subcategory! } : nil)
        selectedBag = item.bag
        isEditing = false
    }
    
    private func deleteItem() {
        withAnimation {
            // Update bag weight
            if let bag = item.bag {
                // Ensure we don't go negative
                let weightToSubtract = item.totalWeight
                bag.currentWeight = max(0, bag.currentWeight - weightToSubtract)
            }
            
            viewContext.delete(item)
            
            do {
                try viewContext.save()
                dismiss()
            } catch {
                print("Failed to delete item: \(error)")
                // Still try to dismiss even if save failed
                dismiss()
            }
        }
    }
    
    private func loadPhoto(from photoItem: PhotosPickerItem?) {
        guard let photoItem = photoItem else { return }
        
        Task {
            if let data = try? await photoItem.loadTransferable(type: Data.self) {
                DispatchQueue.main.async {
                    self.item.photoData = data
                    try? self.viewContext.save()
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        ItemDetailView(item: {
            let context = CoreDataManager.shared.context
            let item = Item(context: context)
            item.id = UUID()
            item.name = "Sample Item"
            item.weight = 1.5
            item.quantity = 2
            item.category = "Electronics"
            item.itemDescription = "A useful electronic device for travel"
            item.isPacked = false
            return item
        }())
    }
    .environment(\.managedObjectContext, CoreDataManager.shared.context)
}