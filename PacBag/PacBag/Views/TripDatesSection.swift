import SwiftUI

/// A trip's start date, end date and length as a section of a list.
struct TripDatesSection: View {
    @Binding var startDate: Date
    @Binding var endDate: Date

    private var duration: Int {
        Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0
    }

    var body: some View {
        Section(header: Text("Dates").solidSectionHeader()) {
            DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                .onChange(of: startDate) { _, newValue in
                    // Ensure end date is after start date
                    if endDate <= newValue {
                        endDate = Calendar.current.date(byAdding: .day, value: 1, to: newValue) ?? newValue.addingTimeInterval(86400)
                    }
                }

            DatePicker("End Date", selection: $endDate, in: startDate.addingTimeInterval(86400)..., displayedComponents: .date)

            HStack {
                Text("Duration")
                Spacer()
                Text(duration == 1 ? "1 day" : "\(duration) days")
                    .foregroundColor(.secondary)
            }
        }
    }
}
