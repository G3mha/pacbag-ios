import MapKit
import SwiftUI

/// The trip forms' destination field. As you type it suggests cities anywhere in the world
/// from Apple Maps, on a card under the field, and any other text is still kept as typed.
struct DestinationField: View {
    @Binding var destination: String
    @StateObject private var search = CitySearch()
    @FocusState private var isFocused: Bool
    @State private var picks = 0

    var body: some View {
        TextField("Destination", text: $destination)
            .focused($isFocused)
            .textContentType(.addressCity)
            .autocorrectionDisabled()
            .onChange(of: destination) { _, text in search.query(text) }
            .sensoryFeedback(.selection, trigger: picks)

        if isFocused && search.state != .idle {
            suggestions
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 2, leading: 16, bottom: 10, trailing: 16))
        }
    }

    private var suggestions: some View {
        VStack(spacing: 0) {
            switch search.state {
            case .idle:
                EmptyView()
            case .searching:
                // Shaped like the rows that are coming, so the card doesn't jump when they arrive.
                ForEach(0..<3, id: \.self) { index in
                    if index > 0 { divider }
                    SuggestionRow(flag: "🏳️", title: AttributedString("Placeholder city"), subtitle: "Region, Country")
                        .redacted(reason: .placeholder)
                }
                .accessibilityHidden(true)
            case .noMatch:
                Text("No cities match. You can keep what you typed.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
            case .found(let results):
                ForEach(Array(results.enumerated()), id: \.element) { index, result in
                    if index > 0 { divider }
                    Button {
                        destination = CitySearch.destinationText(title: result.title, subtitle: result.subtitle)
                        isFocused = false
                        picks += 1
                    } label: {
                        SuggestionRow(
                            flag: CitySearch.flag(title: result.title, subtitle: result.subtitle),
                            title: CitySearch.highlighted(result.title, ranges: result.titleHighlightRanges),
                            subtitle: result.subtitle
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(CitySearch.destinationText(title: result.title, subtitle: result.subtitle))
                    .accessibilityHint("Sets the destination")
                }
            }
        }
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .animation(.snappy(duration: 0.2), value: search.state)
    }

    private var divider: some View {
        Divider().padding(.leading, 56)
    }
}

private struct SuggestionRow: View {
    let flag: String
    let title: AttributedString
    let subtitle: String

    var body: some View {
        HStack(spacing: 12) {
            Text(flag)
                .font(.title2)
                .frame(width: 30)
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .foregroundStyle(.primary)
                if !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .lineLimit(1)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .contentShape(Rectangle())
    }
}

/// Wraps `MKLocalSearchCompleter`, which is free and needs no key, limited to cities.
final class CitySearch: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    enum State: Equatable {
        case idle, searching, noMatch
        case found([MKLocalSearchCompletion])
    }

    @Published private(set) var state = State.idle
    private let completer = MKLocalSearchCompleter()
    private var noMatch: Task<Void, Never>?
    /// What's in the field. The search itself spells flags out, since Maps can't read them.
    private var typed = ""

    override init() {
        super.init()
        completer.delegate = self
        completer.resultTypes = .address
        completer.addressFilter = MKAddressFilter(including: .locality)
    }

    func query(_ text: String) {
        let text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        noMatch?.cancel()
        if text.isEmpty {
            completer.cancel()
            state = .idle
        } else {
            typed = text
            completer.queryFragment = CountryFlag.withNames(text)
            if case .found = state {} else { state = .searching } // Keep the last cities up while the next ones load.
        }
    }

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        noMatch?.cancel()
        let results = Array(completer.results.prefix(5))
        // Picking a city sets the field to that city, which would suggest it straight back.
        let picked = results.first.map { Self.destinationText(title: $0.title, subtitle: $0.subtitle) }
        if picked == typed {
            state = .idle
        } else if results.isEmpty {
            // Maps often answers empty first and with cities a moment later, so the note waits to be sure.
            // One or two letters rarely match a city, so it only shows once there's more to go on.
            guard completer.queryFragment.count >= 3 else { state = .idle; return }
            let fragment = completer.queryFragment
            noMatch = Task { @MainActor [weak self] in
                try? await Task.sleep(for: .milliseconds(800))
                guard let self, !Task.isCancelled, self.completer.queryFragment == fragment else { return }
                self.state = .noMatch
            }
        } else {
            state = .found(results)
        }
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        noMatch?.cancel()
        state = .idle
    }

    /// "Lisbon" and "Portugal" become "Lisbon 🇵🇹", and "Austin" and "TX, United States" become "Austin, TX 🇺🇸".
    /// Maps repeats a city as its own region ("Kyoto" in "Kyoto, Japan"), so a repeat is dropped.
    /// A country without a known flag stays written out.
    static func destinationText(title: String, subtitle: String) -> String {
        let title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        var places = subtitle.split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty && $0.localizedCaseInsensitiveCompare(title) != .orderedSame }
        let flag: String?
        if let country = places.last {
            flag = CountryFlag.flag(for: country)
            if flag != nil { places.removeLast() }
        } else {
            flag = CountryFlag.flag(for: title) // A city-state, like "Singapore".
        }
        let name = ([title] + places).joined(separator: ", ")
        return flag.map { "\(name) \($0)" } ?? name
    }

    /// The flag of the country Maps names last, or of the place itself when it's a city-state. A pin otherwise.
    static func flag(title: String, subtitle: String) -> String {
        let country = subtitle.split(separator: ",").last.map(String.init) ?? title
        return CountryFlag.flag(for: country) ?? "📍"
    }

    /// Bolds the letters Maps matched, the way Maps' own search does.
    static func highlighted(_ title: String, ranges: [NSValue]) -> AttributedString {
        var text = AttributedString(title)
        for value in ranges {
            guard let range = Range(value.rangeValue, in: title),
                  let lower = AttributedString.Index(range.lowerBound, within: text),
                  let upper = AttributedString.Index(range.upperBound, within: text) else { continue }
            text[lower..<upper].font = .body.weight(.semibold)
        }
        return text
    }
}
