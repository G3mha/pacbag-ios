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
    @State private var remindersEnabled: Bool
    
    init(trip: Trip) {
        self.trip = trip
        self._tripName = State(initialValue: trip.name)
        self._destination = State(initialValue: trip.destination)
        self._startDate = State(initialValue: trip.startDate)
        self._endDate = State(initialValue: trip.endDate)
        self._tripDescription = State(initialValue: trip.tripDescription ?? "")
        self._isCompleted = State(initialValue: trip.isCompleted)
        self._remindersEnabled = State(initialValue: trip.remindersEnabled)
    }
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    TextField("Trip Name", text: $tripName)

                    TextField("Destination", text: $destination)

                    TextField("Description (optional)", text: $tripDescription, axis: .vertical)
                        .lineLimit(2...4)
                }

                TripDatesSection(startDate: $startDate, endDate: $endDate)

                Section {
                    Toggle("Mark as Completed", isOn: $isCompleted)

                    Toggle("Enable packing reminders", isOn: $remindersEnabled)
                } footer: {
                    if remindersEnabled {
                        Text("Get notified 1 week, 3 days, and 1 day before your trip.")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                }

                Section("Contents") {
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
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
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
            let wasRemindersEnabled = trip.remindersEnabled
            
            trip.name = tripName.trimmingCharacters(in: .whitespacesAndNewlines)
            trip.destination = destination.trimmingCharacters(in: .whitespacesAndNewlines)
            trip.startDate = startDate
            trip.endDate = endDate
            trip.tripDescription = tripDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : tripDescription.trimmingCharacters(in: .whitespacesAndNewlines)
            trip.isCompleted = isCompleted
            trip.remindersEnabled = remindersEnabled
            
            do {
                try viewContext.save()
                
                // Handle notification changes
                Task {
                    if remindersEnabled && (!wasRemindersEnabled || startDate != trip.startDate) {
                        // Schedule new reminders if enabled or date changed
                        await NotificationManager.shared.schedulePackingReminders(for: trip)
                    } else if !remindersEnabled && wasRemindersEnabled {
                        // Clear reminders if disabled
                        await NotificationManager.shared.clearReminders(for: trip)
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