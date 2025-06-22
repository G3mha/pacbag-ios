import Foundation
import UserNotifications
import SwiftUI

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined
    
    private init() {
        checkAuthorizationStatus()
    }
    
    // MARK: - Authorization
    
    func requestAuthorization() async -> Bool {
        let center = UNUserNotificationCenter.current()
        
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            await MainActor.run {
                self.authorizationStatus = granted ? .authorized : .denied
            }
            return granted
        } catch {
            print("Error requesting notification authorization: \(error)")
            await MainActor.run {
                self.authorizationStatus = .denied
            }
            return false
        }
    }
    
    func checkAuthorizationStatus() {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.authorizationStatus = settings.authorizationStatus
            }
        }
    }
    
    // MARK: - Trip Reminders
    
    func schedulePackingReminders(for trip: Trip) async {
        guard authorizationStatus == .authorized else {
            print("Notifications not authorized")
            return
        }
        
        // Clear existing notifications for this trip
        await clearReminders(for: trip)
        
        let now = Date()
        let tripStart = trip.startDate
        
        // Only schedule notifications for future trips
        guard tripStart > now else { return }
        
        let reminders = generateReminderSchedule(for: trip)
        
        for reminder in reminders {
            await scheduleNotification(for: reminder, trip: trip)
        }
    }
    
    func clearReminders(for trip: Trip) async {
        let center = UNUserNotificationCenter.current()
        let tripId = trip.id.uuidString
        
        // Get all pending notifications
        let requests = await center.pendingNotificationRequests()
        
        // Find notifications for this trip
        let tripNotificationIds = requests
            .filter { $0.identifier.hasPrefix("trip-\(tripId)") }
            .map { $0.identifier }
        
        // Remove them
        center.removePendingNotificationRequests(withIdentifiers: tripNotificationIds)
    }
    
    func clearAllReminders() async {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
    }
    
    // MARK: - Private Methods
    
    private func generateReminderSchedule(for trip: Trip) -> [PackingReminder] {
        var reminders: [PackingReminder] = []
        let now = Date()
        let tripStart = trip.startDate
        let calendar = Calendar.current
        
        // Calculate days until trip
        let daysUntilTrip = calendar.dateComponents([.day], from: now, to: tripStart).day ?? 0
        
        // 1 week before (if trip is more than 7 days away)
        if daysUntilTrip >= 7 {
            let weekBefore = calendar.date(byAdding: .day, value: -7, to: tripStart)!
            reminders.append(PackingReminder(
                type: .oneWeekBefore,
                date: weekBefore,
                trip: trip
            ))
        }
        
        // 3 days before (if trip is more than 3 days away)
        if daysUntilTrip >= 3 {
            let threeDaysBefore = calendar.date(byAdding: .day, value: -3, to: tripStart)!
            reminders.append(PackingReminder(
                type: .threeDaysBefore,
                date: threeDaysBefore,
                trip: trip
            ))
        }
        
        // 1 day before (if trip is more than 1 day away)
        if daysUntilTrip >= 1 {
            let oneDayBefore = calendar.date(byAdding: .day, value: -1, to: tripStart)!
            reminders.append(PackingReminder(
                type: .oneDayBefore,
                date: oneDayBefore,
                trip: trip
            ))
        }
        
        // Day of trip (morning reminder)
        let tripMorning = calendar.date(bySettingHour: 8, minute: 0, second: 0, of: tripStart)!
        if tripMorning > now {
            reminders.append(PackingReminder(
                type: .dayOfTrip,
                date: tripMorning,
                trip: trip
            ))
        }
        
        return reminders.filter { $0.date > now }
    }
    
    private func scheduleNotification(for reminder: PackingReminder, trip: Trip) async {
        let center = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = reminder.type.title
        content.body = reminder.type.body(for: trip)
        content.sound = .default
        content.badge = 1
        
        // Add custom data
        content.userInfo = [
            "tripId": trip.id.uuidString,
            "tripName": trip.name,
            "reminderType": reminder.type.rawValue
        ]
        
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminder.date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let identifier = "trip-\(trip.id.uuidString)-\(reminder.type.rawValue)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        do {
            try await center.add(request)
            print("Scheduled notification: \(reminder.type.rawValue) for trip \(trip.name) at \(reminder.date)")
        } catch {
            print("Error scheduling notification: \(error)")
        }
    }
    
    // MARK: - Utility Methods
    
    func getPendingNotifications() async -> [UNNotificationRequest] {
        let center = UNUserNotificationCenter.current()
        return await center.pendingNotificationRequests()
    }
    
    func getScheduledReminders(for trip: Trip) async -> [UNNotificationRequest] {
        let allNotifications = await getPendingNotifications()
        let tripId = trip.id.uuidString
        
        return allNotifications.filter { notification in
            notification.identifier.hasPrefix("trip-\(tripId)")
        }
    }
}

// MARK: - Supporting Types

struct PackingReminder {
    let type: ReminderType
    let date: Date
    let trip: Trip
}

enum ReminderType: String, CaseIterable {
    case oneWeekBefore = "one_week_before"
    case threeDaysBefore = "three_days_before"
    case oneDayBefore = "one_day_before"
    case dayOfTrip = "day_of_trip"
    
    var title: String {
        switch self {
        case .oneWeekBefore:
            return "🧳 Packing Reminder"
        case .threeDaysBefore:
            return "🎒 Packing Time!"
        case .oneDayBefore:
            return "✈️ Pack Tomorrow!"
        case .dayOfTrip:
            return "🚀 Trip Day!"
        }
    }
    
    func body(for trip: Trip) -> String {
        let destination = trip.destination
        let progress = Int(trip.packingProgress * 100)
        
        switch self {
        case .oneWeekBefore:
            return "Your trip to \(destination) is in one week. Start planning your packing list!"
        case .threeDaysBefore:
            if progress > 0 {
                return "Your trip to \(destination) is in 3 days. You're \(progress)% packed - keep going!"
            } else {
                return "Your trip to \(destination) is in 3 days. Time to start packing!"
            }
        case .oneDayBefore:
            if progress >= 80 {
                return "Your trip to \(destination) is tomorrow! You're \(progress)% packed - almost ready!"
            } else {
                return "Your trip to \(destination) is tomorrow! Don't forget to finish packing (\(progress)% done)."
            }
        case .dayOfTrip:
            if progress >= 100 {
                return "Your trip to \(destination) starts today! All packed and ready to go! 🎉"
            } else {
                return "Your trip to \(destination) starts today! Final packing check - you're \(progress)% done."
            }
        }
    }
    
    var description: String {
        switch self {
        case .oneWeekBefore:
            return "1 week before"
        case .threeDaysBefore:
            return "3 days before"
        case .oneDayBefore:
            return "1 day before"
        case .dayOfTrip:
            return "Day of trip"
        }
    }
}