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
    @State private var editedCategory: String
    @State private var editedSubcategory: String
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var showingCustomCategory = false
    @State private var customCategory = ""
    @State private var customSubcategory = ""
    @State private var userCategories: [String: [String]] = [:]
    @State private var showingDeleteAlert = false
    
    private let categoryStructure: [String: [String]] = [
        "General": [],
        "Clothes": ["Tops", "Bottoms", "Underwear", "Outerwear", "Sleepwear", "Socks"],
        "Electronics": ["Chargers", "Cables", "Devices", "Batteries", "Adapters"],
        "Toiletries": ["Skincare", "Haircare", "Dental", "Makeup", "Personal Care"],
        "Documents": ["ID", "Travel", "Insurance", "Medical", "Tickets"],
        "Shoes": ["Casual", "Formal", "Athletic", "Outdoor", "Special"],
        "Accessories": ["Jewelry", "Bags", "Belts", "Hats", "Glasses"],
        "Medication": ["Prescription", "Over-the-counter", "Vitamins", "First Aid"]
    ]
    
    private var allCategoryStructure: [String: [String]] {
        var combined = categoryStructure
        for (key, value) in userCategories {
            combined[key] = value
        }
        return combined
    }
    
    private var categories: [String] {
        return Array(allCategoryStructure.keys).sorted()
    }
    
    private var subcategories: [String] {
        return allCategoryStructure[editedCategory] ?? []
    }
    
    init(item: Item) {
        self.item = item
        self._editedName = State(initialValue: item.name)
        self._editedDescription = State(initialValue: item.itemDescription ?? "")
        self._editedWeight = State(initialValue: item.weight)
        self._editedQuantity = State(initialValue: Int(item.quantity))
        self._editedCategory = State(initialValue: item.category ?? "General")
        self._editedSubcategory = State(initialValue: item.subcategory ?? "")
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
                    categories: categories,
                    subcategories: subcategories,
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
                    // Add to user categories
                    if !newCategory.isEmpty {
                        if userCategories[newCategory] == nil {
                            userCategories[newCategory] = []
                        }
                        if !newSubcategory.isEmpty && !userCategories[newCategory]!.contains(newSubcategory) {
                            userCategories[newCategory]!.append(newSubcategory)
                        }
                    }
                    
                    // Set as current selection
                    editedCategory = newCategory
                    editedSubcategory = newSubcategory
                    showingCustomCategory = false
                }
            )
        }
    }
    
    private func saveChanges() {
        withAnimation {
            // Update bag weight (remove old, add new)
            if let bag = item.bag {
                bag.currentWeight -= item.totalWeight
                bag.currentWeight += editedWeight * Double(editedQuantity)
            }
            
            item.name = editedName.trimmingCharacters(in: .whitespacesAndNewlines)
            item.itemDescription = editedDescription.isEmpty ? nil : editedDescription.trimmingCharacters(in: .whitespacesAndNewlines)
            item.weight = editedWeight
            item.quantity = Int32(editedQuantity)
            item.category = editedCategory
            item.subcategory = editedSubcategory.isEmpty ? nil : editedSubcategory
            
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
        editedCategory = item.category ?? "General"
        editedSubcategory = item.subcategory ?? ""
        isEditing = false
    }
    
    private func deleteItem() {
        withAnimation {
            // Update bag weight
            if let bag = item.bag {
                bag.currentWeight -= item.totalWeight
            }
            
            viewContext.delete(item)
            
            do {
                try viewContext.save()
                dismiss()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
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
    @Binding var editedCategory: String
    @Binding var editedSubcategory: String
    let categories: [String]
    let subcategories: [String]
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
                                    ForEach(categories, id: \.self) { category in
                                        Text(category).tag(category)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .onChange(of: editedCategory) { oldValue, newValue in
                                    // Reset subcategory when category changes
                                    editedSubcategory = ""
                                }
                                
                                Button(action: { showingCustomCategory = true }) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.blue)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            
                            if !subcategories.isEmpty {
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
                                            Text("None").tag("")
                                            ForEach(subcategories, id: \.self) { subcat in
                                                Text(subcat).tag(subcat)
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
    
    struct CustomCategoryView: View {
        @Environment(\.dismiss) private var dismiss
        @Binding var category: String
        @Binding var subcategory: String
        let onSave: (String, String) -> Void
        
        var body: some View {
            NavigationView {
                Form {
                    Section(header: Text("Create Category")) {
                        VStack(alignment: .leading, spacing: 12) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Category Name")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                TextField("e.g., Sports Equipment", text: $category)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Subcategory (optional)")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                TextField("e.g., Running Gear", text: $subcategory)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                        }
                    }
                    
                    Section(header: Text("Preview")) {
                        if !category.isEmpty {
                            HStack {
                                Image(systemName: "folder.fill")
                                    .foregroundColor(.blue)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Your new category:")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    Text(subcategory.isEmpty ? category : "\(category) > \(subcategory)")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                }
                                
                                Spacer()
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                .navigationTitle("Custom Category")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Save") {
                            onSave(category.trimmingCharacters(in: .whitespacesAndNewlines), 
                                   subcategory.trimmingCharacters(in: .whitespacesAndNewlines))
                        }
                        .disabled(category.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
            }
        }
    }
}
    .environment(\.managedObjectContext, CoreDataManager.shared.context)
}