# App Store listing

Submission notes for the current source. Confirm the live version and review status in App Store Connect before submitting.

**Listing:** [PacBag - Digital Luggage](https://apps.apple.com/br/app/pacbag-digital-luggage/id6749021887)

## Identifiers

| | |
|---|---|
| Name | PacBag - Digital Luggage |
| Subtitle | Smart Travel Packing Lists |
| Bundle ID | `enriccogemha.PacBagApp` |
| Apple ID | 6749021887 |
| SKU | PACBAG001 |
| Current source | 2.0.0 (build 4); App Store status must be checked separately |
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
- Privacy policy: https://pacbag.app/privacy
- Labels and markings (EU DSA): https://pacbag.app/labels-markings

## Description and promotional text

Both live under [`fastlane/metadata/en-US/`](fastlane/metadata/en-US/) and are pushed from there. See [Updating the listing](#updating-the-listing).

The files under `fastlane/metadata/` are release copy, not a record of what is currently live. Check them against the build being submitted before uploading. Source changes alone do not publish App Store metadata.

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

## Review notes for the current source

```
PacBag is a packing list app. No account or test credentials needed — install and use.

To try the main flow: create a trip, add a bag, add items to it, then check items off.
Templates under the Templates tab fill a trip with a starting list.

Packing data syncs through the user's own iCloud account. No PacBag account is required.
Manual packing and local reminders work offline.

Optional AI estimates require consent and a connection. Item names, category names,
or chosen photos are sent through PacBag's server to Anthropic's Claude.
Photo requests also include the preferred language. Apple's signed App Store record
is sent to PacBag's server for request limits. AI can be turned off in Settings.

Contact: me@enriccogemha.dev
```

## Before submitting an update

- [ ] `MARKETING_VERSION` and `CURRENT_PROJECT_VERSION` bumped
- [ ] Tested on a real device, not just the simulator
- [ ] iCloud sync checked across two devices
- [ ] AI consent, estimates, and turning AI off checked against the submitted build
- [ ] Listing copy, review notes, and App Privacy answers match that build
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

In the recorded 1.0 release workflow, promotional text could be updated while the version was on sale, but the description needed a new version. Confirm what App Store Connect allows for the version you are editing.

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

## Shipping a version

1. Edit the text under `fastlane/metadata/`, then `fastlane ios update_metadata`
2. `fastlane snapshot` and `fastlane ios upload_screenshots`
3. Bump `MARKETING_VERSION` and `CURRENT_PROJECT_VERSION`, archive, upload
4. Attach the build to the version
5. Check Age Rating in the web UI — Apple adds questions, and a stale answer
   blocks submission with `You must provide a value for the attribute
   'ageAssurance'`
6. Submit

1.0.1 went out on 27 September 2026 with build 3: the new description, release
notes, promotional text and a fresh set of screenshots.

