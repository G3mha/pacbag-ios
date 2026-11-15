import SwiftUI
import CoreData
import PhotosUI

/// The always-there add field. It's a vertical field because one of those keeps the keyboard up
/// on Return and keeps the line breaks of a pasted list. Return on an empty field puts it away.
struct QuickAddBar: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var bag: Bag
    /// Owned by the bag screen, which drops it before opening an item.
    var isFocused: FocusState<Bool>.Binding
    /// Opens the full item form, for anything a one-line entry can't say.
    var onAddItem: () -> Void
    @ObservedObject private var consent = AIConsent.shared
    @ObservedObject private var fill = AIFill.shared

    @State private var text = ""
    @State private var lastAdded: [Item] = []
    @State private var showingConsent = false
    @State private var pickedPhoto: PhotosPickerItem?

    var body: some View {
        VStack(spacing: 8) {
            banner

            HStack(alignment: .bottom, spacing: 10) {
                HStack(alignment: .bottom, spacing: 10) {
                    TextField("Add an item, like 2 socks", text: $text, axis: .vertical)
                        .lineLimit(1...4)
                        .focused(isFocused)
                        .textInputAutocapitalization(.sentences)
                        .accessibilityIdentifier(AccessibilityID.quickAddField)
                        .onChange(of: text) { _, newText in
                            guard newText.contains(where: \.isNewline) else { return }
                            commit(newText)
                        }

                    photoButton
                }
                .padding(.leading, 16)
                .padding(.trailing, 14)
                .padding(.vertical, 11)
                .frame(minHeight: Self.height)
                .surface(in: RoundedRectangle(cornerRadius: Self.height / 2, style: .continuous))

                // Empty, it opens the full form. With text, it adds what's typed, the same as Return.
                Button(action: hasText ? { commit(text) } : onAddItem) {
                    Image(systemName: hasText ? "arrow.up" : "plus")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(width: Self.height, height: Self.height)
                        .background(Color.accentColor, in: Circle())
                        .contentTransition(.symbolEffect(.replace))
                }
                .buttonStyle(.plain)
                .accessibilityLabel(hasText ? "Add" : "Add Item")
                .accessibilityIdentifier(AccessibilityID.bagDetailAddItem)
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
        .animation(.snappy, value: bannerKind)
        .animation(.snappy, value: hasText)
        .task(id: lastAdded.map(\.objectID)) {
            // The undo pill steps aside on its own after a few seconds.
            guard !lastAdded.isEmpty, (try? await Task.sleep(for: .seconds(5))) != nil else { return }
            lastAdded = []
        }
        // Detached from the view: leaving the bag would cancel a request the server already paid for,
        // free its items, and opening the bag again would send the same request twice.
        .task(id: bag.itemsArray.count) { Task { await fill.fillMissing(in: bag, context: viewContext) } }
        .onChange(of: pickedPhoto) { _, newPhoto in
            guard let newPhoto else { return }
            pickedPhoto = nil
            Task { await addFromPhoto(newPhoto) }
        }
        .sheet(isPresented: $showingConsent) {
            ConsentSheet { granted in
                if granted { Task { await fill.fillMissing(in: bag, context: viewContext) } }
            }
        }
        .alert("You're not alone", isPresented: crisisShowing) {
            Button("OK", role: .cancel) { fill.crisisMessage = nil }
        } message: {
            Text(fill.crisisMessage ?? "")
        }
        .alert("AI estimates", isPresented: noticeShowing) {
            Button("OK", role: .cancel) { fill.notice = nil }
        } message: {
            Text(fill.notice ?? "")
        }
    }

    private static let height: CGFloat = 44

    private var hasText: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private enum BannerKind { case none, added, offer }

    /// One pill at a time, so the undo and the AI offer never draw over each other.
    private var bannerKind: BannerKind {
        if !stillAdded.isEmpty { return .added }
        if consent.shouldOffer && !AIFill.waiting(in: bag).isEmpty { return .offer }
        return .none
    }

    @ViewBuilder private var banner: some View {
        switch bannerKind {
        case .added:
            HStack(spacing: 12) {
                Text(addedSummary)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                Button("Undo", action: undo)
                    .fontWeight(.semibold)
                    .accessibilityIdentifier(AccessibilityID.quickAddUndo)
            }
            .pill()
        case .offer:
            Button(offerText) { showingConsent = true }
                .multilineTextAlignment(.center)
                .pill()
                .accessibilityIdentifier(AccessibilityID.quickAddOffer)
        case .none:
            EmptyView()
        }
    }

    @ViewBuilder private var photoButton: some View {
        if consent.isGranted {
            PhotosPicker(selection: $pickedPhoto, matching: .images) {
                Image(systemName: "camera")
            }
            .foregroundStyle(.secondary)
            .accessibilityLabel("Add from a photo")
            .accessibilityIdentifier(AccessibilityID.quickAddPhoto)
        } else if consent.shouldOffer {
            Button { showingConsent = true } label: {
                Image(systemName: "camera")
            }
            .foregroundStyle(.secondary)
            .accessibilityLabel("Add from a photo")
            .accessibilityIdentifier(AccessibilityID.quickAddPhoto)
        }
    }

    private var offerText: String {
        let count = AIFill.waiting(in: bag).count
        return "\(count == 1 ? "1 item has" : "\(count) items have") no estimate. Turn on AI estimates?"
    }

    private var crisisShowing: Binding<Bool> {
        Binding(get: { fill.crisisMessage != nil }, set: { if !$0 { fill.crisisMessage = nil } })
    }

    private var noticeShowing: Binding<Bool> {
        Binding(get: { fill.notice != nil }, set: { if !$0 { fill.notice = nil } })
    }

    private func addFromPhoto(_ photo: PhotosPickerItem) async {
        guard let data = try? await photo.loadTransferable(type: Data.self),
              let jpeg = AIFill.jpegForUpload(data),
              let item = QuickAdd.add("Photo item", to: bag, in: viewContext) else {
            fill.notice = "Couldn't read that photo."
            return
        }
        item.photoData = jpeg
        try? viewContext.save()
        lastAdded = [item]
        await fill.fillFromPhoto(item, isNewRow: true, context: viewContext)
    }

    /// The last adds, minus any deleted from the list since.
    private var stillAdded: [Item] {
        lastAdded.filter { !$0.isGone }
    }

    private var addedSummary: String {
        guard stillAdded.count == 1, let item = stillAdded.first else { return "Added \(stillAdded.count) items" }
        let count = item.quantity > 1 ? " ×\(item.quantity)" : ""
        return "Added \(item.name)\(count), \(item.category ?? "not sorted")"
    }

    private func commit(_ newText: String) {
        let lines = newText.components(separatedBy: .newlines)
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        text = ""
        guard !lines.isEmpty else {
            isFocused.wrappedValue = false
            return
        }
        withAnimation {
            lastAdded = lines.compactMap { QuickAdd.add($0, to: bag, in: viewContext) }
        }
    }

    private func undo() {
        withAnimation {
            stillAdded.forEach { QuickAdd.remove($0, in: viewContext) }
            lastAdded = []
        }
    }
}

private extension View {
    func pill() -> some View {
        font(.footnote)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .surface(in: Capsule())
            .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}
