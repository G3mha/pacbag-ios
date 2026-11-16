import MapKit
import SwiftUI

/// The trip forms' destination field. As you type it suggests cities anywhere in the world
/// from Apple Maps, and any other text is still kept as typed.
struct DestinationField: View {
    @Binding var destination: String
    @StateObject private var search = CitySearch()
    @FocusState private var isFocused: Bool

    var body: some View {
        TextField("Destination", text: $destination)
            .focused($isFocused)
            .textContentType(.addressCity)
            .onChange(of: destination) { _, text in search.query(text) }

        if isFocused {
            ForEach(search.results, id: \.self) { result in
                Button {
                    destination = CitySearch.destinationText(title: result.title, subtitle: result.subtitle)
                    isFocused = false
                } label: {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(result.title)
                            .foregroundStyle(.primary)
                        if !result.subtitle.isEmpty {
                            Text(result.subtitle)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
    }
}

/// Wraps `MKLocalSearchCompleter`, which is free and needs no key, limited to cities.
final class CitySearch: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    @Published private(set) var results: [MKLocalSearchCompletion] = []
    private let completer = MKLocalSearchCompleter()

    override init() {
        super.init()
        completer.delegate = self
        completer.resultTypes = .address
        completer.addressFilter = MKAddressFilter(including: .locality)
    }

    func query(_ text: String) {
        let text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if text.isEmpty {
            completer.cancel()
            results = []
        } else {
            completer.queryFragment = text
        }
    }

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        // Picking a city sets the field to that city, which would suggest it straight back.
        let picked = completer.results.first.map { Self.destinationText(title: $0.title, subtitle: $0.subtitle) }
        results = picked == completer.queryFragment ? [] : Array(completer.results.prefix(5))
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        results = []
    }

    /// "Austin" and "TX, United States" become "Austin, TX, United States".
    /// Maps repeats a city as its own region ("Kyoto" in "Kyoto, Japan"), so a repeat is dropped.
    static func destinationText(title: String, subtitle: String) -> String {
        let title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let places = subtitle.split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty && $0.localizedCaseInsensitiveCompare(title) != .orderedSame }
        return ([title] + places).joined(separator: ", ")
    }
}
