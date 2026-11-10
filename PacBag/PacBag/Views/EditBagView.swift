import SwiftUI
import CoreData

struct EditBagView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var bag: Bag
    
    @State private var bagName: String
    @State private var maxWeight: Double
    @State private var bagWeight: Double

    init(bag: Bag) {
        self.bag = bag
        self._bagName = State(initialValue: bag.name)
        self._maxWeight = State(initialValue: bag.maxWeight)
        self._bagWeight = State(initialValue: bag.bagWeight)
    }
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    TextField("Bag Name", text: $bagName)
                }

                BagWeightSection(bagWeight: $bagWeight, maxWeight: $maxWeight)

                Section("Contents") {
                    PackingProgressView(
                        packed: bag.packedItemsCount,
                        total: bag.totalItemsCount,
                        weight: bagWeight + bag.itemsWeight,
                        maxWeight: maxWeight
                    )
                }

                Section {
                    Button("Reset Packing Status") {
                        resetPackingStatus()
                    }

                    Button("Delete All Items", role: .destructive) {
                        deleteAllItems()
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Edit Bag")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveBag()
                    }
                    .disabled(bagName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .plainFormSheet()
    }
    
    private func saveBag() {
        withAnimation {
            bag.name = bagName.trimmingCharacters(in: .whitespacesAndNewlines)
            bag.maxWeight = maxWeight
            bag.bagWeight = bagWeight

            do {
                try viewContext.save()
                dismiss()
            } catch {
                print("Failed to save bag changes: \(error)")
            }
        }
    }
    
    private func deleteAllItems() {
        withAnimation {
            for item in bag.itemsArray {
                viewContext.delete(item)
            }
            bag.currentWeight = 0.0
            
            do {
                try viewContext.save()
            } catch {
                print("Failed to save bag changes: \(error)")
            }
        }
    }

    private func resetPackingStatus() {
        withAnimation {
            for item in bag.itemsArray {
                item.isPacked = false
            }

            do {
                try viewContext.save()
            } catch {
                print("Failed to save bag changes: \(error)")
            }
        }
    }
}

#Preview {
    EditBagView(bag: {
        let context = CoreDataManager.shared.context
        let bag = Bag(context: context)
        bag.id = UUID()
        bag.name = "Sample Bag"
        bag.maxWeight = 20.0
        bag.currentWeight = 5.0
        return bag
    }())
    .environment(\.managedObjectContext, CoreDataManager.shared.context)
}