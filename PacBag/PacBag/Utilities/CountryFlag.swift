import Foundation

/// Country flags as emoji, both ways: a picked destination ends in one ("Lisbon 🇵🇹"),
/// and searches need the country's name back ("Lisbon Portugal").
enum CountryFlag {
    /// The flag of a country named in English or the phone's language, like "Portugal" or "United States".
    static func flag(for country: String) -> String? {
        codes[fold(country.trimmingCharacters(in: .whitespaces))].map { code in
            String(String.UnicodeScalarView(code.unicodeScalars.compactMap { UnicodeScalar(127397 + $0.value) }))
        }
    }

    /// "Lisbon 🇵🇹" becomes "Lisbon Portugal", for searching.
    static func withNames(_ text: String) -> String {
        replacingFlags(in: text) { " \($0) " }
    }

    /// "Lisbon 🇵🇹" becomes "Lisbon".
    static func removed(_ text: String) -> String {
        replacingFlags(in: text) { _ in " " }
    }

    private static func replacingFlags(in text: String, with replacement: (String) -> String) -> String {
        let replaced = text.map { character -> String in
            guard let code = code(of: character),
                  let name = Locale(identifier: "en").localizedString(forRegionCode: code) else { return String(character) }
            return replacement(name)
        }.joined()
        return replaced.split(separator: " ", omittingEmptySubsequences: true).joined(separator: " ")
    }

    /// A flag emoji is two regional indicator letters, 🇵 and 🇹 for PT.
    private static func code(of character: Character) -> String? {
        let scalars = character.unicodeScalars
        guard scalars.count == 2, scalars.allSatisfy({ (0x1F1E6...0x1F1FF).contains($0.value) }) else { return nil }
        return String(String.UnicodeScalarView(scalars.compactMap { UnicodeScalar($0.value - 127397) }))
    }

    /// Country names in English and in the phone's language, folded, to their two-letter codes.
    private static let codes: [String: String] = {
        var codes: [String: String] = [:]
        for region in Locale.Region.isoRegions where region.identifier.count == 2 {
            for locale in [Locale(identifier: "en"), Locale.current] {
                if let name = locale.localizedString(forRegionCode: region.identifier) {
                    codes[fold(name)] = region.identifier
                }
            }
        }
        return codes
    }()

    private static func fold(_ text: String) -> String {
        text.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: nil)
    }
}
