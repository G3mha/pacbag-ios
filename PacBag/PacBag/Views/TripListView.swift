import SwiftUI
import CoreData

struct TripListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Trip.startDate, ascending: false)
        ],
        animation: .default)
    private var trips: FetchedResults<Trip>
    
    @State private var showingAddTrip = false
    @State private var selectedFilter: TripFilter = .all
    @State private var showingSettings = false
    @StateObject private var onboardingManager = OnboardingManager.shared
    
    enum TripFilter: String, CaseIterable {
        case all = "All"
        case upcoming = "Upcoming"
        case active = "Active"
        case completed = "Completed"
        
        var systemImage: String {
            switch self {
            case .all:
                return "list.bullet"
            case .upcoming:
                return "clock"
            case .active:
                return "location"
            case .completed:
                return "checkmark.circle"
            }
        }
    }
    
    var filteredTrips: [Trip] {
        switch selectedFilter {
        case .all:
            return Array(trips)
        case .upcoming:
            return trips.filter { $0.isUpcoming }
        case .active:
            return trips.filter { $0.isActive }
        case .completed:
            return trips.filter { $0.isCompleted }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Filter Chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(TripFilter.allCases, id: \.self) { filter in
                            FilterChip(
                                title: filter.rawValue,
                                icon: filter.systemImage,
                                isSelected: selectedFilter == filter,
                                action: { selectedFilter = filter }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)
                .background(Color(.systemBackground))
                
                Divider()
                
                // Trips List
                if filteredTrips.isEmpty {
                    EmptyTripsView(filter: selectedFilter) {
                        showingAddTrip = true
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(filteredTrips) { trip in
                                NavigationLink(destination: TripDetailView(trip: trip)) {
                                    TripCardView(trip: trip)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button("Delete", role: .destructive) {
                                        deleteTrip(trip)
                                    }
                                    
                                    Button("Share") {
                                        // We'll implement this
                                    }
                                    .tint(.blue)
                                }
                                .contextMenu {
                                    Button("Share Trip", systemImage: "square.and.arrow.up") {
                                        // Share action
                                    }
                                    
                                    Button("Edit Trip", systemImage: "pencil") {
                                        // Edit action - navigate to edit
                                    }
                                    
                                    Divider()
                                    
                                    Button("Delete Trip", systemImage: "trash", role: .destructive) {
                                        deleteTrip(trip)
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("My Trips")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showingSettings = true }) {
                        Image(systemName: "gearshape")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddTrip = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddTrip) {
                AddTripView()
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
        }
    }
    
    private func deleteTrip(_ trip: Trip) {
        withAnimation {
            // Clear any notifications for this trip
            Task {
                await NotificationManager.shared.clearReminders(for: trip)
            }
            
            // Delete the trip (Core Data will cascade delete bags and items)
            viewContext.delete(trip)
            
            do {
                try viewContext.save()
            } catch {
                print("Failed to delete trip: \(error)")
            }
        }
    }
}

struct TripCardView: View {
    @ObservedObject var trip: Trip
    @State private var showingShareView = false
    
    var body: some View {
        VStack(spacing: 16) {
            // Header with destination and status
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(trip.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    HStack(spacing: 8) {
                        Image(systemName: "location")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(trip.destination)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
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
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(trip.statusColor.opacity(0.1))
                    .cornerRadius(8)
                    
                    if trip.isUpcoming && trip.daysUntilTrip >= 0 {
                        Text("\(trip.daysUntilTrip) days")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                    Button(action: { showingShareView = true }) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            
            // Date range
            HStack {
                Image(systemName: "calendar")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(trip.formattedDateRange)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(trip.duration) days")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Progress and stats
            VStack(spacing: 12) {
                // Progress bar
                VStack(spacing: 6) {
                    HStack {
                        Text("Packing Progress")
                            .font(.caption)
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        Text("\(Int(trip.packingProgress * 100))%")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(progressColor)
                    }
                    
                    ProgressView(value: trip.packingProgress)
                        .progressViewStyle(LinearProgressViewStyle(tint: progressColor))
                }
                
                // Stats row
                HStack(spacing: 20) {
                    StatItem(
                        value: "\(trip.totalBags)",
                        label: "Bags",
                        icon: "suitcase",
                        color: .blue
                    )
                    
                    StatItem(
                        value: "\(trip.packedItems)/\(trip.totalItems)",
                        label: "Items",
                        icon: "checkmark.circle",
                        color: .green
                    )
                    
                    StatItem(
                        value: String(format: "%.1fkg", trip.totalWeight),
                        label: "Weight",
                        icon: "scalemass",
                        color: .orange
                    )
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        .sheet(isPresented: $showingShareView) {
            ShareView(shareableItem: .trip(trip))
        }
    }
    
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
}

struct StatItem: View {
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

struct EmptyTripsView: View {
    let filter: TripListView.TripFilter
    let onAddTrip: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: emptyStateIcon)
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text(emptyStateTitle)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(emptyStateMessage)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            if filter == .all {
                Button("Create Your First Trip") {
                    onAddTrip()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
            
            Spacer()
        }
    }
    
    private var emptyStateIcon: String {
        switch filter {
        case .all:
            return "airplane"
        case .upcoming:
            return "clock"
        case .active:
            return "location"
        case .completed:
            return "checkmark.circle"
        }
    }
    
    private var emptyStateTitle: String {
        switch filter {
        case .all:
            return "No trips yet"
        case .upcoming:
            return "No upcoming trips"
        case .active:
            return "No active trips"
        case .completed:
            return "No completed trips"
        }
    }
    
    private var emptyStateMessage: String {
        switch filter {
        case .all:
            return "Start planning your adventure by creating your first trip!"
        case .upcoming:
            return "You don't have any upcoming trips planned."
        case .active:
            return "No trips are currently active."
        case .completed:
            return "You haven't completed any trips yet."
        }
    }
}

#Preview {
    TripListView()
        .environment(\.managedObjectContext, CoreDataManager.shared.context)
}