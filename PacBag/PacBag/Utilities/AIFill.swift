import CoreData
import UIKit

/// Fills what the phone couldn't answer. It only writes to empty or estimated fields, so a number
/// someone typed is never replaced.
@MainActor
final class AIFill: ObservableObject {
    static let shared = AIFill()

    /// The fixed support text from the server. The bag screen shows it and stops there.
    @Published var crisisMessage: String?
    @Published var notice: String?

    private let client = AIClient()
    private var inFlight: Set<NSManagedObjectID> = []

    /// Rows with nothing to show yet: no weight and not already tried, or no category.
    static func waiting(in bag: Bag) -> [Item] {
        bag.itemsArray.filter {
            !$0.name.isEmpty && !$0.isWeighed && $0.weightSource != WeightSource.skipped.rawValue
        }
    }

    func fillMissing(in bag: Bag, context: NSManagedObjectContext) async {
        guard AIConsent.shared.isGranted else { return }
        let batch = Array(Self.waiting(in: bag).filter { !inFlight.contains($0.objectID) }.prefix(AIClient.batchSize))
        guard !batch.isEmpty else { return }
        batch.forEach { inFlight.insert($0.objectID) }
        defer { batch.forEach { inFlight.remove($0.objectID) } }

        let request = batch.map { (id: $0.id.uuidString, name: $0.name) }
        // Read now, because a row can be deleted while the request is out.
        let itemsByID = Dictionary(uniqueKeysWithValues: zip(request.map(\.id), batch))
        guard let response = try? await client.fillText(items: request, categories: Self.categoryNames()) else { return }

        switch response.outcome {
        case .crisis:
            batch.filter { !$0.isGone }.forEach { $0.weightSource = WeightSource.skipped.rawValue }
            try? context.save()
            crisisMessage = response.message
        case .ok:
            for filled in response.items ?? [] {
                guard let item = itemsByID[filled.id], !item.isGone else { continue }
                apply(filled, to: item, source: .ai)
            }
            try? context.save()
        case .unusable, .paused:
            break
        }
    }

    /// `isNewRow` means the row exists only because of this photo, so it can take a name and
    /// quantity from it, and it goes away if the photo turns out to be an ID.
    func fillFromPhoto(_ item: Item, isNewRow: Bool, context: NSManagedObjectContext) async {
        guard AIConsent.shared.isGranted, let photo = item.photoData, let jpeg = Self.jpegForUpload(photo) else { return }
        guard let response = try? await client.fillPhoto(jpeg: jpeg, categories: Self.categoryNames()) else {
            notice = "Couldn't reach AI estimates. Check your connection and try again."
            return
        }
        switch response.outcome {
        case .crisis:
            crisisMessage = response.message
        case .ok:
            guard let filled = response.items?.first, !item.isGone else { return }
            if let kind = filled.documentKind, kind != "none" {
                item.photoData = nil
                if isNewRow { QuickAdd.remove(item, in: context) }
                notice = "That looks like a personal document, so PacBag didn't keep the photo."
                try? context.save()
                return
            }
            if isNewRow {
                guard let name = filled.name, !name.isEmpty else {
                    QuickAdd.remove(item, in: context)
                    notice = "PacBag couldn't find anything to pack in that photo."
                    return
                }
                item.name = name
                if let quantity = filled.quantity {
                    item.bag?.currentWeight -= item.totalWeight
                    item.quantity = Int32(quantity)
                    item.bag?.currentWeight += item.totalWeight
                }
            }
            apply(filled, to: item, source: .photo)
            try? context.save()
        case .unusable:
            notice = "PacBag couldn't tell what's in that photo."
        case .paused:
            notice = "AI estimates are paused for now. Try again later."
        }
    }

    private func apply(_ filled: FillResponse.Item, to item: Item, source: WeightSource) {
        if item.category == nil, let category = filled.category {
            QuickAdd.setCategory(category, on: item)
        }
        guard !item.isWeighed || item.isWeightEstimated else { return }
        if let grams = filled.grams {
            item.bag?.currentWeight -= item.totalWeight
            item.weight = Double(grams) / 1000
            item.weightSource = source.rawValue
            item.bag?.currentWeight += item.totalWeight
        } else if !item.isWeighed {
            item.weightSource = WeightSource.skipped.rawValue
        }
    }

    private static func categoryNames() -> [String] {
        CategoryManager.shared.categories.map(\.name)
    }

    /// Small enough to send, and re-encoding drops the location and other metadata.
    static func jpegForUpload(_ data: Data) -> Data? {
        guard let image = UIImage(data: data) else { return nil }
        let longest = max(image.size.width, image.size.height)
        let scale = min(1, 1024 / max(longest, 1))
        let size = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        return UIGraphicsImageRenderer(size: size, format: format).image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }.jpegData(compressionQuality: 0.7)
    }
}
