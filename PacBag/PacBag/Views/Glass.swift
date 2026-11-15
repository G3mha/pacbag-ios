import SwiftUI

/// Liquid Glass on iOS 26, to match the system's navigation buttons, with a fallback before it.
extension View {
    /// A glass background in `shape`, or a material before iOS 26.
    @ViewBuilder func surface<S: Shape>(in shape: S) -> some View {
        if #available(iOS 26, *) {
            glassEffect(.regular.interactive(), in: shape)
        } else {
            background(.regularMaterial, in: shape)
        }
    }

}
