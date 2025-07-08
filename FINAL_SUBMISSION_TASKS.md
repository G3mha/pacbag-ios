# Final Tasks Before App Store Submission

## 1. Code Cleanup
- [ ] Remove all print() statements used for debugging
- [ ] Remove any force unwraps (!) that could cause crashes
- [ ] Ensure no test data in screenshots

## 2. Testing Checklist
- [ ] Fresh install test - Delete app and reinstall
- [ ] Test all features with no network connection
- [ ] Test with full iCloud storage (handle gracefully)
- [ ] Verify all text is properly localized (even if English only)
- [ ] Test on oldest supported device/iOS version

## 3. In Xcode Project Settings
- [ ] Set Deployment Target: iOS 17.0
- [ ] Enable "Requires Full Screen" if not supporting multitasking
- [ ] Set proper Launch Screen
- [ ] Verify Bundle Identifier matches App Store Connect

## 4. Build Settings
- [ ] Set build configuration to "Release"
- [ ] Enable optimizations
- [ ] Strip debug symbols

## 5. Archive Settings
- [ ] Product > Scheme > Edit Scheme
- [ ] Set Build Configuration to "Release"
- [ ] Set Archive Name

## 6. Upload Process
1. Product > Archive
2. In Organizer: Validate (checks for common issues)
3. Distribute App > App Store Connect
4. Upload

## 7. In App Store Connect After Upload
- [ ] Select build for review
- [ ] Answer export compliance (No - doesn't use encryption)
- [ ] Set release date (immediately or scheduled)
- [ ] Submit for review

## 8. Typical Review Time
- Usually 24-48 hours
- Can be up to 7 days
- Expedited review available for critical issues

## 9. Post-Approval
- [ ] Download your own app from App Store
- [ ] Verify everything works as expected
- [ ] Monitor crash reports and user feedback