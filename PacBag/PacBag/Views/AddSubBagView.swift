import SwiftUI
import CoreData

struct AddSubBagView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var parentBag: Bag
    
    @State private var bagName = ""
    @State private var maxWeight = 2.0
    @State private var selectedSubBagType = SubBagType.toiletries
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Sub-bag Information")) {
                    TextField("Sub-bag Name", text: $bagName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Sub-bag Type")
                            .font(.headline)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(SubBagType.allCases, id: \.self) { subBagType in
                                    SubBagTypeCard(
                                        subBagType: subBagType,
                                        isSelected: selectedSubBagType == subBagType
                                    ) {
                                        selectedSubBagType = subBagType
                                        maxWeight = subBagType.defaultWeight
                                        if bagName.isEmpty {
                                            bagName = subBagType.rawValue + " Bag"
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                
                Section(header: Text("Capacity")) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Maximum Weight")
                            Spacer()
                            Text("\(maxWeight, specifier: "%.1f") kg")
                                .foregroundColor(.secondary)
                        }
                        
                        Slider(value: $maxWeight, in: 0.1...10.0, step: 0.1)
                    }
                }
                
                Section(header: Text("Parent Bag")) {
                    HStack {
                        Image(systemName: parentBag.isSubBag ? "bag.fill" : "suitcase.fill")
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading) {
                            Text(parentBag.name)
                                .font(.headline)
                            
                            Text("Available space: \(availableWeight, specifier: "%.1f") kg")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
                
                Section {
                    SubBagPreview(
                        name: bagName.isEmpty ? selectedSubBagType.rawValue + " Bag" : bagName,
                        subBagType: selectedSubBagType,
                        maxWeight: maxWeight
                    )
                }
            }
            .navigationTitle("Add Sub-bag")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveSubBag()
                    }
                    .disabled(bagName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || maxWeight > availableWeight)
                }
            }
        }
    }
    
    private var availableWeight: Double {
        return max(0, parentBag.maxWeight - parentBag.totalWeight)
    }
    
    private func saveSubBag() {
        withAnimation {
            let newSubBag = Bag(context: viewContext)
            newSubBag.id = UUID()
            newSubBag.name = bagName.trimmingCharacters(in: .whitespacesAndNewlines)
            newSubBag.maxWeight = maxWeight
            newSubBag.currentWeight = 0.0
            newSubBag.parentBag = parentBag
            
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

struct SubBagTypeCard: View {
    let subBagType: SubBagType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: subBagType.icon)
                    .font(.title3)
                    .foregroundColor(isSelected ? .white : subBagType.color)
                
                Text(subBagType.rawValue)
                    .font(.caption2)
                    .foregroundColor(isSelected ? .white : .primary)
                    .multilineTextAlignment(.center)
            }
            .frame(width: 70, height: 70)
            .background(isSelected ? subBagType.color : Color(.systemGray6))
            .cornerRadius(10)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SubBagPreview: View {
    let name: String
    let subBagType: SubBagType
    let maxWeight: Double
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Preview")
                .font(.headline)
                .foregroundColor(.secondary)
            
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(subBagType.color.opacity(0.2))
                    .frame(height: 80)
                
                VStack(spacing: 4) {
                    Image(systemName: subBagType.icon)
                        .font(.title2)
                        .foregroundColor(subBagType.color)
                    
                    ProgressView(value: 0.0)
                        .progressViewStyle(LinearProgressViewStyle(tint: .green))
                        .frame(width: 60)
                }
            }
            
            VStack(spacing: 4) {
                Text(name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                HStack(spacing: 8) {
                    Label("0/0", systemImage: "checkmark.circle")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Text("Max: \(maxWeight, specifier: "%.1f")kg")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
    }
}

#Preview {
    AddSubBagView(parentBag: {
        let context = CoreDataManager.shared.context
        let bag = Bag(context: context)
        bag.id = UUID()
        bag.name = "Carry-on"
        bag.maxWeight = 10.0
        bag.currentWeight = 3.0
        return bag
    }())
    .environment(\.managedObjectContext, CoreDataManager.shared.context)
}