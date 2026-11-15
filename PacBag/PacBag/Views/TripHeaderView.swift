import SwiftUI

/// The top of a trip: a packing ring, with when, how long and how heavy beside it.
struct TripHeaderView: View {
    @ObservedObject var trip: Trip

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Not a Label: a list row gives a Label's icon a wide column of its own.
            HStack(spacing: 6) {
                Image(systemName: "mappin.and.ellipse")
                    .foregroundStyle(.secondary)
                Text(trip.destination)
            }
            .font(.headline)

            HStack(spacing: 20) {
                ProgressRing(packed: trip.packedItems, total: trip.totalItems)
                    .frame(width: 112, height: 112)

                VStack(alignment: .leading, spacing: 10) {
                    fact(countdown.value, countdown.caption)
                    fact(dates, nights)
                    fact("\(trip.totalWeight.oneDecimal)kg", trip.totalBags == 1 ? "in 1 bag" : "in \(trip.totalBags) bags")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            if let description = trip.tripDescription, !description.isEmpty {
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 8)
        .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(spokenText)
    }

    private func fact(_ value: String, _ caption: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            Text(value)
                .font(.title3.weight(.semibold))
                .fontDesign(.rounded)
                .monospacedDigit()
            Text(caption)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .lineLimit(1)
        .minimumScaleFactor(0.7)
    }

    private func days(from start: Date, to end: Date) -> Int {
        let calendar = Calendar.current
        return calendar.dateComponents([.day], from: calendar.startOfDay(for: start), to: calendar.startOfDay(for: end)).day ?? 0
    }

    private var countdown: (value: String, caption: String) {
        switch trip.status {
        case .upcoming:
            let left = days(from: .now, to: trip.startDate)
            return left <= 1 ? ("Tomorrow", "it starts") : ("\(left) days", "to go")
        case .active:
            return ("Day \(days(from: trip.startDate, to: .now) + 1)", "of \(trip.duration + 1)")
        case .completed:
            return ("Done", "trip completed")
        case .past:
            return ("Over", "trip finished")
        }
    }

    private var dates: String {
        guard trip.endDate > trip.startDate else {
            return trip.startDate.formatted(.dateTime.day().month(.abbreviated))
        }
        return (trip.startDate..<trip.endDate).formatted(.interval.day().month(.abbreviated))
    }

    private var nights: String {
        switch trip.duration {
        case ..<1: return "day trip"
        case 1: return "1 night"
        default: return "\(trip.duration) nights"
        }
    }

    private var spokenText: String {
        let packing = trip.totalItems == 0
            ? "No items yet"
            : "\(trip.packedItems) of \(trip.totalItems) items packed"
        return "\(trip.destination). \(packing). \(countdown.value) \(countdown.caption). \(dates), \(nights). "
            + "\(trip.totalWeight.oneDecimal) kilograms \(trip.totalBags == 1 ? "in 1 bag" : "in \(trip.totalBags) bags")."
    }
}

/// A ring that fills as items get packed, with the count in the middle. Green once everything's in.
struct ProgressRing: View {
    let packed: Int
    let total: Int
    var lineWidth: CGFloat = 10
    /// Off for a small ring next to text that already says the count.
    var showsLabel = true

    private var progress: Double { total > 0 ? Double(packed) / Double(total) : 0 }
    private var isDone: Bool { total > 0 && packed == total }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color(.tertiarySystemFill), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(isDone ? Color.green : .accentColor, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))

            if showsLabel { label }
        }
        .animation(.snappy, value: packed)
        .animation(.snappy, value: total)
    }

    private var label: some View {
            VStack(spacing: 0) {
                if isDone {
                    Image(systemName: "checkmark")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.green)
                } else {
                    Text(total > 0 ? "\(packed)/\(total)" : "0")
                        .font(.title2.weight(.semibold))
                        .fontDesign(.rounded)
                        .monospacedDigit()
                        .contentTransition(.numericText())
                }
                Text(total > 0 ? "packed" : "items")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(12)
            .minimumScaleFactor(0.6)
    }
}
