import SwiftUI

extension View {
    /// Gives a sheet holding a plain list a solid background. On iPad the
    /// sheet's glass otherwise shows through the list's section headers.
    func plainFormSheet() -> some View {
        presentationBackground(Color(.systemBackground))
    }
}
