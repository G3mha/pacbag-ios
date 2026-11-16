import Foundation

/// A free photo of a place from Wikipedia's article about it, with the credit its license asks for.
struct PlacePhoto: Equatable {
    let imageURL: URL
    let credit: String
    let sourceURL: URL
}

/// Finds a trip destination's photo: the lead image of the top English Wikipedia result.
/// Wikipedia only returns freely licensed lead images here, and the credit comes from the file's page.
enum WikipediaPhoto {
    private static let api = URL(string: "https://en.wikipedia.org/w/api.php")!
    @MainActor private static var cache: [String: PlacePhoto?] = [:]

    // shortcut: cached in memory only, so each launch asks again once per trip opened. Store it if that gets slow.
    @MainActor static func photo(for destination: String) async -> PlacePhoto? {
        let destination = destination.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !destination.isEmpty else { return nil }
        if let cached = cache[destination] { return cached }

        do {
            var photo: PlacePhoto?
            let page = try await get(["generator": "search", "gsrsearch": CountryFlag.withNames(destination), "gsrlimit": "1",
                                      "prop": "pageimages", "piprop": "thumbnail|name", "pithumbsize": "1200"])
            if let image = leadImage(from: page, for: destination) {
                let info = try await get(["titles": "File:\(image.fileName)", "prop": "imageinfo",
                                          "iiprop": "extmetadata|url", "iiextmetadatafilter": "Artist|LicenseShortName"])
                photo = placePhoto(imageURL: image.url, fileInfo: info)
            }
            cache[destination] = photo
            return photo
        } catch {
            return nil // Not cached, so a dropped connection tries again next visit.
        }
    }

    private static func get(_ parameters: [String: String]) async throws -> Data {
        var components = URLComponents(url: api, resolvingAgainstBaseURL: false)!
        components.queryItems = (["action": "query", "format": "json", "formatversion": "2"].merging(parameters) { $1 })
            .map { URLQueryItem(name: $0.key, value: $0.value) }
        var request = URLRequest(url: components.url!)
        // Wikimedia asks apps to name themselves and say how to reach them.
        request.setValue("PacBag/\(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1") (https://pacbag.app)",
                         forHTTPHeaderField: "User-Agent")
        let (data, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw URLError(.badServerResponse) }
        return data
    }

    // MARK: Parsing, kept apart so tests can feed it saved responses

    /// Free text like "Grandma's" still finds some article, so the article has to be about the place:
    /// its title starts with the destination's first part ("Austin, TX" finds "Austin, Texas", "Lisbon 🇵🇹" finds "Lisbon").
    static func leadImage(from data: Data, for destination: String) -> (fileName: String, url: URL)? {
        struct Response: Decodable {
            struct Query: Decodable { let pages: [Page] }
            struct Page: Decodable {
                struct Thumbnail: Decodable { let source: URL }
                let title: String
                let thumbnail: Thumbnail?
                let pageimage: String?
            }
            let query: Query?
        }
        guard let page = (try? JSONDecoder().decode(Response.self, from: data))?.query?.pages.first,
              let fileName = page.pageimage, let url = page.thumbnail?.source else { return nil }
        let place = CountryFlag.removed(destination.split(separator: ",").first.map(String.init) ?? destination)
        let fold = { (text: String) in text.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: nil) }
        guard fold(page.title).hasPrefix(fold(place.trimmingCharacters(in: .whitespaces))) else { return nil }
        return (fileName, url)
    }

    static func placePhoto(imageURL: URL, fileInfo data: Data) -> PlacePhoto? {
        struct Response: Decodable {
            struct Query: Decodable { let pages: [Page] }
            struct Page: Decodable { let imageinfo: [Info]? }
            struct Info: Decodable {
                struct Field: Decodable { let value: String }
                let descriptionurl: URL
                let extmetadata: [String: Field]?
            }
            let query: Query?
        }
        guard let info = (try? JSONDecoder().decode(Response.self, from: data))?.query?.pages.first?.imageinfo?.first
        else { return nil }
        let parts = [info.extmetadata?["Artist"]?.value, info.extmetadata?["LicenseShortName"]?.value]
            .compactMap { $0.map(plainText) }
            .filter { !$0.isEmpty }
        let credit = "Photo: " + (parts + ["Wikimedia Commons"]).joined(separator: ", ")
        return PlacePhoto(imageURL: imageURL, credit: credit, sourceURL: info.descriptionurl)
    }

    /// The artist field is HTML, often a link to the photographer's page.
    static func plainText(_ html: String) -> String {
        html.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&#39;", with: "'")
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }
}
