import SwiftUI
import Foundation

// MARK: - Enums

enum WeightUnit: String, CaseIterable {
    case kilograms = "kg"
    case pounds = "lbs"
    
    var symbol: String {
        return rawValue
    }
    
    var displayName: String {
        switch self {
        case .kilograms:
            return "Kilograms"
        case .pounds:
            return "Pounds"
        }
    }
    
    func convert(from value: Double, to targetUnit: WeightUnit) -> Double {
        if self == targetUnit {
            return value
        }
        
        switch (self, targetUnit) {
        case (.kilograms, .pounds):
            return value * 2.20462
        case (.pounds, .kilograms):
            return value / 2.20462
        default:
            return value
        }
    }
}

enum AppTheme: String, CaseIterable {
    case system = "system"
    case light = "light"
    case dark = "dark"
    
    var displayName: String {
        switch self {
        case .system:
            return "Auto"
        case .light:
            return "Light"
        case .dark:
            return "Dark"
        }
    }
    
    var colorScheme: ColorScheme? {
        switch self {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}

// MARK: - Keys

/// Every stored key. The strings can't change, because a renamed key resets someone's settings.
enum DefaultsKey {
    static let weightUnit = "settings_weight_unit"
    static let appTheme = "settings_app_theme"
    static let defaultItemSortOrder = "settings_default_item_sort_order"
    static let sortAscending = "settings_sort_ascending"
    static let remindersEnabled = "settings_reminders_enabled"
    static let hasCompletedOnboarding = "hasCompletedOnboarding"
    static let customPackingTemplates = "CustomPackingTemplates"
    static let aiConsent = "ai_consent"
    static let retired = ["settings_analytics_enabled", "settings_auto_packing_list",
        "settings_smart_suggestions", "settings_show_weight_in_lists",
        "settings_default_packing_days_before_trip", "settings_default_bag_weight",
        "settings_default_reminder_days", "settings_first_launch", "settings_onboarding_completed",
        "CustomPackingCategories"]
}

// MARK: - SettingsManager

class SettingsManager: ObservableObject {
    static let shared = SettingsManager()
    
    private let userDefaults = UserDefaults.standard
    
    // MARK: - Published Properties
    
    @Published var weightUnit: WeightUnit {
        didSet {
            userDefaults.set(weightUnit.rawValue, forKey: DefaultsKey.weightUnit)
        }
    }
    
    @Published var appTheme: AppTheme {
        didSet {
            userDefaults.set(appTheme.rawValue, forKey: DefaultsKey.appTheme)
            updateAppearance()
        }
    }
    
    @Published var defaultItemSortOrder: ItemSortOrder {
        didSet {
            userDefaults.set(defaultItemSortOrder.rawValue, forKey: DefaultsKey.defaultItemSortOrder)
        }
    }
    
    @Published var sortAscending: Bool {
        didSet {
            userDefaults.set(sortAscending, forKey: DefaultsKey.sortAscending)
        }
    }
    
    /// Packing reminders for every trip. There's no per-trip choice.
    @Published var remindersEnabled: Bool {
        didSet {
            userDefaults.set(remindersEnabled, forKey: DefaultsKey.remindersEnabled)
        }
    }
    
    // MARK: - Initialization
    
    private init() {
        // Load saved values or set defaults
        self.weightUnit = WeightUnit(rawValue: userDefaults.string(forKey: DefaultsKey.weightUnit) ?? "") ?? .kilograms
        self.appTheme = AppTheme(rawValue: userDefaults.string(forKey: DefaultsKey.appTheme) ?? "") ?? .system
        self.defaultItemSortOrder = ItemSortOrder(rawValue: userDefaults.string(forKey: DefaultsKey.defaultItemSortOrder) ?? "") ?? .category
        self.sortAscending = userDefaults.object(forKey: DefaultsKey.sortAscending) as? Bool ?? true
        self.remindersEnabled = userDefaults.object(forKey: DefaultsKey.remindersEnabled) as? Bool ?? true
        
        // Apply theme on initialization
        updateAppearance()
        
        // Settings that no longer exist shouldn't sit on the device.
        DefaultsKey.retired.forEach(userDefaults.removeObject(forKey:))
    }
    
    // MARK: - Public Methods
    
    func resetToDefaults() {
        weightUnit = .kilograms
        appTheme = .system
        defaultItemSortOrder = .category
        sortAscending = true
        remindersEnabled = true
    }
    
    // MARK: - Private Methods
    
    private func updateAppearance() {
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                for window in windowScene.windows {
                    window.overrideUserInterfaceStyle = self.appTheme.colorScheme == .light ? .light : 
                                                       self.appTheme.colorScheme == .dark ? .dark : .unspecified
                }
            }
        }
    }
}

// MARK: - Supporting Types

enum ItemSortOrder: String, CaseIterable {
    case name = "name"
    case category = "category"
    case weight = "weight"
    case dateAdded = "dateAdded"
    case packed = "packed"
    
    var displayName: String {
        switch self {
        case .name:
            return "Name"
        case .category:
            return "Category"
        case .weight:
            return "Weight"
        case .dateAdded:
            return "Date Added"
        case .packed:
            return "Packed Status"
        }
    }
    
    var shortDisplayName: String {
        switch self {
        case .name:
            return "Name"
        case .category:
            return "Category"
        case .weight:
            return "Weight"
        case .dateAdded:
            return "Date"
        case .packed:
            return "Status"
        }
    }
    
    var systemImage: String {
        switch self {
        case .name:
            return "textformat.abc"
        case .category:
            return "folder"
        case .weight:
            return "scalemass"
        case .dateAdded:
            return "calendar"
        case .packed:
            return "checkmark.circle"
        }
    }
}