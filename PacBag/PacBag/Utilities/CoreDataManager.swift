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
                // Log error but don't crash - allow app to continue with limited functionality
                print("Core Data error: \(error). Some features may be unavailable.")
            }
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

        let bagWeight = NSAttributeDescription()
        bagWeight.name = "bagWeight"
        bagWeight.type = .double
        bagWeight.isOptional = false
        bagWeight.defaultValue = 0.0

        bagEntity.properties = [bagId, bagName, bagMaxWeight, bagCurrentWeight, bagWeight]
        
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
        
        // Category Entity
        let categoryEntity = NSEntityDescription()
        categoryEntity.name = "Category"
        categoryEntity.managedObjectClassName = "Category"
        
        let categoryId = NSAttributeDescription()
        categoryId.name = "id"
        categoryId.type = .uuid
        categoryId.isOptional = false
        categoryId.defaultValue = UUID()
        
        let categoryName = NSAttributeDescription()
        categoryName.name = "name"
        categoryName.type = .string
        categoryName.isOptional = false
        categoryName.defaultValue = ""
        
        let categoryIsDefault = NSAttributeDescription()
        categoryIsDefault.name = "isDefault"
        categoryIsDefault.type = .boolean
        categoryIsDefault.isOptional = false
        categoryIsDefault.defaultValue = false
        
        let categoryUsageCount = NSAttributeDescription()
        categoryUsageCount.name = "usageCount"
        categoryUsageCount.type = .integer32
        categoryUsageCount.isOptional = false
        categoryUsageCount.defaultValue = 0
        
        let categoryIconName = NSAttributeDescription()
        categoryIconName.name = "iconName"
        categoryIconName.type = .string
        categoryIconName.isOptional = true
        
        let categoryColorHex = NSAttributeDescription()
        categoryColorHex.name = "colorHex"
        categoryColorHex.type = .string
        categoryColorHex.isOptional = true
        
        let categoryIsArchived = NSAttributeDescription()
        categoryIsArchived.name = "isArchived"
        categoryIsArchived.type = .boolean
        categoryIsArchived.isOptional = false
        categoryIsArchived.defaultValue = false
        
        let categoryCreatedDate = NSAttributeDescription()
        categoryCreatedDate.name = "createdDate"
        categoryCreatedDate.type = .date
        categoryCreatedDate.isOptional = false
        categoryCreatedDate.defaultValue = Date()
        
        let categoryLastUsedDate = NSAttributeDescription()
        categoryLastUsedDate.name = "lastUsedDate"
        categoryLastUsedDate.type = .date
        categoryLastUsedDate.isOptional = true
        
        categoryEntity.properties = [categoryId, categoryName, categoryIsDefault, categoryUsageCount, categoryIconName, categoryColorHex, categoryIsArchived, categoryCreatedDate, categoryLastUsedDate]
        
        // SubCategory Entity
        let subCategoryEntity = NSEntityDescription()
        subCategoryEntity.name = "SubCategory"
        subCategoryEntity.managedObjectClassName = "SubCategory"
        
        let subCategoryId = NSAttributeDescription()
        subCategoryId.name = "id"
        subCategoryId.type = .uuid
        subCategoryId.isOptional = false
        subCategoryId.defaultValue = UUID()
        
        let subCategoryName = NSAttributeDescription()
        subCategoryName.name = "name"
        subCategoryName.type = .string
        subCategoryName.isOptional = false
        subCategoryName.defaultValue = ""
        
        let subCategoryIsDefault = NSAttributeDescription()
        subCategoryIsDefault.name = "isDefault"
        subCategoryIsDefault.type = .boolean
        subCategoryIsDefault.isOptional = false
        subCategoryIsDefault.defaultValue = false
        
        let subCategoryUsageCount = NSAttributeDescription()
        subCategoryUsageCount.name = "usageCount"
        subCategoryUsageCount.type = .integer32
        subCategoryUsageCount.isOptional = false
        subCategoryUsageCount.defaultValue = 0
        
        let subCategoryIsArchived = NSAttributeDescription()
        subCategoryIsArchived.name = "isArchived"
        subCategoryIsArchived.type = .boolean
        subCategoryIsArchived.isOptional = false
        subCategoryIsArchived.defaultValue = false
        
        let subCategoryCreatedDate = NSAttributeDescription()
        subCategoryCreatedDate.name = "createdDate"
        subCategoryCreatedDate.type = .date
        subCategoryCreatedDate.isOptional = false
        subCategoryCreatedDate.defaultValue = Date()
        
        let subCategoryLastUsedDate = NSAttributeDescription()
        subCategoryLastUsedDate.name = "lastUsedDate"
        subCategoryLastUsedDate.type = .date
        subCategoryLastUsedDate.isOptional = true
        
        subCategoryEntity.properties = [subCategoryId, subCategoryName, subCategoryIsDefault, subCategoryUsageCount, subCategoryIsArchived, subCategoryCreatedDate, subCategoryLastUsedDate]
        
        // Category to SubCategory relationships
        let categoryToSubCategories = NSRelationshipDescription()
        categoryToSubCategories.name = "subcategories"
        categoryToSubCategories.destinationEntity = subCategoryEntity
        categoryToSubCategories.maxCount = 0  // to-many
        categoryToSubCategories.deleteRule = .cascadeDeleteRule
        
        let subCategoryToCategory = NSRelationshipDescription()
        subCategoryToCategory.name = "category"
        subCategoryToCategory.destinationEntity = categoryEntity
        subCategoryToCategory.maxCount = 1  // to-one
        subCategoryToCategory.deleteRule = .nullifyDeleteRule
        
        categoryToSubCategories.inverseRelationship = subCategoryToCategory
        subCategoryToCategory.inverseRelationship = categoryToSubCategories
        
        // Category to Items relationships
        let categoryToItems = NSRelationshipDescription()
        categoryToItems.name = "items"
        categoryToItems.destinationEntity = itemEntity
        categoryToItems.maxCount = 0  // to-many
        categoryToItems.deleteRule = .nullifyDeleteRule
        
        let itemToCategory = NSRelationshipDescription()
        itemToCategory.name = "categoryEntity"
        itemToCategory.destinationEntity = categoryEntity
        itemToCategory.maxCount = 1  // to-one
        itemToCategory.deleteRule = .nullifyDeleteRule
        
        categoryToItems.inverseRelationship = itemToCategory
        itemToCategory.inverseRelationship = categoryToItems
        
        // SubCategory to Items relationships
        let subCategoryToItems = NSRelationshipDescription()
        subCategoryToItems.name = "items"
        subCategoryToItems.destinationEntity = itemEntity
        subCategoryToItems.maxCount = 0  // to-many
        subCategoryToItems.deleteRule = .nullifyDeleteRule
        
        let itemToSubCategory = NSRelationshipDescription()
        itemToSubCategory.name = "subcategoryEntity"
        itemToSubCategory.destinationEntity = subCategoryEntity
        itemToSubCategory.maxCount = 1  // to-one
        itemToSubCategory.deleteRule = .nullifyDeleteRule
        
        subCategoryToItems.inverseRelationship = itemToSubCategory
        itemToSubCategory.inverseRelationship = subCategoryToItems
        
        tripEntity.properties.append(tripToBags)
        bagEntity.properties.append(contentsOf: [bagToTrip, bagToItems, bagToSubBags, subBagToParent])
        itemEntity.properties.append(contentsOf: [itemToBag, itemToCategory, itemToSubCategory])
        categoryEntity.properties.append(contentsOf: [categoryToSubCategories, categoryToItems])
        subCategoryEntity.properties.append(contentsOf: [subCategoryToCategory, subCategoryToItems])
        
        model.entities = [tripEntity, bagEntity, itemEntity, categoryEntity, subCategoryEntity]
        
        return model
    }()
    
    func save() {
        if context.hasChanges {
            try? context.save()
        }
    }
}