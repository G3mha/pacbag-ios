import Foundation
import SwiftUI
import CoreData

// MARK: - Packing Template Models

struct PackingTemplate: Identifiable, Codable {
    let id: UUID
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
        self.id = UUID()
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
    let id: UUID
    let name: String
    let category: String
    let weight: Double
    let quantity: Int
    let isEssential: Bool
    let description: String?
    
    init(name: String, category: String, weight: Double = 0.1, quantity: Int = 1, isEssential: Bool = false, description: String? = nil) {
        self.id = UUID()
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
    @Published var customTemplates: [PackingTemplate] = []
    
    private let userDefaults = UserDefaults.standard
    private let customTemplatesKey = "CustomPackingTemplates"
    
    private init() {
        loadDefaultTemplates()
        loadCustomTemplates()
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
    
    // MARK: - Custom Template Management
    
    private func loadCustomTemplates() {
        if let data = userDefaults.data(forKey: customTemplatesKey),
           let decoded = try? JSONDecoder().decode([PackingTemplate].self, from: data) {
            customTemplates = decoded
        }
    }
    
    private func saveCustomTemplates() {
        if let encoded = try? JSONEncoder().encode(customTemplates) {
            userDefaults.set(encoded, forKey: customTemplatesKey)
        }
    }
    
    func createCustomTemplate(from trip: Trip) -> PackingTemplate? {
        guard !trip.bagsArray.isEmpty else { return nil }
        
        var allItems: [TemplateItem] = []
        
        // Collect all items from all bags in the trip
        for bag in trip.bagsArray {
            let bagItems = collectItemsRecursively(from: bag)
            allItems.append(contentsOf: bagItems)
        }
        
        guard !allItems.isEmpty else { return nil }
        
        // Determine trip characteristics
        let tripType = determineTripType(from: trip)
        let duration = determineDuration(from: trip)
        let season = determineSeason(from: trip)
        
        return PackingTemplate(
            name: "\(trip.name) Template",
            description: "Custom template based on \(trip.name)",
            tripType: tripType,
            duration: duration,
            season: season,
            items: allItems,
            icon: tripType.icon,
            color: tripType.color.description,
            isDefault: false
        )
    }
    
    func createCustomTemplate(from bag: Bag, name: String, description: String, tripType: TripType, duration: TripDuration, season: Season) -> PackingTemplate {
        let items = collectItemsRecursively(from: bag)
        
        return PackingTemplate(
            name: name,
            description: description,
            tripType: tripType,
            duration: duration,
            season: season,
            items: items,
            icon: tripType.icon,
            color: tripType.color.description,
            isDefault: false
        )
    }
    
    private func collectItemsRecursively(from bag: Bag) -> [TemplateItem] {
        var items: [TemplateItem] = []
        
        // Add items from this bag
        for item in bag.itemsArray {
            let templateItem = TemplateItem(
                name: item.name,
                category: item.fullCategory,
                weight: item.weight,
                quantity: Int(item.quantity),
                isEssential: item.isPacked, // Use packed status as "essential" indicator
                description: item.itemDescription
            )
            items.append(templateItem)
        }
        
        // Recursively add items from sub-bags
        for subBag in bag.subBagsArray {
            items.append(contentsOf: collectItemsRecursively(from: subBag))
        }
        
        return items
    }
    
    private func determineTripType(from trip: Trip) -> TripType {
        // Simple heuristic based on trip name and destination
        let tripName = trip.name.lowercased()
        let destination = trip.destination.lowercased()
        
        if tripName.contains("business") || tripName.contains("work") || tripName.contains("conference") {
            return .business
        } else if tripName.contains("camping") || destination.contains("camp") {
            return .camping
        } else if tripName.contains("beach") || destination.contains("beach") || destination.contains("hawaii") {
            return .beach
        } else if tripName.contains("city") || destination.contains("city") {
            return .city
        } else if tripName.contains("adventure") || tripName.contains("hiking") || tripName.contains("climb") {
            return .adventure
        } else if tripName.contains("backpack") {
            return .backpacking
        } else {
            return .vacation
        }
    }
    
    private func determineDuration(from trip: Trip) -> TripDuration {
        let startDate = trip.startDate
        let endDate = trip.endDate
        
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: startDate, to: endDate).day ?? 1
        
        switch days {
        case 1:
            return .oneDay
        case 2...3:
            return .weekend
        case 4...7:
            return .shortTrip
        case 8...14:
            return .longTrip
        default:
            return .extended
        }
    }
    
    private func determineSeason(from trip: Trip) -> Season {
        let startDate = trip.startDate
        
        let calendar = Calendar.current
        let month = calendar.component(.month, from: startDate)
        
        switch month {
        case 3...5:
            return .spring
        case 6...8:
            return .summer
        case 9...11:
            return .autumn
        case 12, 1, 2:
            return .winter
        default:
            return .allSeason
        }
    }
    
    func saveCustomTemplate(_ template: PackingTemplate) {
        customTemplates.append(template)
        saveCustomTemplates()
    }
    
    func updateCustomTemplate(_ template: PackingTemplate) {
        if let index = customTemplates.firstIndex(where: { $0.id == template.id }) {
            customTemplates[index] = template
            saveCustomTemplates()
        }
    }
    
    func deleteCustomTemplate(_ template: PackingTemplate) {
        customTemplates.removeAll { $0.id == template.id }
        saveCustomTemplates()
    }
    
    func getAllTemplates() -> [PackingTemplate] {
        return templates + customTemplates
    }
    
    func getTemplates(for tripType: TripType? = nil, duration: TripDuration? = nil, season: Season? = nil) -> [PackingTemplate] {
        return getAllTemplates().filter { template in
            if let tripType = tripType, template.tripType != tripType { return false }
            if let duration = duration, template.duration != duration { return false }
            if let season = season, template.season != season && template.season != .allSeason { return false }
            return true
        }
    }
    
    func exportTemplate(_ template: PackingTemplate) -> Data? {
        return try? JSONEncoder().encode(template)
    }
    
    func importTemplate(from data: Data) -> PackingTemplate? {
        return try? JSONDecoder().decode(PackingTemplate.self, from: data)
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