import SwiftUI
import CoreData

struct TripDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var trip: Trip
    
    @State private var showingAddBag = false
    @State private var showingEditTrip = false
    @State private var showingShareView = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Trip Header
                TripHeaderView(trip: trip)
                
                // Trip Progress
                TripProgressView(trip: trip)
                
                // Quick Actions
                TripActionsView(trip: trip)
                
                // Bags Section
                BagsForTripView(trip: trip, showingAddBag: $showingAddBag)
            }
            .padding()
        }
        .navigationTitle(trip.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button("Edit Trip", systemImage: "pencil") {
                        showingEditTrip = true
                    }
                    
                    Button("Add Bag", systemImage: "plus") {
                        showingAddBag = true
                    }
                    
                    Button("Share Trip", systemImage: "square.and.arrow.up") {
                        showingShareView = true
                    }
                    
                    Divider()
                    
                    Button("Mark as Completed", systemImage: "checkmark.circle") {
                        markTripCompleted()
                    }
                    .disabled(trip.isCompleted)
                    
                    if trip.isCompleted {
                        Button("Mark as Incomplete", systemImage: "arrow.counterclockwise") {
                            markTripIncomplete()
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingAddBag) {
            AddBagView(trip: trip)
        }
        .sheet(isPresented: $showingEditTrip) {
            EditTripView(trip: trip)
        }
        .sheet(isPresented: $showingShareView) {
            ShareView(shareableItem: .trip(trip))
        }
    }
    
    private func markTripCompleted() {
        withAnimation {
            trip.isCompleted = true
            saveContext()
        }
    }
    
    private func markTripIncomplete() {
        withAnimation {
            trip.isCompleted = false
            saveContext()
        }
    }
    
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            print("Error saving context: \(nsError), \(nsError.userInfo)")
        }
    }
}

struct TripHeaderView: View {
    @ObservedObject var trip: Trip
    
    var body: some View {
        VStack(spacing: 16) {
            // Destination and status
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "location.fill")
                            .foregroundColor(.blue)
                        
                        Text(trip.destination)
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                    
                    HStack(spacing: 8) {
                        Image(systemName: "calendar")
                            .foregroundColor(.secondary)
                        
                        Text(trip.formattedDateRange)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    if trip.duration > 1 {
                        HStack(spacing: 8) {
                            Image(systemName: "clock")
                                .foregroundColor(.secondary)
                            
                            Text("\(trip.duration) days")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Spacer()
                
                VStack(spacing: 8) {
                    HStack(spacing: 4) {
                        Image(systemName: trip.status.icon)
                            .font(.caption)
                            .foregroundColor(trip.statusColor)
                        
                        Text(trip.status.rawValue)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(trip.statusColor)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(trip.statusColor.opacity(0.1))
                    .cornerRadius(12)
                    
                    if trip.isUpcoming && trip.daysUntilTrip >= 0 {
                        Text("in \(trip.daysUntilTrip) days")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Description if available
            if let description = trip.tripDescription, !description.isEmpty {
                HStack {
                    Text(description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

struct TripProgressView: View {
    @ObservedObject var trip: Trip
    
    private var progressColor: Color {
        switch trip.packingProgress {
        case 0.0:
            return .gray
        case 0.0..<0.5:
            return .red
        case 0.5..<0.8:
            return .orange
        case 0.8..<1.0:
            return .blue
        case 1.0:
            return .green
        default:
            return .gray
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Packing Progress")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("\(Int(trip.packingProgress * 100))%")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(progressColor)
            }
            
            ProgressView(value: trip.packingProgress)
                .progressViewStyle(LinearProgressViewStyle(tint: progressColor))
                .scaleEffect(y: 2)
            
            HStack(spacing: 20) {
                ProgressStatItem(
                    value: "\(trip.totalBags)",
                    label: "Bags",
                    icon: "suitcase",
                    color: .blue
                )
                
                ProgressStatItem(
                    value: "\(trip.packedItems)",
                    label: "Packed",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
                
                ProgressStatItem(
                    value: "\(trip.totalItems - trip.packedItems)",
                    label: "Remaining",
                    icon: "circle",
                    color: .orange
                )
                
                ProgressStatItem(
                    value: String(format: "%.1fkg", trip.totalWeight),
                    label: "Weight",
                    icon: "scalemass",
                    color: .purple
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

struct ProgressStatItem: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct TripActionsView: View {
    @ObservedObject var trip: Trip
    @State private var showingShareView = false
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Quick Actions")
                .font(.headline)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 12) {
                ActionButton(
                    title: "Pack All",
                    icon: "checkmark.circle.fill",
                    color: .green
                ) {
                    packAllItems()
                }
                .disabled(trip.packingProgress == 1.0)
                
                ActionButton(
                    title: "Unpack All",
                    icon: "circle",
                    color: .orange
                ) {
                    unpackAllItems()
                }
                .disabled(trip.packingProgress == 0.0)
                
                ActionButton(
                    title: "Share Trip",
                    icon: "square.and.arrow.up",
                    color: .purple
                ) {
                    showingShareView = true
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
        .sheet(isPresented: $showingShareView) {
            ShareView(shareableItem: .trip(trip))
        }
    }
    
    private func packAllItems() {
        withAnimation {
            for bag in trip.bagsArray {
                for item in bag.itemsArray {
                    item.isPacked = true
                }
                bag.currentWeight = bag.itemsArray.reduce(0) { $0 + $1.totalWeight }
            }
            saveContext()
        }
    }
    
    private func unpackAllItems() {
        withAnimation {
            for bag in trip.bagsArray {
                for item in bag.itemsArray {
                    item.isPacked = false
                }
            }
            saveContext()
        }
    }
    
    private func saveContext() {
        do {
            try trip.managedObjectContext?.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
}

struct ActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color(.systemBackground))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct BagsForTripView: View {
    @ObservedObject var trip: Trip
    @Binding var showingAddBag: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Bags")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("Add Bag") {
                    showingAddBag = true
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
            }
            
            if trip.bagsArray.isEmpty {
                EmptyBagsForTripView {
                    showingAddBag = true
                }
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(trip.bagsArray) { bag in
                        NavigationLink(destination: BagDetailView(bag: bag)) {
                            TripBagCardView(bag: bag)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
    }
}

struct TripBagCardView: View {
    @ObservedObject var bag: Bag
    
    private var packingProgress: Double {
        guard bag.totalItemsCount > 0 else { return 0 }
        return Double(bag.packedItemsCount) / Double(bag.totalItemsCount)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Bag icon and progress
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(bagColor.opacity(0.2))
                    .frame(width: 60, height: 60)
                
                VStack(spacing: 4) {
                    Image(systemName: bagIcon)
                        .font(.title3)
                        .foregroundColor(bagColor)
                    
                    Text("\(Int(packingProgress * 100))%")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(bagColor)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(bag.name.isEmpty ? "Unnamed Bag" : bag.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                HStack(spacing: 12) {
                    Label("\(bag.packedItemsCount)/\(bag.totalItemsCount)", systemImage: "checkmark.circle")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Label(String(format: "%.1fkg", bag.totalWeight), systemImage: "scalemass")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                ProgressView(value: packingProgress)
                    .progressViewStyle(LinearProgressViewStyle(tint: progressColor))
                    .frame(height: 4)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemGray4), lineWidth: 0.5)
        )
    }
    
    private var bagColor: Color {
        switch packingProgress {
        case 0.0:
            return .gray
        case 0.0..<0.5:
            return .red
        case 0.5..<0.8:
            return .orange
        case 0.8..<1.0:
            return .blue
        case 1.0:
            return .green
        default:
            return .gray
        }
    }
    
    private var progressColor: Color {
        switch packingProgress {
        case 0.0..<0.5:
            return .red
        case 0.5..<0.8:
            return .orange
        case 0.8..<1.0:
            return .blue
        case 1.0:
            return .green
        default:
            return .gray
        }
    }
    
    private var bagIcon: String {
        switch packingProgress {
        case 0.0..<0.3:
            return "suitcase"
        case 0.3..<0.7:
            return "suitcase.fill"
        default:
            return "suitcase.rolling.fill"
        }
    }
}

struct EmptyBagsForTripView: View {
    let onAddBag: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "suitcase")
                .font(.system(size: 40))
                .foregroundColor(.gray)
            
            VStack(spacing: 8) {
                Text("No bags yet")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text("Add bags to start organizing your packing")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button("Add Your First Bag") {
                onAddBag()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    NavigationView {
        TripDetailView(trip: {
            let context = CoreDataManager.shared.context
            let trip = Trip(context: context)
            trip.id = UUID()
            trip.name = "Sample Trip"
            trip.destination = "Paris, France"
            trip.startDate = Date().addingTimeInterval(86400 * 7) // 7 days from now
            trip.endDate = Date().addingTimeInterval(86400 * 14) // 14 days from now
            trip.isCompleted = false
            return trip
        }())
    }
    .environment(\.managedObjectContext, CoreDataManager.shared.context)
}