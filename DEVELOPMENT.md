# Development

Notes for working on the app. The [README](README.md) covers what PacBag does and how to build it.

## Stack

| | |
|---|---|
| Language | Swift 5.0 |
| UI | SwiftUI |
| Storage | Core Data |
| Sync | CloudKit, through `NSPersistentCloudKitContainer` |
| Notifications | `UserNotifications`, local only |
| Photos | `PhotosUI` |
| Deployment target | iOS 18.5 |
| Devices | iPhone and iPad |

No third-party dependencies. No package manager.

## Data model

The model is built in code, in `CoreDataManager.managedObjectModel`. There is no `.xcdatamodeld` file, so adding an attribute means editing that method — see `bagWeight` for the shape of it. Entities:

**Trip** — `name`, `destination`, `startDate`, `endDate`, `tripDescription`, `isCompleted`, `remindersEnabled`. Has many bags.

**Bag** — `name`, `maxWeight`, `currentWeight`. Belongs to a trip, has many items, and can have a `parentBag` plus its own sub-bags.

**Item** — `name`, `weight`, `quantity`, `isPacked`, `category`, `subcategory`, `itemDescription`, `photoData`. Belongs to a bag.

**Category** and **SubCategory** — user-facing groupings with an icon and a color. Items reference them both by string and by relationship (`categoryEntity`, `subcategoryEntity`).

Two computed properties do the work most screens read:

- `Bag.totalWeight` recurses through sub-bags, so a parent bag's weight includes its children's
- `Bag.packingProgress` is packed items over total items, counting sub-bags

## Managers

All in `Utilities/`, all singletons.

`CoreDataManager` — builds the model, configures the CloudKit container, saves the context.

`CategoryManager` — seeds the default categories on first launch and creates custom ones.

`NotificationManager` — schedules and cancels trip reminders. Uses `UNCalendarNotificationTrigger`, so reminders fire without a server.

`SharingManager` — renders a trip or a bag as plain text, Markdown, or RTF. Each format has its own generator; they don't share a walker, so a change to what's exported means touching all three.

`SettingsManager`, `OnboardingManager`, `AppIconManager`, `IconSetupManager` — app preferences, first-run state, and alternate app icons.

## Build and test

```bash
# Debug build
xcodebuild -project PacBag/PacBag.xcodeproj -scheme PacBag -configuration Debug build

# Tests
xcodebuild -project PacBag/PacBag.xcodeproj -scheme PacBag \
  -destination 'platform=iOS Simulator,name=iPhone 16' test
```

Tests are in `PacBagTests/` and `PacBagUITests/`. Both are close to empty — the templates in them are still the Xcode defaults.

## Working on sync

CloudKit sync only runs on a real device signed in to iCloud, and it isn't instant. To check it:

1. Run on two devices on the same Apple ID
2. Add a trip on one, wait, pull to refresh on the other
3. Watch the Console app, filtered to the app, for `NSPersistentCloudKitContainer` logs

`CoreDataManager` logs store-load errors instead of crashing, so a broken container shows up as an app with no data rather than a crash. Check the console before assuming the model is fine.

## Releasing

1. Bump `MARKETING_VERSION` and `CURRENT_PROJECT_VERSION` in the project settings
2. Build for "Any iOS Device", then Product → Archive
3. Validate, then upload to App Store Connect
4. Update [APP_STORE_SUBMISSION.md](APP_STORE_SUBMISSION.md) with whatever changed in the listing

## Not built

Ideas, none of them started. Nothing here is in the shipped app, and none of it should show up in the app's description or on the website until it is.

- Travel document storage
- Weather-based suggestions
- Shared or collaborative lists
- Apple Watch app
- Home screen widgets
- Localization — the app is English only
