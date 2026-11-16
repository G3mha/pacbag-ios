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
    @State private var pickedPhoto: PhotosPickerItem?
    
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

                // Without a photo of their own, the trip page shows Wikipedia's.
                Section(header: Text("Photo").solidSectionHeader()) {
                    if let photo = photoData.flatMap(UIImage.init(data:)) {
                        Image(uiImage: photo)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 160)
                            .frame(maxWidth: .infinity)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .accessibilityLabel("Your trip photo")
                    }

                    PhotosPicker(photoData == nil ? "Add Your Own Photo" : "Change Photo", selection: $pickedPhoto, matching: .images)

                    if photoData != nil {
                        Button("Remove Photo", role: .destructive) {
                            photoData = nil
                            pickedPhoto = nil
                        }
                    }
                }

                Section {
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
        .onChange(of: pickedPhoto) { _, item in
            Task {
                if let data = try? await item?.loadTransferable(type: Data.self) {
                    photoData = data
                }
            }
        }
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