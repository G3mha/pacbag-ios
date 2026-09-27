import SwiftUI
import CoreData

struct EditBagView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var bag: Bag
    
    @State private var bagName: String
    @State private var maxWeight: Double
    
    init(bag: Bag) {
        self.bag = bag
        self._bagName = State(initialValue: bag.name)
        self._maxWeight = State(initialValue: bag.maxWeight)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Bag Information")) {
                    TextField("Bag Name", text: $bagName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Maximum Weight")
                            Spacer()
                            Text("\(maxWeight, specifier: "%.1f") kg")
                                .foregroundColor(.secondary)
                        }
                        
                        Slider(value: $maxWeight, in: 1...50, step: 0.5)
                    }
                }
                
                Section(header: Text("Current Status")) {
                    HStack {
                        Text("Current Weight")
                        Spacer()
                        Text("\(bag.currentWeight, specifier: "%.1f") kg")
                            .foregroundColor(.secondary)
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