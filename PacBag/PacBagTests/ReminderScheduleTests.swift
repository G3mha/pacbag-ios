import Foundation
import Testing
@testable import PacBag

struct ReminderScheduleTests {
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "America/Sao_Paulo")!
        return calendar
    }

    private func date(_ day: Int, _ hour: Int, _ minute: Int = 0) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: 11, day: day, hour: hour, minute: minute))!
    }

    @Test func remindersIgnoreTheTimeTheTripWasSaved() {
        // The start date carries 15:37, the time the trip was saved.
        let reminders = NotificationManager.reminderDates(tripStart: date(20, 15, 37), now: date(10, 10), calendar: calendar)

        #expect(reminders.map(\.type) == [.oneWeekBefore, .threeDaysBefore, .oneDayBefore, .dayOfTrip])
        #expect(reminders.map(\.date) == [date(13, 9), date(17, 9), date(19, 9), date(20, 8)])
    }

    @Test func remindersAlreadyPastAreLeftOut() {
        let reminders = NotificationManager.reminderDates(tripStart: date(20, 15, 37), now: date(17, 12), calendar: calendar)

        #expect(reminders.map(\.type) == [.oneDayBefore, .dayOfTrip])
        #expect(reminders.map(\.date) == [date(19, 9), date(20, 8)])
    }

    @Test func aTripStartingTodayStillGetsItsMorningReminderBeforeEight() {
        let reminders = NotificationManager.reminderDates(tripStart: date(20, 0), now: date(20, 7, 30), calendar: calendar)

        #expect(reminders.map(\.type) == [.dayOfTrip])
        #expect(reminders.map(\.date) == [date(20, 8)])
    }
}
