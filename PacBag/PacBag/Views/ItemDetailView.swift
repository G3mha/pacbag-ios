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
        ScrollView {
            VStack(spacing: 20) {
                // Photo Section
                PhotoDisplaySection(item: item, selectedPhoto: $selectedPhoto, isEditing: isEditing)
                
                // Item Details Section
                ItemDetailsSection(
                    item: item,
                    isEditing: isEditing,
                    editedName: $editedName,
                    editedDescription: $editedDescription,
                    editedWeight: $editedWeight,
                    editedQuantity: $editedQuantity,
                    editedCategory: $editedCategory,
                    editedSubcategory: $editedSubcategory,
                    selectedBag: $selectedBag,
                    availableCategories: availableCategories,
                    availableSubcategories: availableSubcategories,
                    availableBags: availableBags,
                    showingCustomCategory: $showingCustomCategory
                )
                
                // Stats Section
                ItemStatsSection(item: item)
                
                // Actions Section
                ItemActionsSection(
                    item: item,
                    showingDeleteAlert: $showingDeleteAlert
                )
            }
            .padding()
        }
        .navigationTitle(item.name.isEmpty ? "Unnamed Item" : item.name)
        .navigationBarTitleDisplayMode(.large)
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
        .onChange(of: selectedPhoto) { oldValue, newValue in
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
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
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
                let nsError = error as NSError
                print("Unresolved error \(nsError), \(nsError.userInfo)")
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

struct PhotoDisplaySection: View {
    @ObservedObject var item: Item
    @Binding var selectedPhoto: PhotosPickerItem?
    let isEditing: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            if let photo = item.photo {
                Image(uiImage: photo)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
                    .frame(height: 200)
                    .overlay(
                        VStack {
                            Image(systemName: "photo")
                                .font(.system(size: 40))
                                .foregroundColor(.secondary)
                            Text("No photo")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    )
            }
            
            if isEditing {
                HStack(spacing: 12) {
                    PhotosPicker("Change Photo", selection: $selectedPhoto, matching: .images)
                        .buttonStyle(.bordered)
                    
                    if item.hasPhoto {
                        Button("Remove Photo") {
                            item.photoData = nil
                            try? item.managedObjectContext?.save()
                        }
                        .buttonStyle(.bordered)
                        .foregroundColor(.red)
                    }
                }
            }
        }
    }
}

struct ItemDetailsSection: View {
    @ObservedObject var item: Item
    let isEditing: Bool
    @Binding var editedName: String
    @Binding var editedDescription: String
    @Binding var editedWeight: Double
    @Binding var editedQuantity: Int
    @Binding var editedCategory: Category?
    @Binding var editedSubcategory: SubCategory?
    @Binding var selectedBag: Bag?
    let availableCategories: [Category]
    let availableSubcategories: [SubCategory]
    let availableBags: [Bag]
    @Binding var showingCustomCategory: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Details")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(spacing: 12) {
                // Name
                HStack {
                    Text("Name")
                        .fontWeight(.medium)
                        .frame(width: 80, alignment: .leading)
                    
                    if isEditing {
                        TextField("Item name", text: $editedName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    } else {
                        Text(item.name.isEmpty ? "Unnamed Item" : item.name)
                            .foregroundColor(.primary)
                        Spacer()
                    }
                }
                
                // Description
                VStack(alignment: .leading, spacing: 4) {
                    Text("Description")
                        .fontWeight(.medium)
                    
                    if isEditing {
                        TextField("Description (optional)", text: $editedDescription, axis: .vertical)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .lineLimit(2...4)
                    } else {
                        Text(item.itemDescription?.isEmpty == false ? item.itemDescription! : "No description")
                            .foregroundColor(item.itemDescription?.isEmpty == false ? .primary : .secondary)
                            .font(.body)
                    }
                }
                
                // Category
                VStack(alignment: .leading, spacing: 8) {
                    if isEditing {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Picker("Category", selection: $editedCategory) {
                                    Text("Select Category").tag(nil as Category?)
                                    ForEach(availableCategories, id: \.id) { category in
                                        HStack {
                                            Image(systemName: category.icon)
                                                .foregroundColor(category.color)
                                            Text(category.name)
                                        }
                                        .tag(category as Category?)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .onChange(of: editedCategory) { oldValue, newValue in
                                    // Reset subcategory when category changes
                                    editedSubcategory = nil
                                }
                                
                                Button(action: { showingCustomCategory = true }) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.blue)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            
                            if !availableSubcategories.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text("Subcategory")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                        Text("(optional)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Spacer()
                                    }
                                    
                                    HStack {
                                        Picker("Subcategory", selection: $editedSubcategory) {
                                            Text("None").tag(nil as SubCategory?)
                                            ForEach(availableSubcategories, id: \.id) { subcategory in
                                                Text(subcategory.name).tag(subcategory as SubCategory?)
                                            }
                                        }
                                        .pickerStyle(MenuPickerStyle())
                                        .padding(.vertical, 4)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(8)
                                        
                                        Button(action: { showingCustomCategory = true }) {
                                            Image(systemName: "plus.circle.fill")
                                                .font(.title3)
                                                .foregroundColor(.blue)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                            }
                        }
                    } else {
                        HStack {
                            Text("Category")
                                .fontWeight(.medium)
                                .frame(width: 80, alignment: .leading)
                            
                            Text(item.fullCategory)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.2))
                                .cornerRadius(6)
                            Spacer()
                        }
                    }
                }
                
                // Bag Selection
                if isEditing {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Current Bag")
                                .fontWeight(.medium)
                                .frame(width: 80, alignment: .leading)
                            
                            if availableBags.count > 1 {
                                Picker("Bag", selection: $selectedBag) {
                                    ForEach(availableBags, id: \.id) { bag in
                                        Text("\(bag.isSubBag ? "↳ " : "")\(bag.name.isEmpty ? "Unnamed \(bag.isSubBag ? "Sub-bag" : "Bag")" : bag.name)\(bag.isSubBag ? " (Sub-bag)" : "")")
                                            .tag(bag)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                            } else {
                                Text(selectedBag?.name.isEmpty == false ? selectedBag?.name ?? "No Bag" : "No Bag")
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(6)
                                Spacer()
                            }
                        }
                        
                        // Info message when only one bag is available
                        if availableBags.count <= 1 {
                            HStack {
                                Image(systemName: "info.circle")
                                    .foregroundColor(.gray)
                                Text("Add more bags to this trip to enable transfers")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Spacer()
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(6)
                        }
                        
                        if let selectedBag = selectedBag, selectedBag != item.bag {
                            HStack {
                                Image(systemName: "arrow.right.circle.fill")
                                    .foregroundColor(.blue)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Item will be moved to:")
                                        .font(.caption2)
                                        .foregroundColor(.blue)
                                    HStack {
                                        if selectedBag.isSubBag {
                                            Text("↳ ")
                                                .foregroundColor(.blue)
                                        }
                                        Text("\(selectedBag.name.isEmpty ? "Unnamed Bag" : selectedBag.name)")
                                            .font(.caption)
                                            .fontWeight(.medium)
                                            .foregroundColor(.blue)
                                        if selectedBag.isSubBag {
                                            Text("(Sub-bag)")
                                                .font(.caption2)
                                                .foregroundColor(.blue.opacity(0.7))
                                        }
                                    }
                                }
                                Spacer()
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(6)
                        }
                    }
                }
                
                // Quantity
                HStack {
                    Text("Quantity")
                        .fontWeight(.medium)
                        .frame(width: 80, alignment: .leading)
                    
                    if isEditing {
                        Stepper("\(editedQuantity)", value: $editedQuantity, in: 1...99)
                    } else {
                        Text("\(item.quantity)")
                            .foregroundColor(.primary)
                        Spacer()
                    }
                }
                
                // Weight
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Weight per item")
                            .fontWeight(.medium)
                        Spacer()
                        Text("\(isEditing ? editedWeight : item.weight, specifier: "%.1f") kg")
                            .foregroundColor(.secondary)
                    }
                    
                    if isEditing {
                        Slider(value: $editedWeight, in: 0.1...10.0, step: 0.1)
                    }
                    
                    HStack {
                        Text("Total weight")
                            .fontWeight(.medium)
                        Spacer()
                        Text("\(isEditing ? editedWeight * Double(editedQuantity) : item.totalWeight, specifier: "%.1f") kg")
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
}

struct ItemStatsSection: View {
    @ObservedObject var item: Item
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Status")
                .font(.title2)
                .fontWeight(.bold)
            
            HStack(spacing: 20) {
                StatCard(
                    title: "Status",
                    value: item.isPacked ? "Packed" : "Unpacked",
                    icon: item.isPacked ? "checkmark.circle.fill" : "circle",
                    color: item.isPacked ? .green : .orange
                )
                
                StatCard(
                    title: "Bag",
                    value: item.bag?.name ?? "No bag",
                    icon: item.bag?.isSubBag == true ? "bag.fill" : "suitcase.fill",
                    color: .blue
                )
            }
        }
    }
}

struct ItemActionsSection: View {
    @ObservedObject var item: Item
    @Binding var showingDeleteAlert: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Actions")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(spacing: 12) {
                Button(action: {
                    withAnimation {
                        item.isPacked.toggle()
                        try? item.managedObjectContext?.save()
                    }
                }) {
                    HStack {
                        Image(systemName: item.isPacked ? "circle" : "checkmark.circle.fill")
                        Text(item.isPacked ? "Mark as Unpacked" : "Mark as Packed")
                        Spacer()
                    }
                    .foregroundColor(item.isPacked ? .orange : .green)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: { showingDeleteAlert = true }) {
                    HStack {
                        Image(systemName: "trash")
                        Text("Delete Item")
                        Spacer()
                    }
                    .foregroundColor(.red)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
                .buttonStyle(PlainButtonStyle())
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