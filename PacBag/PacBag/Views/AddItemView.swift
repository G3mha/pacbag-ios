import SwiftUI
import CoreData

struct AddItemView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var bag: Bag
    
    @State private var itemName = ""
    @State private var weight = 0.1
    @State private var category = "General"
    @State private var isPacked = false
    
    private let categories = [
        "General", "Clothes", "Electronics", "Toiletries", 
        "Documents", "Shoes", "Accessories", "Medication"
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Item Details")) {
                    TextField("Item Name", text: $itemName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Picker("Category", selection: $category) {
                        ForEach(categories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Weight")
                            Spacer()
                            Text("\(weight, specifier: "%.1f") kg")
                                .foregroundColor(.secondary)
                        }
                        
                        Slider(value: $weight, in: 0.1...10.0, step: 0.1)
                    }
                    
                    Toggle("Already Packed", isOn: $isPacked)
                }
                
                Section(header: Text("Preview")) {
                    ItemPreview(
                        name: itemName.isEmpty ? "New Item" : itemName,
                        weight: weight,
                        category: category,
                        isPacked: isPacked
                    )
                }
            }
            .navigationTitle("Add Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveItem()
                    }
                    .disabled(itemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    private func saveItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.id = UUID()
            newItem.name = itemName.trimmingCharacters(in: .whitespacesAndNewlines)
            newItem.weight = weight
            newItem.category = category
            newItem.isPacked = isPacked
            newItem.bag = bag
            
            // Update bag's current weight
            bag.currentWeight += weight
            
            do {
                try viewContext.save()
                dismiss()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct ItemPreview: View {
    let name: String
    let weight: Double
    let category: String
    let isPacked: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: isPacked ? "checkmark.circle.fill" : "circle")
                .font(.title3)
                .foregroundColor(isPacked ? .green : .gray)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.body)
                    .strikethrough(isPacked)
                    .foregroundColor(isPacked ? .secondary : .primary)
                
                HStack {
                    Text(category)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(4)
                    
                    Text("\(weight, specifier: "%.1f")kg")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    AddItemView(bag: {
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