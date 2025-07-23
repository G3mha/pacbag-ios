import SwiftUI
import CoreData

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var settingsManager = SettingsManager.shared
    @StateObject private var notificationManager = NotificationManager.shared
    
    @State private var showingNotificationSettings = false
    @State private var showingCategoryManagement = false
    @State private var showingCategoryAnalytics = false
    @State private var showingDataExport = false
    @State private var showingDataImport = false
    @State private var showingAbout = false
    @State private var showingDeleteConfirmation = false
    @State private var showingLandingPage = false
    @State private var showingResetConfirmation = false
    @StateObject private var onboardingManager = OnboardingManager.shared
    
    var body: some View {
        NavigationView {
            List {
                // User Preferences Section
                Section(header: Text("Preferences")) {
                    // Weight Unit Setting
                    HStack {
                        Image(systemName: "scalemass")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        
                        Text("Weight Unit")
                        
                        Spacer()
                        
                        Picker("Weight Unit", selection: $settingsManager.weightUnit) {
                            ForEach(WeightUnit.allCases, id: \.self) { unit in
                                Text(unit.symbol).tag(unit)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .frame(width: 120)
                    }
                    
                    // Default Bag Weight
                    HStack {
                        Image(systemName: "bag")
                            .foregroundColor(.green)
                            .frame(width: 24)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Default Bag Weight")
                            Text("\(settingsManager.defaultBagWeight, specifier: "%.1f") \(settingsManager.weightUnit.symbol)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Stepper("", value: $settingsManager.defaultBagWeight, in: 0.1...50.0, step: 0.1)
                            .labelsHidden()
                    }
                    
                    // App Theme
                    HStack {
                        Image(systemName: "paintbrush")
                            .foregroundColor(.purple)
                            .frame(width: 24)
                        
                        Text("Appearance")
                        
                        Spacer()
                        
                        Picker("Appearance", selection: $settingsManager.appTheme) {
                            ForEach(AppTheme.allCases, id: \.self) { theme in
                                Text(theme.displayName).tag(theme)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .frame(width: 160)
                    }
                    
                    // Item Sort Order
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "arrow.up.arrow.down")
                                .foregroundColor(.blue)
                                .frame(width: 24)
                            
                            Text("Default Item Sorting")
                            
                            Spacer()
                        }
                        
                        HStack {
                            Text("Sort by:")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Picker("Sort Order", selection: $settingsManager.defaultItemSortOrder) {
                                ForEach(ItemSortOrder.allCases, id: \.self) { order in
                                    Text(order.displayName).tag(order)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                        
                        HStack {
                            Text("Direction:")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Picker("Sort Direction", selection: $settingsManager.sortAscending) {
                                Text("Ascending (A→Z)").tag(true)
                                Text("Descending (Z→A)").tag(false)
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .frame(width: 180)
                        }
                    }
                }
                
                // Notifications Section
                Section(header: Text("Notifications")) {
                    Button(action: { showingNotificationSettings = true }) {
                        HStack {
                            Image(systemName: "bell")
                                .foregroundColor(.orange)
                                .frame(width: 24)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Notification Settings")
                                    .foregroundColor(.primary)
                                
                                Text(notificationStatusText)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Default reminder timing
                    HStack {
                        Image(systemName: "clock")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        
                        Text("Default Reminder")
                        
                        Spacer()
                        
                        Picker("Default Reminder", selection: $settingsManager.defaultReminderDays) {
                            Text("1 day").tag(1)
                            Text("3 days").tag(3)
                            Text("1 week").tag(7)
                            Text("2 weeks").tag(14)
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                }
                
                // Categories Section
                Section(header: Text("Categories")) {
                    Button(action: { showingCategoryManagement = true }) {
                        HStack {
                            Image(systemName: "folder.badge.gearshape")
                                .foregroundColor(.indigo)
                                .frame(width: 24)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Manage Categories")
                                    .foregroundColor(.primary)
                                
                                Text("\(CategoryManager.shared.categories.count) categories")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: { showingCategoryAnalytics = true }) {
                        HStack {
                            Image(systemName: "chart.bar")
                                .foregroundColor(.green)
                                .frame(width: 24)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Category Analytics")
                                    .foregroundColor(.primary)
                                
                                Text("Usage insights and trends")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                // Data Management Section
                Section(header: Text("Data Management")) {
                    Button(action: { showingDataExport = true }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(.blue)
                                .frame(width: 24)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Export Data")
                                    .foregroundColor(.primary)
                                
                                Text("Backup trips and settings")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: { showingDataImport = true }) {
                        HStack {
                            Image(systemName: "square.and.arrow.down")
                                .foregroundColor(.green)
                                .frame(width: 24)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Import Data")
                                    .foregroundColor(.primary)
                                
                                Text("Restore from backup")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // iCloud Sync Status
                    HStack {
                        Image(systemName: "icloud")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("iCloud Sync")
                            Text(iCloudSyncStatus)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: iCloudSyncIcon)
                            .foregroundColor(iCloudSyncColor)
                    }
                }
                
                // Privacy & Security Section
                Section(header: Text("Privacy & Security")) {
                    Toggle(isOn: $settingsManager.analyticsEnabled) {
                        HStack {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .foregroundColor(.purple)
                                .frame(width: 24)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Usage Analytics")
                                Text("Help improve PacBag")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    Button("Reset All Data", role: .destructive) {
                        showingDeleteConfirmation = true
                    }
                }
                
                // Developer Section
                Section(header: Text("Developer")) {
                    Button(action: { showingLandingPage = true }) {
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .frame(width: 24)
                            
                            Text("View Landing Page")
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button("Reset App", role: .destructive) {
                        showingResetConfirmation = true
                    }
                }
                
                // About Section
                Section(header: Text("About")) {
                    Button(action: { showingAbout = true }) {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(.gray)
                                .frame(width: 24)
                            
                            Text("About PacBag")
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    HStack {
                        Image(systemName: "number")
                            .foregroundColor(.gray)
                            .frame(width: 24)
                        
                        Text("Version")
                        
                        Spacer()
                        
                        Text(appVersion)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingNotificationSettings) {
            NotificationSettingsView()
        }
        .sheet(isPresented: $showingCategoryManagement) {
            CategoryManagementView()
        }
        .sheet(isPresented: $showingCategoryAnalytics) {
            CategoryAnalyticsView()
        }
        .sheet(isPresented: $showingDataExport) {
            DataExportView()
        }
        .sheet(isPresented: $showingDataImport) {
            DataImportView()
        }
        .sheet(isPresented: $showingAbout) {
            AboutView()
        }
        .sheet(isPresented: $showingLandingPage) {
            LandingPageView()
        }
        .alert("Reset All Data", isPresented: $showingDeleteConfirmation) {
            Button("Reset", role: .destructive) {
                resetAllData()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will permanently delete all trips, bags, items, and categories. This action cannot be undone.")
        }
        .alert("Reset App", isPresented: $showingResetConfirmation) {
            Button("Reset", role: .destructive) {
                onboardingManager.resetOnboarding()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will reset the app to its initial state and show the onboarding flow again.")
        }
        .onAppear {
            notificationManager.checkAuthorizationStatus()
        }
    }
    
    private var notificationStatusText: String {
        switch notificationManager.authorizationStatus {
        case .authorized:
            return "Enabled"
        case .denied:
            return "Disabled"
        case .notDetermined:
            return "Not configured"
        default:
            return "Unknown"
        }
    }
    
    private var iCloudSyncStatus: String {
        // This would be determined by Core Data CloudKit status
        return "Syncing"
    }
    
    private var iCloudSyncIcon: String {
        return "checkmark.circle.fill"
    }
    
    private var iCloudSyncColor: Color {
        return .green
    }
    
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
    
    private func resetAllData() {
        withAnimation {
            // Delete all trips (cascade will handle bags and items)
            let request: NSFetchRequest<Trip> = Trip.fetchRequest()
            if let trips = try? viewContext.fetch(request) {
                for trip in trips {
                    viewContext.delete(trip)
                }
            }
            
            // Reset categories to defaults
            CategoryManager.shared.resetToDefaults()
            
            // Clear notification manager
            Task {
                await notificationManager.clearAllReminders()
            }
            
            // Reset settings
            settingsManager.resetToDefaults()
            
            do {
                try viewContext.save()
            } catch {
                print("Failed to clear all data: \(error)")
                fatalError("Unresolved error \(error)")
            }
        }
    }
}

// MARK: - Supporting Views

struct DataExportView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var sharingManager = SharingManager.shared
    @State private var selectedFormat: ExportFormat = .json
    @State private var includeCategories = true
    @State private var includeSettings = true
    @State private var showingShareSheet = false
    @State private var exportedData: Data?
    
    enum ExportFormat: String, CaseIterable {
        case json = "JSON"
        case csv = "CSV" 
        case txt = "Text"
        
        var fileExtension: String {
            switch self {
            case .json: return "json"
            case .csv: return "csv"
            case .txt: return "txt"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Export Format")) {
                    Picker("Format", selection: $selectedFormat) {
                        ForEach(ExportFormat.allCases, id: \.self) { format in
                            Text(format.rawValue).tag(format)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section(header: Text("Include")) {
                    Toggle("Categories & Settings", isOn: $includeCategories)
                    Toggle("App Preferences", isOn: $includeSettings)
                }
                
                Section(header: Text("Export")) {
                    Button("Export All Data") {
                        exportData()
                    }
                    .disabled(exportedData != nil)
                }
            }
            .navigationTitle("Export Data")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            if let data = exportedData {
                ShareSheet(items: [data])
            }
        }
    }
    
    private func exportData() {
        // Implementation would export data in selected format
        // For now, just create placeholder data
        let exportString = "PacBag Export Data"
        exportedData = exportString.data(using: .utf8)
        showingShareSheet = true
    }
}

struct DataImportView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showingFilePicker = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Spacer()
                
                Image(systemName: "square.and.arrow.down")
                    .font(.system(size: 60))
                    .foregroundColor(.green)
                
                VStack(spacing: 12) {
                    Text("Import Data")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Select a PacBag backup file to restore your data")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                Button("Select File") {
                    showingFilePicker = true
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                
                Spacer()
            }
            .navigationTitle("Import Data")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Spacer()
                
                Image(systemName: "suitcase.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                VStack(spacing: 12) {
                    Text("PacBag")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Smart Travel Packing")
                        .font(.title3)
                        .foregroundColor(.secondary)
                    
                    Text("Version \(appVersion)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack(spacing: 16) {
                    Text("PacBag helps you pack smart for any trip with intelligent organization, reminders, and analytics.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    HStack(spacing: 20) {
                        VStack {
                            Text("📱")
                                .font(.title2)
                            Text("iOS 17+")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack {
                            Text("☁️")
                                .font(.title2)
                            Text("iCloud Sync")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack {
                            Text("📊")
                                .font(.title2)
                            Text("Analytics")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                
                Spacer()
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    SettingsView()
        .environment(\.managedObjectContext, CoreDataManager.shared.context)
}