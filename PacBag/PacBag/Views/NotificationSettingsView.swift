import SwiftUI
import UserNotifications

struct NotificationSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var notificationManager = NotificationManager.shared
    @State private var showingSystemSettings = false
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Notification Permissions")) {
                    HStack {
                        Image(systemName: permissionIcon)
                            .foregroundColor(permissionColor)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Push Notifications")
                                .font(.headline)
                            
                            Text(permissionStatusText)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if notificationManager.authorizationStatus == .denied {
                            Button("Settings") {
                                showingSystemSettings = true
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.small)
                        } else if notificationManager.authorizationStatus == .notDetermined {
                            Button("Enable") {
                                Task {
                                    await notificationManager.requestAuthorization()
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.small)
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                if notificationManager.authorizationStatus == .authorized {
                    Section(header: Text("Reminder Types")) {
                        ForEach(ReminderType.allCases, id: \.self) { reminderType in
                            ReminderTypeRow(reminderType: reminderType)
                        }
                    }
                    
                    Section(header: Text("About Reminders")) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("PacBag will send you helpful reminders before your trips:")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                ReminderExplanationRow(
                                    icon: "📅",
                                    title: "1 week before",
                                    description: "Start planning your packing list"
                                )
                                
                                ReminderExplanationRow(
                                    icon: "🎒",
                                    title: "3 days before",
                                    description: "Begin packing with progress updates"
                                )
                                
                                ReminderExplanationRow(
                                    icon: "✈️",
                                    title: "1 day before",
                                    description: "Final packing reminder"
                                )
                                
                                ReminderExplanationRow(
                                    icon: "🚀",
                                    title: "Day of trip",
                                    description: "Last-minute packing check"
                                )
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    
                    Section(header: Text("Manage Notifications")) {
                        Button("Clear All Pending Reminders") {
                            Task {
                                await notificationManager.clearAllReminders()
                            }
                        }
                        .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Notifications")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingSystemSettings) {
                SystemSettingsView()
            }
            .onAppear {
                notificationManager.checkAuthorizationStatus()
            }
        }
    }
    
    private var permissionIcon: String {
        switch notificationManager.authorizationStatus {
        case .authorized:
            return "checkmark.circle.fill"
        case .denied:
            return "xmark.circle.fill"
        case .notDetermined:
            return "questionmark.circle.fill"
        default:
            return "exclamationmark.circle.fill"
        }
    }
    
    private var permissionColor: Color {
        switch notificationManager.authorizationStatus {
        case .authorized:
            return .green
        case .denied:
            return .red
        case .notDetermined:
            return .orange
        default:
            return .gray
        }
    }
    
    private var permissionStatusText: String {
        switch notificationManager.authorizationStatus {
        case .authorized:
            return "Enabled - You'll receive packing reminders"
        case .denied:
            return "Disabled - Enable in Settings to receive reminders"
        case .notDetermined:
            return "Not set - Tap Enable to allow notifications"
        default:
            return "Status unknown"
        }
    }
}

struct ReminderTypeRow: View {
    let reminderType: ReminderType
    
    var body: some View {
        HStack {
            Text(reminderType.title)
                .font(.body)
            
            Spacer()
            
            Text(reminderType.description)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 2)
    }
}

struct ReminderExplanationRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Text(icon)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

struct SystemSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Spacer()
                
                Image(systemName: "gear")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                VStack(spacing: 12) {
                    Text("Enable Notifications in Settings")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                    
                    Text("To receive packing reminders, please enable notifications for PacBag in your device settings.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                Button("Open Settings") {
                    if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(settingsUrl)
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                
                Spacer()
            }
            .navigationTitle("Notification Settings")
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
}

#Preview {
    NotificationSettingsView()
}