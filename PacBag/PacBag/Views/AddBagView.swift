import SwiftUI
import CoreData

struct AddBagView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var bagName = ""
    @State private var maxWeight = 20.0
    @State private var selectedBagType = BagType.suitcase
    @State private var showingTemplates = false
    @State private var createdBag: Bag?
    
    enum BagType: String, CaseIterable {
        case suitcase = "Suitcase"
        case backpack = "Backpack"
        case carryOn = "Carry-on"
        case duffel = "Duffel Bag"
        case tote = "Tote Bag"
        
        var icon: String {
            switch self {
            case .suitcase:
                return "suitcase.rolling"
            case .backpack:
                return "backpack"
            case .carryOn:
                return "suitcase"
            case .duffel:
                return "sportscourt"
            case .tote:
                return "bag"
            }
        }
        
        var defaultWeight: Double {
            switch self {
            case .suitcase:
                return 23.0  // Standard checked luggage
            case .backpack:
                return 15.0
            case .carryOn:
                return 10.0
            case .duffel:
                return 20.0
            case .tote:
                return 5.0
            }
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Bag Information")) {
                    TextField("Bag Name", text: $bagName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Bag Type")
                            .font(.headline)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(BagType.allCases, id: \.self) { bagType in
                                    BagTypeCard(
                                        bagType: bagType,
                                        isSelected: selectedBagType == bagType
                                    ) {
                                        selectedBagType = bagType
                                        maxWeight = bagType.defaultWeight
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
                        
                        Slider(value: $maxWeight, in: 1...50, step: 0.5)
                    }
                }
                
                Section(header: Text("Quick Start")) {
                    VStack(spacing: 12) {
                        Button("Create with Template") {
                            // First save the bag, then show templates
                            createdBag = createBag()
                            if createdBag != nil {
                                showingTemplates = true
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .frame(maxWidth: .infinity)
                        .disabled(bagName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        
                        Text("Create a bag and populate it with items from a packing template")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.vertical, 8)
                }
                
                Section {
                    BagPreview(
                        name: bagName.isEmpty ? selectedBagType.rawValue : bagName,
                        bagType: selectedBagType,
                        maxWeight: maxWeight
                    )
                }
            }
            .navigationTitle("Add New Bag")
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
            .sheet(isPresented: $showingTemplates, onDismiss: {
                // When template view is dismissed, close the add bag view too
                if createdBag != nil {
                    dismiss()
                }
            }) {
                if let createdBag = createdBag {
                    PackingTemplatesView(bag: createdBag)
                }
            }
        }
    }
    
    private func createBag() -> Bag? {
        let newBag = Bag(context: viewContext)
        newBag.id = UUID()
        newBag.name = bagName.trimmingCharacters(in: .whitespacesAndNewlines)
        newBag.maxWeight = maxWeight
        newBag.currentWeight = 0.0
        
        do {
            try viewContext.save()
            return newBag
        } catch {
            let nsError = error as NSError
            print("Error creating bag: \(nsError), \(nsError.userInfo)")
            return nil
        }
    }
    
    private func saveBag() {
        withAnimation {
            let newBag = createBag()
            if newBag != nil {
                dismiss()
            }
        }
    }
}

struct BagTypeCard: View {
    let bagType: AddBagView.BagType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: bagType.icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : .primary)
                
                Text(bagType.rawValue)
                    .font(.caption)
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .frame(width: 80, height: 80)
            .background(isSelected ? Color.blue : Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct BagPreview: View {
    let name: String
    let bagType: AddBagView.BagType
    let maxWeight: Double
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Preview")
                .font(.headline)
                .foregroundColor(.secondary)
            
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.blue.opacity(0.2))
                    .frame(height: 100)
                
                VStack {
                    Image(systemName: bagType.icon)
                        .font(.largeTitle)
                        .foregroundColor(.blue)
                    
                    ProgressView(value: 0.0)
                        .progressViewStyle(LinearProgressViewStyle(tint: .green))
                        .frame(width: 80)
                }
            }
            
            VStack(spacing: 4) {
                Text(name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                HStack(spacing: 8) {
                    Label("0/0", systemImage: "checkmark.circle")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Label("0.0kg", systemImage: "scalemass")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text("Max: \(maxWeight, specifier: "%.1f")kg")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }
}

#Preview {
    AddBagView()
        .environment(\.managedObjectContext, CoreDataManager.shared.context)
}