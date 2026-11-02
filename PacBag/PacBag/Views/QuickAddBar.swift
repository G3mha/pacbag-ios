import SwiftUI
import CoreData

/// The always-there add field. It's a vertical field because one of those keeps the keyboard up
/// on Return and keeps the line breaks of a pasted list. Return on an empty field puts it away.
struct QuickAddBar: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var bag: Bag

    @State private var text = ""
    @State private var lastAdded: [Item] = []
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !lastAdded.isEmpty {
                HStack {
                    Text(addedSummary)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)

                    Spacer()

                    Button("Undo", action: undo)
                        .font(.caption)
                        .accessibilityIdentifier(AccessibilityID.quickAddUndo)
                }
            }

            TextField("Add an item, like 2 socks", text: $text, axis: .vertical)
                .lineLimit(1...4)
                .focused($isFocused)
                .textInputAutocapitalization(.sentences)
                .accessibilityIdentifier(AccessibilityID.quickAddField)
                .onChange(of: text) { _, newText in
                    guard newText.contains(where: \.isNewline) else { return }
                    commit(newText)
                }
        }
        .padding(.horizontal)
        .padding(.vertical, 14)
        .background(.bar)
        .contentShape(Rectangle())
        .onTapGesture { isFocused = true }
    }

    private var addedSummary: String {
        guard lastAdded.count == 1, let item = lastAdded.first else { return "Added \(lastAdded.count) items" }
        let count = item.quantity > 1 ? " ×\(item.quantity)" : ""
        return "Added \(item.name)\(count), \(item.category ?? "not sorted")"
    }

    private func commit(_ newText: String) {
        let lines = newText.components(separatedBy: .newlines)
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        text = ""
        guard !lines.isEmpty else {
            isFocused = false
            return
        }
        withAnimation {
            lastAdded = lines.compactMap { QuickAdd.add($0, to: bag, in: viewContext) }
        }
    }

    private func undo() {
        withAnimation {
            lastAdded.forEach { QuickAdd.remove($0, in: viewContext) }
            lastAdded = []
        }
    }
}
