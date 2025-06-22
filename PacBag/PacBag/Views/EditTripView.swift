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
                        .onChange(of: startDate) { oldValue, newValue in
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
                
                Section(header: Text("Status")) {
                    Toggle("Mark as Completed", isOn: $isCompleted)
                    
                    if isCompleted {
                        Text("This trip will be marked as completed")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section(header: Text("Trip Statistics")) {
                    HStack {
                        Text("Total Bags")
                        Spacer()
                        Text("\(trip.totalBags)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Total Items")
                        Spacer()
                        Text("\(trip.totalItems)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Packed Items")
                        Spacer()
                        Text("\(trip.packedItems)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Total Weight")
                        Spacer()
                        Text(String(format: "%.1fkg", trip.totalWeight))
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Packing Progress")
                        Spacer()
                        Text("\(Int(trip.packingProgress * 100))%")
                            .foregroundColor(.secondary)
                    }
                }
            }
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
                dismiss()
            } catch {
                let nsError = error as NSError
                print("Error saving trip: \(nsError), \(nsError.userInfo)")
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