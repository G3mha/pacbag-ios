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
                // User Preferences Section
                Section(header: Text("Preferences")) {
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
                
                // Privacy & Security Section
                Section(header: Text("Privacy & Security")) {
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

                    Link(destination: LegalLinks.privacyPolicy) {
                        HStack {
                            Image(systemName: "hand.raised")
                                .foregroundColor(.gray)
                                .frame(width: 24)

                            Text("Privacy Policy")
                                .foregroundColor(.primary)

                            Spacer()

                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    Link(destination: LegalLinks.termsOfUse) {
                        HStack {
                            Image(systemName: "doc.text")
                                .foregroundColor(.gray)
                                .frame(width: 24)

                            Text("Terms of Use")
                                .foregroundColor(.primary)

                            Spacer()

                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

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