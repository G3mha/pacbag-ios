import SwiftUI

/// A trip's photo, as its own list row above the header: the one the user picked, or else
/// Wikipedia's photo of the destination with its credit. Shows nothing when neither exists.
struct TripPhotoView: View {
    @ObservedObject var trip: Trip
    @State private var found: PlacePhoto?
    /// The destination `found` belongs to. While it differs, the row shows a placeholder and looks again.
    @State private var lookedUp: String?

    var body: some View {
        Group {
            if let photo = trip.photo {
                frame(Image(uiImage: photo).resizable().scaledToFill())
            } else if lookedUp != trip.destination {
                placeholder
            } else if let found {
                VStack(alignment: .leading, spacing: 6) {
                    AsyncImage(url: found.imageURL) { phase in
                        if let image = phase.image {
                            frame(image.resizable().scaledToFill())
                        } else {
                            placeholder
                        }
                    }
                    Link(found.credit, destination: found.sourceURL)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
        }
        .listRowSeparator(.hidden)
        .task(id: trip.photoData == nil ? trip.destination : nil) {
            guard trip.photoData == nil else { return }
            let destination = trip.destination
            found = await WikipediaPhoto.photo(for: destination)
            if !Task.isCancelled { lookedUp = destination }
        }
    }

    private var placeholder: some View {
        frame(Color(.secondarySystemFill))
    }

    private func frame(_ content: some View) -> some View {
        content
            .frame(height: 180)
            .frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .accessibilityHidden(true)
    }
}
