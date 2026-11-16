import SwiftUI
import CoreData

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
    
    init(trip: Trip) {
        self.trip = trip
        self._tripName = State(initialValue: trip.name)
        self._destination = State(initialValue: trip.destination)
        self._startDate = State(initialValue: trip.startDate)
        self._endDate = State(initialValue: trip.endDate)
        self._tripDescription = State(initialValue: trip.tripDescription ?? "")
        self._isCompleted = State(initialValue: trip.isCompleted)
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