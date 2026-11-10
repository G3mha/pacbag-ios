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

                    sheetRow("Notification Settings", value: notificationStatusText) {
                        showingNotificationSettings = true
                    }
                }

                Section(header: Text("Categories").solidSectionHeader()) {
                    sheetRow("Manage Categories", value: "\(CategoryManager.shared.categories.count)") {
                        showingCategoryManagement = true
                    }

                    sheetRow("Category Analytics") {
                        showingCategoryAnalytics = true
                    }
                }

                Section(header: Text("Privacy & Security").solidSectionHeader()) {
                    Button("Reset All Data", role: .destructive) {
                        showingDeleteConfirmation = true
                    }
                }

                Section(header: Text("Developer").solidSectionHeader()) {
                    sheetRow("View Landing Page") {
                        showingLandingPage = true
                    }

                    Button("Reset App", role: .destructive) {
                        showingResetConfirmation = true
                    }
                }

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
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .plainFormSheet()
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