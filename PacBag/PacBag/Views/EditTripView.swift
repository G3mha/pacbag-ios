import SwiftUI
import CoreData
import PhotosUI

struct EditTripView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var trip: Trip
    
    @State private var tripName: String
    @State private var destination: String
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var tripDescription: String
    @State private var isCompleted: Bool
    @State private var photoData: Data?
    
    init(trip: Trip) {
        self.trip = trip
        self._tripName = State(initialValue: trip.name)
        self._destination = State(initialValue: trip.destination)
        self._startDate = State(initialValue: trip.startDate)
        self._endDate = State(initialValue: trip.endDate)
        self._tripDescription = State(initialValue: trip.tripDescription ?? "")
        self._isCompleted = State(initialValue: trip.isCompleted)
        self._photoData = State(initialValue: trip.photoData)
    }
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    TextField("Trip Name", text: $tripName)

                    DestinationField(destination: $destination)

                    TextField("Description (optional)", text: $tripDescription, axis: .vertical)
                        .lineLimit(2...4)
                }

                TripDatesSection(startDate: $startDate, endDate: $endDate)

                Section(header: Text("Cover Photo").solidSectionHeader()) {
                    CoverPhotoPicker(photoData: $photoData, destination: destination)
                }
                .listRowSeparator(.hidden)

                Section(header: Text("Status").solidSectionHeader()) {
                    Toggle("Mark as Completed", isOn: $isCompleted)
                }

                Section(header: Text("Contents").solidSectionHeader()) {
                    PackingProgressView(
                        packed: trip.packedItems,
                        total: trip.totalItems,
                        weight: trip.totalWeight
                    )
                }
            }
            .listStyle(.plain)
            .navigationTitle("Edit Trip")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel", systemImage: "xmark") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save", systemImage: "checkmark") {
                        saveTrip()
                    }
                    .disabled(!isFormValid)
                }
            }
        }
        .plainFormSheet()
    }
    
    private var isFormValid: Bool {
        !tripName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !destination.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        endDate > startDate
    }
    
    private func saveTrip() {
        withAnimation {
            trip.name = tripName.trimmingCharacters(in: .whitespacesAndNewlines)
            trip.destination = destination.trimmingCharacters(in: .whitespacesAndNewlines)
            trip.startDate = startDate
            trip.endDate = endDate
            trip.tripDescription = tripDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : tripDescription.trimmingCharacters(in: .whitespacesAndNewlines)
            trip.isCompleted = isCompleted
            // Only written when it changed, so editing the name leaves the synced photo alone.
            if trip.photoData != photoData {
                trip.photoData = photoData
            }
            
            do {
                try viewContext.save()
                
                // Dates and names may have changed, so the pending reminders are rebuilt.
                Task {
                    if isCompleted {
                        await NotificationManager.shared.clearReminders(for: trip)
                    } else {
                        await NotificationManager.shared.schedulePackingReminders(for: trip)
                    }
                }
                
                dismiss()
            } catch {
                print("Failed to save trip: \(error)")
            }
        }
    }
}

/// The cover as the trip page will show it, with the one button that changes it.
/// Without a photo of the user's own, that's Wikipedia's photo of the destination being typed.
private struct CoverPhotoPicker: View {
    @Binding var photoData: Data?
    let destination: String

    @State private var picked: PhotosPickerItem?
    @State private var isLoading = false
    @State private var wikipedia: PlacePhoto?
    /// The destination `wikipedia` belongs to. While it differs, the card shows a placeholder.
    @State private var lookedUp: String?

    private var ownPhoto: UIImage? { photoData.flatMap(UIImage.init(data:)) }

    var body: some View {
        cover
            .frame(height: 180)
            .frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(alignment: .bottom) {
                HStack(alignment: .bottom) {
                    if let caption {
                        Text(caption)
                            .font(.caption.weight(.medium))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .surface(in: Capsule())
                    }
                    Spacer()
                    control
                }
                .padding(10)
            }
            .overlay {
                if isLoading { ProgressView().controlSize(.large) }
            }
            .animation(.snappy, value: photoData)
            .task(id: destination) {
                // Waits for the typing to stop, so each letter isn't its own lookup.
                guard (try? await Task.sleep(for: .milliseconds(600))) != nil else { return }
                wikipedia = await WikipediaPhoto.photo(for: destination)
                if !Task.isCancelled { lookedUp = destination }
            }
            .onChange(of: picked) { _, item in
                guard let item else { return }
                isLoading = true
                Task {
                    if let data = try? await item.loadTransferable(type: Data.self) { photoData = data }
                    isLoading = false
                    picked = nil
                }
            }
    }

    @ViewBuilder private var cover: some View {
        if let ownPhoto {
            Image(uiImage: ownPhoto).resizable().scaledToFill()
                .accessibilityLabel("Your cover photo")
        } else if lookedUp != destination {
            skeleton
        } else if let wikipedia {
            AsyncImage(url: wikipedia.imageURL) { phase in
                if let image = phase.image {
                    image.resizable().scaledToFill()
                } else {
                    skeleton
                }
            }
            .accessibilityLabel("Cover photo from Wikipedia")
        } else {
            Color(.secondarySystemFill)
                .overlay(alignment: .top) {
                    Image(systemName: "photo")
                        .font(.largeTitle)
                        .foregroundStyle(.tertiary)
                        .padding(.top, 44)
                }
                .accessibilityHidden(true)
        }
    }

    private var skeleton: some View {
        Color(.secondarySystemFill).accessibilityHidden(true)
    }

    private var caption: String? {
        if ownPhoto != nil { return "Your photo" }
        guard lookedUp == destination else { return nil }
        return wikipedia == nil ? "No photo for this place yet" : "From Wikipedia"
    }

    @ViewBuilder private var control: some View {
        if ownPhoto != nil {
            Menu {
                PhotosPicker(selection: $picked, matching: .images) {
                    Label("Replace Photo", systemImage: "photo.on.rectangle")
                }
                // Going back to Wikipedia's loses nothing, so only a plain remove is red.
                if wikipedia != nil {
                    Button("Use Wikipedia Photo", systemImage: "arrow.uturn.backward") { photoData = nil }
                } else {
                    Button("Remove Photo", systemImage: "trash", role: .destructive) { photoData = nil }
                }
            } label: {
                Label("Change", systemImage: "photo.on.rectangle")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
            }
            .glassButtonStyle()
        } else {
            PhotosPicker(selection: $picked, matching: .images) {
                Label("Choose Photo", systemImage: "photo.badge.plus")
                    .labelStyle(.iconOnly) // The name stays for VoiceOver.
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.white) // The picker draws its icon in the tint, the same blue as the button.
                    .frame(width: 30, height: 30)
            }
            .glassButtonStyle(prominent: true, shape: .circle)
        }
    }
}

#Preview {
    EditTripView(trip: {
        let context = CoreDataManager.shared.context
        let trip = Trip(context: context)
        trip.id = UUID()
        trip.name = "Sample Trip"
        trip.destination = "Paris, France"
        trip.startDate = Date().addingTimeInterval(86400 * 7)
        trip.endDate = Date().addingTimeInterval(86400 * 14)
        trip.isCompleted = false
        return trip
    }())
    .environment(\.managedObjectContext, CoreDataManager.shared.context)
}