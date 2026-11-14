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
    @State private var showingSettings = false
    @State private var tripToEdit: Trip?
    @State private var tripToShare: Trip?
    @State private var tripToDelete: Trip?

    /// Soonest first, so the next trip is at the top.
    private var upcomingTrips: [Trip] {
        trips.filter { !$0.isGone && !$0.isCompleted && $0.endDate >= Date() }.reversed()
    }

    /// Most recent first.
    private var pastTrips: [Trip] {
        trips.filter { !$0.isGone && ($0.isCompleted || $0.endDate < Date()) }
    }

    var body: some View {
        NavigationStack {
            Group {
                if trips.isEmpty {
                    EmptyTripsView {
                        showingAddTrip = true
                    }
                } else {
                    List {
                        tripSection("Current and upcoming", trips: upcomingTrips)
                        tripSection("Past", trips: pastTrips)
                    }
                    .listStyle(.plain)
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
            .sheet(item: $tripToEdit) { trip in
                EditTripView(trip: trip)
            }
            .sheet(item: $tripToShare) { trip in
                ShareView(shareableItem: .trip(trip))
            }
            .alert("Delete Trip", isPresented: Binding(
                get: { tripToDelete != nil },
                set: { if !$0 { tripToDelete = nil } }
            ), presenting: tripToDelete) { trip in
                Button("Delete", role: .destructive) {
                    deleteTrip(trip)
                }
                Button("Cancel", role: .cancel) { }
            } message: { trip in
                Text("Are you sure you want to delete \"\(trip.name)\"? This will also delete all bags and items in this trip. This action cannot be undone.")
            }
        }
    }

    @ViewBuilder
    private func tripSection(_ title: String, trips: [Trip]) -> some View {
        if !trips.isEmpty {
            Section(header: Text(title).solidSectionHeader()) {
                ForEach(trips, id: \.objectID) { trip in
                    NavigationLink(destination: TripDetailView(trip: trip)) {
                        TripRowView(trip: trip)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button("Delete", role: .destructive) {
                            tripToDelete = trip
                        }

                        Button("Share") {
                            tripToShare = trip
                        }
                    }
                    .contextMenu {
                        Button("Edit Trip", systemImage: "pencil") {
                            tripToEdit = trip
                        }

                        Button("Share Trip", systemImage: "square.and.arrow.up") {
                            tripToShare = trip
                        }

                        Divider()

                        Button("Delete Trip", systemImage: "trash", role: .destructive) {
                            tripToDelete = trip
                        }
                    }
                }
            }
        }
    }

    private func deleteTrip(_ trip: Trip) {
        withAnimation {
            // Clear any notifications for this trip
            let tripID = trip.id
            Task {
                await NotificationManager.shared.clearReminders(forTripWithID: tripID)
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

struct TripRowView: View {
    @ObservedObject var trip: Trip

    private var packedText: String {
        trip.totalItems > 0 ? "\(trip.packedItems) of \(trip.totalItems) packed" : "No items yet"
    }

    var body: some View {
        if !trip.isGone {
            VStack(alignment: .leading, spacing: 2) {
                Text(trip.name)
                    .font(.headline)
                    .lineLimit(1)

                Text(trip.formattedDateRange)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text(packedText)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 2)
            .refreshesOnContextChange(trip)
        }
    }
}

struct EmptyTripsView: View {
    let onAddTrip: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Text("No trips yet")
                .font(.headline)

            Text("Add a trip, then the bags you're taking.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button("Create Your First Trip") {
                onAddTrip()
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 4)
        }
        .padding()
    }
}

#Preview {
    TripListView()
        .environment(\.managedObjectContext, CoreDataManager.shared.context)
}
