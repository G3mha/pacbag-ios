import SwiftUI
import CoreData

/// The summary at the top of a trip or bag: weight, items packed and one bar.
struct PackingProgressView: View {
    let packed: Int
    let total: Int
    let weight: Double
    var maxWeight: Double?

    private var progress: Double {
        guard total > 0 else { return 0 }
        return Double(packed) / Double(total)
    }

    private var isOverLimit: Bool {
        guard let maxWeight, maxWeight > 0 else { return false }
        return weight > maxWeight
    }

    private var weightText: String {
        guard let maxWeight, maxWeight > 0 else { return "\(weight.oneDecimal) kg" }
        let text = "\(weight.oneDecimal) / \(maxWeight.oneDecimal) kg"
        return isOverLimit ? "\(text), over limit" : text
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Text(weightText)
                    .fontWeight(.medium)
                    .foregroundColor(isOverLimit ? .red : .primary)

                Spacer()

                Text(total > 0 ? "\(packed) of \(total) packed" : "No items yet")
                    .foregroundColor(.secondary)
            }
            .font(.subheadline)

            ProgressView(value: progress)
        }
        .padding(.vertical, 4)
    }
}

extension Double {
    /// Follows the device locale, so every weight in the app uses the same decimal mark.
    var oneDecimal: String {
        formatted(.number.precision(.fractionLength(1)))
    }
}

extension NSManagedObject {
    /// True once an object is deleted. A view can still redraw with it at that
    /// point, and reading its non-optional Date or UUID properties would crash.
    /// Lists key on objectID rather than id for the same reason.
    var isGone: Bool {
        isDeleted || managedObjectContext == nil
    }
}

extension View {
    /// Core Data only publishes changes to an object's own attributes, so a trip
    /// or bag screen wouldn't otherwise notice an item being packed further down.
    func refreshesOnContextChange(_ object: NSManagedObject) -> some View {
        onReceive(NotificationCenter.default.publisher(for: .NSManagedObjectContextObjectsDidChange)) { _ in
            guard !object.isGone else { return }
            object.objectWillChange.send()
        }
    }
}

#Preview {
    PackingProgressView(packed: 4, total: 11, weight: 21.5, maxWeight: 20)
        .padding()
}
