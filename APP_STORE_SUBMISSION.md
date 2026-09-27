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
| Version | 1.0 live; 1.0.1 in Prepare for Submission (build 3) |
| Price | Free, no in-app purchases |
| Category | Travel, then Productivity |
| Age rating | 4+ |
| Minimum iOS | 18.5 |
| Devices | iPhone and iPad |
| Language | English |
| Export compliance | No non-exempt encryption, declared in `Info.plist` |
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

Generated, not collected by hand:

```bash
fastlane snapshot            # captures both device classes
fastlane ios upload_screenshots
```

A UI test in `PacBagUITests/ScreenshotTests.swift` drives one pass through the
app. Output is gitignored — regenerate it rather than committing it.

Four screens, at 1320×2868 (iPhone 6.9") and 2064×2752 (iPad 13"):

1. My Trips
2. The trip, with packing progress
3. Adding a bag, showing the empty-bag weight against the limit
4. Inside a bag

Two things to know before changing the test: it passes
`-PacBagDisableCloudKit`, without which the app cannot launch in a simulator at
all; and the simulator must be `en_US`, or weights render as "3,0 kg".

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

Build 2 is uploaded, processed and attached, and the listing text is in place.
One thing is left, and it has to be done in the web UI:

Build 3, the listing text and the screenshots are all in place. One thing is
left, and it has to be done in the web UI:

**App Store Connect > PacBag > Age Rating > Edit.** Apple expanded the age
rating questionnaire, so the answers recorded for 1.0 are no longer complete.
A submission fails with `You must provide a value for the attribute
'ageAssurance'` until the new questions are answered.

Then **1.0.1 > Add for Review > Submit**.

A review submission with no items, `c6bf7ec6`, was left behind by a failed
attempt. Apple would not let it be cancelled. It should be harmless.
