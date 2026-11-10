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
    @State private var createWithBag = false
    @State private var remindersEnabled = true
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    TextField("Trip Name", text: $tripName)

                    TextField("Destination", text: $destination)

                    TextField("Description (optional)", text: $tripDescription, axis: .vertical)
                        .lineLimit(2...4)
                }

                Section("Dates") {
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                        .onChange(of: startDate) { _, newValue in
                            // Ensure end date is after start date
                            if endDate <= newValue {
                                endDate = Calendar.current.date(byAdding: .day, value: 1, to: newValue) ?? newValue.addingTimeInterval(86400)
                            }
                        }

                    DatePicker("End Date", selection: $endDate, in: startDate.addingTimeInterval(86400)..., displayedComponents: .date)

                    HStack {
                        Text("Duration")
                        Spacer()
                        Text(duration == 1 ? "1 day" : "\(duration) days")
                            .foregroundColor(.secondary)
                    }
                }

                Section {
                    Toggle("Create with first bag", isOn: $createWithBag)

                    Toggle("Enable packing reminders", isOn: $remindersEnabled)
                } footer: {
                    if remindersEnabled {
                        Text("Get notified 1 week, 3 days, and 1 day before your trip.")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("New Trip")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        createTrip()
                    }
                    .disabled(!isFormValid)
                }
            }
        }
        .plainFormSheet()
    }
    
    private var duration: Int {
        let calendar = Calendar.current
        return calendar.dateComponents([.day], from: startDate, to: endDate).day ?? 0
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
            newTrip.remindersEnabled = remindersEnabled
            
            // Create a default bag if requested
            if createWithBag {
                let defaultBag = Bag(context: viewContext)
                defaultBag.id = UUID()
                defaultBag.name = "Main Suitcase"
                defaultBag.maxWeight = AddBagView.BagType.suitcase.defaultWeight
                defaultBag.bagWeight = AddBagView.BagType.suitcase.defaultBagWeight
                defaultBag.currentWeight = 0.0
                defaultBag.trip = newTrip
            }
            
            do {
                try viewContext.save()
                
                // Schedule notifications if enabled
                if remindersEnabled {
                    Task {
                        await NotificationManager.shared.schedulePackingReminders(for: newTrip)
                    }
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