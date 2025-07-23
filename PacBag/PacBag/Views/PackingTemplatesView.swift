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
            VStack(spacing: 0) {
                // Search and Filters
                VStack(spacing: 16) {
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        
                        TextField("Search templates...", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                        
                        if !searchText.isEmpty {
                            Button("Clear") {
                                searchText = ""
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    
                    // Filter Chips
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            FilterChip(
                                title: "All Types",
                                isSelected: selectedTripType == nil,
                                action: { selectedTripType = nil }
                            )
                            
                            ForEach(TripType.allCases, id: \.self) { tripType in
                                FilterChip(
                                    title: tripType.rawValue,
                                    icon: tripType.icon,
                                    isSelected: selectedTripType == tripType,
                                    action: { selectedTripType = tripType }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            FilterChip(
                                title: "All Durations",
                                isSelected: selectedDuration == nil,
                                action: { selectedDuration = nil }
                            )
                            
                            ForEach(TripDuration.allCases, id: \.self) { duration in
                                FilterChip(
                                    title: duration.rawValue,
                                    isSelected: selectedDuration == duration,
                                    action: { selectedDuration = duration }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                
                Divider()
                
                // Templates Grid
                ScrollView {
                    LazyVStack(spacing: 24) {
                        // Custom Templates Section
                        if !customTemplates.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Text("My Templates")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    Button("Manage") {
                                        showingCustomTemplateManagement = true
                                    }
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                }
                                .padding(.horizontal)
                                
                                LazyVGrid(columns: [
                                    GridItem(.adaptive(minimum: 160), spacing: 16)
                                ], spacing: 16) {
                                    ForEach(customTemplates) { template in
                                        TemplateCard(template: template) {
                                            showingTemplateDetail = template
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        // Default Templates Section
                        if !defaultTemplates.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Text(customTemplates.isEmpty ? "Templates" : "Default Templates")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                }
                                .padding(.horizontal)
                                
                                LazyVGrid(columns: [
                                    GridItem(.adaptive(minimum: 160), spacing: 16)
                                ], spacing: 16) {
                                    ForEach(defaultTemplates) { template in
                                        TemplateCard(template: template) {
                                            showingTemplateDetail = template
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        // Create Template Button
                        if !customTemplates.isEmpty || !defaultTemplates.isEmpty {
                            VStack(spacing: 16) {
                                Divider()
                                    .padding(.horizontal)
                                
                                Button("Create Custom Template") {
                                    showingCreateTemplate = true
                                }
                                .font(.body)
                                .foregroundColor(.blue)
                                .padding()
                            }
                        }
                    }
                    .padding(.vertical)
                }
                
                if filteredTemplates.isEmpty {
                    Spacer()
                    EmptyTemplatesView(hasFilters: selectedTripType != nil || selectedDuration != nil || !searchText.isEmpty)
                    Spacer()
                }
            }
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
                TemplateDetailView(template: template, bag: bag)
            }
            .sheet(isPresented: $showingCreateTemplate) {
                CustomTemplateCreationView(sourceTrip: bag.trip, sourceBag: bag)
            }
            .sheet(isPresented: $showingCustomTemplateManagement) {
                CustomTemplateManagementView()
            }
        }
    }
}

struct FilterChip: View {
    let title: String
    let icon: String?
    let isSelected: Bool
    let action: () -> Void
    
    init(title: String, icon: String? = nil, isSelected: Bool, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.isSelected = isSelected
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.caption)
                }
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.blue : Color(.systemGray6))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct TemplateCard: View {
    let template: PackingTemplate
    let action: () -> Void
    
    private var templateColor: Color {
        return template.tripType.color
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                // Header with icon
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(templateColor.opacity(0.2))
                        .frame(height: 80)
                    
                    VStack(spacing: 6) {
                        Image(systemName: template.icon)
                            .font(.largeTitle)
                            .foregroundColor(templateColor)
                        
                        Text("\(template.items.count) items")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                VStack(spacing: 6) {
                    Text(template.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text(template.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                    
                    HStack(spacing: 8) {
                        Label(template.duration.rawValue, systemImage: "calendar")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .labelStyle(.iconOnly)
                        
                        Text(template.duration.rawValue)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        if template.season != .allSeason {
                            Image(systemName: template.season.icon)
                                .font(.caption2)
                                .foregroundColor(template.season.color)
                        }
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct EmptyTemplatesView: View {
    let hasFilters: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text(hasFilters ? "No templates found" : "No templates available")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text(hasFilters ? "Try adjusting your filters or search terms" : "Templates will appear here")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

struct TemplateDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    let template: PackingTemplate
    @ObservedObject var bag: Bag
    
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
        dismiss()
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
            dismiss()
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