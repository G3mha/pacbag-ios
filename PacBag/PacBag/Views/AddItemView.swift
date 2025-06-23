import SwiftUI
import CoreData
import PhotosUI

struct AddItemView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var bag: Bag
    
    @State private var itemName = ""
    @State private var weight = 0.1
    @State private var category = "General"
    @State private var subcategory = ""
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
    
    private var categories: [String] {
        return categoryManager.sortedCategoryNames
    }
    
    private var subcategories: [String] {
        return categoryManager.subcategories(for: category)
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
                    
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Picker("Category", selection: $category) {
                                ForEach(categories, id: \.self) { category in
                                    Text(category).tag(category)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .onChange(of: category) { oldValue, newValue in
                                // Reset subcategory when category changes
                                subcategory = ""
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
                                    Picker("Subcategory", selection: $subcategory) {
                                        Text("None").tag("")
                                        ForEach(subcategories, id: \.self) { subcat in
                                            Text(subcat).tag(subcat)
                                        }
                                    }
                                    .pickerStyle(MenuPickerStyle())
                                    .padding(.vertical, 4)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                                    
                                    Button(action: { 
                                        customCategory = category
                                        showingCustomCategory = true 
                                    }) {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.title3)
                                            .foregroundColor(.blue)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.top, 8)
                        }
                        
                        
                        // Current selection display
                        if !category.isEmpty {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Current Selection:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text(subcategory.isEmpty ? category : "\(category) > \(subcategory)")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(6)
                            }
                            .padding(.top, 8)
                        }
                    }
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
                        category: category,
                        subcategory: subcategory,
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
        .onChange(of: selectedPhoto) { oldValue, newValue in
            loadPhoto(from: newValue)
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
                    category = newCategory
                    subcategory = newSubcategory
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
            newItem.category = category
            newItem.subcategory = subcategory.isEmpty ? nil : subcategory
            newItem.isPacked = isPacked
            newItem.photoData = photoData
            newItem.bag = bag
            
            // Update bag's current weight (total weight for all quantities)
            bag.currentWeight += weight * Double(quantity)
            
            do {
                try viewContext.save()
                dismiss()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
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