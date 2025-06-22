import Foundation

// MARK: - Template Creation Functions

extension PackingTemplateManager {
    
    // MARK: - Business Templates
    
    func createBusinessWeekTemplate() -> PackingTemplate {
        let items = [
            // Clothes
            TemplateItem(name: "Dress Shirts", category: "Clothes", weight: 0.3, quantity: 5, isEssential: true),
            TemplateItem(name: "Business Suits", category: "Clothes", weight: 1.5, quantity: 2, isEssential: true),
            TemplateItem(name: "Dress Pants", category: "Clothes", weight: 0.8, quantity: 3, isEssential: true),
            TemplateItem(name: "Ties", category: "Accessories", weight: 0.1, quantity: 3),
            TemplateItem(name: "Underwear", category: "Clothes", weight: 0.1, quantity: 7, isEssential: true),
            TemplateItem(name: "Dress Socks", category: "Clothes", weight: 0.1, quantity: 7, isEssential: true),
            TemplateItem(name: "Dress Shoes", category: "Shoes", weight: 1.2, quantity: 2, isEssential: true),
            TemplateItem(name: "Belt", category: "Accessories", weight: 0.3, quantity: 1, isEssential: true),
            
            // Electronics
            TemplateItem(name: "Laptop", category: "Electronics", weight: 2.0, quantity: 1, isEssential: true),
            TemplateItem(name: "Laptop Charger", category: "Electronics", weight: 0.5, quantity: 1, isEssential: true),
            TemplateItem(name: "Phone Charger", category: "Electronics", weight: 0.2, quantity: 1, isEssential: true),
            TemplateItem(name: "Business Cards", category: "Documents", weight: 0.1, quantity: 1),
            
            // Toiletries
            TemplateItem(name: "Toothbrush", category: "Toiletries", weight: 0.1, quantity: 1, isEssential: true),
            TemplateItem(name: "Toothpaste", category: "Toiletries", weight: 0.2, quantity: 1, isEssential: true),
            TemplateItem(name: "Shampoo", category: "Toiletries", weight: 0.3, quantity: 1),
            TemplateItem(name: "Deodorant", category: "Toiletries", weight: 0.2, quantity: 1, isEssential: true),
            TemplateItem(name: "Razor", category: "Toiletries", weight: 0.1, quantity: 1),
            
            // Documents
            TemplateItem(name: "Passport/ID", category: "Documents", weight: 0.1, quantity: 1, isEssential: true),
            TemplateItem(name: "Flight Tickets", category: "Documents", weight: 0.1, quantity: 1, isEssential: true),
            TemplateItem(name: "Hotel Reservations", category: "Documents", weight: 0.1, quantity: 1, isEssential: true)
        ]
        
        return PackingTemplate(
            name: "Business Week",
            description: "5-7 day business trip with meetings and conferences",
            tripType: .business,
            duration: .shortTrip,
            season: .allSeason,
            items: items,
            icon: "briefcase.fill",
            color: "blue"
        )
    }
    
    func createBusinessWeekendTemplate() -> PackingTemplate {
        let items = [
            TemplateItem(name: "Dress Shirts", category: "Clothes", weight: 0.3, quantity: 2, isEssential: true),
            TemplateItem(name: "Business Suit", category: "Clothes", weight: 1.5, quantity: 1, isEssential: true),
            TemplateItem(name: "Dress Pants", category: "Clothes", weight: 0.8, quantity: 1, isEssential: true),
            TemplateItem(name: "Ties", category: "Accessories", weight: 0.1, quantity: 2),
            TemplateItem(name: "Underwear", category: "Clothes", weight: 0.1, quantity: 3, isEssential: true),
            TemplateItem(name: "Dress Socks", category: "Clothes", weight: 0.1, quantity: 3, isEssential: true),
            TemplateItem(name: "Dress Shoes", category: "Shoes", weight: 1.2, quantity: 1, isEssential: true),
            TemplateItem(name: "Laptop", category: "Electronics", weight: 2.0, quantity: 1, isEssential: true),
            TemplateItem(name: "Chargers", category: "Electronics", weight: 0.5, quantity: 1, isEssential: true),
            TemplateItem(name: "Toiletries Kit", category: "Toiletries", weight: 0.8, quantity: 1, isEssential: true),
            TemplateItem(name: "Documents", category: "Documents", weight: 0.2, quantity: 1, isEssential: true)
        ]
        
        return PackingTemplate(
            name: "Business Weekend",
            description: "Short business trip or conference weekend",
            tripType: .business,
            duration: .weekend,
            season: .allSeason,
            items: items,
            icon: "briefcase.fill",
            color: "blue"
        )
    }
    
    // MARK: - Vacation Templates
    
    func createBeachVacationTemplate() -> PackingTemplate {
        let items = [
            // Beach Essentials
            TemplateItem(name: "Swimwear", category: "Clothes", weight: 0.2, quantity: 2, isEssential: true),
            TemplateItem(name: "Beach Towel", category: "General", weight: 0.8, quantity: 1, isEssential: true),
            TemplateItem(name: "Sunscreen", category: "Toiletries", weight: 0.3, quantity: 1, isEssential: true),
            TemplateItem(name: "Sunglasses", category: "Accessories", weight: 0.1, quantity: 1, isEssential: true),
            TemplateItem(name: "Sun Hat", category: "Accessories", weight: 0.2, quantity: 1),
            TemplateItem(name: "Flip Flops", category: "Shoes", weight: 0.4, quantity: 1, isEssential: true),
            
            // Summer Clothes
            TemplateItem(name: "T-Shirts", category: "Clothes", weight: 0.2, quantity: 5),
            TemplateItem(name: "Shorts", category: "Clothes", weight: 0.3, quantity: 3, isEssential: true),
            TemplateItem(name: "Summer Dress", category: "Clothes", weight: 0.4, quantity: 2),
            TemplateItem(name: "Light Jacket", category: "Clothes", weight: 0.6, quantity: 1),
            TemplateItem(name: "Underwear", category: "Clothes", weight: 0.1, quantity: 7, isEssential: true),
            
            // Electronics
            TemplateItem(name: "Camera", category: "Electronics", weight: 0.8, quantity: 1),
            TemplateItem(name: "Phone Charger", category: "Electronics", weight: 0.2, quantity: 1, isEssential: true),
            TemplateItem(name: "Waterproof Phone Case", category: "Electronics", weight: 0.1, quantity: 1),
            
            // Toiletries
            TemplateItem(name: "Toiletries Kit", category: "Toiletries", weight: 1.0, quantity: 1, isEssential: true),
            TemplateItem(name: "After-sun Lotion", category: "Toiletries", weight: 0.3, quantity: 1),
            
            // Documents
            TemplateItem(name: "Passport", category: "Documents", weight: 0.1, quantity: 1, isEssential: true),
            TemplateItem(name: "Travel Insurance", category: "Documents", weight: 0.1, quantity: 1, isEssential: true)
        ]
        
        return PackingTemplate(
            name: "Beach Vacation",
            description: "Relaxing beach holiday with sun, sand, and sea",
            tripType: .beach,
            duration: .longTrip,
            season: .summer,
            items: items,
            icon: "sun.max.fill",
            color: "cyan"
        )
    }
    
    func createCityBreakTemplate() -> PackingTemplate {
        let items = [
            // Comfortable Clothes
            TemplateItem(name: "Jeans", category: "Clothes", weight: 0.8, quantity: 2, isEssential: true),
            TemplateItem(name: "T-Shirts", category: "Clothes", weight: 0.2, quantity: 4),
            TemplateItem(name: "Sweater", category: "Clothes", weight: 0.6, quantity: 1),
            TemplateItem(name: "Light Jacket", category: "Clothes", weight: 0.8, quantity: 1, isEssential: true),
            TemplateItem(name: "Comfortable Shoes", category: "Shoes", weight: 0.8, quantity: 1, isEssential: true),
            TemplateItem(name: "Dressy Outfit", category: "Clothes", weight: 1.0, quantity: 1),
            TemplateItem(name: "Underwear", category: "Clothes", weight: 0.1, quantity: 5, isEssential: true),
            
            // City Exploration
            TemplateItem(name: "Daypack", category: "General", weight: 0.5, quantity: 1, isEssential: true),
            TemplateItem(name: "Camera", category: "Electronics", weight: 0.8, quantity: 1),
            TemplateItem(name: "Portable Charger", category: "Electronics", weight: 0.3, quantity: 1, isEssential: true),
            TemplateItem(name: "City Guide/Map", category: "Documents", weight: 0.2, quantity: 1),
            TemplateItem(name: "Umbrella", category: "General", weight: 0.4, quantity: 1),
            
            // Electronics
            TemplateItem(name: "Phone Charger", category: "Electronics", weight: 0.2, quantity: 1, isEssential: true),
            TemplateItem(name: "Adapter", category: "Electronics", weight: 0.2, quantity: 1),
            
            // Toiletries
            TemplateItem(name: "Toiletries Kit", category: "Toiletries", weight: 0.8, quantity: 1, isEssential: true),
            
            // Documents
            TemplateItem(name: "ID/Passport", category: "Documents", weight: 0.1, quantity: 1, isEssential: true),
            TemplateItem(name: "Tickets/Reservations", category: "Documents", weight: 0.1, quantity: 1, isEssential: true)
        ]
        
        return PackingTemplate(
            name: "City Break",
            description: "Urban exploration with museums, restaurants, and sightseeing",
            tripType: .city,
            duration: .shortTrip,
            season: .allSeason,
            items: items,
            icon: "building.2.fill",
            color: "purple"
        )
    }
    
    func createWeekendGetawayTemplate() -> PackingTemplate {
        let items = [
            TemplateItem(name: "Casual Clothes", category: "Clothes", weight: 0.4, quantity: 3, isEssential: true),
            TemplateItem(name: "Comfortable Shoes", category: "Shoes", weight: 0.8, quantity: 1, isEssential: true),
            TemplateItem(name: "Light Jacket", category: "Clothes", weight: 0.6, quantity: 1),
            TemplateItem(name: "Underwear", category: "Clothes", weight: 0.1, quantity: 3, isEssential: true),
            TemplateItem(name: "Sleepwear", category: "Clothes", weight: 0.3, quantity: 1, isEssential: true),
            TemplateItem(name: "Phone Charger", category: "Electronics", weight: 0.2, quantity: 1, isEssential: true),
            TemplateItem(name: "Toiletries Kit", category: "Toiletries", weight: 0.6, quantity: 1, isEssential: true),
            TemplateItem(name: "Sunglasses", category: "Accessories", weight: 0.1, quantity: 1),
            TemplateItem(name: "Documents", category: "Documents", weight: 0.1, quantity: 1, isEssential: true)
        ]
        
        return PackingTemplate(
            name: "Weekend Getaway",
            description: "Quick 2-3 day relaxing trip",
            tripType: .weekend,
            duration: .weekend,
            season: .allSeason,
            items: items,
            icon: "car.fill",
            color: "pink"
        )
    }
    
    // MARK: - Adventure Templates
    
    func createCampingTemplate() -> PackingTemplate {
        let items = [
            // Camping Gear
            TemplateItem(name: "Tent", category: "General", weight: 3.0, quantity: 1, isEssential: true),
            TemplateItem(name: "Sleeping Bag", category: "General", weight: 2.0, quantity: 1, isEssential: true),
            TemplateItem(name: "Sleeping Pad", category: "General", weight: 1.0, quantity: 1, isEssential: true),
            TemplateItem(name: "Camping Pillow", category: "General", weight: 0.3, quantity: 1),
            TemplateItem(name: "Headlamp", category: "Electronics", weight: 0.2, quantity: 1, isEssential: true),
            TemplateItem(name: "Flashlight", category: "Electronics", weight: 0.3, quantity: 1),
            TemplateItem(name: "First Aid Kit", category: "Medication", weight: 0.5, quantity: 1, isEssential: true),
            
            // Outdoor Clothes
            TemplateItem(name: "Hiking Boots", category: "Shoes", weight: 1.5, quantity: 1, isEssential: true),
            TemplateItem(name: "Rain Jacket", category: "Clothes", weight: 0.8, quantity: 1, isEssential: true),
            TemplateItem(name: "Hiking Pants", category: "Clothes", weight: 0.6, quantity: 2, isEssential: true),
            TemplateItem(name: "Quick-dry Shirts", category: "Clothes", weight: 0.3, quantity: 3, isEssential: true),
            TemplateItem(name: "Warm Layer", category: "Clothes", weight: 0.8, quantity: 1, isEssential: true),
            TemplateItem(name: "Hat", category: "Accessories", weight: 0.1, quantity: 1),
            TemplateItem(name: "Underwear", category: "Clothes", weight: 0.1, quantity: 5, isEssential: true),
            TemplateItem(name: "Hiking Socks", category: "Clothes", weight: 0.1, quantity: 5, isEssential: true),
            
            // Cooking & Food
            TemplateItem(name: "Camping Stove", category: "General", weight: 1.2, quantity: 1, isEssential: true),
            TemplateItem(name: "Fuel Canister", category: "General", weight: 0.5, quantity: 2, isEssential: true),
            TemplateItem(name: "Cookware Set", category: "General", weight: 1.0, quantity: 1, isEssential: true),
            TemplateItem(name: "Water Bottles", category: "General", weight: 0.5, quantity: 2, isEssential: true),
            TemplateItem(name: "Water Filter", category: "General", weight: 0.4, quantity: 1),
            
            // Other Essentials
            TemplateItem(name: "Multi-tool", category: "General", weight: 0.3, quantity: 1, isEssential: true),
            TemplateItem(name: "Rope/Paracord", category: "General", weight: 0.5, quantity: 1),
            TemplateItem(name: "Insect Repellent", category: "Toiletries", weight: 0.2, quantity: 1, isEssential: true),
            TemplateItem(name: "Sunscreen", category: "Toiletries", weight: 0.3, quantity: 1, isEssential: true),
            TemplateItem(name: "Toiletries Kit", category: "Toiletries", weight: 0.8, quantity: 1, isEssential: true)
        ]
        
        return PackingTemplate(
            name: "Camping Adventure",
            description: "Multi-day camping trip with outdoor activities",
            tripType: .camping,
            duration: .shortTrip,
            season: .allSeason,
            items: items,
            icon: "tent.fill",
            color: "green"
        )
    }
    
    func createBackpackingTemplate() -> PackingTemplate {
        let items = [
            // Backpacking Essentials
            TemplateItem(name: "Backpack (60L+)", category: "General", weight: 2.5, quantity: 1, isEssential: true),
            TemplateItem(name: "Lightweight Tent", category: "General", weight: 2.0, quantity: 1, isEssential: true),
            TemplateItem(name: "Ultralight Sleeping Bag", category: "General", weight: 1.5, quantity: 1, isEssential: true),
            TemplateItem(name: "Sleeping Pad", category: "General", weight: 0.8, quantity: 1, isEssential: true),
            TemplateItem(name: "Trekking Poles", category: "General", weight: 1.0, quantity: 1),
            
            // Minimal Clothing
            TemplateItem(name: "Hiking Boots", category: "Shoes", weight: 1.5, quantity: 1, isEssential: true),
            TemplateItem(name: "Merino Wool Shirts", category: "Clothes", weight: 0.3, quantity: 2, isEssential: true),
            TemplateItem(name: "Hiking Pants", category: "Clothes", weight: 0.6, quantity: 1, isEssential: true),
            TemplateItem(name: "Rain Gear", category: "Clothes", weight: 0.8, quantity: 1, isEssential: true),
            TemplateItem(name: "Insulation Layer", category: "Clothes", weight: 0.8, quantity: 1, isEssential: true),
            TemplateItem(name: "Underwear", category: "Clothes", weight: 0.1, quantity: 3, isEssential: true),
            TemplateItem(name: "Hiking Socks", category: "Clothes", weight: 0.1, quantity: 3, isEssential: true),
            
            // Lightweight Gear
            TemplateItem(name: "Lightweight Stove", category: "General", weight: 0.5, quantity: 1, isEssential: true),
            TemplateItem(name: "Titanium Cookware", category: "General", weight: 0.4, quantity: 1, isEssential: true),
            TemplateItem(name: "Water Filter", category: "General", weight: 0.4, quantity: 1, isEssential: true),
            TemplateItem(name: "Headlamp", category: "Electronics", weight: 0.2, quantity: 1, isEssential: true),
            TemplateItem(name: "First Aid Kit", category: "Medication", weight: 0.3, quantity: 1, isEssential: true),
            TemplateItem(name: "Multi-tool", category: "General", weight: 0.2, quantity: 1, isEssential: true),
            TemplateItem(name: "Minimal Toiletries", category: "Toiletries", weight: 0.3, quantity: 1, isEssential: true)
        ]
        
        return PackingTemplate(
            name: "Backpacking",
            description: "Lightweight multi-day hiking and camping",
            tripType: .backpacking,
            duration: .longTrip,
            season: .allSeason,
            items: items,
            icon: "backpack.fill",
            color: "brown"
        )
    }
    
    func createAdventureTemplate() -> PackingTemplate {
        let items = [
            // Adventure Gear
            TemplateItem(name: "Adventure Backpack", category: "General", weight: 2.0, quantity: 1, isEssential: true),
            TemplateItem(name: "Climbing Helmet", category: "General", weight: 0.8, quantity: 1),
            TemplateItem(name: "Harness", category: "General", weight: 0.5, quantity: 1),
            TemplateItem(name: "Carabiners", category: "General", weight: 0.2, quantity: 5),
            TemplateItem(name: "Action Camera", category: "Electronics", weight: 0.3, quantity: 1),
            
            // Outdoor Clothing
            TemplateItem(name: "Adventure Boots", category: "Shoes", weight: 1.8, quantity: 1, isEssential: true),
            TemplateItem(name: "Technical Pants", category: "Clothes", weight: 0.8, quantity: 2, isEssential: true),
            TemplateItem(name: "Performance Shirts", category: "Clothes", weight: 0.3, quantity: 3, isEssential: true),
            TemplateItem(name: "Hardshell Jacket", category: "Clothes", weight: 1.0, quantity: 1, isEssential: true),
            TemplateItem(name: "Insulated Jacket", category: "Clothes", weight: 1.2, quantity: 1, isEssential: true),
            TemplateItem(name: "Gloves", category: "Accessories", weight: 0.2, quantity: 1, isEssential: true),
            TemplateItem(name: "Adventure Hat", category: "Accessories", weight: 0.1, quantity: 1),
            TemplateItem(name: "Underwear", category: "Clothes", weight: 0.1, quantity: 5, isEssential: true),
            TemplateItem(name: "Technical Socks", category: "Clothes", weight: 0.1, quantity: 5, isEssential: true),
            
            // Safety & Navigation
            TemplateItem(name: "GPS Device", category: "Electronics", weight: 0.4, quantity: 1),
            TemplateItem(name: "Emergency Whistle", category: "General", weight: 0.1, quantity: 1, isEssential: true),
            TemplateItem(name: "First Aid Kit", category: "Medication", weight: 0.8, quantity: 1, isEssential: true),
            TemplateItem(name: "Headlamp", category: "Electronics", weight: 0.2, quantity: 1, isEssential: true),
            TemplateItem(name: "Backup Flashlight", category: "Electronics", weight: 0.3, quantity: 1),
            TemplateItem(name: "Multi-tool", category: "General", weight: 0.4, quantity: 1, isEssential: true),
            
            // Essentials
            TemplateItem(name: "Water Bottles", category: "General", weight: 0.5, quantity: 2, isEssential: true),
            TemplateItem(name: "Energy Food", category: "General", weight: 1.0, quantity: 1, isEssential: true),
            TemplateItem(name: "Sunscreen", category: "Toiletries", weight: 0.3, quantity: 1, isEssential: true),
            TemplateItem(name: "Toiletries Kit", category: "Toiletries", weight: 0.5, quantity: 1, isEssential: true)
        ]
        
        return PackingTemplate(
            name: "Adventure Sports",
            description: "Multi-activity adventure with climbing, hiking, and outdoor sports",
            tripType: .adventure,
            duration: .longTrip,
            season: .allSeason,
            items: items,
            icon: "mountain.2.fill",
            color: "red"
        )
    }
}