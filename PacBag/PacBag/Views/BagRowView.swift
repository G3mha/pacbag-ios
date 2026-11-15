import SwiftUI

/// A bag as a card in a list: how packed it is, how close to its limit, and what kinds of things are in it.
/// Trips use it for their bags and bags for their sub-bags. Give the row `.cardRow()`.
struct BagRowView: View {
    @ObservedObject var bag: Bag

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                ProgressRing(packed: bag.packedItemsCount, total: bag.totalItemsCount, lineWidth: 4, showsLabel: false)
                    .frame(width: 22, height: 22)
                Text(bag.name.isEmpty ? "Unnamed Bag" : bag.name)
                    .font(.headline)
                    .lineLimit(1)
                Spacer(minLength: 8)
                if bag.totalItemsCount > 0 {
                    Text("\(bag.packedItemsCount)/\(bag.totalItemsCount) packed")
                        .font(.subheadline)
                        .monospacedDigit()
                        .foregroundStyle(.secondary)
                }
            }

            WeightGauge(bagWeight: bag.bagWeight, itemsWeight: bag.itemsWeight, maxWeight: bag.maxWeight)

            if categories.isEmpty {
                Text("No items yet")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                HStack(spacing: 6) {
                    ForEach(categories.prefix(Self.maxChips), id: \.name) { category in
                        chip(Image(systemName: category.icon), "\(category.count)")
                    }
                    if categories.count > Self.maxChips {
                        chip(nil, "+\(categories.count - Self.maxChips)")
                    }
                }
            }
        }
        .padding(.vertical, 6)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(spokenText)
    }

    private static let maxChips = 5

    private func chip(_ icon: Image?, _ text: String) -> some View {
        HStack(spacing: 4) {
            icon?.font(.caption)
            Text(text).monospacedDigit()
        }
        .font(.footnote.weight(.medium))
        .foregroundStyle(.secondary)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color(.tertiarySystemFill), in: Capsule())
    }

    /// Item rows per category, the biggest first, with the icon the category was given.
    private var categories: [(name: String, icon: String, count: Int)] {
        let icons = Dictionary(CategoryManager.shared.categories.map { ($0.name, $0.icon) }, uniquingKeysWith: { first, _ in first })
        return Dictionary(grouping: allItems(of: bag), by: { $0.category ?? "" })
            .map { name, items in
                (name.isEmpty ? "Not sorted" : name, name.isEmpty ? "tray" : icons[name] ?? "folder.fill", items.count)
            }
            .sorted { $0.count != $1.count ? $0.count > $1.count : $0.name < $1.name }
    }

    private func allItems(of bag: Bag) -> [Item] {
        bag.itemsArray + bag.subBagsArray.flatMap { allItems(of: $0) }
    }

    private var spokenText: String {
        let packing = bag.totalItemsCount > 0
            ? "\(bag.packedItemsCount) of \(bag.totalItemsCount) packed"
            : "No items yet"
        let contents = categories.map { "\($0.count) \($0.name)" }.joined(separator: ", ")
        return [bag.name, packing, WeightGauge.spokenText(total: bag.totalWeight, maxWeight: bag.maxWeight), contents]
            .filter { !$0.isEmpty }
            .joined(separator: ". ")
    }
}

/// A bar of a bag's weight against its limit: the empty bag in grey, the items in color.
/// It turns orange near the limit and red past it.
struct WeightGauge: View {
    let bagWeight: Double
    let itemsWeight: Double
    let maxWeight: Double

    private var total: Double { bagWeight + itemsWeight }
    private var hasLimit: Bool { maxWeight > 0 }
    private var isOver: Bool { hasLimit && total > maxWeight }

    private var tint: Color {
        guard hasLimit else { return .accentColor }
        if isOver { return .red }
        return total / maxWeight >= 0.9 ? .orange : .accentColor
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if hasLimit {
                GeometryReader { geo in
                    // Past the limit the bar is the total, so the overflow still shows as a longer red run.
                    let scale = max(maxWeight, total)
                    HStack(spacing: 0) {
                        Rectangle().fill(Color.secondary.opacity(0.6))
                            .frame(width: geo.size.width * bagWeight / scale)
                        Rectangle().fill(tint)
                            .frame(width: geo.size.width * itemsWeight / scale)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.tertiarySystemFill))
                    .clipShape(Capsule())
                }
                .frame(height: 8)
                .animation(.snappy, value: total)
            }

            HStack(alignment: .firstTextBaseline) {
                Text("\(total.oneDecimal)kg")
                    .fontWeight(.semibold)
                    .foregroundStyle(isOver ? .red : .primary)
                    + Text(hasLimit ? " of \(maxWeight.oneDecimal)kg" : "")
                    .foregroundStyle(.secondary)
                Spacer()
                if hasLimit {
                    Text(isOver ? "\((total - maxWeight).oneDecimal)kg over" : "\((maxWeight - total).oneDecimal)kg left")
                        .foregroundStyle(isOver ? .red : .secondary)
                }
            }
            .font(.subheadline)
            .monospacedDigit()
        }
    }

    static func spokenText(total: Double, maxWeight: Double) -> String {
        guard maxWeight > 0 else { return "\(total.oneDecimal) kilograms" }
        let gap = abs(maxWeight - total).oneDecimal
        return "\(total.oneDecimal) of \(maxWeight.oneDecimal) kilograms, \(total > maxWeight ? "\(gap) over the limit" : "\(gap) left")"
    }
}

extension View {
    /// Draws a list row as a rounded card with space around it, in place of a plain row with separators.
    func cardRow() -> some View {
        listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: 12, leading: 30, bottom: 12, trailing: 26))
            .listRowBackground(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color(.secondarySystemBackground))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 5)
            )
    }
}
