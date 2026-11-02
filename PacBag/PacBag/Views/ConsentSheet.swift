import SwiftUI

/// The one place someone agrees to AI estimates. Only "Turn on" grants, and nothing is pre-ticked.
struct ConsentSheet: View {
    @Environment(\.dismiss) private var dismiss
    var onAnswer: (Bool) -> Void = { _ in }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Turn on AI estimates?")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("PacBag can estimate weights and categories for items it doesn't recognize, and fill in an item from a photo.")

                Text("To do that, it sends the item names you type and the photos you choose to PacBag's server, which passes them to Anthropic's Claude. PacBag's server doesn't save them. Anthropic may keep them for up to 30 days.")

                Text("Estimates can be wrong, so check anything that matters, like an airline limit.")

                Text("If you're under 18, ask a parent first. You can turn this off any time in Settings.")
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    Button("Not now") { answer(false) }
                        .buttonStyle(.bordered)
                        .frame(maxWidth: .infinity)
                        .accessibilityIdentifier(AccessibilityID.consentDecline)

                    Button("Turn on") { answer(true) }
                        .buttonStyle(.borderedProminent)
                        .frame(maxWidth: .infinity)
                        .accessibilityIdentifier(AccessibilityID.consentAccept)
                }

                HStack(spacing: 16) {
                    Link("Privacy Policy", destination: URL(string: "https://pacbag.app/privacy")!)
                    Link("Terms of Use", destination: URL(string: "https://pacbag.app/terms")!)
                }
                .font(.footnote)
            }
            .padding()
            .background(.bar)
        }
        .interactiveDismissDisabled()
        .presentationDetents([.large])
    }

    private func answer(_ granted: Bool) {
        if granted {
            AIConsent.shared.grant()
        } else {
            AIConsent.shared.decline()
        }
        onAnswer(granted)
        dismiss()
    }
}
