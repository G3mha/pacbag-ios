//
//  Persistence.swift
//  PacBag
//
//  Created by Enricco Gemha on 18/06/25.
//

import CoreData

// Legacy file - now using CoreDataManager.swift instead
// This file can be deleted or kept for reference

struct PersistenceController {
    static let shared = PersistenceController()

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for i in 0..<5 {
            let newItem = Item(context: viewContext)
            newItem.id = UUID()
            newItem.name = "Sample Item \(i + 1)"
            newItem.weight = Double.random(in: 0.1...2.0)
            newItem.quantity = Int32.random(in: 1...3)
            newItem.isPacked = i % 2 == 0
            newItem.category = ["Clothes", "Electronics", "Toiletries", "Documents"].randomElement()
        }
        do {
            try viewContext.save()
        } catch {
            print("Failed to save context: \(error)")
            fatalError("Unresolved error \(error)")
        }
        return result
    }()

    let container: NSPersistentCloudKitContainer

    init(inMemory: Bool = false) {
        // Use CoreDataManager's model instead
        container = NSPersistentCloudKitContainer(name: "PacBagModel", managedObjectModel: CoreDataManager.shared.persistentContainer.managedObjectModel)
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
