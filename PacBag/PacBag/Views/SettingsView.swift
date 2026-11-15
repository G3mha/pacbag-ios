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
    @State private var showingAbout = false
    @State private var showingDeleteConfirmation = false
    @State private var showingLandingPage = false
    @State private var showingResetConfirmation = false
    @StateObject private var onboardingManager = OnboardingManager.shared
    @ObservedObject private var aiConsent = AIConsent.shared
    @ObservedObject private var syncMonitor = SyncMonitor.shared
    @State private var showingAIConsent = false
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Preferences").solidSectionHeader()) {
                    Picker("Appearance", selection: $settingsManager.appTheme) {
                        ForEach(AppTheme.allCases, id: \.self) { theme in
                            Text(theme.displayName).tag(theme)
                        }
                    }
                    .pickerStyle(.menu)

                    Picker("Sort Items By", selection: $settingsManager.defaultItemSortOrder) {
                        ForEach(ItemSortOrder.allCases, id: \.self) { order in
                            Text(order.displayName).tag(order)
                        }
                    }
                    .pickerStyle(.menu)

                    Picker("Sort Direction", selection: $settingsManager.sortAscending) {
                        Text("Ascending").tag(true)
                        Text("Descending").tag(false)
                    }
                    .pickerStyle(.menu)

                }

                Section {
                    Toggle("Packing reminders", isOn: $settingsManager.remindersEnabled)
                        .onChange(of: settingsManager.remindersEnabled) { _, _ in
                            Task { await notificationManager.applyReminderSetting() }
                        }

                    sheetRow("Notification Settings", value: notificationStatusText) {
                        showingNotificationSettings = true
                    }
                } header: {
                    Text("Notifications").solidSectionHeader()
                } footer: {
                    Text("Get notified 1 week, 3 days and 1 day before each trip, and on the morning it starts.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }

                Section(header: Text("Categories").solidSectionHeader()) {
                    sheetRow("Manage Categories", value: "\(CategoryManager.shared.categories.count)") {
                        showingCategoryManagement = true
                    }

                    sheetRow("Category Analytics") {
                        showingCategoryAnalytics = true
                    }
                }

                Section(header: Text("iCloud").solidSectionHeader()) {
                    LabeledContent("Sync", value: syncMonitor.text)
                }

                Section(header: Text("Privacy & Security").solidSectionHeader()) {
                    Toggle("AI estimates", isOn: Binding(
                        get: { aiConsent.isGranted },
                        set: { isOn in
                            if isOn { showingAIConsent = true } else { aiConsent.decline() }
                        }
                    ))

                    ListGlassButton(title: "Reset All Data", systemImage: "trash", role: .destructive) {
                        showingDeleteConfirmation = true
                    }
                }

                #if DEBUG
                Section(header: Text("Developer").solidSectionHeader()) {
                    sheetRow("View Landing Page") {
                        showingLandingPage = true
                    }

                    ListGlassButton(title: "Reset App", systemImage: "arrow.counterclockwise", role: .destructive) {
                        showingResetConfirmation = true
                    }
                }
                #endif

                Section(header: Text("About").solidSectionHeader()) {
                    sheetRow("About PacBag") {
                        showingAbout = true
                    }

                    linkRow("Privacy Policy", destination: LegalLinks.privacyPolicy)
                    linkRow("Terms of Use", destination: LegalLinks.termsOfUse)

                    LabeledContent("Version", value: appVersion)
                }
            }
            .listStyle(.plain)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done", systemImage: "checkmark") {
                        dismiss()
                    }
                }
            }
        }
        .plainFormSheet()
        .sheet(isPresented: $showingAIConsent) {
            ConsentSheet()
        }
        .task {
            await syncMonitor.refresh(
                cloudKitIsOn: CoreDataManager.shared.storeDescription.cloudKitContainerOptions != nil,
                containerID: CoreDataManager.cloudKitContainerID
            )
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
    
    private func sheetRow(_ title: String, value: String? = nil, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .foregroundColor(.primary)

                Spacer()

                if let value {
                    Text(value)
                        .foregroundColor(.secondary)
                }

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func linkRow(_ title: String, destination: URL) -> some View {
        Link(destination: destination) {
            HStack {
                Text(title)
                    .foregroundColor(.primary)

                Spacer()

                Image(systemName: "arrow.up.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
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

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                VStack(alignment: .leading, spacing: 2) {
                    Text("PacBag")
                        .font(.title2)
                        .fontWeight(.semibold)

                    Text("Travel packing lists")
                        .foregroundColor(.secondary)
                }
                .listRowSeparator(.hidden, edges: .top)

                Text("PacBag keeps your packing lists, weights and reminders for each trip.")

                LabeledContent("Version", value: appVersion)
            }
            .listStyle(.plain)
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done", systemImage: "checkmark") {
                        dismiss()
                    }
                }
            }
        }
        .plainFormSheet()
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