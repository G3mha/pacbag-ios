# PacBag App Publishing Steps

## Step 1: Apple Developer Account
1. Go to https://developer.apple.com
2. Click "Account" → "Enroll"
3. Choose Individual or Organization ($99/year)
4. Complete enrollment with Apple ID

## Step 2: In Apple Developer Portal
1. Sign in to https://developer.apple.com/account
2. Go to "Certificates, Identifiers & Profiles"
3. Create App ID:
   - Click "Identifiers" → "+"
   - Select "App IDs" → Continue
   - Select "App" → Continue
   - Bundle ID: `com.yourdomain.PacBag` (or similar)
   - Description: "PacBag"
   - Enable Capabilities:
     ✓ CloudKit
     ✓ Push Notifications
   - Click "Continue" → "Register"

## Step 3: Configure CloudKit
1. Still in Developer Portal
2. Click on your App ID
3. Click "Configure" next to CloudKit
4. Create CloudKit Container:
   - Use default: `iCloud.com.yourdomain.PacBag`
   - Click "Create"

## Step 4: In Xcode
1. Open PacBag.xcodeproj
2. Select project → Target → Signing & Capabilities
3. Team: Select your developer account
4. Bundle Identifier: Match what you created (e.g., `com.yourdomain.PacBag`)
5. Check capabilities are enabled:
   - ✓ CloudKit
   - ✓ Push Notifications

## Step 5: Prepare for Archive
1. Select target device: "Any iOS Device (arm64)"
2. Product → Clean Build Folder
3. Update version (current is probably 1.0):
   - Project → Target → General
   - Version: 1.0.0
   - Build: 1

## Step 6: Archive and Upload
1. Product → Archive
2. Wait for archive to complete
3. In Organizer window:
   - Select your archive
   - Click "Distribute App"
   - Choose "App Store Connect" → Next
   - Choose "Upload" → Next
   - Let Xcode handle signing → Next
   - Review → Upload

## Step 7: App Store Connect
1. Go to https://appstoreconnect.apple.com
2. My Apps → "+" → New App
3. Fill in:
   - Platform: iOS
   - App Name: PacBag
   - Primary Language: English (U.S.)
   - Bundle ID: Select from dropdown
   - SKU: PACBAG001 (any unique string)
   - User Access: Full Access

## Step 8: App Information
In App Store Connect, fill in all sections:

### Version Information
- Screenshots (required for each device size)
- Description (from checklist)
- Keywords
- Support URL: https://yourwebsite.com/support
- Marketing URL (optional)

### General Information
- App Icon (1024x1024) - automatically pulled from build
- Version: 1.0.0
- Copyright: © 2024 Your Name
- Primary Category: Travel
- Secondary Category: Productivity

### App Privacy
- Privacy Policy URL: https://yourwebsite.com/privacy-policy.html
- Privacy Choices: No data collected

### Pricing and Availability
- Price: Free or select tier
- Availability: All countries or select specific ones

## Step 9: Submit for Review
1. Select the build you uploaded
2. Answer export compliance: No (doesn't use encryption)
3. Submit for Review

## Timeline
- Review usually takes 24-48 hours
- First submission might take longer
- You'll get email updates on status

## Common Issues to Avoid
1. Make sure all placeholder text is removed
2. Screenshots must be exact dimensions
3. Privacy policy URL must be accessible
4. No crashes or obvious bugs
5. All features must work

## After Approval
1. Set release date (immediate or scheduled)
2. Monitor ratings and reviews
3. Respond to user feedback
4. Plan your first update