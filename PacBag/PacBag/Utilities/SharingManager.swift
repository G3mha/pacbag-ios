import Foundation
import SwiftUI
import UniformTypeIdentifiers

class SharingManager: ObservableObject {
    static let shared = SharingManager()
    
    private init() {}
    
    // MARK: - Trip Export Functions
    
    func exportTrip(_ trip: Trip, format: ExportFormat) -> ExportItem {
        switch format {
        case .plainText:
            return ExportItem(
                content: generateTripPlainText(trip),
                fileName: "\(trip.name.replacingOccurrences(of: " ", with: "_"))_packing_list.txt",
                contentType: .plainText
            )
        case .markdown:
            return ExportItem(
                content: generateTripMarkdown(trip),
                fileName: "\(trip.name.replacingOccurrences(of: " ", with: "_"))_packing_list.md",
                contentType: UTType(filenameExtension: "md") ?? .plainText
            )
        case .richText:
            return ExportItem(
                content: generateTripRichText(trip),
                fileName: "\(trip.name.replacingOccurrences(of: " ", with: "_"))_packing_list.rtf",
                contentType: .rtf
            )
        }
    }
    
    func exportBag(_ bag: Bag, format: ExportFormat) -> ExportItem {
        switch format {
        case .plainText:
            return ExportItem(
                content: generateBagPlainText(bag),
                fileName: "\(bag.name.replacingOccurrences(of: " ", with: "_"))_items.txt",
                contentType: .plainText
            )
        case .markdown:
            return ExportItem(
                content: generateBagMarkdown(bag),
                fileName: "\(bag.name.replacingOccurrences(of: " ", with: "_"))_items.md",
                contentType: UTType(filenameExtension: "md") ?? .plainText
            )
        case .richText:
            return ExportItem(
                content: generateBagRichText(bag),
                fileName: "\(bag.name.replacingOccurrences(of: " ", with: "_"))_items.rtf",
                contentType: .rtf
            )
        }
    }
    
    // MARK: - Plain Text Generation
    
    private func generateTripPlainText(_ trip: Trip) -> String {
        var content = ""
        
        // Trip Header
        content += "🧳 \(trip.name.uppercased()) PACKING LIST\n"
        content += String(repeating: "=", count: trip.name.count + 25) + "\n\n"
        
        // Trip Details
        content += "📍 Destination: \(trip.destination)\n"
        content += "📅 Dates: \(trip.formattedDateRange)\n"
        content += "⏰ Duration: \(trip.duration) days\n"
        
        if let description = trip.tripDescription, !description.isEmpty {
            content += "📝 Description: \(description)\n"
        }
        
        content += "\n"
        
        // Trip Summary
        content += "📊 TRIP SUMMARY\n"
        content += "---------------\n"
        content += "Total Bags: \(trip.totalBags)\n"
        content += "Total Items: \(trip.totalItems)\n"
        content += "Packed Items: \(trip.packedItems)\n"
        content += "Progress: \(Int(trip.packingProgress * 100))%\n"
        content += "Total Weight: \(String(format: "%.1f", trip.totalWeight))kg\n\n"
        
        // Bags and Items
        if trip.bagsArray.isEmpty {
            content += "No bags created yet.\n"
        } else {
            content += "🎒 BAGS & ITEMS\n"
            content += "---------------\n\n"
            
            for (index, bag) in trip.bagsArray.enumerated() {
                content += "\(index + 1). \(bag.name.uppercased())\n"
                content += "   Weight: \(String(format: "%.1f", bag.totalWeight))/\(String(format: "%.1f", bag.maxWeight))kg\n"
                content += "   Progress: \(Int(bag.packingProgress * 100))% (\(bag.packedItemsCount)/\(bag.totalItemsCount) items)\n"
                
                if bag.itemsArray.isEmpty {
                    content += "   No items added yet.\n\n"
                } else {
                    content += "\n"
                    for item in bag.itemsArray.sorted(by: { $0.name < $1.name }) {
                        let checkbox = item.isPacked ? "✅" : "⬜"
                        content += "   \(checkbox) \(item.name)"
                        
                        if item.quantity > 1 {
                            content += " (×\(item.quantity))"
                        }
                        
                        content += " - \(String(format: "%.1f", item.totalWeight))kg"
                        
                        if let category = item.category, !category.isEmpty {
                            content += " [\(category)]"
                        }
                        
                        if let description = item.itemDescription, !description.isEmpty {
                            content += "\n     \(description)"
                        }
                        
                        content += "\n"
                    }
                    content += "\n"
                }
            }
        }
        
        // Footer
        content += "Generated by PacBag on \(DateFormatter.shortDateTime.string(from: Date()))\n"
        
        return content
    }
    
    // MARK: - Markdown Generation
    
    private func generateTripMarkdown(_ trip: Trip) -> String {
        var content = ""
        
        // Trip Header
        content += "# 🧳 \(trip.name) Packing List\n\n"
        
        // Trip Details
        content += "## Trip Details\n\n"
        content += "- **Destination:** \(trip.destination)\n"
        content += "- **Dates:** \(trip.formattedDateRange)\n"
        content += "- **Duration:** \(trip.duration) days\n"
        
        if let description = trip.tripDescription, !description.isEmpty {
            content += "- **Description:** \(description)\n"
        }
        
        content += "\n"
        
        // Trip Summary
        content += "## 📊 Trip Summary\n\n"
        content += "| Metric | Value |\n"
        content += "|--------|-------|\n"
        content += "| Total Bags | \(trip.totalBags) |\n"
        content += "| Total Items | \(trip.totalItems) |\n"
        content += "| Packed Items | \(trip.packedItems) |\n"
        content += "| Progress | \(Int(trip.packingProgress * 100))% |\n"
        content += "| Total Weight | \(String(format: "%.1f", trip.totalWeight))kg |\n\n"
        
        // Bags and Items
        if trip.bagsArray.isEmpty {
            content += "## 🎒 Bags\n\nNo bags created yet.\n\n"
        } else {
            content += "## 🎒 Bags & Items\n\n"
            
            for bag in trip.bagsArray {
                content += "### \(bag.name)\n\n"
                content += "**Weight:** \(String(format: "%.1f", bag.totalWeight))/\(String(format: "%.1f", bag.maxWeight))kg | "
                content += "**Progress:** \(Int(bag.packingProgress * 100))% (\(bag.packedItemsCount)/\(bag.totalItemsCount) items)\n\n"
                
                if bag.itemsArray.isEmpty {
                    content += "No items added yet.\n\n"
                } else {
                    for item in bag.itemsArray.sorted(by: { $0.name < $1.name }) {
                        let checkbox = item.isPacked ? "- [x]" : "- [ ]"
                        content += "\(checkbox) **\(item.name)**"
                        
                        if item.quantity > 1 {
                            content += " (×\(item.quantity))"
                        }
                        
                        content += " - *\(String(format: "%.1f", item.totalWeight))kg*"
                        
                        if let category = item.category, !category.isEmpty {
                            content += " `\(category)`"
                        }
                        
                        if let description = item.itemDescription, !description.isEmpty {
                            content += "\n  > \(description)"
                        }
                        
                        content += "\n"
                    }
                    content += "\n"
                }
            }
        }
        
        // Footer
        content += "---\n"
        content += "*Generated by PacBag on \(DateFormatter.shortDateTime.string(from: Date()))*\n"
        
        return content
    }
    
    // MARK: - Rich Text Generation
    
    private func generateTripRichText(_ trip: Trip) -> String {
        // For RTF, we'll use a simplified version that most apps can read
        var content = ""
        
        content += "{\\rtf1\\ansi\\deff0 {\\fonttbl {\\f0 Times New Roman;}}\\f0\\fs24\n"
        content += "\\b\\fs28 \\u129532? \(trip.name.uppercased()) PACKING LIST\\b0\\fs24\\par\n"
        content += "\\par\n"
        
        // Trip Details
        content += "\\b Destination:\\b0  \(trip.destination)\\par\n"
        content += "\\b Dates:\\b0  \(trip.formattedDateRange)\\par\n"
        content += "\\b Duration:\\b0  \(trip.duration) days\\par\n"
        
        if let description = trip.tripDescription, !description.isEmpty {
            content += "\\b Description:\\b0  \(description)\\par\n"
        }
        
        content += "\\par\n"
        
        // Summary
        content += "\\b TRIP SUMMARY\\b0\\par\n"
        content += "Total Bags: \(trip.totalBags)\\par\n"
        content += "Total Items: \(trip.totalItems)\\par\n"
        content += "Packed Items: \(trip.packedItems)\\par\n"
        content += "Progress: \(Int(trip.packingProgress * 100))%\\par\n"
        content += "Total Weight: \(String(format: "%.1f", trip.totalWeight))kg\\par\n"
        content += "\\par\n"
        
        // Bags
        if !trip.bagsArray.isEmpty {
            content += "\\b BAGS & ITEMS\\b0\\par\n"
            content += "\\par\n"
            
            for bag in trip.bagsArray {
                content += "\\b \(bag.name)\\b0\\par\n"
                content += "Weight: \(String(format: "%.1f", bag.totalWeight))/\(String(format: "%.1f", bag.maxWeight))kg\\par\n"
                content += "Progress: \(Int(bag.packingProgress * 100))%\\par\n"
                content += "\\par\n"
                
                for item in bag.itemsArray.sorted(by: { $0.name < $1.name }) {
                    let checkbox = item.isPacked ? "\\u9989?" : "\\u11036?"
                    content += "\(checkbox) \(item.name)"
                    
                    if item.quantity > 1 {
                        content += " (x\(item.quantity))"
                    }
                    
                    content += " - \(String(format: "%.1f", item.totalWeight))kg"
                    
                    if let category = item.category, !category.isEmpty {
                        content += " [\(category)]"
                    }
                    
                    content += "\\par\n"
                }
                content += "\\par\n"
            }
        }
        
        content += "\\par\n"
        content += "\\i Generated by PacBag on \(DateFormatter.shortDateTime.string(from: Date()))\\i0\\par\n"
        content += "}\n"
        
        return content
    }
    
    // MARK: - Bag-specific Generation Methods
    
    private func generateBagPlainText(_ bag: Bag) -> String {
        var content = ""
        
        content += "🎒 \(bag.name.uppercased()) ITEMS\n"
        content += String(repeating: "=", count: bag.name.count + 15) + "\n\n"
        
        if let trip = bag.trip {
            content += "Trip: \(trip.name) to \(trip.destination)\n"
            content += "Dates: \(trip.formattedDateRange)\n\n"
        }
        
        content += "📊 BAG SUMMARY\n"
        content += "Weight: \(String(format: "%.1f", bag.totalWeight))/\(String(format: "%.1f", bag.maxWeight))kg\n"
        content += "Items: \(bag.packedItemsCount)/\(bag.totalItemsCount) packed\n"
        content += "Progress: \(Int(bag.packingProgress * 100))%\n\n"
        
        if bag.itemsArray.isEmpty {
            content += "No items added yet.\n"
        } else {
            content += "📝 ITEMS LIST\n"
            content += "-------------\n\n"
            
            let groupedItems = Dictionary(grouping: bag.itemsArray) { item in
                item.category?.isEmpty == false ? item.category! : "Other"
            }
            
            for (category, items) in groupedItems.sorted(by: { $0.key < $1.key }) {
                content += "\(category.uppercased()):\n"
                
                for item in items.sorted(by: { $0.name < $1.name }) {
                    let checkbox = item.isPacked ? "✅" : "⬜"
                    content += "  \(checkbox) \(item.name)"
                    
                    if item.quantity > 1 {
                        content += " (×\(item.quantity))"
                    }
                    
                    content += " - \(String(format: "%.1f", item.totalWeight))kg"
                    
                    if let description = item.itemDescription, !description.isEmpty {
                        content += "\n      \(description)"
                    }
                    
                    content += "\n"
                }
                content += "\n"
            }
        }
        
        content += "Generated by PacBag on \(DateFormatter.shortDateTime.string(from: Date()))\n"
        
        return content
    }
    
    private func generateBagMarkdown(_ bag: Bag) -> String {
        var content = ""
        
        content += "# 🎒 \(bag.name) Items\n\n"
        
        if let trip = bag.trip {
            content += "**Trip:** \(trip.name) to \(trip.destination)  \n"
            content += "**Dates:** \(trip.formattedDateRange)\n\n"
        }
        
        content += "## 📊 Bag Summary\n\n"
        content += "- **Weight:** \(String(format: "%.1f", bag.totalWeight))/\(String(format: "%.1f", bag.maxWeight))kg\n"
        content += "- **Items:** \(bag.packedItemsCount)/\(bag.totalItemsCount) packed\n"
        content += "- **Progress:** \(Int(bag.packingProgress * 100))%\n\n"
        
        if bag.itemsArray.isEmpty {
            content += "## 📝 Items\n\nNo items added yet.\n\n"
        } else {
            content += "## 📝 Items\n\n"
            
            let groupedItems = Dictionary(grouping: bag.itemsArray) { item in
                item.category?.isEmpty == false ? item.category! : "Other"
            }
            
            for (category, items) in groupedItems.sorted(by: { $0.key < $1.key }) {
                content += "### \(category)\n\n"
                
                for item in items.sorted(by: { $0.name < $1.name }) {
                    let checkbox = item.isPacked ? "- [x]" : "- [ ]"
                    content += "\(checkbox) **\(item.name)**"
                    
                    if item.quantity > 1 {
                        content += " (×\(item.quantity))"
                    }
                    
                    content += " - *\(String(format: "%.1f", item.totalWeight))kg*"
                    
                    if let description = item.itemDescription, !description.isEmpty {
                        content += "\n  > \(description)"
                    }
                    
                    content += "\n"
                }
                content += "\n"
            }
        }
        
        content += "---\n"
        content += "*Generated by PacBag on \(DateFormatter.shortDateTime.string(from: Date()))*\n"
        
        return content
    }
    
    private func generateBagRichText(_ bag: Bag) -> String {
        // Simplified RTF for bag
        var content = ""
        
        content += "{\\rtf1\\ansi\\deff0 {\\fonttbl {\\f0 Times New Roman;}}\\f0\\fs24\n"
        content += "\\b\\fs28 \\u127890? \(bag.name.uppercased()) ITEMS\\b0\\fs24\\par\n"
        content += "\\par\n"
        
        if let trip = bag.trip {
            content += "\\b Trip:\\b0 \(trip.name) to \(trip.destination)\\par\n"
            content += "\\b Dates:\\b0 \(trip.formattedDateRange)\\par\n"
            content += "\\par\n"
        }
        
        content += "\\b BAG SUMMARY\\b0\\par\n"
        content += "Weight: \(String(format: "%.1f", bag.totalWeight))/\(String(format: "%.1f", bag.maxWeight))kg\\par\n"
        content += "Items: \(bag.packedItemsCount)/\(bag.totalItemsCount) packed\\par\n"
        content += "Progress: \(Int(bag.packingProgress * 100))%\\par\n"
        content += "\\par\n"
        
        if !bag.itemsArray.isEmpty {
            content += "\\b ITEMS\\b0\\par\n"
            content += "\\par\n"
            
            for item in bag.itemsArray.sorted(by: { $0.name < $1.name }) {
                let checkbox = item.isPacked ? "\\u9989?" : "\\u11036?"
                content += "\(checkbox) \(item.name)"
                
                if item.quantity > 1 {
                    content += " (x\(item.quantity))"
                }
                
                content += " - \(String(format: "%.1f", item.totalWeight))kg"
                
                if let category = item.category, !category.isEmpty {
                    content += " [\(category)]"
                }
                
                content += "\\par\n"
            }
        }
        
        content += "\\par\n"
        content += "\\i Generated by PacBag on \(DateFormatter.shortDateTime.string(from: Date()))\\i0\\par\n"
        content += "}\n"
        
        return content
    }
}

// MARK: - Supporting Types

struct ExportItem {
    let content: String
    let fileName: String
    let contentType: UTType
}

enum ExportFormat: String, CaseIterable {
    case plainText = "Plain Text"
    case markdown = "Markdown"
    case richText = "Rich Text"
    
    var systemImage: String {
        switch self {
        case .plainText:
            return "doc.text"
        case .markdown:
            return "doc.richtext"
        case .richText:
            return "doc.richtext.fill"
        }
    }
    
    var description: String {
        switch self {
        case .plainText:
            return "Simple text format, works everywhere"
        case .markdown:
            return "Formatted text with checkboxes and tables"
        case .richText:
            return "Rich formatted text with styling"
        }
    }
}

// MARK: - DateFormatter Extension

extension DateFormatter {
    static let shortDateTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
}