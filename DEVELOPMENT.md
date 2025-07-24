# PacBag Development Guide

## Architecture Overview

### Tech Stack
- **Language**: Swift 5.9
- **UI Framework**: SwiftUI
- **Data Persistence**: Core Data + CloudKit
- **Minimum iOS**: 17.0
- **Architecture Pattern**: MVVM

### Key Technologies
- CloudKit for sync
- UserNotifications for reminders
- PhotosUI for item images
- Core Data for local storage

## Project Structure

```
PacBag/
├── Models/
│   ├── Trip.swift              # Trip entity
│   ├── Bag.swift               # Bag entity  
│   ├── Item.swift              # Item entity
│   ├── Category.swift          # Category management
│   ├── SubCategory.swift       # Subcategory support
│   └── PackingTemplate.swift   # Template system
├── Views/
│   ├── TripListView.swift      # Main trips screen
│   ├── TripDetailView.swift    # Trip details
│   ├── BagDetailView.swift     # Bag contents
│   ├── AddItemView.swift       # Item creation
│   └── SettingsView.swift      # App settings
├── Utilities/
│   ├── CoreDataManager.swift   # Core Data stack
│   ├── CategoryManager.swift   # Category logic
│   ├── NotificationManager.swift # Reminders
│   └── SharingManager.swift    # Export functionality
└── Resources/
    ├── Info.plist              # App configuration
    └── PacBag.entitlements     # Capabilities
```

## Core Features Implementation

### Data Model

#### Core Entities
- **Trip**: Contains multiple bags, has reminder settings
- **Bag**: Belongs to trip, contains items, tracks weight
- **Item**: Belongs to bag, has category, quantity, weight
- **Category**: System and custom categories with icons
- **SubCategory**: Optional subcategories for organization

#### Relationships
```
Trip 1 → * Bag 1 → * Item
Category 1 → * SubCategory
Category 1 → * Item
```

### CloudKit Integration
- Automatic sync via NSPersistentCloudKitContainer
- No custom CloudKit code required
- User's private database only
- Offline support built-in

### Key Managers

#### CoreDataManager
- Singleton pattern
- Handles persistent container setup
- CloudKit configuration
- Save context management

#### CategoryManager  
- Default categories initialization
- Custom category creation
- Icon and color management
- Usage analytics

#### NotificationManager
- Local notifications only
- Trip reminder scheduling
- Permission handling
- Notification cleanup

## Building & Testing

### Requirements
- Xcode 15.0+
- macOS Sonoma 14.0+
- iOS 17.0+ device/simulator

### Build Configuration
```bash
# Debug build
xcodebuild -project PacBag.xcodeproj -scheme PacBag -configuration Debug

# Release build  
xcodebuild -project PacBag.xcodeproj -scheme PacBag -configuration Release

# Archive for App Store
xcodebuild -project PacBag.xcodeproj -scheme PacBag -configuration Release archive
```

### Testing
- Unit tests in PacBagTests/
- UI tests in PacBagUITests/
- Test CloudKit sync with multiple devices
- Test data migration scenarios

## Code Style Guidelines

### SwiftUI Best Practices
- Use `@StateObject` for view models
- Prefer `@EnvironmentObject` for shared state
- Extract complex views into components
- Use preview providers for development

### Data Handling
- Always handle Core Data errors
- Use proper optionals (no force unwrapping)
- Validate user input
- Handle edge cases gracefully

### Naming Conventions
- Views: `*View` suffix (e.g., `TripDetailView`)
- View Models: `*ViewModel` suffix
- Managers: `*Manager` suffix
- Models: Noun without suffix

## Common Tasks

### Adding a New Feature
1. Update Core Data model if needed
2. Create/modify views
3. Update relevant managers
4. Add unit tests
5. Test CloudKit sync
6. Update documentation

### Debugging CloudKit
1. Check Console app for CloudKit logs
2. Verify entitlements configuration
3. Test with Development/Production environments
4. Check iCloud account status

### Performance Optimization
- Use `@FetchRequest` with predicates
- Implement pagination for large lists
- Optimize image storage
- Profile with Instruments

## Troubleshooting

### Common Issues

**CloudKit not syncing**
- Verify iCloud signed in
- Check network connection
- Ensure CloudKit capability enabled
- Check container configuration

**Core Data errors**
- Check for model version conflicts
- Verify migration policies
- Clear derived data
- Reset simulator/device

**UI performance**
- Profile with Instruments
- Check for excessive redraws
- Optimize ForEach usage
- Use lazy loading

## Release Process

1. **Version Bump**
   - Update version in project settings
   - Update build number

2. **Testing**
   - Run full test suite
   - Test on multiple devices
   - Verify CloudKit sync
   - Check for memory leaks

3. **Code Cleanup**
   - Remove debug prints
   - Fix all warnings
   - Run SwiftLint (if configured)

4. **Archive**
   - Select "Any iOS Device"
   - Product → Archive
   - Validate archive
   - Upload to App Store Connect

## Security Considerations

- No user data leaves device (except iCloud)
- No analytics or tracking
- No third-party SDKs
- Photos remain in user's library
- All data encrypted by iOS/iCloud

## Future Enhancements

### Planned Features
- Travel document storage
- Weather integration
- Collaborative lists
- Apple Watch app
- Widgets

### Technical Improvements
- Swift 6 migration
- Performance optimizations
- Accessibility enhancements
- Localization support