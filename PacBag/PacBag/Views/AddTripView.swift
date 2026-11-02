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
            Form {
                Section(header: Text("Trip Information")) {
                    TextField("Trip Name", text: $tripName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Destination", text: $destination)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Description (Optional)", text: $tripDescription, axis: .vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .lineLimit(3...6)
                }
                
                Section(header: Text("Dates")) {
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
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("\(duration) days")
                            .foregroundColor(.primary)
                            .fontWeight(.medium)
                    }
                }
            }
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
            newTrip.remindersEnabled = true
            
            do {
                try viewContext.save()
                
                Task {
                    await NotificationManager.shared.schedulePackingReminders(for: newTrip)
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