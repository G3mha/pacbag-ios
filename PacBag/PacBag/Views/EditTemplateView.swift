import SwiftUI

struct EditTemplateView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var templateManager = PackingTemplateManager.shared
    
    let template: PackingTemplate
    
    @State private var editedName: String
    @State private var editedDescription: String
    @State private var editedTripType: TripType
    @State private var editedDuration: TripDuration
    @State private var editedSeason: Season
    @State private var editedItems: [TemplateItem]
    @State private var showingAddItem = false
    @State private var showingItemDetail = false
    @State private var selectedItem: TemplateItem?
    @State private var showingDeleteAlert = false
    @State private var itemToDelete: TemplateItem?
    
    init(template: PackingTemplate) {
        self.template = template
        self._editedName = State(initialValue: template.name)
        self._editedDescription = State(initialValue: template.description)
        self._editedTripType = State(initialValue: template.tripType)
        self._editedDuration = State(initialValue: template.duration)
        self._editedSeason = State(initialValue: template.season)
        self._editedItems = State(initialValue: template.items)
    }
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Template Details")) {
                    TextField("Template Name", text: $editedName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Description", text: $editedDescription, axis: .vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .lineLimit(3...6)
                }
                
                Section(header: Text("Trip Characteristics")) {
                    Picker("Trip Type", selection: $editedTripType) {
                        ForEach(TripType.allCases, id: \.self) { tripType in
                            HStack {
                                Image(systemName: tripType.icon)
                                    .foregroundColor(tripType.color)
                                Text(tripType.rawValue)
                            }
                            .tag(tripType)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                    Picker("Duration", selection: $editedDuration) {
                        ForEach(TripDuration.allCases, id: \.self) { duration in
                            Text(duration.rawValue).tag(duration)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                    Picker("Season", selection: $editedSeason) {
                        ForEach(Season.allCases, id: \.self) { season in
                            HStack {
                                Image(systemName: season.icon)
                                    .foregroundColor(season.color)
                                Text(season.rawValue)
                            }
                            .tag(season)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                Section(header: 
                    HStack {
                        Text("Items (\(editedItems.count))")
                        Spacer()
                        Button("Add Item") {
                            showingAddItem = true
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                    }
                ) {
                    if editedItems.isEmpty {
                        Text("No items in this template")
                            .foregroundColor(.secondary)
                            .italic()
                    } else {
                        ForEach(editedItems) { item in
                            EditableTemplateItemRow(
                                item: item,
                                onEdit: {
                                    selectedItem = item
                                    showingItemDetail = true
                                },
                                onDelete: {
                                    itemToDelete = item
                                    showingDeleteAlert = true
                                }
                            )
                        }
                    }
                }
            }
            .navigationTitle("Edit Template")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveChanges()
                    }
                    .disabled(editedName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .sheet(isPresented: $showingAddItem) {
            AddTemplateItemView { newItem in
                editedItems.append(newItem)
            }
        }
        .sheet(isPresented: $showingItemDetail) {
            if let item = selectedItem {
                EditTemplateItemView(item: item) { updatedItem in
                    if let index = editedItems.firstIndex(where: { $0.id == item.id }) {
                        editedItems[index] = updatedItem
                    }
                }
            }
        }
        .alert("Delete Item", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                if let item = itemToDelete {
                    editedItems.removeAll { $0.id == item.id }
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to remove this item from the template?")
        }
    }
    
    private func saveChanges() {
        let updatedTemplate = PackingTemplate(
            name: editedName.trimmingCharacters(in: .whitespacesAndNewlines),
            description: editedDescription,
            tripType: editedTripType,
            duration: editedDuration,
            season: editedSeason,
            items: editedItems,
            icon: editedTripType.icon,
            color: editedTripType.color.description,
            isDefault: false
        )
        
        templateManager.updateCustomTemplate(updatedTemplate)
        dismiss()
    }
}

struct EditableTemplateItemRow: View {
    let item: TemplateItem
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.body)
                
                HStack {
                    Text(item.category)
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(4)
                    
                    if item.quantity > 1 {
                        Text("×\(item.quantity)")
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.orange.opacity(0.2))
                            .cornerRadius(4)
                    }
                    
                    if item.isEssential {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundColor(.yellow)
                    }
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text("\(item.weight, specifier: "%.1f")kg")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Menu {
                    Button("Edit", systemImage: "pencil") {
                        onEdit()
                    }
                    
                    Button("Delete", systemImage: "trash", role: .destructive) {
                        onDelete()
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 2)
    }
}

struct AddTemplateItemView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var categoryManager = CategoryManager.shared
    
    let onSave: (TemplateItem) -> Void
    
    @State private var itemName = ""
    @State private var selectedCategory: Category?
    @State private var weight = 0.1
    @State private var quantity = 1
    @State private var isEssential = false
    @State private var itemDescription = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Item Details")) {
                    TextField("Item Name", text: $itemName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Description (optional)", text: $itemDescription, axis: .vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .lineLimit(2...4)
                }
                
                Section(header: Text("Category")) {
                    Picker("Category", selection: $selectedCategory) {
                        Text("Select Category").tag(nil as Category?)
                        ForEach(CategoryManager.shared.categories, id: \.id) { category in
                            HStack {
                                Image(systemName: category.icon)
                                    .foregroundColor(category.color)
                                Text(category.name)
                            }
                            .tag(category as Category?)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
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
                    }
                }
                
                Section(header: Text("Settings")) {
                    Toggle("Essential Item", isOn: $isEssential)
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
    }
    
    private func saveItem() {
        let newItem = TemplateItem(
            name: itemName.trimmingCharacters(in: .whitespacesAndNewlines),
            category: selectedCategory?.name ?? "General",
            weight: weight,
            quantity: quantity,
            isEssential: isEssential,
            description: itemDescription.isEmpty ? nil : itemDescription
        )
        
        onSave(newItem)
        dismiss()
    }
}

struct EditTemplateItemView: View {
    @Environment(\.dismiss) private var dismiss
    
    let item: TemplateItem
    let onSave: (TemplateItem) -> Void
    
    @State private var editedName: String
    @State private var selectedCategory: Category?
    @State private var editedWeight: Double
    @State private var editedQuantity: Int
    @State private var editedIsEssential: Bool
    @State private var editedDescription: String
    
    init(item: TemplateItem, onSave: @escaping (TemplateItem) -> Void) {
        self.item = item
        self.onSave = onSave
        self._editedName = State(initialValue: item.name)
        self._selectedCategory = State(initialValue: CategoryManager.shared.category(named: item.category))
        self._editedWeight = State(initialValue: item.weight)
        self._editedQuantity = State(initialValue: item.quantity)
        self._editedIsEssential = State(initialValue: item.isEssential)
        self._editedDescription = State(initialValue: item.description ?? "")
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Item Details")) {
                    TextField("Item Name", text: $editedName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Description (optional)", text: $editedDescription, axis: .vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .lineLimit(2...4)
                }
                
                Section(header: Text("Category")) {
                    Picker("Category", selection: $selectedCategory) {
                        Text("Select Category").tag(nil as Category?)
                        ForEach(CategoryManager.shared.categories, id: \.id) { category in
                            HStack {
                                Image(systemName: category.icon)
                                    .foregroundColor(category.color)
                                Text(category.name)
                            }
                            .tag(category as Category?)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                Section(header: Text("Quantity & Weight")) {
                    HStack {
                        Text("Quantity")
                        Spacer()
                        Stepper("\(editedQuantity)", value: $editedQuantity, in: 1...99)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Weight per item")
                            Spacer()
                            Text("\(editedWeight, specifier: "%.1f") kg")
                                .foregroundColor(.secondary)
                        }
                        
                        Slider(value: $editedWeight, in: 0.1...10.0, step: 0.1)
                    }
                }
                
                Section(header: Text("Settings")) {
                    Toggle("Essential Item", isOn: $editedIsEssential)
                }
            }
            .navigationTitle("Edit Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveChanges()
                    }
                    .disabled(editedName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    private func saveChanges() {
        let updatedItem = TemplateItem(
            name: editedName.trimmingCharacters(in: .whitespacesAndNewlines),
            category: selectedCategory?.name ?? "General",
            weight: editedWeight,
            quantity: editedQuantity,
            isEssential: editedIsEssential,
            description: editedDescription.isEmpty ? nil : editedDescription
        )
        
        onSave(updatedItem)
        dismiss()
    }
}

#Preview {
    let sampleTemplate = PackingTemplate(
        name: "Sample Template",
        description: "A sample template for preview",
        tripType: .vacation,
        duration: .weekend,
        season: .summer,
        items: [
            TemplateItem(name: "T-Shirt", category: "Clothes", weight: 0.2, quantity: 3),
            TemplateItem(name: "Jeans", category: "Clothes", weight: 0.8, quantity: 1),
            TemplateItem(name: "Phone Charger", category: "Electronics", weight: 0.1, quantity: 1, isEssential: true)
        ],
        icon: "airplane",
        color: "orange",
        isDefault: false
    )
    
    EditTemplateView(template: sampleTemplate)
}