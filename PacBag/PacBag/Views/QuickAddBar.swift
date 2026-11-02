import SwiftUI
import CoreData
import PhotosUI

/// The always-there add field. It's a vertical field because one of those keeps the keyboard up
/// on Return and keeps the line breaks of a pasted list. Return on an empty field puts it away.
struct QuickAddBar: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var bag: Bag
    @ObservedObject private var consent = AIConsent.shared
    @ObservedObject private var fill = AIFill.shared

    @State private var text = ""
    @State private var lastAdded: [Item] = []
    @State private var showingConsent = false
    @State private var pickedPhoto: PhotosPickerItem?
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

            if consent.shouldOffer && !AIFill.waiting(in: bag).isEmpty {
                Button(offerText) { showingConsent = true }
                    .font(.caption)
                    .accessibilityIdentifier(AccessibilityID.quickAddOffer)
            }

            HStack(alignment: .top, spacing: 12) {
                TextField("Add an item, like 2 socks", text: $text, axis: .vertical)
                    .lineLimit(1...4)
                    .focused($isFocused)
                    .textInputAutocapitalization(.sentences)
                    .accessibilityIdentifier(AccessibilityID.quickAddField)
                    .onChange(of: text) { _, newText in
                        guard newText.contains(where: \.isNewline) else { return }
                        commit(newText)
                    }

                if consent.isGranted {
                    PhotosPicker(selection: $pickedPhoto, matching: .images) {
                        Image(systemName: "camera")
                    }
                    .accessibilityLabel("Add from a photo")
                    .accessibilityIdentifier(AccessibilityID.quickAddPhoto)
                } else if consent.shouldOffer {
                    Button { showingConsent = true } label: {
                        Image(systemName: "camera")
                    }
                    .accessibilityLabel("Add from a photo")
                    .accessibilityIdentifier(AccessibilityID.quickAddPhoto)
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 14)
        .background(.bar)
        .contentShape(Rectangle())
        .onTapGesture { isFocused = true }
        .task(id: bag.itemsArray.count) { await fill.fillMissing(in: bag, context: viewContext) }
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
