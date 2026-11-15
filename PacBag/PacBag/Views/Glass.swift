import SwiftUI

/// Liquid Glass on iOS 26, to match the system's navigation buttons, with a fallback before it.
extension View {
    /// A glass background in `shape`, tinted when `tint` is given. Before iOS 26 it's a material, or the tint as a fill.
    @ViewBuilder func surface<S: Shape>(in shape: S, tint: Color? = nil) -> some View {
        if #available(iOS 26, *) {
            glassEffect(.regular.tint(tint).interactive(), in: shape)
        } else if let tint {
            background(tint, in: shape)
        } else {
            background(.regularMaterial, in: shape)
        }
    }

    /// A glass button, or a bordered one before iOS 26. Color it with `.tint`.
    /// A prominent one is filled with the tint, for the main action on a screen.
    @ViewBuilder func glassButtonStyle(prominent: Bool = false, shape: ButtonBorderShape = .capsule) -> some View {
        Group {
            if #available(iOS 26, *) {
                if prominent { buttonStyle(.glassProminent) } else { buttonStyle(.glass) }
            } else {
                if prominent { buttonStyle(.borderedProminent) } else { buttonStyle(.bordered) }
            }
        }
        .buttonBorderShape(shape)
    }
}
