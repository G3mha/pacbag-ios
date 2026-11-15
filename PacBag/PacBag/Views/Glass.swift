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

    /// A glass capsule button, or a bordered one before iOS 26. Color it with `.tint`.
    @ViewBuilder func glassButtonStyle() -> some View {
        Group {
            if #available(iOS 26, *) {
                buttonStyle(.glass)
            } else {
                buttonStyle(.bordered)
            }
        }
        .buttonBorderShape(.capsule)
    }
}
