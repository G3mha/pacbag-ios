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
        
        // Explicitly set CloudKit container
        storeDescription?.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(
            containerIdentifier: "iCloud.enriccogemha.PacBag"
        )
        
        container.loadPersistentStores { storeDescription, error in
            if let error = error {
                fatalError("Core Data error: \(error)")
            }
            print("✅ Core Data loaded successfully")
            print("📱 Store URL: \(storeDescription.url?.absoluteString ?? "Unknown")")
            print("☁️ CloudKit enabled: \(storeDescription.cloudKitContainerOptions != nil)")
        }
        
        // Enable CloudKit sync debugging
        container.viewContext.automaticallyMergesChangesFromParent = true
        
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
        
        let tripId = NSAttributeDescription()
        tripId.name = "id"
        tripId.type = .uuid
        tripId.isOptional = false
        tripId.defaultValue = UUID()
        
        let tripDescription = NSAttributeDescription()
        tripDescription.name = "tripDescription"
        tripDescription.type = .string
        tripDescription.isOptional = true
        
        let tripIsCompleted = NSAttributeDescription()
        tripIsCompleted.name = "isCompleted"
        tripIsCompleted.type = .boolean
        tripIsCompleted.isOptional = false
        tripIsCompleted.defaultValue = false
        
        let tripRemindersEnabled = NSAttributeDescription()
        tripRemindersEnabled.name = "remindersEnabled"
        tripRemindersEnabled.type = .boolean
        tripRemindersEnabled.isOptional = false
        tripRemindersEnabled.defaultValue = true
        
        tripEntity.properties = [tripId, tripName, tripStartDate, tripEndDate, tripDestination, tripDescription, tripIsCompleted, tripRemindersEnabled]
        
        // Bag Entity
        let bagEntity = NSEntityDescription()
        bagEntity.name = "Bag"
        bagEntity.managedObjectClassName = "Bag"
        
        let bagId = NSAttributeDescription()
        bagId.name = "id"
        bagId.type = .uuid
        bagId.isOptional = false
        bagId.defaultValue = UUID()
        
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
        
        bagEntity.properties = [bagId, bagName, bagMaxWeight, bagCurrentWeight]
        
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
        
        let itemSubcategory = NSAttributeDescription()
        itemSubcategory.name = "subcategory"
        itemSubcategory.type = .string
        itemSubcategory.isOptional = true
        
        let itemDescription = NSAttributeDescription()
        itemDescription.name = "itemDescription"
        itemDescription.type = .string
        itemDescription.isOptional = true
        
        let itemQuantity = NSAttributeDescription()
        itemQuantity.name = "quantity"
        itemQuantity.type = .integer32
        itemQuantity.isOptional = false
        itemQuantity.defaultValue = 1
        
        let itemPhotoData = NSAttributeDescription()
        itemPhotoData.name = "photoData"
        itemPhotoData.type = .binaryData
        itemPhotoData.isOptional = true
        itemPhotoData.allowsExternalBinaryDataStorage = true
        
        itemEntity.properties = [itemId, itemName, itemWeight, itemIsPacked, itemCategory, itemSubcategory, itemDescription, itemQuantity, itemPhotoData]
        
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
        
        // Sub-bag relationships (Bag to Bag)
        let bagToSubBags = NSRelationshipDescription()
        bagToSubBags.name = "subBags"
        bagToSubBags.destinationEntity = bagEntity
        bagToSubBags.maxCount = 0  // 0 means to-many
        bagToSubBags.deleteRule = .cascadeDeleteRule
        
        let subBagToParent = NSRelationshipDescription()
        subBagToParent.name = "parentBag"
        subBagToParent.destinationEntity = bagEntity
        subBagToParent.maxCount = 1  // 1 means to-one
        subBagToParent.deleteRule = .nullifyDeleteRule
        
        bagToSubBags.inverseRelationship = subBagToParent
        subBagToParent.inverseRelationship = bagToSubBags
        
        tripEntity.properties.append(tripToBags)
        bagEntity.properties.append(contentsOf: [bagToTrip, bagToItems, bagToSubBags, subBagToParent])
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