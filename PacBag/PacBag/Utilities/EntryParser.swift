import Foundation

struct ParsedEntry: Equatable {
    let name: String
    let quantity: Int
    let quantityWasParsed: Bool
}

/// Reads one typed line into a name and a quantity. "2 person tent" is one tent, and
/// "iPhone 15" stays literal, because a wrong multiple is worse than a missed one.
enum EntryParser {
    static let quantityRange = 1...99

    private static let spelled = ["one": 1, "two": 2, "three": 3, "four": 4, "five": 5, "six": 6, "seven": 7,
                                  "eight": 8, "nine": 9, "ten": 10, "eleven": 11, "twelve": 12]
    private static let number = "(\\d+|" + spelled.keys.joined(separator: "|") + ")"
    private static let unitWords: Set<String> = [
        "in", "person", "people", "man", "men", "day", "days", "night", "nights", "week", "weeks", "hour", "hours",
        "year", "years", "inch", "inches", "ft", "foot", "feet", "m", "cm", "mm", "km", "l", "ml", "litre", "liter",
        "litres", "liters", "g", "kg", "oz", "lb", "lbs", "gb", "tb", "mb", "mah", "wh", "w", "v", "k", "piece", "way",
        "port", "ports", "burner", "season", "seasons", "seater", "wheel", "wheels", "wheeler", "star", "stars", "pin",
        "pc", "litro", "litros", "pessoa", "pessoas", "dia", "dias", "noite", "noites", "persona", "personas", "día",
        "días", "noche", "noches",
    ]
    private static let unitWordsWithFollowingWord: Set<String> = ["pack", "tablets", "capsules", "pins"]

    static func parse(_ raw: String) -> ParsedEntry {
        let text = raw.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines.union(CharacterSet(charactersIn: ".,;:!?")))
        let literal = ParsedEntry(name: text, quantity: 1, quantityWasParsed: false)

        if let name = groups("^(?:(?:a|an|one) pair of|um par de)\\s+(.+)$", text)?.first {
            return ParsedEntry(name: name, quantity: 1, quantityWasParsed: true)
        }
        if let match = groups("^\(number)\\s*x\\s+(.+)$", text) {
            return match[1].first?.isNumber == true ? literal : entry(match[0], match[1], else: literal)
        }
        for pattern in ["^\(number)\\s+(?:pairs?|par|pares|pcs|sets|pieces)\\s+(?:(?:of|de)\\s+)?(.+)$",
                        "^\(number)\\s+(?:pc|piece|set|pack|packs)\\s+(?:of|de)\\s+(.+)$"] {
            if let match = groups(pattern, text) { return entry(match[0], match[1], else: literal) }
        }
        if let match = groups("^\(number)\\s+(.+)$", text), !startsWithUnitWord(match[1]) {
            return entry(match[0], match[1], else: literal)
        }
        if let match = groups("^(.+?)\\s+x\\s*\(number)$", text) {
            return entry(match[1], match[0], else: literal)
        }
        if let match = groups("^(.+?)\\s*\\(\\s*\(number)(?:\\s+pairs?)?\\s*\\)$", text) {
            return entry(match[1], match[0], else: literal)
        }
        return literal
    }

    /// The key for matching names: no case, accents or plural `s`.
    static func normalize(_ name: String) -> String {
        name.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: nil)
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }
            .map { $0.count > 3 && $0.hasSuffix("s") && !$0.hasSuffix("ss") ? String($0.dropLast()) : $0 }
            .joined(separator: " ")
    }

    private static func entry(_ count: String, _ name: String, else literal: ParsedEntry) -> ParsedEntry {
        guard let quantity = Int(count) ?? spelled[count.lowercased()], quantityRange.contains(quantity) else { return literal }
        return ParsedEntry(name: name, quantity: quantity, quantityWasParsed: true)
    }

    private static func startsWithUnitWord(_ name: String) -> Bool {
        let words = name.lowercased().split(separator: " ").map(String.init)
        guard let first = words.first else { return false }
        return unitWords.contains(first) || (words.count > 1 && unitWordsWithFollowingWord.contains(first))
    }

    /// The capture groups of a case-insensitive match, in order, or nil.
    private static func groups(_ pattern: String, _ text: String) -> [String]? {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
              let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)) else { return nil }
        return (1..<match.numberOfRanges).compactMap { Range(match.range(at: $0), in: text).map { String(text[$0]) } }
    }
}
