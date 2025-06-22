import Foundation
import SwiftUI
import CoreData

// MARK: - Packing Template Models

struct PackingTemplate: Identifiable, Codable {
    let id = UUID()
    let name: String
    let description: String
    let tripType: TripType
    let duration: TripDuration
    let season: Season
    let items: [TemplateItem]
    let icon: String
    let color: String
    let isDefault: Bool
    
    init(name: String, description: String, tripType: TripType, duration: TripDuration, season: Season, items: [TemplateItem], icon: String, color: String, isDefault: Bool = true) {
        self.name = name
        self.description = description
        self.tripType = tripType
        self.duration = duration
        self.season = season
        self.items = items
        self.icon = icon
        self.color = color
        self.isDefault = isDefault
    }
}

struct TemplateItem: Identifiable, Codable {
    let id = UUID()
    let name: String
    let category: String
    let weight: Double
    let quantity: Int
    let isEssential: Bool
    let description: String?
    
    init(name: String, category: String, weight: Double = 0.1, quantity: Int = 1, isEssential: Bool = false, description: String? = nil) {
        self.name = name
        self.category = category
        self.weight = weight
        self.quantity = quantity
        self.isEssential = isEssential
        self.description = description
    }
}

enum TripType: String, CaseIterable, Codable {
    case business = "Business"
    case vacation = "Vacation"
    case camping = "Camping"
    case beach = "Beach"
    case city = "City Break"
    case adventure = "Adventure"
    case backpacking = "Backpacking"
    case weekend = "Weekend Getaway"
    
    var icon: String {
        switch self {
        case .business:
            return "briefcase.fill"
        case .vacation:
            return "airplane"
        case .camping:
            return "tent.fill"
        case .beach:
            return "sun.max.fill"
        case .city:
            return "building.2.fill"
        case .adventure:
            return "mountain.2.fill"
        case .backpacking:
            return "backpack.fill"
        case .weekend:
            return "car.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .business:
            return .blue
        case .vacation:
            return .orange
        case .camping:
            return .green
        case .beach:
            return .cyan
        case .city:
            return .purple
        case .adventure:
            return .red
        case .backpacking:
            return .brown
        case .weekend:
            return .pink
        }
    }
}

enum TripDuration: String, CaseIterable, Codable {
    case oneDay = "1 Day"
    case weekend = "2-3 Days"
    case shortTrip = "4-7 Days"
    case longTrip = "1-2 Weeks"
    case extended = "2+ Weeks"
    
    var dayRange: ClosedRange<Int> {
        switch self {
        case .oneDay:
            return 1...1
        case .weekend:
            return 2...3
        case .shortTrip:
            return 4...7
        case .longTrip:
            return 8...14
        case .extended:
            return 15...30
        }
    }
}

enum Season: String, CaseIterable, Codable {
    case spring = "Spring"
    case summer = "Summer"
    case autumn = "Autumn"
    case winter = "Winter"
    case allSeason = "All Seasons"
    
    var icon: String {
        switch self {
        case .spring:
            return "leaf.fill"
        case .summer:
            return "sun.max.fill"
        case .autumn:
            return "leaf.fill"
        case .winter:
            return "snowflake"
        case .allSeason:
            return "globe"
        }
    }
    
    var color: Color {
        switch self {
        case .spring:
            return .green
        case .summer:
            return .yellow
        case .autumn:
            return .orange
        case .winter:
            return .blue
        case .allSeason:
            return .gray
        }
    }
}

// MARK: - Template Manager

class PackingTemplateManager: ObservableObject {
    static let shared = PackingTemplateManager()
    
    @Published var templates: [PackingTemplate] = []
    
    private init() {
        loadDefaultTemplates()
    }
    
    private func loadDefaultTemplates() {
        templates = [
            // Business Trip Templates
            createBusinessWeekTemplate(),
            createBusinessWeekendTemplate(),
            
            // Vacation Templates
            createBeachVacationTemplate(),
            createCityBreakTemplate(),
            createWeekendGetawayTemplate(),
            
            // Adventure Templates
            createCampingTemplate(),
            createBackpackingTemplate(),
            createAdventureTemplate()
        ]
    }
    
    func getTemplates(for tripType: TripType? = nil, duration: TripDuration? = nil, season: Season? = nil) -> [PackingTemplate] {
        return templates.filter { template in
            if let tripType = tripType, template.tripType != tripType { return false }
            if let duration = duration, template.duration != duration { return false }
            if let season = season, template.season != season && template.season != .allSeason { return false }
            return true
        }
    }
    
    func applyTemplate(_ template: PackingTemplate, to bag: Bag, context: NSManagedObjectContext) {
        for templateItem in template.items {
            let newItem = Item(context: context)
            newItem.id = UUID()
            newItem.name = templateItem.name
            newItem.category = templateItem.category
            newItem.weight = templateItem.weight
            newItem.quantity = Int32(templateItem.quantity)
            newItem.itemDescription = templateItem.description
            newItem.isPacked = false
            newItem.bag = bag
        }
        
        // Update bag weight
        let totalWeight = template.items.reduce(0.0) { sum, item in
            sum + (item.weight * Double(item.quantity))
        }
        bag.currentWeight += totalWeight
        
        do {
            try context.save()
        } catch {
            print("Error applying template: \(error)")
        }
    }
}