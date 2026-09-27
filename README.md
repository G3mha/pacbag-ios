# PacBag

An iOS app for packing luggage. You list the bags you're taking, put items in them, and check items off as they go in. It adds up weight per bag, so you find out you're over the airline limit at home instead of at the counter.

Built by **Enricco Gemha**. On the App Store since 24 July 2025: [PacBag - Digital Luggage](https://apps.apple.com/br/app/pacbag-digital-luggage/id6749021887). Free, no in-app purchases, no account.

The landing page is a separate repo: [pacbag-website](https://github.com/G3mha/pacbag-website).

## What it does

**Trips** have a name, a destination, and start and end dates. A trip holds bags.

**Bags** are one of five types — suitcase, backpack, carry-on, duffel, tote. A bag can hold sub-bags, so a packing cube inside a suitcase gets its own list. Each bag has a weight limit, and the app shows how much of it you've used.

**Items** have a name, a category, a quantity, a weight, and an optional photo from your library. Checking one off moves the trip's packing progress.

**Templates** fill a new trip with a starting list. Eight ship with the app: Business Week, Business Weekend, Beach Vacation, City Break, Weekend Getaway, Camping Adventure, Backpacking, and Adventure Sports. You can save your own too.

**Categories** group items — Clothes, Electronics, Toiletries, and so on — and can have subcategories. You can add your own with an icon and a color.

**Reminders** are local notifications scheduled against a trip's start date. Nothing leaves the device to send them.

**Export** writes a trip or a single bag out as plain text, Markdown, or rich text and hands it to the iOS share sheet.

**Sync** goes through CloudKit. Your trips live in your own iCloud account and appear on your other devices signed in to the same Apple ID.

## Scope

There's no server. No weather lookup, no destination-based suggestions, nothing guessing what you should bring, no shared or collaborative lists. The features above are the whole app.

## Build it

You need:

- Xcode 16.4 or later — the deployment target is iOS 18.5
- An iPhone or iPad on iOS 18.5+, or a matching simulator
- An Apple Developer account, because the app uses an iCloud container

```bash
git clone https://github.com/G3mha/pacbag-ios.git
cd pacbag-ios
open PacBag/PacBag.xcodeproj
```

In Xcode, pick your team under **Signing & Capabilities**, then ⌘R to build and run. The iCloud container is hardcoded to `iCloud.com.enriccogemha.PacBag`, so point it at one of your own.

## Layout

```
PacBag/PacBag/
├── Models/             Core Data entities and the template catalog
├── Views/              SwiftUI screens
├── Utilities/          Core Data stack, categories, notifications, export
├── Persistence.swift   Container used by SwiftUI previews
└── PacBagApp.swift     App entry point
```

## How it's put together

SwiftUI for the interface, Core Data for storage, CloudKit for sync.

`CoreDataManager` builds the managed object model in Swift instead of loading a `.xcdatamodeld` file, then wraps it in an `NSPersistentCloudKitContainer`. That container is what syncs; there's no CloudKit code of its own anywhere in the app.

The entities:

```
Trip ──< Bag ──< Item
         └──< Bag      (sub-bags, through parentBag)

Category ──< SubCategory
Category ──< Item
```

`Bag.totalWeight` adds the bag's own items to the totals of its sub-bags, so a suitcase weighs what's in it plus what's in the cubes inside it.

## Privacy

No analytics, no third-party SDKs, no accounts. Trips sync through your iCloud account and go nowhere else. Photos you attach are copied into the app's own store when you pick them — the app never reads your library on its own.

Full policy: [pacbag.app/privacy-policy](https://pacbag.app/privacy-policy)

## More docs

- [DEVELOPMENT.md](DEVELOPMENT.md) — architecture, data model, build and release steps
- [APP_STORE_SUBMISSION.md](APP_STORE_SUBMISSION.md) — the published listing and what an update needs

## Contact

Enricco Gemha — me@enriccogemha.dev

## License

© 2025 Enricco Gemha. All rights reserved.
