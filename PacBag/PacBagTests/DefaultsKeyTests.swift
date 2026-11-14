import XCTest
@testable import PacBag

/// A deliberate copy of each stored key. A renamed key silently resets someone's settings.
final class DefaultsKeyTests: XCTestCase {
    private let defaults = UserDefaults.standard

    func testSettingsWriteToTheirStoredKeys() {
        let settings = SettingsManager.shared
        let saved = (settings.appTheme, settings.defaultItemSortOrder, settings.sortAscending)
        defer { (settings.appTheme, settings.defaultItemSortOrder, settings.sortAscending) = saved }

        settings.appTheme = .dark
        XCTAssertEqual(defaults.string(forKey: "settings_app_theme"), "dark")

        settings.defaultItemSortOrder = .weight
        XCTAssertEqual(defaults.string(forKey: "settings_default_item_sort_order"), "weight")

        settings.sortAscending = false
        XCTAssertEqual(defaults.object(forKey: "settings_sort_ascending") as? Bool, false)
    }

    func testOnboardingWritesToItsStoredKey() {
        let onboarding = OnboardingManager.shared
        let saved = onboarding.hasCompletedOnboarding
        defer { onboarding.hasCompletedOnboarding = saved }

        onboarding.completeOnboarding()
        XCTAssertEqual(defaults.object(forKey: "hasCompletedOnboarding") as? Bool, true)
        onboarding.resetOnboarding()
        XCTAssertEqual(defaults.object(forKey: "hasCompletedOnboarding") as? Bool, false)
    }

    func testKeysEqualTheirStoredStrings() {
        XCTAssertEqual(DefaultsKey.appTheme, "settings_app_theme")
        XCTAssertEqual(DefaultsKey.defaultItemSortOrder, "settings_default_item_sort_order")
        XCTAssertEqual(DefaultsKey.sortAscending, "settings_sort_ascending")
        XCTAssertEqual(DefaultsKey.remindersEnabled, "settings_reminders_enabled")
        XCTAssertEqual(DefaultsKey.hasCompletedOnboarding, "hasCompletedOnboarding")
        XCTAssertEqual(DefaultsKey.customPackingTemplates, "CustomPackingTemplates")
    }

    func testRetiredKeysStayRetired() {
        XCTAssertEqual(Set(DefaultsKey.retired), [
            "settings_weight_unit", "settings_analytics_enabled", "settings_auto_packing_list", "settings_smart_suggestions",
            "settings_show_weight_in_lists", "settings_default_packing_days_before_trip",
            "settings_default_bag_weight", "settings_default_reminder_days", "settings_first_launch",
            "settings_onboarding_completed", "CustomPackingCategories",
        ])
    }
}
