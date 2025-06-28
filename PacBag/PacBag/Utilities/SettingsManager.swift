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

// MARK: - SettingsManager

class SettingsManager: ObservableObject {
    static let shared = SettingsManager()
    
    private let userDefaults = UserDefaults.standard
    
    // MARK: - Published Properties
    
    @Published var weightUnit: WeightUnit {
        didSet {
            userDefaults.set(weightUnit.rawValue, forKey: Keys.weightUnit)
        }
    }
    
    @Published var defaultBagWeight: Double {
        didSet {
            userDefaults.set(defaultBagWeight, forKey: Keys.defaultBagWeight)
        }
    }
    
    @Published var appTheme: AppTheme {
        didSet {
            userDefaults.set(appTheme.rawValue, forKey: Keys.appTheme)
            updateAppearance()
        }
    }
    
    @Published var defaultReminderDays: Int {
        didSet {
            userDefaults.set(defaultReminderDays, forKey: Keys.defaultReminderDays)
        }
    }
    
    @Published var analyticsEnabled: Bool {
        didSet {
            userDefaults.set(analyticsEnabled, forKey: Keys.analyticsEnabled)
        }
    }
    
    @Published var autoPackingList: Bool {
        didSet {
            userDefaults.set(autoPackingList, forKey: Keys.autoPackingList)
        }
    }
    
    @Published var smartSuggestions: Bool {
        didSet {
            userDefaults.set(smartSuggestions, forKey: Keys.smartSuggestions)
        }
    }
    
    @Published var showWeightInLists: Bool {
        didSet {
            userDefaults.set(showWeightInLists, forKey: Keys.showWeightInLists)
        }
    }
    
    @Published var defaultPackingDaysBeforeTrip: Int {
        didSet {
            userDefaults.set(defaultPackingDaysBeforeTrip, forKey: Keys.defaultPackingDaysBeforeTrip)
        }
    }
    
    @Published var defaultItemSortOrder: ItemSortOrder {
        didSet {
            userDefaults.set(defaultItemSortOrder.rawValue, forKey: Keys.defaultItemSortOrder)
        }
    }
    
    @Published var sortAscending: Bool {
        didSet {
            userDefaults.set(sortAscending, forKey: Keys.sortAscending)
        }
    }
    
    // MARK: - Keys
    
    private enum Keys {
        static let weightUnit = "settings_weight_unit"
        static let defaultBagWeight = "settings_default_bag_weight"
        static let appTheme = "settings_app_theme"
        static let defaultReminderDays = "settings_default_reminder_days"
        static let analyticsEnabled = "settings_analytics_enabled"
        static let autoPackingList = "settings_auto_packing_list"
        static let smartSuggestions = "settings_smart_suggestions"
        static let showWeightInLists = "settings_show_weight_in_lists"
        static let defaultPackingDaysBeforeTrip = "settings_default_packing_days_before_trip"
        static let defaultItemSortOrder = "settings_default_item_sort_order"
        static let sortAscending = "settings_sort_ascending"
        static let firstLaunch = "settings_first_launch"
        static let onboardingCompleted = "settings_onboarding_completed"
    }
    
    // MARK: - Initialization
    
    private init() {
        // Load saved values or set defaults
        self.weightUnit = WeightUnit(rawValue: userDefaults.string(forKey: Keys.weightUnit) ?? "") ?? .kilograms
        self.defaultBagWeight = userDefaults.object(forKey: Keys.defaultBagWeight) as? Double ?? 2.0
        self.appTheme = AppTheme(rawValue: userDefaults.string(forKey: Keys.appTheme) ?? "") ?? .system
        self.defaultReminderDays = userDefaults.object(forKey: Keys.defaultReminderDays) as? Int ?? 3
        self.analyticsEnabled = userDefaults.object(forKey: Keys.analyticsEnabled) as? Bool ?? true
        self.autoPackingList = userDefaults.object(forKey: Keys.autoPackingList) as? Bool ?? true
        self.smartSuggestions = userDefaults.object(forKey: Keys.smartSuggestions) as? Bool ?? true
        self.showWeightInLists = userDefaults.object(forKey: Keys.showWeightInLists) as? Bool ?? true
        self.defaultPackingDaysBeforeTrip = userDefaults.object(forKey: Keys.defaultPackingDaysBeforeTrip) as? Int ?? 7
        self.defaultItemSortOrder = ItemSortOrder(rawValue: userDefaults.string(forKey: Keys.defaultItemSortOrder) ?? "") ?? .category
        self.sortAscending = userDefaults.object(forKey: Keys.sortAscending) as? Bool ?? true
        
        // Apply theme on initialization
        updateAppearance()
        
        // Mark first launch
        if !userDefaults.bool(forKey: Keys.firstLaunch) {
            userDefaults.set(true, forKey: Keys.firstLaunch)
            // Perform first-launch setup if needed
        }
    }
    
    // MARK: - Public Methods
    
    func resetToDefaults() {
        weightUnit = .kilograms
        defaultBagWeight = 2.0
        appTheme = .system
        defaultReminderDays = 3
        analyticsEnabled = true
        autoPackingList = true
        smartSuggestions = true
        showWeightInLists = true
        defaultPackingDaysBeforeTrip = 7
        defaultItemSortOrder = .category
        sortAscending = true
    }
    
    func isFirstLaunch() -> Bool {
        return !userDefaults.bool(forKey: Keys.firstLaunch)
    }
    
    func markOnboardingCompleted() {
        userDefaults.set(true, forKey: Keys.onboardingCompleted)
    }
    
    func isOnboardingCompleted() -> Bool {
        return userDefaults.bool(forKey: Keys.onboardingCompleted)
    }
    
    // MARK: - Weight Conversion Helpers
    
    func convertWeight(_ weight: Double, from sourceUnit: WeightUnit) -> Double {
        return sourceUnit.convert(from: weight, to: weightUnit)
    }
    
    func formatWeight(_ weight: Double) -> String {
        return String(format: "%.1f %@", weight, weightUnit.symbol)
    }
    
    func formatWeightRange(min: Double, max: Double) -> String {
        return String(format: "%.1f - %.1f %@", min, max, weightUnit.symbol)
    }
    
    // MARK: - Export/Import
    
    func exportSettings() -> [String: Any] {
        return [
            "weightUnit": weightUnit.rawValue,
            "defaultBagWeight": defaultBagWeight,
            "appTheme": appTheme.rawValue,
            "defaultReminderDays": defaultReminderDays,
            "analyticsEnabled": analyticsEnabled,
            "autoPackingList": autoPackingList,
            "smartSuggestions": smartSuggestions,
            "showWeightInLists": showWeightInLists,
            "defaultPackingDaysBeforeTrip": defaultPackingDaysBeforeTrip,
            "defaultItemSortOrder": defaultItemSortOrder.rawValue,
            "sortAscending": sortAscending
        ]
    }
    
    func importSettings(from data: [String: Any]) {
        if let weightUnitString = data["weightUnit"] as? String,
           let weightUnit = WeightUnit(rawValue: weightUnitString) {
            self.weightUnit = weightUnit
        }
        
        if let defaultBagWeight = data["defaultBagWeight"] as? Double {
            self.defaultBagWeight = defaultBagWeight
        }
        
        if let appThemeString = data["appTheme"] as? String,
           let appTheme = AppTheme(rawValue: appThemeString) {
            self.appTheme = appTheme
        }
        
        if let defaultReminderDays = data["defaultReminderDays"] as? Int {
            self.defaultReminderDays = defaultReminderDays
        }
        
        if let analyticsEnabled = data["analyticsEnabled"] as? Bool {
            self.analyticsEnabled = analyticsEnabled
        }
        
        if let autoPackingList = data["autoPackingList"] as? Bool {
            self.autoPackingList = autoPackingList
        }
        
        if let smartSuggestions = data["smartSuggestions"] as? Bool {
            self.smartSuggestions = smartSuggestions
        }
        
        if let showWeightInLists = data["showWeightInLists"] as? Bool {
            self.showWeightInLists = showWeightInLists
        }
        
        if let defaultPackingDaysBeforeTrip = data["defaultPackingDaysBeforeTrip"] as? Int {
            self.defaultPackingDaysBeforeTrip = defaultPackingDaysBeforeTrip
        }
        
        if let defaultItemSortOrderString = data["defaultItemSortOrder"] as? String,
           let defaultItemSortOrder = ItemSortOrder(rawValue: defaultItemSortOrderString) {
            self.defaultItemSortOrder = defaultItemSortOrder
        }
        
        if let sortAscending = data["sortAscending"] as? Bool {
            self.sortAscending = sortAscending
        }
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

// MARK: - Preference Extensions

extension SettingsManager {
    
    // Computed properties for complex preferences
    var preferredItemSortDescriptor: NSSortDescriptor {
        let descriptor = defaultItemSortOrder.sortDescriptor
        return NSSortDescriptor(key: descriptor.key, ascending: sortAscending)
    }
    
    var preferredDateFormat: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }
    
    var preferredWeightPrecision: Int {
        switch weightUnit {
        case .kilograms:
            return 1 // 1 decimal place for kg
        case .pounds:
            return 1 // 1 decimal place for lbs
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
    
    var sortDescriptor: NSSortDescriptor {
        switch self {
        case .name:
            return NSSortDescriptor(keyPath: \Item.name, ascending: true)
        case .category:
            return NSSortDescriptor(keyPath: \Item.category, ascending: true)
        case .weight:
            return NSSortDescriptor(keyPath: \Item.weight, ascending: false)
        case .dateAdded:
            return NSSortDescriptor(keyPath: \Item.id, ascending: false) // Using ID as proxy for creation date
        case .packed:
            return NSSortDescriptor(keyPath: \Item.isPacked, ascending: true)
        }
    }
}