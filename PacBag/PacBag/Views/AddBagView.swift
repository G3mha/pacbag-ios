import SwiftUI
import CoreData

struct AddBagView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    let trip: Trip?

    @State private var bagName = ""
    @State private var maxWeight = 20.0
    @State private var bagWeight = 3.0
    @State private var selectedBagType = BagType.suitcase
    @State private var showingTemplates = false
    @State private var createdBag: Bag?

    init(trip: Trip? = nil) {
        self.trip = trip
    }

    enum BagType: String, CaseIterable {
        case suitcase = "Suitcase"
        case backpack = "Backpack"
        case carryOn = "Carry-on"
        case duffel = "Duffel Bag"
        case tote = "Tote Bag"

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

        var defaultBagWeight: Double {
            switch self {
            case .suitcase:
                return 4.5  // Average large suitcase weight
            case .backpack:
                return 1.5
            case .carryOn:
                return 3.0
            case .duffel:
                return 1.0
            case .tote:
                return 0.5
            }
        }
    }

    private var isNameEmpty: Bool {
        bagName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationView {
            List {
                Section {
                    TextField("Bag Name", text: $bagName)

                    Picker("Type", selection: $selectedBagType) {
                        ForEach(BagType.allCases, id: \.self) { bagType in
                            Text(bagType.rawValue).tag(bagType)
                        }
                    }
                    .pickerStyle(.menu)
                    .onChange(of: selectedBagType) { _, bagType in
                        maxWeight = bagType.defaultWeight
                        bagWeight = bagType.defaultBagWeight
                    }
                }

                Section {
                    BagWeightRows(bagWeight: $bagWeight, maxWeight: $maxWeight)
                } header: {
                    Text("Weight")
                } footer: {
                    Text("The limit counts the bag and everything in it.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }

                Section {
                    Button("Create with Template") {
                        // First save the bag, then show templates
                        createdBag = createBag()
                        if createdBag != nil {
                            showingTemplates = true
                        }
                    }
                    .disabled(isNameEmpty)
                } footer: {
                    Text("Saves the bag, then fills it from a packing template.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
            .listStyle(.plain)
            .navigationTitle("New Bag")
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
                    .disabled(isNameEmpty)
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
        // On iPad the sheet's glass shows through a plain list's section headers.
        .presentationBackground(Color(.systemBackground))
    }

    private func createBag() -> Bag? {
        let newBag = Bag(context: viewContext)
        newBag.id = UUID()
        newBag.name = bagName.trimmingCharacters(in: .whitespacesAndNewlines)
        newBag.maxWeight = maxWeight
        newBag.bagWeight = bagWeight
        newBag.currentWeight = 0.0
        newBag.trip = trip // Assign to trip if provided

        do {
            try viewContext.save()
            return newBag
        } catch {
            print("Failed to save new bag: \(error)")
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

#Preview {
    AddBagView()
        .environment(\.managedObjectContext, CoreDataManager.shared.context)
}
