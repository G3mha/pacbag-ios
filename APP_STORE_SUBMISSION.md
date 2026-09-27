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
| Version | 1.0 (build 1) |
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

## Description

The text below is a rewrite. The live listing still has the original, which called the app an "intelligent travel companion" and promised "smart" templates — wording the app doesn't earn. Paste this into App Store Connect to replace it.

```
PacBag keeps track of what's in your luggage.

List the bags you're taking. Put items in them. Check items off as they go in. PacBag adds up the weight of each bag against the limit you set, so you find out you're overweight at home instead of at the airport.

WHAT'S IN IT
• Trips with dates, holding as many bags as you need
• Suitcases, backpacks, carry-ons, duffels and totes — and sub-bags, for packing cubes
• Weight per item and per bag, against a limit you choose
• Eight ready-made lists: business trips, beach, city breaks, camping, backpacking and more
• Your own templates, saved for next time
• Categories and subcategories you can rename, recolor, and add to
• Reminders before you leave
• Export a trip or a bag as text, Markdown, or rich text and send it to anyone
• iCloud sync across your iPhone and iPad

NO ACCOUNT, NO SERVER
There's nothing to sign up for. Your lists sit in your own iCloud account. No analytics, no ads, no tracking.
```

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
