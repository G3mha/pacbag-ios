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
            return
        }
        
        // Clear existing notifications for this trip
        await clearReminders(for: trip)

        // Reminders whose time has passed are left out of the schedule.
        let reminders = generateReminderSchedule(for: trip)
        
        for reminder in reminders {
            await scheduleNotification(for: reminder, trip: trip)
        }
    }
    
    func clearReminders(for trip: Trip) async {
        await clearReminders(forTripWithID: trip.id)
    }

    /// Use this when the trip is being deleted. Capture the ID first, because
    /// reading `id` from a deleted trip traps.
    func clearReminders(forTripWithID id: UUID) async {
        let center = UNUserNotificationCenter.current()
        let tripId = id.uuidString

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
        Self.reminderDates(tripStart: trip.startDate, now: Date()).map {
            PackingReminder(type: $0.type, date: $0.date, trip: trip)
        }
    }

    /// When each reminder goes off. A trip's start date only says which day
    /// the trip begins. Its clock time is whenever the trip was saved, so each
    /// reminder is set to a fixed hour on its own day instead.
    static func reminderDates(tripStart: Date, now: Date, calendar: Calendar = .current) -> [(type: ReminderType, date: Date)] {
        let startDay = calendar.startOfDay(for: tripStart)
        let schedule: [(type: ReminderType, daysBefore: Int, hour: Int)] = [
            (.oneWeekBefore, 7, 9),
            (.threeDaysBefore, 3, 9),
            (.oneDayBefore, 1, 9),
            (.dayOfTrip, 0, 8)
        ]

        return schedule.compactMap { entry in
            guard let day = calendar.date(byAdding: .day, value: -entry.daysBefore, to: startDay),
                  let date = calendar.date(bySettingHour: entry.hour, minute: 0, second: 0, of: day),
                  date > now else { return nil }
            return (entry.type, date)
        }
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
        } catch {
            print("Failed to schedule notification: \(error)")
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