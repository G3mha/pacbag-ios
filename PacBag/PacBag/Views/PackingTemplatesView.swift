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
                    }
                }

                if !defaultTemplates.isEmpty {
                    Section(customTemplates.isEmpty ? "Templates" : "Default Templates") {
                        ForEach(defaultTemplates) { template in
                            TemplateRowView(template: template) {
                                showingTemplateDetail = template
                            }
                        }
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
    
    private var templateColor: Color {
        return template.tripType.color
    }
    
    private var essentialItems: [TemplateItem] {
        return template.items.filter { $0.isEssential }
    }
    
    private var nonEssentialItems: [TemplateItem] {
        return template.items.filter { !$0.isEssential }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Template Header
                    TemplateHeaderView(template: template)
                    
                    // Template Stats
                    TemplateStatsView(template: template)
                    
                    // Essential Items
                    if !essentialItems.isEmpty {
                        TemplateItemsSection(
                            title: "Essential Items",
                            items: essentialItems,
                            selectedItems: $selectedItems,
                            color: templateColor
                        )
                    }
                    
                    // Optional Items
                    if !nonEssentialItems.isEmpty {
                        TemplateItemsSection(
                            title: "Optional Items",
                            items: nonEssentialItems,
                            selectedItems: $selectedItems,
                            color: templateColor
                        )
                    }
                    
                    // Apply Button
                    VStack(spacing: 12) {
                        Button("Apply Template to \(bag.name)") {
                            showingApplyConfirmation = true
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        
                        Button("Apply Selected Items Only") {
                            applySelectedItems()
                        }
                        .buttonStyle(.bordered)
                        .disabled(selectedItems.isEmpty)
                    }
                    .padding()
                }
            }
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

struct TemplateHeaderView: View {
    let template: PackingTemplate
    
    private var templateColor: Color {
        return template.tripType.color
    }
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(templateColor.opacity(0.2))
                    .frame(height: 120)
                
                VStack(spacing: 8) {
                    Image(systemName: template.icon)
                        .font(.system(size: 40))
                        .foregroundColor(templateColor)
                    
                    Text(template.tripType.rawValue)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(templateColor)
                }
            }
            
            VStack(spacing: 8) {
                Text(template.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                HStack(spacing: 16) {
                    Label(template.duration.rawValue, systemImage: "calendar")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if template.season != .allSeason {
                        Label(template.season.rawValue, systemImage: template.season.icon)
                            .font(.caption)
                            .foregroundColor(template.season.color)
                    }
                }
            }
        }
        .padding()
    }
}

struct TemplateStatsView: View {
    let template: PackingTemplate
    
    private var totalWeight: Double {
        return template.items.reduce(0.0) { sum, item in
            sum + (item.weight * Double(item.quantity))
        }
    }
    
    private var essentialCount: Int {
        return template.items.filter { $0.isEssential }.count
    }
    
    var body: some View {
        HStack(spacing: 20) {
            StatCard(
                title: "Total Items",
                value: "\(template.items.count)",
                icon: "cube.box",
                color: .blue
            )
            
            StatCard(
                title: "Essential",
                value: "\(essentialCount)",
                icon: "star.fill",
                color: .orange
            )
            
            StatCard(
                title: "Est. Weight",
                value: String(format: "%.1fkg", totalWeight),
                icon: "scalemass",
                color: .green
            )
        }
        .padding()
    }
}

struct TemplateItemsSection: View {
    let title: String
    let items: [TemplateItem]
    @Binding var selectedItems: Set<UUID>
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(selectedItems.intersection(Set(items.map { $0.id })).count == items.count ? "Deselect All" : "Select All") {
                    let itemIds = Set(items.map { $0.id })
                    if selectedItems.intersection(itemIds).count == items.count {
                        selectedItems.subtract(itemIds)
                    } else {
                        selectedItems.formUnion(itemIds)
                    }
                }
                .font(.caption)
                .foregroundColor(color)
            }
            
            LazyVStack(spacing: 8) {
                ForEach(items) { item in
                    TemplateItemRow(
                        item: item,
                        isSelected: selectedItems.contains(item.id),
                        color: color
                    ) {
                        if selectedItems.contains(item.id) {
                            selectedItems.remove(item.id)
                        } else {
                            selectedItems.insert(item.id)
                        }
                    }
                }
            }
        }
        .padding()
    }
}

struct TemplateItemRow: View {
    let item: TemplateItem
    let isSelected: Bool
    let color: Color
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 12) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(isSelected ? color : .gray)
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(item.name)
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
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
                                .foregroundColor(.orange)
                        }
                    }
                    
                    HStack {
                        Text(item.category)
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(4)
                        
                        Text("\(item.weight, specifier: "%.1f")kg")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if item.quantity > 1 {
                            Text("= \(item.weight * Double(item.quantity), specifier: "%.1f")kg")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                        }
                        
                        Spacer()
                    }
                    
                    if let description = item.description {
                        Text(description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(isSelected ? color.opacity(0.1) : Color(.systemBackground))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? color.opacity(0.3) : Color(.systemGray4), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
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