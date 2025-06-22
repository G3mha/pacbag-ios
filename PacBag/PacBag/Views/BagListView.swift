import SwiftUI
import CoreData

struct BagListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Bag.name, ascending: true)],
        predicate: NSPredicate(format: "parentBag == nil"),
        animation: .default)
    private var bags: FetchedResults<Bag>
    
    @State private var showingAddBag = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.adaptive(minimum: 160), spacing: 16)
                ], spacing: 16) {
                    ForEach(bags) { bag in
                        NavigationLink(destination: BagDetailView(bag: bag)) {
                            BagCardView(bag: bag)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    // Add new bag button
                    Button(action: { showingAddBag = true }) {
                        AddBagCardView()
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding()
            }
            .navigationTitle("My Bags")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddBag = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddBag) {
                AddBagView()
            }
        }
    }
}

struct BagCardView: View {
    let bag: Bag
    
    private var packingProgress: Double {
        guard bag.totalItemsCount > 0 else { return 0 }
        return Double(bag.packedItemsCount) / Double(bag.totalItemsCount)
    }
    
    private var packingProgressColor: Color {
        switch packingProgress {
        case 0.0:
            return .gray
        case 0.0..<0.5:
            return .red
        case 0.5..<0.8:
            return .orange
        case 0.8..<1.0:
            return .blue
        case 1.0:
            return .green
        default:
            return .gray
        }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Bag Icon and Visual Representation
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(bagColor.opacity(0.2))
                    .frame(height: 100)
                
                VStack(spacing: 8) {
                    Image(systemName: bagIcon)
                        .font(.largeTitle)
                        .foregroundColor(bagColor)
                    
                    // Simple progress indicator
                    VStack(spacing: 4) {
                        Text("\(Int(packingProgress * 100))%")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(packingProgressColor)
                        
                        ProgressView(value: packingProgress)
                            .progressViewStyle(LinearProgressViewStyle(tint: packingProgressColor))
                            .frame(width: 80)
                    }
                }
            }
            
            VStack(spacing: 4) {
                Text(bag.name.isEmpty ? "Unnamed Bag" : bag.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    Label("\(bag.packedItemsCount)/\(bag.totalItemsCount)", systemImage: "checkmark.circle")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Label("\(bag.totalWeight, specifier: "%.1f")kg", systemImage: "scalemass")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if bag.totalSubBagsCount > 0 {
                    Text("\(bag.totalSubBagsCount) sub-bags")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    private var bagColor: Color {
        switch bag.weightUtilization {
        case 0.0..<0.3:
            return .green
        case 0.3..<0.7:
            return .orange
        case 0.7..<0.9:
            return .red
        default:
            return .purple
        }
    }
    
    private var progressColor: Color {
        switch bag.weightUtilization {
        case 0.0..<0.7:
            return .green
        case 0.7..<0.9:
            return .orange
        default:
            return .red
        }
    }
    
    private var bagIcon: String {
        switch bag.weightUtilization {
        case 0.0..<0.3:
            return "suitcase"
        case 0.3..<0.7:
            return "suitcase.fill"
        default:
            return "suitcase.rolling.fill"
        }
    }
}

struct AddBagCardView: View {
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.blue.opacity(0.2))
                    .frame(height: 100)
                
                VStack {
                    Image(systemName: "plus.circle.fill")
                        .font(.largeTitle)
                        .foregroundColor(.blue)
                    
                    Text("Add Bag")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            
            Text("New Bag")
                .font(.headline)
                .foregroundColor(.blue)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.blue.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [5]))
        )
    }
}

#Preview {
    BagListView()
        .environment(\.managedObjectContext, CoreDataManager.shared.context)
}