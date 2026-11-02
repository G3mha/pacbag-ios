import Foundation

/// Identifiers shared by the app and the UI tests, in the format `screen.element`.
/// Docs: `docs/ssot-registry.md` section 2.10. An id lands with its first test, and
/// rule `a11y-literal` bans string literals in `.accessibilityIdentifier(`.
enum AccessibilityID {
    /// The header Add Item button, until every entry points at quick add.
    static let bagDetailAddItem = "bagDetail.addItem"
    static let bagDetailTotal = "bagDetail.total"

    static let itemRowToggle = "itemRow.toggle"
    static func itemRow(_ name: String) -> String {
        "itemRow." + name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    static let itemDetailNameField = "itemDetail.nameField"
    static let itemDetailWeightField = "itemDetail.weightField"
    /// The draft's Add and Cancel. A saved item has neither.
    static let itemDetailSave = "itemDetail.save"
    static let itemDetailCancel = "itemDetail.cancel"
}
