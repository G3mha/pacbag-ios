import SwiftUI

/// A bag's empty weight and limit as a section of a list.
struct BagWeightSection: View {
    @Binding var bagWeight: Double
    @Binding var maxWeight: Double

    private var availableWeight: Double {
        max(0, maxWeight - bagWeight)
    }

    var body: some View {
        Section {
            WeightSliderRow(title: "Empty bag", weight: $bagWeight, range: 0...10, step: 0.5)
            WeightSliderRow(title: "Weight limit", weight: $maxWeight, range: 1...50, step: 0.5)

            HStack {
                Text("Left for items")
                Spacer()
                Text("\(availableWeight.oneDecimal) kg")
                    .foregroundColor(maxWeight > bagWeight ? .secondary : .red)
            }
        } header: {
            Text("Weight")
                .solidSectionHeader()
        } footer: {
            Text("The limit counts the bag and everything in it.")
                .font(.footnote)
                .foregroundColor(.secondary)
        }
    }
}

struct WeightSliderRow: View {
    let title: String
    @Binding var weight: Double
    let range: ClosedRange<Double>
    let step: Double

    var body: some View {
        VStack(spacing: 4) {
            HStack {
                Text(title)
                Spacer()
                Text("\(weight.oneDecimal) kg")
                    .foregroundColor(.secondary)
            }

            Slider(value: $weight, in: range, step: step)
                .accessibilityLabel(title)
                .accessibilityValue("\(weight.oneDecimal) kg")
        }
        .padding(.vertical, 2)
    }
}
