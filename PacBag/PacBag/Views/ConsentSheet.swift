import SwiftUI

/// The one place someone agrees to AI estimates. Only "Turn on" grants, and nothing is pre-ticked.
struct ConsentSheet: View {
    @Environment(\.dismiss) private var dismiss
    var onAnswer: (Bool) -> Void = { _ in }

    private let points = [
        Point(
            title: "What's sent",
            detail: "Item names you type and photos you pick go to Anthropic's Claude through PacBag's server."
        ),
        Point(
            title: "What's kept",
            detail: "PacBag's server keeps nothing. Anthropic may keep it for up to 30 days."
        )
    ]

    var body: some View {
        List {
            VStack(alignment: .leading, spacing: 4) {
                Text("Turn on AI estimates?")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Get weights and categories for items PacBag doesn't know, or fill one in from a photo.")
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
            .listRowSeparator(.hidden, edges: .top)

            ForEach(points, id: \.title) { point in
                VStack(alignment: .leading, spacing: 2) {
                    Text(point.title)
                        .fontWeight(.semibold)

                    Text(point.detail)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
            }

            legalRow("Privacy Policy", destination: LegalLinks.privacyPolicy)
            legalRow("Terms of Use", destination: LegalLinks.termsOfUse)

            Text("Under 18? Ask a parent first. You can turn this off in Settings.")
                .font(.footnote)
                .foregroundColor(.secondary)
                .listRowSeparator(.hidden, edges: .bottom)
        }
        .listStyle(.plain)
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 12) {
                Button { answer(true) } label: {
                    Text("Turn on")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .accessibilityIdentifier(AccessibilityID.consentAccept)

                Button { answer(false) } label: {
                    Text("Not now")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .accessibilityIdentifier(AccessibilityID.consentDecline)
            }
            .padding()
            .background(Color(.systemBackground))
        }
        .interactiveDismissDisabled()
        .presentationDetents([.large])
        .plainFormSheet()
    }

    private func legalRow(_ title: String, destination: URL) -> some View {
        Link(destination: destination) {
            HStack {
                Text(title)
                    .foregroundColor(.primary)

                Spacer()

                Image(systemName: "arrow.up.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
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

private struct Point {
    let title: String
    let detail: String
}

#Preview {
    ConsentSheet()
}
