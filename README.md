# PacBag

An iPhone and iPad app for packing lists and luggage weight. Organize trips, bags, and items, then check things off as you pack. Built with SwiftUI, Core Data, and CloudKit. No PacBag account required.

[App Store](https://apps.apple.com/br/app/pacbag-digital-luggage/id6749021887) · [Website](https://pacbag.app)

## Data and AI

Packing data is stored locally and syncs through your iCloud account. The current source also includes optional AI estimates for item weights and categories, plus filling an item from a photo.

AI is off until you consent. When enabled, item names, category names, or chosen photos go through PacBag's server to Anthropic's Claude. You can turn it off in Settings. Estimates can be wrong; weights you enter are not replaced.

Manual packing works offline. AI estimates need a connection. See the [privacy policy](https://pacbag.app/privacy) for other network services and data handling.

## Build it

Use Xcode 16.4+ and iOS 18.5+.

```bash
git clone https://github.com/G3mha/pacbag-ios.git
cd pacbag-ios
open PacBag/PacBag.xcodeproj
```

Choose your signing team and iCloud container in Xcode, then build and run.

## Development

- [App development](DEVELOPMENT.md)
- [AI backend setup](backend/README.md)
- [App Store submission notes](APP_STORE_SUBMISSION.md)
- [Website source](https://github.com/G3mha/pacbag-website)

© 2025 Enricco Gemha. All rights reserved.
