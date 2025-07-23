import SwiftUI
import CoreData
import PhotosUI

struct AddItemView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var bag: Bag
    
    @State private var itemName = ""
    @State private var weight = 0.1
    @State private var selectedCategory: Category?
    @State private var selectedSubcategory: SubCategory?
    @State private var showingCustomCategory = false
    @State private var customCategory = ""
    @State private var customSubcategory = ""
    @StateObject private var categoryManager = CategoryManager.shared
    @State private var itemDescription = ""
    @State private var quantity: Int = 1
    @State private var isPacked = false
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var photoData: Data?
    @State private var showingCamera = false
    
    private var availableCategories: [Category] {
        return categoryManager.categories
    }
    
    private var availableSubcategories: [SubCategory] {
        guard let category = selectedCategory else { return [] }
        return categoryManager.subcategories(for: category)
    }
    
    private var categorySelectionView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Picker("Category", selection: $selectedCategory) {
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
                .onChange(of: selectedCategory) { _, _ in
                    selectedSubcategory = nil
                }
                
                Button(action: { showingCustomCategory = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            if !availableSubcategories.isEmpty {
                subcategorySelectionView
            }
            
            if let category = selectedCategory {
                currentSelectionView(category: category)
            }
        }
    }
    
    @ViewBuilder
    private var subcategorySelectionView: some View {
        VStack(alignment: .leading, spacing: 8) {
            subcategoryHeader
            subcategoryGrid
        }
    }
    
    private var subcategoryHeader: some View {
        HStack {
            Text("Subcategory")
                .font(.subheadline)
                .fontWeight(.medium)
            Text("(optional)")
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
        }
    }
    
    private var subcategoryGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
            ForEach(availableSubcategories, id: \.id) { subcategory in
                subcategoryButton(for: subcategory)
            }
        }
    }
    
    private func subcategoryButton(for subcategory: SubCategory) -> some View {
        Button(action: {
            if selectedSubcategory == subcategory {
                selectedSubcategory = nil
            } else {
                selectedSubcategory = subcategory
            }
        }) {
            HStack {
                Image(systemName: subcategory.category.icon)
                    .foregroundColor(subcategory.category.color)
                Text(subcategory.name)
                    .font(.caption)
                Spacer()
                if selectedSubcategory == subcategory {
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                        .font(.caption)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(selectedSubcategory == subcategory ? subcategory.category.color.opacity(0.2) : Color.gray.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(selectedSubcategory == subcategory ? subcategory.category.color : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func currentSelectionView(category: Category) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Current Selection:")
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack {
                Image(systemName: category.icon)
                    .foregroundColor(category.color)
                Text(selectedSubcategory == nil ? category.name : "\(category.name) > \(selectedSubcategory?.name ?? "Unknown")")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(category.color.opacity(0.1))
            .cornerRadius(6)
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Item Details")) {
                    TextField("Item Name", text: $itemName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Description (optional)", text: $itemDescription, axis: .vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .lineLimit(2...4)
                    
                    categorySelectionView
                }
                
                Section(header: Text("Quantity & Weight")) {
                    HStack {
                        Text("Quantity")
                        Spacer()
                        Stepper("\(quantity)", value: $quantity, in: 1...99)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Weight per item")
                            Spacer()
                            Text("\(weight, specifier: "%.1f") kg")
                                .foregroundColor(.secondary)
                        }
                        
                        Slider(value: $weight, in: 0.1...10.0, step: 0.1)
                        
                        HStack {
                            Text("Total weight")
                            Spacer()
                            Text("\(weight * Double(quantity), specifier: "%.1f") kg")
                                .foregroundColor(.primary)
                                .fontWeight(.semibold)
                        }
                    }
                }
                
                Section(header: Text("Photo")) {
                    PhotoSectionView(
                        photoData: $photoData,
                        selectedPhoto: $selectedPhoto,
                        showingCamera: $showingCamera
                    )
                }
                
                Section(header: Text("Packing")) {
                    Toggle("Already Packed", isOn: $isPacked)
                }
                
                Section(header: Text("Preview")) {
                    EnhancedItemPreview(
                        name: itemName.isEmpty ? "New Item" : itemName,
                        description: itemDescription,
                        weight: weight,
                        quantity: quantity,
                        category: selectedCategory?.name ?? "General",
                        subcategory: selectedSubcategory?.name ?? "",
                        photoData: photoData,
                        isPacked: isPacked
                    )
                }
            }
            .navigationTitle("Add Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveItem()
                    }
                    .disabled(itemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .onChange(of: selectedPhoto) { _, newValue in
            loadPhoto(from: newValue)
        }
        .onAppear {
            // Set default category if none selected
            if selectedCategory == nil && !availableCategories.isEmpty {
                selectedCategory = categoryManager.category(named: "General") ?? availableCategories.first
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
                        selectedCategory = category
                        if !newSubcategory.isEmpty {
                            selectedSubcategory = category.subcategoriesArray.first { $0.name == newSubcategory }
                        }
                    }
                    showingCustomCategory = false
                }
            )
        }
    }
    
    private func saveItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.id = UUID()
            newItem.name = itemName.trimmingCharacters(in: .whitespacesAndNewlines)
            newItem.itemDescription = itemDescription.isEmpty ? nil : itemDescription.trimmingCharacters(in: .whitespacesAndNewlines)
            newItem.weight = weight
            newItem.quantity = Int32(quantity)
            // Set both legacy and new category relationships for compatibility
            newItem.category = selectedCategory?.name
            newItem.subcategory = selectedSubcategory?.name
            newItem.categoryEntity = selectedCategory
            newItem.subcategoryEntity = selectedSubcategory
            
            // Track usage
            if let category = selectedCategory {
                categoryManager.incrementUsage(for: category)
            }
            if let subcategory = selectedSubcategory {
                categoryManager.incrementUsage(for: subcategory)
            }
            newItem.isPacked = isPacked
            newItem.photoData = photoData
            newItem.bag = bag
            
            // Update bag's current weight (total weight for all quantities)
            bag.currentWeight += weight * Double(quantity)
            
            do {
                try viewContext.save()
                dismiss()
            } catch {
                print("Failed to save item: \(error)")
                fatalError("Unresolved error \(error)")
            }
        }
    }
    
    private func loadPhoto(from item: PhotosPickerItem?) {
        guard let item = item else { return }
        
        Task {
            if let data = try? await item.loadTransferable(type: Data.self) {
                DispatchQueue.main.async {
                    self.photoData = data
                }
            }
        }
    }
}

struct PhotoSectionView: View {
    @Binding var photoData: Data?
    @Binding var selectedPhoto: PhotosPickerItem?
    @Binding var showingCamera: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            if let photoData = photoData, let image = UIImage(data: photoData) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemGray6))
                    .frame(height: 120)
                    .overlay(
                        VStack {
                            Image(systemName: "photo")
                                .font(.largeTitle)
                                .foregroundColor(.secondary)
                            Text("No photo selected")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    )
            }
            
            HStack(spacing: 12) {
                PhotosPicker("Select Photo", selection: $selectedPhoto, matching: .images)
                    .buttonStyle(.bordered)
                
                if photoData != nil {
                    Button("Remove Photo") {
                        photoData = nil
                        selectedPhoto = nil
                    }
                    .buttonStyle(.bordered)
                    .foregroundColor(.red)
                }
            }
        }
    }
}

struct EnhancedItemPreview: View {
    let name: String
    let description: String
    let weight: Double
    let quantity: Int
    let category: String
    let subcategory: String
    let photoData: Data?
    let isPacked: Bool
    
    private var fullCategory: String {
        if !category.isEmpty {
            if !subcategory.isEmpty {
                return "\(category) > \(subcategory)"
            }
            return category
        }
        return "General"
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                // Photo thumbnail
                if let photoData = photoData, let image = UIImage(data: photoData) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 50, height: 50)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                } else {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(.systemGray5))
                        .frame(width: 50, height: 50)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.secondary)
                        )
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: isPacked ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(isPacked ? .green : .gray)
                        
                        Text(name)
                            .font(.headline)
                            .strikethrough(isPacked)
                            .foregroundColor(isPacked ? .secondary : .primary)
                        
                        Spacer()
                        
                        if quantity > 1 {
                            Text("×\(quantity)")
                                .font(.caption)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.orange.opacity(0.2))
                                .cornerRadius(4)
                        }
                    }
                    
                    if !description.isEmpty {
                        Text(description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    
                    HStack {
                        Text(fullCategory)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(4)
                        
                        Spacer()
                        
                        Text("\(weight, specifier: "%.1f")kg")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if quantity > 1 {
                            Text("= \(weight * Double(quantity), specifier: "%.1f")kg")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                        }
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }
}

// Legacy preview for compatibility
struct ItemPreview: View {
    let name: String
    let weight: Double
    let category: String
    let isPacked: Bool
    
    var body: some View {
        EnhancedItemPreview(
            name: name,
            description: "",
            weight: weight,
            quantity: 1,
            category: category,
            subcategory: "",
            photoData: nil,
            isPacked: isPacked
        )
    }
}


#Preview {
    AddItemView(bag: {
        let context = CoreDataManager.shared.context
        let bag = Bag(context: context)
        bag.id = UUID()
        bag.name = "Sample Bag"
        bag.maxWeight = 20.0
        bag.currentWeight = 5.0
        return bag
    }())
    .environment(\.managedObjectContext, CoreDataManager.shared.context)
}