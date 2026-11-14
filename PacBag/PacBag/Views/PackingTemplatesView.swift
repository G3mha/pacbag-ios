import SwiftUI
import CoreData

struct PackingTemplatesView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var bag: Bag
    @StateObject private var templateManager = PackingTemplateManager.shared
    
    @State private var selectedTripType: TripType? = nil
    @State private var selectedDuration: TripDuration? = nil
    @State private var selectedSeason: Season? = nil
    @State private var searchText = ""
    @State private var showingTemplateDetail: PackingTemplate? = nil
    @State private var showingCreateTemplate = false
    @State private var showingCustomTemplateManagement = false
    
    var filteredTemplates: [PackingTemplate] {
        var templates = templateManager.getTemplates(
            for: selectedTripType,
            duration: selectedDuration,
            season: selectedSeason
        )
        
        if !searchText.isEmpty {
            templates = templates.filter { template in
                template.name.localizedCaseInsensitiveContains(searchText) ||
                template.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return templates
    }
    
    var defaultTemplates: [PackingTemplate] {
        return filteredTemplates.filter { $0.isDefault }
    }
    
    var customTemplates: [PackingTemplate] {
        return filteredTemplates.filter { !$0.isDefault }
    }
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    Picker("Trip Type", selection: $selectedTripType) {
                        Text("All Types").tag(nil as TripType?)
                        ForEach(TripType.allCases, id: \.self) { tripType in
                            Text(tripType.rawValue).tag(tripType as TripType?)
                        }
                    }
                    .pickerStyle(.menu)

                    Picker("Duration", selection: $selectedDuration) {
                        Text("All Durations").tag(nil as TripDuration?)
                        ForEach(TripDuration.allCases, id: \.self) { duration in
                            Text(duration.rawValue).tag(duration as TripDuration?)
                        }
                    }
                    .pickerStyle(.menu)
                }

                if !customTemplates.isEmpty {
                    Section {
                        ForEach(customTemplates) { template in
                            TemplateRowView(template: template) {
                                showingTemplateDetail = template
                            }
                        }
                    } header: {
                        HStack {
                            Text("My Templates")

                            Spacer()

                            Button("Manage") {
                                showingCustomTemplateManagement = true
                            }
                            .font(.subheadline)
                        }
                        .solidSectionHeader()
                    }
                }

                if !defaultTemplates.isEmpty {
                    Section {
                        ForEach(defaultTemplates) { template in
                            TemplateRowView(template: template) {
                                showingTemplateDetail = template
                            }
                        }
                    } header: {
                        Text(customTemplates.isEmpty ? "Templates" : "Default Templates")
                            .solidSectionHeader()
                    }
                }

                if filteredTemplates.isEmpty {
                    EmptyTemplatesView(hasFilters: selectedTripType != nil || selectedDuration != nil || !searchText.isEmpty)
                        .listRowSeparator(.hidden)
                } else {
                    Section {
                        Button("Create Custom Template") {
                            showingCreateTemplate = true
                        }
                    }
                }
            }
            .listStyle(.plain)
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search templates")
            .navigationTitle("Packing Templates")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(item: $showingTemplateDetail) { template in
                TemplateDetailView(template: template, bag: bag, onApplied: { dismiss() })
            }
            .sheet(isPresented: $showingCreateTemplate) {
                CustomTemplateCreationView(sourceTrip: bag.trip, sourceBag: bag)
            }
            .sheet(isPresented: $showingCustomTemplateManagement) {
                CustomTemplateManagementView()
            }
        }
        .plainFormSheet()
    }
}

/// A template as a single line in a list.
struct TemplateRowView: View {
    let template: PackingTemplate
    let action: () -> Void

    private var details: String {
        var parts = ["\(template.items.count) items", template.duration.rawValue]
        if template.season != .allSeason {
            parts.append(template.season.rawValue)
        }
        return parts.joined(separator: " · ")
    }

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 2) {
                Text(template.name)
                    .foregroundColor(.primary)

                Text(template.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)

                Text(details)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 2)
        }
    }
}

struct EmptyTemplatesView: View {
    let hasFilters: Bool

    var body: some View {
        VStack(spacing: 12) {
            Text(hasFilters ? "No templates found" : "No templates available")
                .font(.headline)

            Text(hasFilters ? "Try changing your filters or search." : "Templates will appear here.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
    }
}

struct TemplateDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    let template: PackingTemplate
    @ObservedObject var bag: Bag
    /// Closes the template list as well. This view's own `dismiss` would only step back to it.
    let onApplied: () -> Void

    @State private var showingApplyConfirmation = false
    @State private var selectedItems: Set<UUID> = []
    
    private var essentialItems: [TemplateItem] {
        return template.items.filter { $0.isEssential }
    }
    
    private var nonEssentialItems: [TemplateItem] {
        return template.items.filter { !$0.isEssential }
    }
    
    private var totalWeight: Double {
        template.items.reduce(0.0) { sum, item in
            sum + (item.weight * Double(item.quantity))
        }
    }

    var body: some View {
        NavigationView {
            List {
                Section {
                    Text(template.description)

                    LabeledContent("Trip Type", value: template.tripType.rawValue)
                    LabeledContent("Duration", value: template.duration.rawValue)

                    if template.season != .allSeason {
                        LabeledContent("Season", value: template.season.rawValue)
                    }

                    LabeledContent("Items", value: "\(template.items.count)")
                    LabeledContent("Essential", value: "\(essentialItems.count)")
                    LabeledContent("Estimated Weight", value: "\(totalWeight.oneDecimal) kg")
                }

                if !essentialItems.isEmpty {
                    TemplateItemsSection(
                        title: "Essential Items",
                        items: essentialItems,
                        selectedItems: $selectedItems
                    )
                }

                if !nonEssentialItems.isEmpty {
                    TemplateItemsSection(
                        title: "Optional Items",
                        items: nonEssentialItems,
                        selectedItems: $selectedItems
                    )
                }

                Section {
                    Button("Apply Template to \(bag.name)") {
                        showingApplyConfirmation = true
                    }

                    Button("Apply Selected Items Only") {
                        applySelectedItems()
                    }
                    .disabled(selectedItems.isEmpty)
                }
            }
            .listStyle(.plain)
            .navigationTitle(template.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Apply Template", isPresented: $showingApplyConfirmation) {
                Button("Apply All Items") {
                    applyTemplate()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This will add all \(template.items.count) items from the '\(template.name)' template to your bag.")
            }
        }
        .plainFormSheet()
        .onAppear {
            // Pre-select essential items
            selectedItems = Set(essentialItems.map { $0.id })
        }
    }
    
    private func applyTemplate() {
        PackingTemplateManager.shared.applyTemplate(template, to: bag, context: viewContext)
        onApplied()
    }
    
    private func applySelectedItems() {
        let itemsToApply = template.items.filter { selectedItems.contains($0.id) }
        
        for templateItem in itemsToApply {
            let newItem = Item(context: viewContext)
            newItem.id = UUID()
            newItem.name = templateItem.name
            newItem.category = templateItem.category
            newItem.weight = templateItem.weight
            newItem.quantity = Int32(templateItem.quantity)
            newItem.itemDescription = templateItem.description
            newItem.isPacked = false
            newItem.bag = bag
        }
        
        // Update bag weight
        let totalWeight = itemsToApply.reduce(0.0) { sum, item in
            sum + (item.weight * Double(item.quantity))
        }
        bag.currentWeight += totalWeight
        
        do {
            try viewContext.save()
            onApplied()
        } catch {
            print("Failed to save template items: \(error)")
        }
    }
}

struct TemplateItemsSection: View {
    let title: String
    let items: [TemplateItem]
    @Binding var selectedItems: Set<UUID>

    private var itemIDs: Set<UUID> {
        Set(items.map { $0.id })
    }

    private var isAllSelected: Bool {
        selectedItems.intersection(itemIDs).count == items.count
    }

    var body: some View {
        Section {
            ForEach(items) { item in
                TemplateItemRow(item: item, isSelected: selectedItems.contains(item.id)) {
                    if selectedItems.contains(item.id) {
                        selectedItems.remove(item.id)
                    } else {
                        selectedItems.insert(item.id)
                    }
                }
            }
        } header: {
            HStack {
                Text(title)

                Spacer()

                Button(isAllSelected ? "Deselect All" : "Select All") {
                    if isAllSelected {
                        selectedItems.subtract(itemIDs)
                    } else {
                        selectedItems.formUnion(itemIDs)
                    }
                }
                .font(.subheadline)
            }
            .solidSectionHeader()
        }
    }
}

struct TemplateItemRow: View {
    let item: TemplateItem
    let isSelected: Bool
    let onToggle: () -> Void

    private var details: String {
        guard item.quantity > 1 else { return item.category }
        return "\(item.category) · \(item.weight.oneDecimal) kg each"
    }

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 12) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(isSelected ? .accentColor : .secondary)

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(item.name)
                            .foregroundColor(.primary)

                        if item.quantity > 1 {
                            Text("×\(item.quantity)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }

                    Text(details)
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    if let description = item.description {
                        Text(description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                }

                Spacer()

                Text("\((item.weight * Double(item.quantity)).oneDecimal) kg")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    PackingTemplatesView(bag: {
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