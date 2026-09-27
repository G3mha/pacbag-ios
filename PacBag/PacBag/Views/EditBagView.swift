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
            Form {
                Section(header: Text("Bag Information")) {
                    HStack(spacing: 12) {
                        Image(systemName: "bag.fill")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        TextField("Bag Name", text: $bagName)
                    }
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }

                Section(header: Text("Weight Settings")) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "scalemass")
                                .foregroundColor(.orange)
                                .frame(width: 24)
                            Text("Bag Weight (Empty)")
                            Spacer()
                            Text("\(bagWeight, specifier: "%.1f") kg")
                                .font(.headline)
                                .foregroundColor(.orange)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color.orange.opacity(0.15))
                                .cornerRadius(8)
                        }

                        Slider(value: $bagWeight, in: 0...10, step: 0.5)
                            .tint(.orange)

                        Text("Weight of the empty bag itself")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)

                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "gauge.with.dots.needle.bottom.50percent")
                                .foregroundColor(.blue)
                                .frame(width: 24)
                            Text("Maximum Total Weight")
                            Spacer()
                            Text("\(maxWeight, specifier: "%.1f") kg")
                                .font(.headline)
                                .foregroundColor(.blue)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.15))
                                .cornerRadius(8)
                        }

                        Slider(value: $maxWeight, in: 1...50, step: 0.5)
                            .tint(.blue)

                        Text("Airline weight limit (bag + items)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)

                    // Available capacity display
                    HStack {
                        Image(systemName: "arrow.up.left.and.arrow.down.right")
                            .foregroundColor(maxWeight > bagWeight ? .green : .red)
                            .frame(width: 24)
                        Text("Available for Items")
                        Spacer()
                        Text("\(max(0, maxWeight - bagWeight), specifier: "%.1f") kg")
                            .font(.headline)
                            .foregroundColor(maxWeight > bagWeight ? .green : .red)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background((maxWeight > bagWeight ? Color.green : Color.red).opacity(0.15))
                            .cornerRadius(8)
                    }
                    .padding(.vertical, 8)
                }
                
                Section(header: Text("Current Status")) {
                    HStack {
                        Text("Bag Weight")
                        Spacer()
                        Text("\(bag.bagWeight, specifier: "%.1f") kg")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Items Weight")
                        Spacer()
                        Text("\(bag.itemsWeight, specifier: "%.1f") kg")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Total Weight")
                        Spacer()
                        Text("\(bag.totalWeight, specifier: "%.1f") kg")
                            .foregroundColor(bag.totalWeight > bag.maxWeight ? .red : .green)
                            .fontWeight(.semibold)
                    }

                    HStack {
                        Text("Items Count")
                        Spacer()
                        Text("\(bag.totalItemsCount)")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Packed Items")
                        Spacer()
                        Text("\(bag.packedItemsCount)")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section(header: Text("Actions")) {
                    Button("Delete All Items", role: .destructive) {
                        deleteAllItems()
                    }
                    
                    Button("Reset Packing Status") {
                        resetPackingStatus()
                    }
                }
            }
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