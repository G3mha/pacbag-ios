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
    @State private var showingDatePicker = false
    
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
                
                Section(header: Text("Quick Setup")) {
                    Toggle("Create with first bag", isOn: $createWithBag)
                    
                    if createWithBag {
                        Text("A suitcase will be automatically created for this trip")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section {
                    TripPreview(
                        name: tripName.isEmpty ? "New Trip" : tripName,
                        destination: destination.isEmpty ? "Destination" : destination,
                        startDate: startDate,
                        endDate: endDate,
                        duration: duration
                    )
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
            
            // Create a default bag if requested
            if createWithBag {
                let defaultBag = Bag(context: viewContext)
                defaultBag.id = UUID()
                defaultBag.name = "Main Suitcase"
                defaultBag.maxWeight = 23.0 // Standard checked luggage weight
                defaultBag.currentWeight = 0.0
                defaultBag.trip = newTrip
            }
            
            do {
                try viewContext.save()
                dismiss()
            } catch {
                let nsError = error as NSError
                print("Error creating trip: \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct TripPreview: View {
    let name: String
    let destination: String
    let startDate: Date
    let endDate: Date
    let duration: Int
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Preview")
                .font(.headline)
                .foregroundColor(.secondary)
            
            VStack(spacing: 12) {
                // Trip header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(name)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        HStack(spacing: 8) {
                            Image(systemName: "location")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text(destination)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 4) {
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                                .font(.caption)
                                .foregroundColor(.blue)
                            
                            Text("Upcoming")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.blue)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                        
                        Text("\(daysUntilTrip) days")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Date info
                HStack {
                    Image(systemName: "calendar")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(formattedDateRange)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(duration) days")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Empty progress
                VStack(spacing: 6) {
                    HStack {
                        Text("Packing Progress")
                            .font(.caption)
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        Text("0%")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.gray)
                    }
                    
                    ProgressView(value: 0.0)
                        .progressViewStyle(LinearProgressViewStyle(tint: .gray))
                }
                
                // Stats
                HStack(spacing: 20) {
                    PreviewStatItem(value: "0", label: "Bags", icon: "suitcase", color: .blue)
                    PreviewStatItem(value: "0/0", label: "Items", icon: "checkmark.circle", color: .green)
                    PreviewStatItem(value: "0.0kg", label: "Weight", icon: "scalemass", color: .orange)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .padding(.vertical)
    }
    
    private var daysUntilTrip: Int {
        let calendar = Calendar.current
        return calendar.dateComponents([.day], from: Date(), to: startDate).day ?? 0
    }
    
    private var formattedDateRange: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        
        if Calendar.current.isDate(startDate, inSameDayAs: endDate) {
            return formatter.string(from: startDate)
        } else {
            return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
        }
    }
}

struct PreviewStatItem: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(color)
            
            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    AddTripView()
        .environment(\.managedObjectContext, CoreDataManager.shared.context)
}