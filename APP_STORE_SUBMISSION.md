# App Store listing

What's published, and what to check when submitting an update. Live since 24 July 2025.

**Listing:** [PacBag - Digital Luggage](https://apps.apple.com/br/app/pacbag-digital-luggage/id6749021887)

## Identifiers

| | |
|---|---|
| Name | PacBag - Digital Luggage |
| Subtitle | Smart Travel Packing Lists |
| Bundle ID | `enriccogemha.PacBagApp` |
| Apple ID | 6749021887 |
| SKU | PACBAG001 |
| Version | 1.0 live; 1.0.1 in Prepare for Submission (build 2) |
| Price | Free, no in-app purchases |
| Category | Travel, then Productivity |
| Age rating | 4+ |
| Minimum iOS | 18.5 |
| Devices | iPhone and iPad |
| Language | English |
| Export compliance | No encryption |
| Copyright | © 2025 Enricco Gemha |

## URLs

- Marketing: https://pacbag.app
- Support: https://pacbag.app/support
- Privacy policy: https://pacbag.app/privacy-policy
- Labels and markings (EU DSA): https://pacbag.app/labels-markings

## Description and promotional text

Both live under [`fastlane/metadata/en-US/`](fastlane/metadata/en-US/) and are pushed from there. See [Updating the listing](#updating-the-listing).

Promotional text is live on 1.0. The description and release notes are on
1.0.1, which sits in Prepare for Submission — Apple refuses a description edit
on a version that is already on sale.

## What's new — 1.0

```
First release.
```

## Keywords

```
travel, packing, list, organizer, trip, planner, vacation, luggage, checklist, travel app
```

## Screenshots

Two sizes are uploaded: iPhone 6.9" (1290 × 2796) and iPad 13" (2048 × 2732).

Captions:

1. Every trip in one place
2. See what's in each bag
3. Start from a ready-made list
4. Weight, quantity and category per item
5. Categories you control
6. Packing progress at a glance
7. Suitcase, carry-on, backpack — all tracked
8. The same lists on your iPad

## Review notes

```
PacBag is a packing list app. No account or test credentials needed — install and use.

To try the main flow: create a trip, add a bag, add items to it, then check items off.
Templates under the Templates tab fill a trip with a starting list.

Data syncs through the user's own iCloud account. There is no server and no login.
Reminders are local notifications; nothing is pushed from outside the device.
Every feature works offline.

Contact: me@enriccogemha.dev
```

## Before submitting an update

- [ ] `MARKETING_VERSION` and `CURRENT_PROJECT_VERSION` bumped
- [ ] Tested on a real device, not just the simulator
- [ ] iCloud sync checked across two devices
- [ ] No debug prints left in
- [ ] Build has no warnings
- [ ] Screenshots still match the UI
- [ ] This file updated with anything that changed in the listing

## Known cleanup

Doesn't affect users, but should go before the next submission: `Info.plist` declares the `remote-notification` background mode, and `PacBag.entitlements` sets `aps-environment` to `development`. The app only uses local notifications, so neither is needed.

## Updating the listing

Text fields are managed with fastlane. What Apple accepts depends on the
version's state, and it is stricter than fastlane's own list of "live editable"
fields suggests.

On PacBag today -- one version, 1.0, READY_FOR_SALE, nothing in Prepare for
Submission -- **promotional text** goes through. **Description** comes back as
`Attribute 'description' cannot be edited at this time` and needs a new app
version, as do the name, keywords, screenshots and category.

The lane sends each field separately and prints what was refused, so a rejected
field does not block the rest.

Edit the matching file under `fastlane/metadata/`, then:

```bash
export ASC_KEY_ID=<the AuthKey_XXXXXXXXXX.p8 filename>
export ASC_ISSUER_ID=<App Store Connect > Users and Access > Integrations>
bundle exec fastlane ios update_metadata
```

It opens an HTML preview and asks before sending anything. Add `force:true` to
skip the prompt. No build is uploaded and nothing is submitted for review.

`deliver` skips any metadata file that is absent, so a file you have not created
leaves that field alone on App Store Connect.

## Shipping 1.0.1

The listing text is already on 1.0.1. What is left is the build:

1. Archive in Xcode and upload to App Store Connect (the project is at 1.0.1, build 2)
2. Attach the build to the 1.0.1 version
3. Submit for review

Nothing here submits for you. `update_metadata` only writes text.
