import SwiftUI

extension View {
    /// Gives a sheet holding a plain list a solid background. On iPad the
    /// sheet's glass otherwise shows through the list's section headers.
    func plainFormSheet() -> some View {
        presentationBackground(Color(.systemBackground))
    }

    /// Plain lists pin section headers without a background, so on a long list
    /// the rows scroll straight through the header text.
    func solidSectionHeader() -> some View {
        frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemBackground).padding(.horizontal, -40).padding(.vertical, -10))
    }
}
