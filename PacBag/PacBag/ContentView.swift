//
//  ContentView.swift
//  PacBag
//
//  Created by Enricco Gemha on 18/06/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.name, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>

    var body: some View {
        NavigationView {
            List {
                ForEach(items) { item in
                    NavigationLink {
                        VStack(alignment: .leading) {
                            Text("Item: \(item.name)")
                            Text("Weight: \(item.weight, specifier: "%.1f") kg")
                            Text("Packed: \(item.isPacked ? "Yes" : "No")")
                            if let category = item.category {
                                Text("Category: \(category)")
                            }
                        }
                    } label: {
                        HStack {
                            Text(item.name.isEmpty ? "Unnamed Item" : item.name)
                            Spacer()
                            Image(systemName: item.isPacked ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(item.isPacked ? .green : .gray)
                        }
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            .navigationTitle("PacBag Items")
            Text("Select an item")
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.id = UUID()
            newItem.name = "New Item"
            newItem.weight = 0.0
            newItem.isPacked = false
            newItem.category = "General"

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, CoreDataManager.shared.context)
}
