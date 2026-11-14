import SwiftUI
import UniformTypeIdentifiers

struct ShareView: View {
    let shareableItem: ShareableItem
    @State private var selectedFormat: ExportFormat = .plainText
    @State private var exportItem: ExportItem?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    ForEach(ExportFormat.allCases, id: \.self) { format in
                        Button {
                            selectedFormat = format
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(format.rawValue)
                                        .foregroundColor(.primary)

                                    Text(format.description)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }

                                Spacer()

                                if selectedFormat == format {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.accentColor)
                                }
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityAddTraits(selectedFormat == format ? .isSelected : [])
                    }
                } header: {
                    Text("Format")
                        .solidSectionHeader()
                } footer: {
                    Text("Shares \(shareableItem.title) as a file you can send or open in another app.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
            .listStyle(.plain)
            .safeAreaInset(edge: .bottom) {
                Button {
                    share()
                } label: {
                    Text("Share")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .padding()
                .background(Color(.systemBackground))
            }
            .navigationTitle("Share \(shareableItem.type.capitalized)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(item: $exportItem) { exportItem in
                ShareSheetView(exportItem: exportItem)
            }
        }
        .plainFormSheet()
    }
    
    private func share() {
        let sharingManager = SharingManager.shared
        
        switch shareableItem {
        case .trip(let trip):
            exportItem = sharingManager.exportTrip(trip, format: selectedFormat)
        case .bag(let bag):
            exportItem = sharingManager.exportBag(bag, format: selectedFormat)
        }
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
extension ExportItem: Identifiable {
    var id: String { fileName }
}
