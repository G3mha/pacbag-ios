import SwiftUI
import CoreData

struct SubBagView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var parentBag: Bag
    
    @State private var showingAddSubBag = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Sub-bags")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button("Add Sub-bag") {
                    showingAddSubBag = true
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
            }
            
            if parentBag.subBagsArray.isEmpty {
                EmptySubBagsView()
            } else {
                LazyVGrid(columns: [
                    GridItem(.adaptive(minimum: 140), spacing: 12)
                ], spacing: 12) {
                    ForEach(parentBag.subBagsArray) { subBag in
                        NavigationLink(destination: SubBagDetailView(subBag: subBag)) {
                            SubBagCardView(subBag: subBag)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddSubBag) {
            AddSubBagView(parentBag: parentBag)
        }
    }
}

struct SubBagCardView: View {
    @ObservedObject var subBag: Bag
    
    var body: some View {
        VStack(spacing: 8) {
            // Sub-bag icon and visual representation
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(subBagColor.opacity(0.2))
                    .frame(height: 70)
                
                VStack(spacing: 4) {
                    Image(systemName: subBagIcon)
                        .font(.title2)
                        .foregroundColor(subBagColor)
                    
                    if subBag.totalItemsCount > 0 {
                        ProgressView(value: subBag.weightUtilization)
                            .progressViewStyle(LinearProgressViewStyle(tint: progressColor))
                            .frame(width: 60)
                    }
                }
            }
            
            VStack(spacing: 2) {
                Text(subBag.name.isEmpty ? "Unnamed Sub-bag" : subBag.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                
                HStack(spacing: 4) {
                    Label("\(subBag.packedItemsCount)/\(subBag.totalItemsCount)", systemImage: "checkmark.circle")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .labelStyle(.iconOnly)
                    
                    Text("\(subBag.packedItemsCount)/\(subBag.totalItemsCount)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(8)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private var subBagColor: Color {
        switch subBagType {
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
        default:
            return .gray
        }
    }
    
    private var progressColor: Color {
        switch subBag.weightUtilization {
        case 0.0..<0.7:
            return .green
        case 0.7..<0.9:
            return .orange
        default:
            return .red
        }
    }
    
    private var subBagIcon: String {
        switch subBagType {
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
        default:
            return "bag.fill"
        }
    }
    
    private var subBagType: SubBagType {
        return SubBagType.fromName(subBag.name)
    }
}

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

struct EmptySubBagsView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "bag.badge.plus")
                .font(.system(size: 30))
                .foregroundColor(.gray)
            
            Text("No sub-bags yet")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Add smaller bags for better organization")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
        .background(Color(.systemGray6))
        .cornerRadius(12)
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

#Preview {
    SubBagView(parentBag: {
        let context = CoreDataManager.shared.context
        let bag = Bag(context: context)
        bag.id = UUID()
        bag.name = "Carry-on"
        bag.maxWeight = 10.0
        bag.currentWeight = 3.0
        return bag
    }())
    .environment(\.managedObjectContext, CoreDataManager.shared.context)
}