import SwiftUI
import Foundation

// MARK: - Enums

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
    
    @Published var appTheme: AppTheme {
        didSet {
            userDefaults.set(appTheme.rawValue, forKey: Keys.appTheme)
            updateAppearance()
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
        static let appTheme = "settings_app_theme"
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
        self.appTheme = AppTheme(rawValue: userDefaults.string(forKey: Keys.appTheme) ?? "") ?? .system
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
        appTheme = .system
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