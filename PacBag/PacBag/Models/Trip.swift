import Foundation
import CoreData
import CloudKit
import SwiftUI

@objc(Trip)
public class Trip: NSManagedObject, Identifiable {
    
}

extension Trip {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Trip> {
        return NSFetchRequest<Trip>(entityName: "Trip")
    }
    
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var startDate: Date
    @NSManaged public var endDate: Date
    @NSManaged public var destination: String
    @NSManaged public var tripDescription: String?
    @NSManaged public var isCompleted: Bool
    @NSManaged public var remindersEnabled: Bool
    @NSManaged public var bags: NSSet?
}

// MARK: Generated accessors for bags
extension Trip {
    @objc(addBagsObject:)
    @NSManaged public func addToBags(_ value: Bag)
    
    @objc(removeBagsObject:)
    @NSManaged public func removeFromBags(_ value: Bag)
    
    @objc(addBags:)
    @NSManaged public func addToBags(_ values: NSSet)
    
    @objc(removeBags:)
    @NSManaged public func removeFromBags(_ values: NSSet)
}

// MARK: - Computed Properties
extension Trip {
    var bagsArray: [Bag] {
        let set = bags as? Set<Bag> ?? []
        return set.sorted { $0.name < $1.name }
    }
    
    var duration: Int {
        let calendar = Calendar.current
        return calendar.dateComponents([.day], from: startDate, to: endDate).day ?? 0
    }
    
    var daysUntilTrip: Int {
        let calendar = Calendar.current
        return calendar.dateComponents([.day], from: Date(), to: startDate).day ?? 0
    }
    
    var isUpcoming: Bool {
        return startDate > Date()
    }
    
    var isActive: Bool {
        let now = Date()
        return startDate <= now && endDate >= now
    }
    
    var totalBags: Int {
        return bagsArray.count
    }
    
    var totalItems: Int {
        return bagsArray.reduce(0) { $0 + $1.totalItemsCount }
    }
    
    var packedItems: Int {
        return bagsArray.reduce(0) { $0 + $1.packedItemsCount }
    }
    
    var packingProgress: Double {
        guard totalItems > 0 else { return 0.0 }
        return Double(packedItems) / Double(totalItems)
    }
    
    var totalWeight: Double {
        return bagsArray.reduce(0) { $0 + $1.totalWeight }
    }
    
    var status: TripStatus {
        if isCompleted {
            return .completed
        } else if isActive {
            return .active
        } else if isUpcoming {
            return .upcoming
        } else {
            return .past
        }
    }
    
    var statusColor: Color {
        switch status {
        case .upcoming:
            return .blue
        case .active:
            return .green
        case .completed:
            return .gray
        case .past:
            return .orange
        }
    }
    
    var formattedDateRange: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        
        if Calendar.current.isDate(startDate, inSameDayAs: endDate) {
            return formatter.string(from: startDate)
        } else {
            return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
        }
    }
}

enum TripStatus: String, CaseIterable {
    case upcoming = "Upcoming"
    case active = "Active"
    case completed = "Completed"
    case past = "Past"
    
    var icon: String {
        switch self {
        case .upcoming:
            return "clock"
        case .active:
            return "location"
        case .completed:
            return "checkmark.circle.fill"
        case .past:
            return "archivebox"
        }
    }
}

