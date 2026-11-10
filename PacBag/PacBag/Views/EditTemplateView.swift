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
    @State private var itemToEdit: TemplateItem?
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
                Section {
                    TextField("Template Name", text: $editedName)

                    TextField("Description", text: $editedDescription, axis: .vertical)
                        .lineLimit(2...4)
                }

                TemplateTripSection(tripType: $editedTripType, duration: $editedDuration, season: $editedSeason)

                Section {
                    if editedItems.isEmpty {
                        Text("No items in this template")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(editedItems) { item in
                            EditableTemplateItemRow(
                                item: item,
                                onEdit: {
                                    itemToEdit = item
                                },
                                onDelete: {
                                    itemToDelete = item
                                    showingDeleteAlert = true
                                }
                            )
                        }
                    }
                } header: {
                    HStack {
                        Text("Items (\(editedItems.count))")

                        Spacer()

                        Button("Add Item") {
                            showingAddItem = true
                        }
                        .font(.subheadline)
                    }
                    .solidSectionHeader()
                }
            }
            .listStyle(.plain)
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
        .plainFormSheet()
        .sheet(isPresented: $showingAddItem) {
            TemplateItemFormView(item: nil) { newItem in
                editedItems.append(newItem)
            }
        }
        .sheet(item: $itemToEdit) { item in
            TemplateItemFormView(item: item) { updatedItem in
                if let index = editedItems.firstIndex(where: { $0.id == item.id }) {
                    editedItems[index] = updatedItem
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
            id: template.id,
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

    private var details: String {
        var parts = [item.category, "\((item.weight * Double(item.quantity)).oneDecimal) kg"]
        if item.isEssential {
            parts.append("Essential")
        }
        return parts.joined(separator: " · ")
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(item.name)

                    if item.quantity > 1 {
                        Text("×\(item.quantity)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }

                Text(details)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()

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
            .accessibilityLabel("Actions for \(item.name)")
        }
        .padding(.vertical, 2)
    }
}

/// Adds a template item when `item` is nil, or edits it otherwise.
struct TemplateItemFormView: View {
    @Environment(\.dismiss) private var dismiss

    let item: TemplateItem?
    let onSave: (TemplateItem) -> Void

    @State private var name: String
    @State private var selectedCategory: Category?
    @State private var weight: Double
    @State private var quantity: Int
    @State private var isEssential: Bool
    @State private var itemDescription: String

    init(item: TemplateItem?, onSave: @escaping (TemplateItem) -> Void) {
        self.item = item
        self.onSave = onSave
        self._name = State(initialValue: item?.name ?? "")
        self._selectedCategory = State(initialValue: item.flatMap { CategoryManager.shared.category(named: $0.category) })
        self._weight = State(initialValue: item?.weight ?? 0.1)
        self._quantity = State(initialValue: item?.quantity ?? 1)
        self._isEssential = State(initialValue: item?.isEssential ?? false)
        self._itemDescription = State(initialValue: item?.description ?? "")
    }

    var body: some View {
        NavigationView {
            List {
                Section {
                    TextField("Item Name", text: $name)

                    TextField("Description (optional)", text: $itemDescription, axis: .vertical)
                        .lineLimit(2...4)

                    Picker("Category", selection: $selectedCategory) {
                        Text("General").tag(nil as Category?)
                        ForEach(CategoryManager.shared.categories, id: \.id) { category in
                            Text(category.name).tag(category as Category?)
                        }
                    }
                    .pickerStyle(.menu)

                    Toggle("Essential", isOn: $isEssential)
                }

                ItemWeightSection(quantity: $quantity, weight: $weight)
            }
            .listStyle(.plain)
            .navigationTitle(item == nil ? "New Item" : "Edit Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        save()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .plainFormSheet()
    }

    private func save() {
        let savedItem = TemplateItem(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            category: selectedCategory?.name ?? "General",
            weight: weight,
            quantity: quantity,
            isEssential: isEssential,
            description: itemDescription.isEmpty ? nil : itemDescription
        )

        onSave(savedItem)
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
