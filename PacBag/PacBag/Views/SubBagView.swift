import SwiftUI

enum SubBagType: String, CaseIterable {
    case toiletries = "Toiletries"
    case accessories = "Accessories"
    case electronics = "Electronics"
    case documents = "Documents"
    case medication = "Medication"
    case general = "General"
    
    var icon: String {
        switch self {
        case .toiletries:
            return "drop.fill"
        case .accessories:
            return "crown.fill"
        case .electronics:
            return "bolt.fill"
        case .documents:
            return "doc.fill"
        case .medication:
            return "cross.fill"
        case .general:
            return "bag.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .toiletries:
            return .blue
        case .accessories:
            return .purple
        case .electronics:
            return .orange
        case .documents:
            return .green
        case .medication:
            return .red
        case .general:
            return .gray
        }
    }
    
    var defaultWeight: Double {
        switch self {
        case .toiletries:
            return 2.0
        case .accessories:
            return 1.5
        case .electronics:
            return 3.0
        case .documents:
            return 0.5
        case .medication:
            return 0.3
        case .general:
            return 1.0
        }
    }
    
    static func fromName(_ name: String) -> SubBagType {
        return SubBagType.allCases.first { 
            name.lowercased().contains($0.rawValue.lowercased()) 
        } ?? .general
    }
}

struct SubBagDetailView: View {
    @ObservedObject var subBag: Bag
    
    var body: some View {
        BagDetailView(bag: subBag)
            .navigationTitle("\(subBag.name)")
            .navigationBarTitleDisplayMode(.inline)
    }
}
