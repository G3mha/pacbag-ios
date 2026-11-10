import SwiftUI

struct LandingPageView: View {
    @StateObject private var onboardingManager = OnboardingManager.shared
    @Environment(\.dismiss) private var dismiss

    private var isModal: Bool {
        onboardingManager.hasCompletedOnboarding
    }

    private let features = [
        Feature(
            title: "Bags inside bags",
            description: "A packing cube in your suitcase gets its own list, and the suitcase still counts what is inside it"
        ),
        Feature(
            title: "Lists to start from",
            description: "Eight ready-made lists, from a business week to a camping trip, or save your own"
        ),
        Feature(
            title: "Categories you control",
            description: "Rename them, add subcategories, pick your own icons and colours"
        ),
        Feature(
            title: "Your iCloud, no account",
            description: "Trips sync between your iPhone and iPad through your own Apple ID"
        )
    ]

    var body: some View {
        NavigationStack {
            List {
                VStack(alignment: .leading, spacing: 4) {
                    Text("PacBag")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Know what is in every bag, and what it weighs")
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 8)
                .listRowSeparator(.hidden, edges: .top)

                ForEach(features, id: \.title) { feature in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(feature.title)
                            .fontWeight(.semibold)

                        Text(feature.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }

                legalRow("Privacy Policy", destination: LegalLinks.privacyPolicy)
                legalRow("Terms of Use", destination: LegalLinks.termsOfUse)

                Text("Built by Enricco Gemha in São Paulo")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .listRowSeparator(.hidden, edges: .bottom)
            }
            .listStyle(.plain)
            .safeAreaInset(edge: .bottom) {
                if !isModal {
                    Button {
                        onboardingManager.completeOnboarding()
                    } label: {
                        Text("Get started")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .padding()
                    .background(Color(.systemBackground))
                }
            }
            .toolbar(isModal ? .visible : .hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
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
}

private struct Feature {
    let title: String
    let description: String
}

#Preview {
    LandingPageView()
}
