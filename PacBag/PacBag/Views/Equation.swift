import SwiftUI

/// A small sum laid out like a calculator, such as 2 × 0,5kg = 1,0kg, for a list row.
/// VoiceOver reads it as one sentence, so pass one that says the sum in words.
struct Equation: View {
    struct Term {
        let value: String
        let caption: String
        /// Narrows a short term, such as a count, so the weights get the room.
        var maxWidth: CGFloat = .infinity
    }

    let left: Term
    let sign: String
    let right: Term
    let result: Term
    /// The result's color. Red works for a sum that went wrong, such as a limit already used up.
    var resultTint: Color = .accentColor
    let spokenText: String

    var body: some View {
        HStack(spacing: 6) {
            tile(left)
            symbol(sign)
            tile(right)
            symbol("=")
            tile(result, tint: resultTint)
        }
        .padding(.vertical, 6)
        .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(spokenText)
    }

    private func tile(_ term: Term, tint: Color? = nil) -> some View {
        VStack(spacing: 2) {
            Text(term.value)
                .font(.title3.weight(.semibold))
                .fontDesign(.rounded)
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .foregroundStyle(tint ?? .primary)
                .contentTransition(.numericText())
            Text(term.caption)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .frame(maxWidth: term.maxWidth, minHeight: 64)
        .background(
            tint?.opacity(0.15) ?? Color(.secondarySystemBackground),
            in: RoundedRectangle(cornerRadius: 14, style: .continuous)
        )
    }

    private func symbol(_ text: String) -> some View {
        Text(text)
            .font(.title3.weight(.medium))
            .foregroundStyle(.tertiary)
    }
}
