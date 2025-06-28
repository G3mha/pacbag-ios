import SwiftUI
import CoreData

struct CustomTemplateCreationView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var templateManager = PackingTemplateManager.shared
    
    let sourceTrip: Trip?
    let sourceBag: Bag?
    
    @State private var templateName = ""
    @State private var templateDescription = ""
    @State private var selectedTripType: TripType = .vacation
    @State private var selectedDuration: TripDuration = .weekend
    @State private var selectedSeason: Season = .allSeason
    @State private var showingSuccessAlert = false
    @State private var createdTemplate: PackingTemplate?
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Template Details")) {
                    TextField("Template Name", text: $templateName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Description", text: $templateDescription, axis: .vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .lineLimit(3...6)
                }
                
                Section(header: Text("Trip Characteristics")) {
                    Picker("Trip Type", selection: $selectedTripType) {
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
                    
                    Picker("Duration", selection: $selectedDuration) {
                        ForEach(TripDuration.allCases, id: \.self) { duration in
                            Text(duration.rawValue).tag(duration)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                    Picker("Season", selection: $selectedSeason) {
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
                
                Section(header: Text("Preview")) {
                    TemplatePreviewCard(
                        name: templateName.isEmpty ? "My Custom Template" : templateName,
                        description: templateDescription.isEmpty ? "Template description" : templateDescription,
                        tripType: selectedTripType,
                        duration: selectedDuration,
                        season: selectedSeason,
                        itemCount: itemCount
                    )
                }
                
                if let sourceTrip = sourceTrip {
                    Section(header: Text("Source Trip")) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(sourceTrip.name)
                                    .font(.headline)
                                
                                if !sourceTrip.destination.isEmpty {
                                    Text(sourceTrip.destination)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Text("\(sourceTrip.bagsArray.count) bags, \(totalItemCount) items")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "suitcase.fill")
                                .foregroundColor(.blue)
                        }
                        .padding(.vertical, 4)
                    }
                } else if let sourceBag = sourceBag {
                    Section(header: Text("Source Bag")) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(sourceBag.name.isEmpty ? "Unnamed Bag" : sourceBag.name)
                                    .font(.headline)
                                
                                Text("\(sourceBag.itemsArray.count) items")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: sourceBag.isSubBag ? "bag.fill" : "suitcase.fill")
                                .foregroundColor(.blue)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Create Template")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveTemplate()
                    }
                    .disabled(templateName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .alert("Template Created", isPresented: $showingSuccessAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Your custom template has been saved successfully!")
        }
        .onAppear {
            setDefaultValues()
        }
    }
    
    private var itemCount: Int {
        if let sourceTrip = sourceTrip {
            return sourceTrip.bagsArray.reduce(0) { sum, bag in
                sum + countItemsRecursively(in: bag)
            }
        } else if let sourceBag = sourceBag {
            return countItemsRecursively(in: sourceBag)
        }
        return 0
    }
    
    private var totalItemCount: Int {
        guard let sourceTrip = sourceTrip else { return 0 }
        return sourceTrip.bagsArray.reduce(0) { sum, bag in
            sum + countItemsRecursively(in: bag)
        }
    }
    
    private func countItemsRecursively(in bag: Bag) -> Int {
        let itemCount = bag.itemsArray.count
        let subBagItemCount = bag.subBagsArray.reduce(0) { sum, subBag in
            sum + countItemsRecursively(in: subBag)
        }
        return itemCount + subBagItemCount
    }
    
    private func setDefaultValues() {
        if let sourceTrip = sourceTrip {
            templateName = "\(sourceTrip.name) Template"
            templateDescription = "Custom template based on \(sourceTrip.name)"
            
            // Try to auto-detect trip characteristics
            if let template = templateManager.createCustomTemplate(from: sourceTrip) {
                selectedTripType = template.tripType
                selectedDuration = template.duration
                selectedSeason = template.season
            }
        } else if let sourceBag = sourceBag {
            let bagName = sourceBag.name.isEmpty ? "My Bag" : sourceBag.name
            templateName = "\(bagName) Template"
            templateDescription = "Custom template based on \(bagName)"
        }
    }
    
    private func saveTemplate() {
        let name = templateName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let sourceTrip = sourceTrip {
            if let template = templateManager.createCustomTemplate(from: sourceTrip) {
                // Update with user-specified details
                let customTemplate = PackingTemplate(
                    name: name,
                    description: templateDescription,
                    tripType: selectedTripType,
                    duration: selectedDuration,
                    season: selectedSeason,
                    items: template.items,
                    icon: selectedTripType.icon,
                    color: selectedTripType.color.description,
                    isDefault: false
                )
                
                templateManager.saveCustomTemplate(customTemplate)
                createdTemplate = customTemplate
                showingSuccessAlert = true
            }
        } else if let sourceBag = sourceBag {
            let template = templateManager.createCustomTemplate(
                from: sourceBag,
                name: name,
                description: templateDescription,
                tripType: selectedTripType,
                duration: selectedDuration,
                season: selectedSeason
            )
            
            templateManager.saveCustomTemplate(template)
            createdTemplate = template
            showingSuccessAlert = true
        }
    }
}

struct TemplatePreviewCard: View {
    let name: String
    let description: String
    let tripType: TripType
    let duration: TripDuration
    let season: Season
    let itemCount: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: tripType.icon)
                    .font(.title2)
                    .foregroundColor(tripType.color)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(name)
                        .font(.headline)
                        .lineLimit(1)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
            }
            
            HStack(spacing: 12) {
                TemplateTagView(icon: "clock", text: duration.rawValue, color: .blue)
                TemplateTagView(icon: season.icon, text: season.rawValue, color: season.color)
                TemplateTagView(icon: "list.bullet", text: "\(itemCount) items", color: .gray)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct TemplateTagView: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
            Text(text)
                .font(.caption)
        }
        .foregroundColor(color)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.1))
        .cornerRadius(6)
    }
}

// MARK: - Custom Template Management View

struct CustomTemplateManagementView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var templateManager = PackingTemplateManager.shared
    @State private var showingCreateTemplate = false
    @State private var showingEditTemplate = false
    @State private var selectedTemplate: PackingTemplate?
    @State private var showingDeleteAlert = false
    @State private var templateToDelete: PackingTemplate?
    @State private var showingShareSheet = false
    @State private var shareData: Data?
    
    var body: some View {
        NavigationView {
            List {
                if templateManager.customTemplates.isEmpty {
                    Section {
                        VStack(spacing: 16) {
                            Image(systemName: "doc.badge.plus")
                                .font(.system(size: 50))
                                .foregroundColor(.secondary)
                            
                            Text("No Custom Templates")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text("Create templates from your trips and bags to reuse packing lists for similar journeys.")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                        .listRowBackground(Color.clear)
                    }
                } else {
                    Section(header: Text("My Custom Templates")) {
                        ForEach(templateManager.customTemplates) { template in
                            CustomTemplateRow(
                                template: template,
                                onEdit: {
                                    selectedTemplate = template
                                    showingEditTemplate = true
                                },
                                onDelete: {
                                    templateToDelete = template
                                    showingDeleteAlert = true
                                },
                                onShare: {
                                    shareTemplate(template)
                                }
                            )
                        }
                    }
                }
            }
            .navigationTitle("Custom Templates")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingEditTemplate) {
            if let template = selectedTemplate {
                EditTemplateView(template: template)
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            if let data = shareData {
                ShareSheet(items: [data])
            }
        }
        .alert("Delete Template", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                if let template = templateToDelete {
                    templateManager.deleteCustomTemplate(template)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete this template? This action cannot be undone.")
        }
    }
    
    private func shareTemplate(_ template: PackingTemplate) {
        if let data = templateManager.exportTemplate(template) {
            shareData = data
            showingShareSheet = true
        }
    }
}

struct CustomTemplateRow: View {
    let template: PackingTemplate
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onShare: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: template.icon)
                    .font(.title2)
                    .foregroundColor(Color(template.color) ?? .blue)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(template.name)
                        .font(.headline)
                    
                    Text(template.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                Menu {
                    Button("Edit", systemImage: "pencil") {
                        onEdit()
                    }
                    
                    Button("Share", systemImage: "square.and.arrow.up") {
                        onShare()
                    }
                    
                    Divider()
                    
                    Button("Delete", systemImage: "trash", role: .destructive) {
                        onDelete()
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(.secondary)
                }
            }
            
            HStack(spacing: 8) {
                TemplateTagView(icon: "clock", text: template.duration.rawValue, color: .blue)
                TemplateTagView(icon: template.season.icon, text: template.season.rawValue, color: template.season.color)
                TemplateTagView(icon: "list.bullet", text: "\(template.items.count) items", color: .gray)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    CustomTemplateCreationView(sourceTrip: nil, sourceBag: nil)
}