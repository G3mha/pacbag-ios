# PacBag - Project Setup Tutorial

## Prerequisites

- Xcode 15+ installed
- Apple Developer account (already have ✓)
- Git repository initialized (already have ✓)

## 1. Create Xcode Project

### Open Xcode

```bash
# In your existing git repo directory
open -a Xcode
```

### Create New Project

**In Xcode:**

- File → New → Project
- Choose "iOS" → "App"
- **Product Name**: "PacBag"
- **Interface**: SwiftUI
- **Language**: Swift
- **Use Core Data**: ✓
- **Use CloudKit**: ✓
- **Include Tests**: ✓

## 2. Project Structure

```
PacBag/
├── PacBag/
│   ├── PacBagApp.swift           # App entry point
│   ├── ContentView.swift         # Main view
│   ├── Models/
│   │   └── PacBag.xcdatamodeld   # Core Data model
│   ├── Views/
│   │   ├── TripListView.swift
│   │   ├── BagDetailView.swift
│   │   └── ItemListView.swift
│   ├── ViewModels/
│   │   ├── TripViewModel.swift
│   │   └── BagViewModel.swift
│   └── Utilities/
│       ├── CoreDataManager.swift
│       └── CloudKitManager.swift
├── PacBagTests/
└── PacBagUITests/
```

## 3. Git Integration

```bash
# Add Xcode files to your existing repo
git add .
git commit -m "Initial iOS project setup with SwiftUI and Core Data"
```

## 4. CloudKit Configuration

### Enable CloudKit Capability

1. Select your project in Xcode
2. Go to **Target** → **Signing & Capabilities**
3. Look for the **iCloud** section (should already be present)
4. Under **Services**, ensure **CloudKit** is checked ✓
5. Click **+ Container** to add a CloudKit container
6. In the dialog, enter: `iCloud.com.yourname.PacBag` (replace "yourname" with your developer ID)
7. Click **OK** - Xcode will create the container and add it to your app's entitlements
8. Ensure your Apple Developer account is selected

### Core Data + CloudKit Setup

The generated project template includes:

- Core Data stack with CloudKit integration
- Automatic CloudKit container configuration
- NSPersistentCloudKitContainer setup

## 5. Core Data Model Setup

You can set up Core Data either through Xcode's visual editor OR entirely through code. Code-based setup is often preferred for better version control.

### Option A: Code-Based Setup (Recommended)

Skip creating the `.xcdatamodeld` file and set up everything in Swift code. This approach is cleaner and easier to track in git.

#### 1. Create Core Data Models
Create these Swift files in your project:

**Models/Trip.swift**
```swift
import Foundation
import CoreData
import CloudKit

@objc(Trip)
public class Trip: NSManagedObject {
    
}

extension Trip {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Trip> {
        return NSFetchRequest<Trip>(entityName: "Trip")
    }
    
    @NSManaged public var name: String
    @NSManaged public var startDate: Date
    @NSManaged public var endDate: Date
    @NSManaged public var destination: String
    @NSManaged public var bags: NSSet?
}

// MARK: Generated accessors for bags
extension Trip {
    @objc(addBagsObject:)
    @NSManaged public func addToBags(_ value: Bag)
    
    @objc(removeBagsObject:)
    @NSManaged public func removeFromBags(_ value: Bag)
    
    @objc(addBags:)
    @NSManaged public func addToBags(_ values: NSSet)
    
    @objc(removeBags:)
    @NSManaged public func removeFromBags(_ values: NSSet)
}
```

**Models/Bag.swift**
```swift
import Foundation
import CoreData
import CloudKit

@objc(Bag)
public class Bag: NSManagedObject {
    
}

extension Bag {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Bag> {
        return NSFetchRequest<Bag>(entityName: "Bag")
    }
    
    @NSManaged public var name: String
    @NSManaged public var maxWeight: Double
    @NSManaged public var currentWeight: Double
    @NSManaged public var trip: Trip?
    @NSManaged public var items: NSSet?
}

// MARK: Generated accessors for items
extension Bag {
    @objc(addItemsObject:)
    @NSManaged public func addToItems(_ value: Item)
    
    @objc(removeItemsObject:)
    @NSManaged public func removeFromItems(_ value: Item)
    
    @objc(addItems:)
    @NSManaged public func addToItems(_ values: NSSet)
    
    @objc(removeItems:)
    @NSManaged public func removeFromItems(_ values: NSSet)
}
```

**Models/Item.swift**
```swift
import Foundation
import CoreData
import CloudKit

@objc(Item)
public class Item: NSManagedObject {
    
}

extension Item {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Item> {
        return NSFetchRequest<Item>(entityName: "Item")
    }
    
    @NSManaged public var name: String
    @NSManaged public var weight: Double
    @NSManaged public var isPacked: Bool
    @NSManaged public var category: String?
    @NSManaged public var bag: Bag?
}
```

#### 2. Create Core Data Manager
**Utilities/CoreDataManager.swift**
```swift
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
        
        itemEntity.properties = [itemName, itemWeight, itemIsPacked, itemCategory]
        
        // Relationships
        let tripToBags = NSRelationshipDescription()
        tripToBags.name = "bags"
        tripToBags.destinationEntity = bagEntity
        tripToBags.isToMany = true
        tripToBags.deleteRule = .cascadeDeleteRule
        
        let bagToTrip = NSRelationshipDescription()
        bagToTrip.name = "trip"
        bagToTrip.destinationEntity = tripEntity
        bagToTrip.isToMany = false
        bagToTrip.deleteRule = .nullifyDeleteRule
        
        tripToBags.inverseRelationship = bagToTrip
        bagToTrip.inverseRelationship = tripToBags
        
        let bagToItems = NSRelationshipDescription()
        bagToItems.name = "items"
        bagToItems.destinationEntity = itemEntity
        bagToItems.isToMany = true
        bagToItems.deleteRule = .cascadeDeleteRule
        
        let itemToBag = NSRelationshipDescription()
        itemToBag.name = "bag"
        itemToBag.destinationEntity = bagEntity
        itemToBag.isToMany = false
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
```

#### 3. Update App Entry Point
In **PacBagApp.swift**, inject the Core Data context:
```swift
import SwiftUI

@main
struct PacBagApp: App {
    let coreDataManager = CoreDataManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, coreDataManager.context)
        }
    }
}
```

### Option B: Visual Editor Setup

Since the `.xcdatamodeld` file wasn't created automatically, create it manually:

1. In Xcode: **File** → **New** → **File**
2. Choose **iOS** → **Core Data** → **Data Model**
3. Click **Next**
4. Name it `PacBag` (Xcode will add `.xcdatamodeld` automatically)
5. Make sure it's saved in your project folder and added to your target
6. Click **Create**

#### Open Core Data Model Editor

1. Click on `PacBag.xcdatamodeld` to open the Core Data Model Editor
2. You'll see a visual editor with entities, attributes, and relationships

#### Create Trip Entity

1. Click **+ Add Entity** button (bottom toolbar)
2. Rename "Entity" to "Trip"
3. Select the Trip entity, then in **Data Model Inspector** (right panel):
   - Set **Codegen** to "Class Definition"
   - Look for **Used with CloudKit** checkbox (may be under different sections in newer Xcode)
   - If you can't find it, skip for now - CloudKit sync can be configured later
4. Add attributes by clicking **+** in Attributes section:
   - `name`: String, Optional: No, Default Value: ""
   - `startDate`: Date, Optional: No, Default Value: (current date)
   - `endDate`: Date, Optional: No, Default Value: (current date)
   - `destination`: String, Optional: No, Default Value: ""

#### Create Bag Entity

1. Click **+ Add Entity** again
2. Rename to "Bag"  
3. Set **Codegen** to "Class Definition" (skip CloudKit checkbox if not found)
4. Add attributes:
   - `name`: String, Optional: No, Default Value: ""
   - `maxWeight`: Double, Optional: No, Default Value: 0
   - `currentWeight`: Double, Optional: No, Default Value: 0

#### Create Item Entity

1. Click **+ Add Entity** again
2. Rename to "Item"
3. Set **Codegen** to "Class Definition" (skip CloudKit checkbox if not found)
4. Add attributes:
   - `name`: String, Optional: No, Default Value: ""
   - `weight`: Double, Optional: No, Default Value: 0
   - `isPacked`: Boolean, Optional: No, Default Value: NO
   - `category`: String, Optional: Yes

#### Create Relationships

1. Select **Bag** entity
2. In **Relationships** section, click **+**
3. Name: `trip`, Destination: Trip, Delete Rule: Nullify

4. Select **Trip** entity  
5. Add relationship: `bags`, Destination: Bag, Delete Rule: Cascade, Type: "To Many"

6. Select **Item** entity
7. Add relationship: `bag`, Destination: Bag, Delete Rule: Nullify

8. Select **Bag** entity
9. Add relationship: `items`, Destination: Item, Delete Rule: Cascade, Type: "To Many"

#### Configure Inverse Relationships

1. Select Bag's `trip` relationship → set **Inverse** to `bags`
2. Select Trip's `bags` relationship → set **Inverse** to `trip`
3. Select Item's `bag` relationship → set **Inverse** to `items`  
4. Select Bag's `items` relationship → set **Inverse** to `bag`

#### Save the Model

Press **⌘+S** to save your Core Data model.

## 6. Development Workflow

### Daily Development
```bash
# Start development
git pull origin main
# Make changes in Xcode
git add .
git commit -m "Feature description"
git push origin main
```

### Testing on Device
1. Connect iOS device
2. Select device in Xcode
3. Ensure Apple Developer account is signed in
4. Build and run (⌘+R)

## 7. Next Steps
1. Design Core Data entities in the `.xcdatamodeld` file
2. Create basic SwiftUI views for trip and bag management
3. Implement MVVM architecture
4. Add CloudKit sync functionality
5. Test on physical device for CloudKit functionality

## 8. Troubleshooting

### Common Issues
- **CloudKit Sync Not Working**: Ensure you're signed into iCloud on test devices
- **Build Errors**: Check Bundle Identifier is unique
- **Core Data Issues**: Reset simulator if data model changes

### Useful Xcode Shortcuts
- **⌘+R**: Build and run
- **⌘+.**: Stop running
- **⌘+Shift+K**: Clean build folder
- **⌘+Option+Shift+K**: Clean build folder and derived data
