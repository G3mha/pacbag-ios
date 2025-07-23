import SwiftUI
import UniformTypeIdentifiers

struct ShareView: View {
    let shareableItem: ShareableItem
    @State private var selectedFormat: ExportFormat = .plainText
    @State private var showingShareSheet = false
    @State private var exportItem: ExportItem?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: shareableItem.icon)
                        .font(.system(size: 50))
                        .foregroundColor(.blue)
                    
                    VStack(spacing: 4) {
                        Text("Share \(shareableItem.title)")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Export your \(shareableItem.type) as a file or share directly")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding()
                
                // Format Selection
                VStack(alignment: .leading, spacing: 16) {
                    Text("Choose Format")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    VStack(spacing: 12) {
                        ForEach(ExportFormat.allCases, id: \.self) { format in
                            FormatSelectionCard(
                                format: format,
                                isSelected: selectedFormat == format
                            ) {
                                selectedFormat = format
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 12) {
                    Button("Share") {
                        generateAndShare()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .frame(maxWidth: .infinity)
                    
                    Button("Preview") {
                        generatePreview()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                    .frame(maxWidth: .infinity)
                }
                .padding()
            }
            .navigationTitle("Share")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                if let exportItem = exportItem {
                    ShareSheetView(exportItem: exportItem)
                }
            }
        }
    }
    
    private func generateAndShare() {
        let sharingManager = SharingManager.shared
        
        switch shareableItem {
        case .trip(let trip):
            exportItem = sharingManager.exportTrip(trip, format: selectedFormat)
        case .bag(let bag):
            exportItem = sharingManager.exportBag(bag, format: selectedFormat)
        }
        
        showingShareSheet = true
    }
    
    private func generatePreview() {
        let sharingManager = SharingManager.shared
        
        switch shareableItem {
        case .trip(let trip):
            exportItem = sharingManager.exportTrip(trip, format: selectedFormat)
        case .bag(let bag):
            exportItem = sharingManager.exportBag(bag, format: selectedFormat)
        }
        
        // Show preview in a separate view
        // For now, we'll just trigger the share sheet as a preview
        showingShareSheet = true
    }
}

struct FormatSelectionCard: View {
    let format: ExportFormat
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: format.systemImage)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : .blue)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(format.rawValue)
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundColor(isSelected ? .white : .primary)
                    
                    Text(format.description)
                        .font(.caption)
                        .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(.white)
                }
            }
            .padding()
            .background(isSelected ? Color.blue : Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ShareSheetView: UIViewControllerRepresentable {
    let exportItem: ExportItem
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        // Create a temporary file URL
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(exportItem.fileName)
        
        do {
            try exportItem.content.write(to: tempURL, atomically: true, encoding: .utf8)
        } catch {
            print("Failed to write export file: \(error)")
        }
        
        let activityVC = UIActivityViewController(
            activityItems: [tempURL, exportItem.content],
            applicationActivities: nil
        )
        
        // Exclude some activities that don't make sense for text files
        activityVC.excludedActivityTypes = [
            .assignToContact,
            .saveToCameraRoll,
            .addToReadingList
        ]
        
        return activityVC
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No updates needed
    }
}

// MARK: - Supporting Types

enum ShareableItem {
    case trip(Trip)
    case bag(Bag)
    
    var title: String {
        switch self {
        case .trip(let trip):
            return trip.name
        case .bag(let bag):
            return bag.name
        }
    }
    
    var type: String {
        switch self {
        case .trip:
            return "trip"
        case .bag:
            return "bag"
        }
    }
    
    var icon: String {
        switch self {
        case .trip:
            return "airplane"
        case .bag:
            return "suitcase"
        }
    }
}

#Preview {
    ShareView(shareableItem: .trip({
        let context = CoreDataManager.shared.context
        let trip = Trip(context: context)
        trip.id = UUID()
        trip.name = "Summer Vacation"
        trip.destination = "Paris, France"
        trip.startDate = Date()
        trip.endDate = Date().addingTimeInterval(86400 * 7)
        trip.isCompleted = false
        trip.remindersEnabled = true
        return trip
    }()))
}