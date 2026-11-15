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

/// A full-width glass button for a list, set apart from the rows above it. A destructive one is red.
struct ListGlassButton: View {
    let title: String
    let systemImage: String
    var role: ButtonRole?
    let action: () -> Void
    @Environment(\.isEnabled) private var isEnabled

    private var tint: Color { role == .destructive ? .red : .accentColor }

    var body: some View {
        Button(role: role, action: action) {
            Label(title, systemImage: systemImage)
                .font(.body.weight(.semibold))
                // Set by hand so the icon matches the text, which also means dimming it by hand when disabled.
                .foregroundStyle(isEnabled ? tint : .secondary)
                .frame(maxWidth: .infinity, minHeight: 36)
        }
        .glassButtonStyle()
        .tint(tint)
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets(top: 28, leading: 16, bottom: 16, trailing: 16))
    }
}
