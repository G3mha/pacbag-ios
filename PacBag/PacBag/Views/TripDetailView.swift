import SwiftUI
import CoreData

struct TripDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var trip: Trip

    @State private var showingAddBag = false
    @State private var showingEditTrip = false
    @State private var showingShareView = false
    @State private var showingDeleteConfirmation = false
    @State private var showingCreateTemplate = false
    @State private var bagToEdit: Bag?
    @State private var bagToShare: Bag?
    @State private var bagToDelete: Bag?

    private var statusText: String {
        switch trip.status {
        case .upcoming:
            return "Starts \(trip.startDate.formatted(.relative(presentation: .named)))"
        case .active:
            return "Happening now"
        case .completed:
            return "Completed"
        case .past:
            return "Finished"
        }
    }

    var body: some View {
        List {
            if !trip.isGone {
                Section {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(trip.destination)
                            .font(.headline)

                        Text("\(trip.formattedDateRange) · \(statusText)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        if let description = trip.tripDescription, !description.isEmpty {
                            Text(description)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }

                    PackingProgressView(
                        packed: trip.packedItems,
                        total: trip.totalItems,
                        weight: trip.totalWeight
                    )
                }
            }

            if trip.bagsArray.isEmpty {
                EmptyBagsForTripView {
                    showingAddBag = true
                }
                .listRowSeparator(.hidden)
            } else {
                Section(header: Text("Bags").solidSectionHeader()) {
                    ForEach(trip.bagsArray, id: \.objectID) { bag in
                        bagRow(bag)
                    }
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle(trip.name)
        .navigationBarTitleDisplayMode(.large)
        .refreshesOnContextChange(trip)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddBag = true }) {
                    Label("Add Bag", systemImage: "plus")
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                menu
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
        .sheet(isPresented: $showingCreateTemplate) {
            CustomTemplateCreationView(sourceTrip: trip, sourceBag: nil)
        }
        .sheet(item: $bagToEdit) { bag in
            EditBagView(bag: bag)
        }
        .sheet(item: $bagToShare) { bag in
            ShareView(shareableItem: .bag(bag))
        }
        .alert("Delete Trip", isPresented: $showingDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                deleteTrip()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete \"\(trip.name)\"? This will also delete all bags and items in this trip. This action cannot be undone.")
        }
        .alert("Delete Bag", isPresented: Binding(
            get: { bagToDelete != nil },
            set: { if !$0 { bagToDelete = nil } }
        ), presenting: bagToDelete) { bag in
            Button("Delete", role: .destructive) {
                deleteBag(bag)
            }
            Button("Cancel", role: .cancel) { }
        } message: { bag in
            Text("Are you sure you want to delete \"\(bag.name)\" and everything in it? This action cannot be undone.")
        }
    }

    private var menu: some View {
        Menu {
            Button("Edit Trip", systemImage: "pencil") {
                showingEditTrip = true
            }

            Divider()

            Button("Pack All", systemImage: "checkmark.circle") {
                setAllPacked(true)
            }
            .disabled(trip.totalItems == 0 || trip.packingProgress == 1.0)

            Button("Unpack All", systemImage: "circle") {
                setAllPacked(false)
            }
            .disabled(trip.packedItems == 0)

            Divider()

            Button("Share Trip", systemImage: "square.and.arrow.up") {
                showingShareView = true
            }

            Button("Create Template", systemImage: "doc.badge.plus") {
                showingCreateTemplate = true
            }

            Divider()

            if trip.isCompleted {
                Button("Mark as Incomplete", systemImage: "arrow.counterclockwise") {
                    setCompleted(false)
                }
            } else {
                Button("Mark as Completed", systemImage: "checkmark.circle") {
                    setCompleted(true)
                }
            }

            Button("Delete Trip", systemImage: "trash", role: .destructive) {
                showingDeleteConfirmation = true
            }
        } label: {
            Image(systemName: "ellipsis.circle")
        }
    }

    private func bagRow(_ bag: Bag) -> some View {
        NavigationLink(destination: BagDetailView(bag: bag)) {
            BagRowView(bag: bag)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button("Delete", role: .destructive) {
                bagToDelete = bag
            }

            Button("Share") {
                bagToShare = bag
            }
        }
        .contextMenu {
            Button("Edit Bag", systemImage: "pencil") {
                bagToEdit = bag
            }

            Button("Share Bag", systemImage: "square.and.arrow.up") {
                bagToShare = bag
            }

            Divider()

            Button("Delete Bag", systemImage: "trash", role: .destructive) {
                bagToDelete = bag
            }
        }
    }

    private func setAllPacked(_ isPacked: Bool) {
        withAnimation {
            for bag in trip.bagsArray {
                bag.setAllItemsPacked(isPacked)
            }
            saveContext()
        }
    }

    private func setCompleted(_ isCompleted: Bool) {
        withAnimation {
            trip.isCompleted = isCompleted
            saveContext()
        }
    }

    private func deleteBag(_ bag: Bag) {
        withAnimation {
            viewContext.delete(bag)
            saveContext()
        }
    }

    private func deleteTrip() {
        // Clear any notifications for this trip
        let tripID = trip.id
        Task {
            await NotificationManager.shared.clearReminders(forTripWithID: tripID)
        }

        // Delete the trip (Core Data will cascade delete bags and items)
        viewContext.delete(trip)
        saveContext()
        dismiss() // Navigate back after deletion
    }

    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
}

/// A bag as a single line in a list. Trips use it for their bags and bags for their sub-bags.
struct BagRowView: View {
    @ObservedObject var bag: Bag

    private var isOverLimit: Bool {
        bag.maxWeight > 0 && bag.totalWeight > bag.maxWeight
    }

    private var packedText: String {
        bag.totalItemsCount > 0 ? "\(bag.packedItemsCount) of \(bag.totalItemsCount) packed" : "No items yet"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(bag.name.isEmpty ? "Unnamed Bag" : bag.name)

            HStack(spacing: 0) {
                Text("\(packedText) · ")
                    .foregroundColor(.secondary)

                Text(isOverLimit ? "\(bag.totalWeight.oneDecimal) kg, over limit" : "\(bag.totalWeight.oneDecimal) kg")
                    .foregroundColor(isOverLimit ? .red : .secondary)
            }
            .font(.subheadline)
        }
        .padding(.vertical, 2)
    }
}

struct EmptyBagsForTripView: View {
    let onAddBag: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Text("No bags yet")
                .font(.headline)

            Text("Add a bag to start packing for this trip.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button("Add Your First Bag") {
                onAddBag()
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
    }
}

#Preview {
    NavigationStack {
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
