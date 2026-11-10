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
    
    private var availableCategories: [Category] {
        return categoryManager.categories
    }
    
    private var availableSubcategories: [SubCategory] {
        guard let category = selectedCategory else { return [] }
        return categoryManager.subcategories(for: category)
    }
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    TextField("Item Name", text: $itemName)

                    TextField("Description (optional)", text: $itemDescription, axis: .vertical)
                        .lineLimit(2...4)
                }

                Section {
                    Picker("Category", selection: $selectedCategory) {
                        Text("Select Category").tag(nil as Category?)
                        ForEach(availableCategories, id: \.id) { category in
                            Text(category.name).tag(category as Category?)
                        }
                    }
                    .pickerStyle(.menu)
                    .onChange(of: selectedCategory) { _, _ in
                        selectedSubcategory = nil
                    }

                    if !availableSubcategories.isEmpty {
                        Picker("Subcategory", selection: $selectedSubcategory) {
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
                }

                Section("Weight") {
                    Stepper(value: $quantity, in: 1...99) {
                        HStack {
                            Text("Quantity")
                            Spacer()
                            Text("\(quantity)")
                                .foregroundColor(.secondary)
                        }
                    }

                    WeightSliderRow(title: "Per item", weight: $weight, range: 0.1...10.0, step: 0.1)

                    HStack {
                        Text("Total")
                        Spacer()
                        Text("\((weight * Double(quantity)).oneDecimal) kg")
                            .foregroundColor(.secondary)
                    }
                }

                Section("Photo") {
                    if let photoData, let image = UIImage(data: photoData) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 120)
                            .frame(maxWidth: .infinity)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }

                    PhotosPicker(photoData == nil ? "Add Photo" : "Change Photo", selection: $selectedPhoto, matching: .images)

                    if photoData != nil {
                        Button("Remove Photo", role: .destructive) {
                            photoData = nil
                            selectedPhoto = nil
                        }
                    }
                }

                Section {
                    Toggle("Already Packed", isOn: $isPacked)
                }
            }
            .listStyle(.plain)
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
        .plainFormSheet()
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
