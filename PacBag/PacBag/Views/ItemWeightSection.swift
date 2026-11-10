import SwiftUI

/// An item's quantity and weight as a section of a list.
struct ItemWeightSection: View {
    @Binding var quantity: Int
    @Binding var weight: Double

    var body: some View {
        Section(header: Text("Weight").solidSectionHeader()) {
            Stepper(value: $quantity, in: 1...99) {
                HStack {
                    Text("Quantity")
                    Spacer()
                    Text("\(quantity)")
                        .foregroundColor(.secondary)
                }
            }

            WeightSliderRow(title: "Per item", weight: $weight, range: 0.1...10.0, step: 0.1)

            HStack {
                Text("Total")
                Spacer()
                Text("\((weight * Double(quantity)).oneDecimal) kg")
                    .foregroundColor(.secondary)
            }
        }
    }
}
