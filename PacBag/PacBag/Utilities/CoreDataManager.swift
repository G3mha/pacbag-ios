import CoreData
import CloudKit

class CoreDataManager {
    static let shared = CoreDataManager()
    
    private init() {}
    
    lazy var persistentContainer: NSPersistentCloudKitContainer = {
        let container = NSPersistentCloudKitContainer(name: "PacBagModel", managedObjectModel: managedObjectModel)
        
        // Configure for CloudKit
        let storeDescription = container.persistentStoreDescriptions.first
        storeDescription?.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        storeDescription?.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data error: \(error)")
            }
        }
        
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    private lazy var managedObjectModel: NSManagedObjectModel = {
        let model = NSManagedObjectModel()
        
        // Trip Entity
        let tripEntity = NSEntityDescription()
        tripEntity.name = "Trip"
        tripEntity.managedObjectClassName = "Trip"
        
        let tripName = NSAttributeDescription()
        tripName.name = "name"
        tripName.type = .string
        tripName.isOptional = false
        tripName.defaultValue = ""
        
        let tripStartDate = NSAttributeDescription()
        tripStartDate.name = "startDate"
        tripStartDate.type = .date
        tripStartDate.isOptional = false
        tripStartDate.defaultValue = Date()
        
        let tripEndDate = NSAttributeDescription()
        tripEndDate.name = "endDate"
        tripEndDate.type = .date
        tripEndDate.isOptional = false
        tripEndDate.defaultValue = Date()
        
        let tripDestination = NSAttributeDescription()
        tripDestination.name = "destination"
        tripDestination.type = .string
        tripDestination.isOptional = false
        tripDestination.defaultValue = ""
        
        tripEntity.properties = [tripName, tripStartDate, tripEndDate, tripDestination]
        
        // Bag Entity
        let bagEntity = NSEntityDescription()
        bagEntity.name = "Bag"
        bagEntity.managedObjectClassName = "Bag"
        
        let bagName = NSAttributeDescription()
        bagName.name = "name"
        bagName.type = .string
        bagName.isOptional = false
        bagName.defaultValue = ""
        
        let bagMaxWeight = NSAttributeDescription()
        bagMaxWeight.name = "maxWeight"
        bagMaxWeight.type = .double
        bagMaxWeight.isOptional = false
        bagMaxWeight.defaultValue = 0.0
        
        let bagCurrentWeight = NSAttributeDescription()
        bagCurrentWeight.name = "currentWeight"
        bagCurrentWeight.type = .double
        bagCurrentWeight.isOptional = false
        bagCurrentWeight.defaultValue = 0.0
        
        bagEntity.properties = [bagName, bagMaxWeight, bagCurrentWeight]
        
        // Item Entity
        let itemEntity = NSEntityDescription()
        itemEntity.name = "Item"
        itemEntity.managedObjectClassName = "Item"
        
        let itemId = NSAttributeDescription()
        itemId.name = "id"
        itemId.type = .uuid
        itemId.isOptional = false
        itemId.defaultValue = UUID()
        
        let itemName = NSAttributeDescription()
        itemName.name = "name"
        itemName.type = .string
        itemName.isOptional = false
        itemName.defaultValue = ""
        
        let itemWeight = NSAttributeDescription()
        itemWeight.name = "weight"
        itemWeight.type = .double
        itemWeight.isOptional = false
        itemWeight.defaultValue = 0.0
        
        let itemIsPacked = NSAttributeDescription()
        itemIsPacked.name = "isPacked"
        itemIsPacked.type = .boolean
        itemIsPacked.isOptional = false
        itemIsPacked.defaultValue = false
        
        let itemCategory = NSAttributeDescription()
        itemCategory.name = "category"
        itemCategory.type = .string
        itemCategory.isOptional = true
        
        itemEntity.properties = [itemId, itemName, itemWeight, itemIsPacked, itemCategory]
        
        // Relationships
        let tripToBags = NSRelationshipDescription()
        tripToBags.name = "bags"
        tripToBags.destinationEntity = bagEntity
        tripToBags.maxCount = 0  // 0 means to-many
        tripToBags.deleteRule = .cascadeDeleteRule
        
        let bagToTrip = NSRelationshipDescription()
        bagToTrip.name = "trip"
        bagToTrip.destinationEntity = tripEntity
        bagToTrip.maxCount = 1  // 1 means to-one
        bagToTrip.deleteRule = .nullifyDeleteRule
        
        tripToBags.inverseRelationship = bagToTrip
        bagToTrip.inverseRelationship = tripToBags
        
        let bagToItems = NSRelationshipDescription()
        bagToItems.name = "items"
        bagToItems.destinationEntity = itemEntity
        bagToItems.maxCount = 0  // 0 means to-many
        bagToItems.deleteRule = .cascadeDeleteRule
        
        let itemToBag = NSRelationshipDescription()
        itemToBag.name = "bag"
        itemToBag.destinationEntity = bagEntity
        itemToBag.maxCount = 1  // 1 means to-one
        itemToBag.deleteRule = .nullifyDeleteRule
        
        bagToItems.inverseRelationship = itemToBag
        itemToBag.inverseRelationship = bagToItems
        
        tripEntity.properties.append(tripToBags)
        bagEntity.properties.append(contentsOf: [bagToTrip, bagToItems])
        itemEntity.properties.append(itemToBag)
        
        model.entities = [tripEntity, bagEntity, itemEntity]
        
        return model
    }()
    
    func save() {
        if context.hasChanges {
            try? context.save()
        }
    }
}