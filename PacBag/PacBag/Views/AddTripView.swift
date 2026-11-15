import SwiftUI
import CoreData

struct AddTripView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var tripName = ""
    @State private var destination = ""
    @State private var startDate = Date()
    @State private var endDate = Date().addingTimeInterval(86400 * 7) // 7 days from now
    @State private var tripDescription = ""
    
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
            }
            .listStyle(.plain)
            .navigationTitle("New Trip")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel", systemImage: "xmark") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create", systemImage: "checkmark") {
                        createTrip()
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
    
    private func createTrip() {
        withAnimation {
            let newTrip = Trip(context: viewContext)
            newTrip.id = UUID()
            newTrip.name = tripName.trimmingCharacters(in: .whitespacesAndNewlines)
            newTrip.destination = destination.trimmingCharacters(in: .whitespacesAndNewlines)
            newTrip.startDate = startDate
            newTrip.endDate = endDate
            newTrip.tripDescription = tripDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : tripDescription.trimmingCharacters(in: .whitespacesAndNewlines)
            newTrip.isCompleted = false
            
            do {
                try viewContext.save()
                
                // The first trip is when someone gets asked to allow notifications.
                Task {
                    await NotificationManager.shared.applyReminderSetting()
                }
                
                dismiss()
            } catch {
                print("Failed to save new trip: \(error)")
            }
        }
    }
}

#Preview {
    AddTripView()
        .environment(\.managedObjectContext, CoreDataManager.shared.context)
}