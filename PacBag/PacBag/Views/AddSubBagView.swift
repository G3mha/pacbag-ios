import SwiftUI
import CoreData

struct AddSubBagView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @ObservedObject var parentBag: Bag

    @State private var bagName = ""
    @State private var maxWeight = SubBagType.toiletries.defaultWeight
    @State private var selectedSubBagType = SubBagType.toiletries

    private var isNameEmpty: Bool {
        bagName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var fitsInParent: Bool {
        maxWeight <= availableWeight
    }

    var body: some View {
        NavigationView {
            List {
                Section {
                    TextField("Sub-bag Name", text: $bagName)

                    Picker("Type", selection: $selectedSubBagType) {
                        ForEach(SubBagType.allCases, id: \.self) { subBagType in
                            Text(subBagType.rawValue).tag(subBagType)
                        }
                    }
                    .pickerStyle(.menu)
                    .onChange(of: selectedSubBagType) { _, subBagType in
                        maxWeight = subBagType.defaultWeight
                        if isNameEmpty {
                            bagName = subBagType.rawValue + " Bag"
                        }
                    }
                }

                Section {
                    WeightSliderRow(title: "Weight limit", weight: $maxWeight, range: 0.1...10.0, step: 0.1)

                    HStack {
                        Text("Free in \(parentBag.name)")
                        Spacer()
                        Text("\(availableWeight.oneDecimal) kg")
                            .foregroundColor(fitsInParent ? .secondary : .red)
                    }
                } header: {
                    Text("Weight")
                        .solidSectionHeader()
                } footer: {
                    Text(fitsInParent
                         ? "The sub-bag's limit has to fit in what's left of \(parentBag.name)."
                         : "Lower the limit to \(availableWeight.oneDecimal) kg or less to save.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
            .listStyle(.plain)
            .navigationTitle("New Sub-bag")
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
                    .disabled(isNameEmpty || !fitsInParent)
                }
            }
        }
        .plainFormSheet()
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
                print("Failed to save sub-bag: \(error)")
                fatalError("Unresolved error \(error)")
            }
        }
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
