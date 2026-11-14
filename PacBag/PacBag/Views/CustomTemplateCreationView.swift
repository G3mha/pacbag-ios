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
            List {
                Section {
                    TextField("Template Name", text: $templateName)

                    TextField("Description", text: $templateDescription, axis: .vertical)
                        .lineLimit(2...4)
                }

                TemplateTripSection(tripType: $selectedTripType, duration: $selectedDuration, season: $selectedSeason)

                if let sourceTrip = sourceTrip {
                    Section(header: Text("From").solidSectionHeader()) {
                        LabeledContent("Trip", value: sourceTrip.name)
                        LabeledContent("Bags", value: "\(sourceTrip.bagsArray.count)")
                        LabeledContent("Items", value: "\(itemCount)")
                    }
                } else if let sourceBag = sourceBag {
                    Section(header: Text("From").solidSectionHeader()) {
                        LabeledContent("Bag", value: sourceBag.name.isEmpty ? "Unnamed Bag" : sourceBag.name)
                        LabeledContent("Items", value: "\(itemCount)")
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("New Template")
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
        .plainFormSheet()
        .alert("Template Created", isPresented: $showingSuccessAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Your custom template has been saved.")
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

/// A template's trip type, duration and season as a section of a list.
struct TemplateTripSection: View {
    @Binding var tripType: TripType
    @Binding var duration: TripDuration
    @Binding var season: Season

    var body: some View {
        Section(header: Text("Trip").solidSectionHeader()) {
            Picker("Trip Type", selection: $tripType) {
                ForEach(TripType.allCases, id: \.self) { tripType in
                    Text(tripType.rawValue).tag(tripType)
                }
            }
            .pickerStyle(.menu)

            Picker("Duration", selection: $duration) {
                ForEach(TripDuration.allCases, id: \.self) { duration in
                    Text(duration.rawValue).tag(duration)
                }
            }
            .pickerStyle(.menu)

            Picker("Season", selection: $season) {
                ForEach(Season.allCases, id: \.self) { season in
                    Text(season.rawValue).tag(season)
                }
            }
            .pickerStyle(.menu)
        }
    }
}

// MARK: - Custom Template Management View

struct CustomTemplateManagementView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var templateManager = PackingTemplateManager.shared
    @State private var templateToEdit: PackingTemplate?
    @State private var showingDeleteAlert = false
    @State private var templateToDelete: PackingTemplate?
    @State private var showingShareSheet = false
    @State private var shareData: Data?

    var body: some View {
        NavigationView {
            List {
                if templateManager.customTemplates.isEmpty {
                    VStack(spacing: 12) {
                        Text("No custom templates")
                            .font(.headline)

                        Text("Save a trip or a bag as a template and it shows up here.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                    .listRowSeparator(.hidden)
                } else {
                    ForEach(templateManager.customTemplates) { template in
                        CustomTemplateRow(
                            template: template,
                            onEdit: {
                                templateToEdit = template
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
            .listStyle(.plain)
            .navigationTitle("Custom Templates")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .plainFormSheet()
        .sheet(item: $templateToEdit) { template in
            EditTemplateView(template: template)
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

    private var details: String {
        var parts = ["\(template.items.count) items", template.duration.rawValue]
        if template.season != .allSeason {
            parts.append(template.season.rawValue)
        }
        return parts.joined(separator: " · ")
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(template.name)

                if !template.description.isEmpty {
                    Text(template.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
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
            .accessibilityLabel("Actions for \(template.name)")
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    CustomTemplateCreationView(sourceTrip: nil, sourceBag: nil)
}
