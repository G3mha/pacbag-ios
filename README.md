# PacBag - Digital Luggage

<div align="center">
  <img src="assets/icon-raw.png" width="120" height="120" alt="PacBag Icon" />
  <h3>Never forget to pack again</h3>
  <p>Smart travel packing lists for iOS</p>
  
  [![iOS](https://img.shields.io/badge/iOS-17.0+-007AFF?style=flat-square&logo=apple)](https://apps.apple.com/app/pacbag)
  [![Swift](https://img.shields.io/badge/Swift-5.9-FA7343?style=flat-square&logo=swift)](https://swift.org)
  [![SwiftUI](https://img.shields.io/badge/SwiftUI-5.0-blue?style=flat-square)](https://developer.apple.com/xcode/swiftui/)
</div>

## Overview

PacBag is an intelligent travel companion that takes the stress out of packing. Create digital twins of your luggage, track items across multiple bags, and never leave essentials behind.

### Key Features

- 🎒 **Smart Packing Templates** - Pre-built lists for different trip types
- 📦 **Multi-Bag Organization** - Track items across suitcases, carry-ons, and backpacks
- ⚖️ **Weight Tracking** - Stay within airline limits
- 🏷️ **Custom Categories** - Organize items your way
- 🔔 **Trip Reminders** - Get notified before you travel
- 📤 **List Sharing** - Export and share with travel companions
- ☁️ **iCloud Sync** - Access lists on all your devices
- 🔒 **Privacy First** - All data stays in your iCloud, no tracking

## Development

### Requirements

- Xcode 15.0+
- iOS 17.0+
- Swift 5.9+
- macOS Sonoma 14.0+ (for development)

### Project Structure

```
PacBag/
├── PacBag/              # Main app target
│   ├── Models/          # Core Data models
│   ├── Views/           # SwiftUI views
│   ├── Utilities/       # Managers and helpers
│   └── Assets.xcassets/ # Images and colors
├── website/             # Landing page (Next.js)
└── assets/             # Project assets
```

### Getting Started

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/pacbag.git
   cd pacbag
   ```

2. Open in Xcode:
   ```bash
   open PacBag/PacBag.xcodeproj
   ```

3. Select your development team in Xcode's Signing & Capabilities

4. Build and run (⌘R)

### Architecture

- **SwiftUI** - Modern declarative UI
- **Core Data + CloudKit** - Local storage with cloud sync
- **MVVM Pattern** - Clean separation of concerns
- **iOS 17 Features** - Latest platform capabilities

## App Store Information

### Metadata
- **Name**: PacBag - Digital Luggage
- **Subtitle**: Smart Travel Packing Lists
- **Category**: Travel (Primary), Productivity (Secondary)
- **Price**: Free
- **Bundle ID**: enriccogemha.PacBagApp

### Description
PacBag is your intelligent travel companion that takes the stress out of packing. Never forget essential items again with smart packing templates, customizable lists, and helpful reminders.

### Keywords
travel, packing, list, organizer, trip, planner, vacation, luggage, checklist, travel app

### Support
- **Website**: https://pacbag.app
- **Support**: https://pacbag.app/support
- **Privacy Policy**: https://pacbag.app/privacy-policy

## Privacy & Compliance

PacBag is designed with privacy at its core:
- ✅ No data collection or analytics
- ✅ All data stored in user's iCloud
- ✅ No third-party services
- ✅ GDPR compliant
- ✅ EU DSA compliant

See our [Privacy Policy](https://pacbag.app/privacy-policy) for details.

## Website

The marketing website is built with Next.js and deployed on Vercel.

### Running Locally
```bash
cd website
npm install
npm run dev
```

Visit http://localhost:3000

### Deployment
```bash
git push origin main
# Vercel auto-deploys from main branch
```

## Contributing

This is currently a personal project, but feedback and suggestions are welcome!

## Author

**Enricco Gemha**  
- Email: me@enriccogemha.dev
- Website: https://pacbag.app

## License

© 2025 Enricco Gemha. All rights reserved.

---

<div align="center">
  Made with ❤️ in São Paulo
</div>