import Foundation

/// Typical weights and categories, from `catalog.json`. That file is the only home of these values.
enum ItemCatalog {
    struct Entry: Decodable {
        let key: String
        let category: String
        let grams: Double
    }

    private static let entries: [String: Entry] = {
        guard let url = Bundle.main.url(forResource: "catalog", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let rows = try? JSONDecoder().decode([Entry].self, from: data) else { return [:] }
        return Dictionary(rows.map { (EntryParser.normalize($0.key), $0) }, uniquingKeysWith: { first, _ in first })
    }()

    /// The whole name first, then its endings, so "wool socks" finds "socks".
    static func lookup(_ name: String) -> Entry? {
        var words = EntryParser.normalize(name).split(separator: " ").map(String.init)
        while !words.isEmpty {
            if let entry = entries[words.joined(separator: " ")] { return entry }
            words.removeFirst()
        }
        return nil
    }
}
