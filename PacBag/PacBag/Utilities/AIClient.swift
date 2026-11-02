import Foundation
import StoreKit

struct FillResponse: Decodable {
    enum Outcome: String, Decodable { case ok, crisis, unusable, paused }
    struct Item: Decodable {
        let id: String
        let category: String?
        let grams: Int?
        let name: String?
        let quantity: Int?
        let documentKind: String?
    }

    let outcome: Outcome
    let items: [Item]?
    let message: String?
}

/// Talks to PacBag's server, which holds the Claude key. Any failure just means try again later.
struct AIClient {
    static let batchSize = 25
    private static let productionURL = URL(string: "https://api.pacbag.app")!

    private static var baseURL: URL {
        #if DEBUG
        if let override = ProcessInfo.processInfo.environment["PACBAG_API_URL"], let url = URL(string: override) {
            return url
        }
        #endif
        return productionURL
    }

    func fillText(items: [(id: String, name: String)], categories: [String]) async throws -> FillResponse {
        try await post([
            "kind": "text",
            "items": items.map { ["id": $0.id, "name": $0.name] },
            "categories": categories,
        ])
    }

    func fillPhoto(jpeg: Data, categories: [String]) async throws -> FillResponse {
        try await post([
            "kind": "photo",
            "image": jpeg.base64EncodedString(),
            "categories": categories,
            "nameLanguage": Locale.preferredLanguages.first ?? "en",
        ])
    }

    private func post(_ body: [String: Any]) async throws -> FillResponse {
        var request = URLRequest(url: Self.baseURL.appendingPathComponent("v1/fill"))
        request.httpMethod = "POST"
        request.timeoutInterval = 60
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let transaction = try? await AppTransaction.shared {
            request.setValue(transaction.jwsRepresentation, forHTTPHeaderField: "X-App-Transaction")
        }
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw URLError(.badServerResponse) }
        return try JSONDecoder().decode(FillResponse.self, from: data)
    }
}
