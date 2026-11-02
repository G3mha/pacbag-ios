import Foundation

/// Whether the person has said yes to sending item names and chosen photos off the phone.
/// Nothing leaves the phone until `isGranted` is true.
@MainActor
final class AIConsent: ObservableObject {
    static let shared = AIConsent()

    private enum State: String { case granted, declined }
    private let defaults = UserDefaults.standard

    @Published private var state: State?

    private init() {
        state = defaults.string(forKey: DefaultsKey.aiConsent).flatMap(State.init(rawValue:))
    }

    var isGranted: Bool { state == .granted }
    /// True until they've answered once, so the offer doesn't keep coming back after "Not now".
    var shouldOffer: Bool { state == nil }

    func grant() { set(.granted) }
    func decline() { set(.declined) }

    private func set(_ newState: State) {
        state = newState
        defaults.set(newState.rawValue, forKey: DefaultsKey.aiConsent)
    }
}
