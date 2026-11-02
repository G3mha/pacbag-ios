# Manual test scripts

Run these by hand on the stated devices. Scripts TM7, TM8, TM10 and TM11 land with the 2.0 work.

**TM1. iOS 18.5 smoke, including `CategoryAnalyticsView`.**
1. Run the app on `PacBag 18.5`. It launches with no CloudKit crash.
2. Add some data, then open analytics from each entry point: `V/SettingsView.swift:391`, `V/CategoryManagementView.swift:101` and `:311`. At `app-1.0.1`, and until `DebugSeed` lands, add a few items by hand, because `-PacBagSeed` doesn't exist yet. After that, launch with `-PacBagSeed smoke`.
3. Scroll past "Usage Distribution" (`V/CategoryAnalyticsView.swift:153-158`), and swipe the page `TabView` (`:27`).
4. Repeat with no usage data at all.
5. Expected: no crash. Run this **at `app-1.0.1` first**, so you know whether the warning at `:158` was ever a real crash. Then run it after the fix.

**TM2. Liquid Glass visual pass.** On iOS 26.5, 27.0, iPhone Duo on 27.1 or later, and one real device in light and dark. Look at each and compare against its row:

| Surface | Look for |
|---|---|
| Trip list, bag cards (`TripCardView` at `V/TripListView.swift:160`, `TripBagCardView` at `V/TripDetailView.swift:505`) | Corners next to larger sheet and control radii |
| Bag detail toolbar and `Menu` | Icons on `Button("Edit Bag", systemImage:)` in iOS 27. If gone and you want them, `.labelStyle(.titleAndIcon)` |
| Every sheet (40 sites) | Full-width backgrounds fighting the scroll edge effect, sheet radius |
| `QuickAddBar` in `safeAreaInset` | Bar over the scroll edge, last row reachable, strip readable while scrolling |
| Forms and lists | Larger row height pushing content under the keyboard |
| `WaitingRow`, skeletons, `CrisisCard` | Legible at all settings |
| Settings, Accessibility | Reduce Transparency on, Increase Contrast on, iOS 27 glass slider at both ends |
| Whole app | Largest Dynamic Type on the bag screen, item detail and consent sheet |
| iPhone in landscape, iOS 18.5 and 27.0 | `QuickAddBar` with the keyboard up and down, consent sheet, `CrisisCard`. Field text and Undo visible, and nothing clipped with the keyboard down |
| iPhone Duo, both displays | Bag screen with the keyboard up, and one fold during typing. An iOS 27.1 SDK build extends to the full display with vertical bars and resizes when folded **[fetched]**, so check content adapts. Fix vertical bars with `toolbarVerticalBehavior(_:)` if they get in the way |
| **[2.0]** `PhotoNotice` in the strip | iPhone SE (3rd generation) Simulator, `-PacBagFakePhoto -PacBagFakeAI response_unusable`, keyboard up, at default text and largest Dynamic Type. All of C18 can be read |

Pass means nothing is unreadable, clipped or untappable. Mismatched corners are listed debt, not a blocker. New UI follows your design rules: no sparkle icons, no em dashes.

**TM3. iPad.** Rotate on the bag screen and consent sheet. Use a hardware keyboard: Return commits and keeps focus. Menu symbols on iPadOS 27 (the iOS 27 note names iPadOS) and sheet size. Sub-bag quick add.

**TM3's steps for leaving a screen with text in a field.** Run these in a saved item, on the iPad, and on a phone through TM4's steps in the real app (owner of the rule: `specs/domain-layer.md` section 2.1).
1. Type a weight and swipe back with no Done, or tap Back if the layout has no swipe, then reopen the row. It's saved.
2. Type a weight, go Home, force quit, reopen. The weight's kept. If it isn't, write down what's kept. Do the same with notes.
3. On a row with an estimate, empty the weight field, go Home, force quit, reopen. The estimate's still there, because an empty weight is skipped.
4. Type a name, go Home, force quit, reopen. The old name shows, because a half-typed name doesn't survive a kill. That's accepted (owner: `specs/domain-layer.md` section 3).

**TM4. Quick add on a real device (G2).** Type 10 names fast using the software keyboard. Keyboard stays up. The strip shows the last 2 or 3 with fill state. Undo removes the newest. Dictation: "rain jacket." with a trailing period parses clean. VoiceOver announces each add. Reduce Motion on.

**TM4's steps in the real app.** G2's throwaway project stops above, because it has no item screen. These run on the real app whenever TM4 counts toward an exit, and they log with TM4.
1. With VoiceOver, change a category on a list row. Run T35 and T37 in `specs/quick-add.md` in the same session. Run T38 on the iPhone SE (3rd generation) Simulator in section 2.9.
2. Run TM3's steps for leaving a screen with text in a field on this phone.
3. Type a name, lock the phone, unlock. The text and keyboard are still there.
4. Pull Notification Center down and back while typing a name. Nothing saves.
5. On the oldest device, on a dev-signed build with `-PacBagSeed large_1000`: launch, then add 10 names fast. Record load time and any hitch. In the same session, time a 100 line paste by hand (T17 in `specs/quick-add.md`).

TM5 and TM6 are the go and no-go runs of the sync checks, on TestFlight against production. They share steps with the G4 script, and `specs/data-model.md` section 8.6 owns those steps and what each result means. TM5 step 3 is G4 step 7. TM6 step 3 is G4 step 3, TM6 steps 4 and 5 are G4 step 6, and TM6 step 6 is G4 step 4.

**TM5. Two-device sync, both on the same build and the throwaway account.**
1. Add a trip, a bag and 3 items on A. Open B, and wait up to 5 minutes **[assumption]**. They appear. Push isn't configured (`7571c1e`), so expect the update on app open, and write down what you see (`architecture.md` section 18). Then leave B on one of those item screens with no field focused, change that item's weight on A, send B to the background and bring it back. The weight field follows the new number, and nothing else on the row changes.
2. Fresh install on B before its first import: launch offline, then go online. Duplicate categories appear, then merge after import. Each default category shows once, and no item is left in "Not sorted" that had a category. Until import ends or 20 s pass, the trip list shows the placeholder and not "No trips yet". Write down which you saw.
3. Offline conflict: edit an item's name on A and its weight on B while both are offline, then reconnect. **Write down whether both survive (per-field) or one wins (per-record). This is G4's answer.** A per-record result changes copy and the "what 1.0.1 shows" table in `specs/data-model.md` section 3, and nothing else.
4. Delete a custom category on A. It stays gone on B after sync and after a relaunch on both. The UI can't delete a default row (`V/CategoryManagementView.swift:211,222`), and `CategoryReconciler` restores a default only when a race archived every row for its key (`specs/data-model.md` section 4.3).
5. Log check in Console: no 134406, no `Invalid Arguments`.
6. Settings shows a real sync status from `CloudKitEventObserver`, and not the old hard-coded row.
7. Run this one last, since it wipes the account. Leave B on a bag screen and send it to the background. On A, Reset All Data. Bring B to the front after A's Settings reads Up to date. B empties with no crash, and each default shows once after import.

**TM6. Mixed clients on one iCloud account. Run in this order.** Device B is the frozen App Store 1.0.1 (D6). Device A has the new build. Use the throwaway account. Steps 4 and 6 record what happens, and G4 writes that down.

| Step | On | Do | Expected | If wrong |
|---|---|---|---|---|
| 1 | B, 1.0.1 | Make a trip with items, including one at the default 0.1 kg and one in General | | |
| 2 | A, 1.1 over App Store 1.0.1 | Install TestFlight 1.1 over the App Store build | Everything's there. 0.1 reads unverified, and Owner's call 8 sets its verdict effect. General shows as chosen. Failure screen never appears. The first bag you open shows the one-line upgrade note once (owner: `specs/quick-add.md` section 7), and it doesn't come back | Stop. A failed migration stops the release |
| 3 | A | Quick add `Hat`, which is unknown or catalog | Row appears on B at 0.0 kg either way, since an estimate sits in a field 1.0.1 can't read. Category nil or the mirror string. B's total runs low with no marker, which is accepted (`registry.md` section 2.5) | |
| 4 | B | Open `Hat`, change only its name, Save. Then on A enter 12 kg on one item, 40 g on another and 650 g on a third, and on B open each and Save untouched | **Write down what the slider writes** for each (`understand/concurrency.md`). A clamped 12 kg or 40 g still reads `entered`, which is accepted (`specs/data-model.md` section 3). 650 g sits inside the range and off the 0.1 step, so Save may round it **[unverified]**, and it still reads `entered` | Reader table covers 0.1 and General |
| 5 | A | Read `Hat` | If the source survived: a slider floor of 0.1 reads `unknown` with no estimate, and `estimate` with one. Category General on an `unknown` row reads Not sorted. Any other number reads `entered` | If the source went to 0, record it, since that's the erase case. Otherwise fix `weightState` |
| 6 | A | Give an item an estimate. On B, edit its name only | **Write down whether the source and `weightEstimateKg` survive on A.** If old clients erase unknown fields, an estimate row falls back to source `legacy`. With `weight` 0 it reads "not weighed". If 1.0.1's Save also wrote the slider floor, it reads `unverified` at 100 g, the same as any old 0.1 row. Its category reads `entered`, which is cheap to fix | Nothing to fix. The result feeds copy and the "what 1.0.1 shows" table in `specs/data-model.md` section 3. It adds no fallback and no time |
| 7 | B | Add a new custom category | Syncs and shows on A | |
| 8 | A | Reconciler has run | Losers are hidden on B after its next reload (`U/CategoryManager.swift:116`). Items still show a category on B | |
| 9 | Both | Delete an item with a photo on A | Gone on B. Size of app data falls on A | |
| 10 | A, 2.0 later | Repeat 3 to 6 with `aiText` values | Same. A number B writes reads `entered` on A, since a number in `weight` is a person's | |

`Bag.currentWeight`: `grep` finds no reader in the app outside its declaration (`M/Bag.swift:18`) and the model (`U/CoreDataManager.swift:141`), so 1.0.1 won't show a stale bag total when writes stop **[measured by grep at `0c10439`]**. Step 1 still glances at the bag total on B.

**TM9. Crisis (2.0, and the device part on 1.1).** Use a phrase from `X/crisis_cases.json`. The device part is steps 1, 3, 5, 6, 7 and 8, leaving out step 7's 2.0 parts on 1.1.
1. Quick add, offline and declined: card once, buttons open `tel:988`, `sms:988`, and both URLs, item saved as typed, marked `skipped`. Nothing goes on the network. With the device region set to the US, the buttons are in file order: Call, Text, Chat, Visit findahelpline.com. All three 988 actions carry `regions: ["US"]`, so with the region set to Brazil, Visit findahelpline.com comes first, nothing's removed, and the text doesn't change (owner: `specs/compliance.md` section 2.7).
2. Create and rename a custom category with the phrase (2.0): card shows.
3. Relaunch, drain again: no second card.
4. A photo of a printed phrase (2.0): OCR check shows the card, no upload.
5. Benign `killer heels`, `suicide doors`, `die Hose`: no card. Refusal test names like `bear spray`: never the card.
6. Check the text against `X/crisis_response.json` by eye on the card, including the outside-US sentence.
7. Details form, on 1.1 and 2.0, on an iPhone and an iPad, with VoiceOver on. Type the phrase and tap Add. The sheet closes first. A form that closes itself presents after it closes, through the sheet's `onDismiss` and `onCrisisHit` (owner: `specs/ai-client.md` S6.3), so the card shows on the bag screen and stays until Close. Focus starts on the message, and Close returns to the bag. On 2.0, do the same on the custom category form in step 2, where Close returns to whatever's under the form. On 2.0, also show the card over a sheet that stays up: `-PacBagFakeAI response_crisis` in a Debug build with Settings open (T42 in `specs/ai-client.md`). Close returns to Settings. Nobody has run this on a device yet.
8. Rename a saved item to the phrase in item detail, on 1.1 and on 2.0, with consent off and on. The card shows when the name commits. The name stays as typed, the resolver doesn't run, any field with no answer goes `skipped`, and nothing goes on the network. A weight you entered stays.

**TM12. Deletion.**
1. Delete an item with an external photo on a device, and app data size falls.
2. Reset All Data (`V/SettingsView.swift:311`): trips, custom templates and in-memory thumbnails all go. In 2.0, both consent keys go too, and `DELETE /v1/me` is called only if consent was granted when the reset started, because "ever granted" can't be read after a revoke (`specs/data-model.md` section 10).
3. On a dev-signed device with iCloud on, add a photo under 128 KB, Download Container, and copy a 32-byte run from the middle of the stored value. Reset All Data, wait for the export, relaunch, Download Container again, and search every file as downloaded, before any checkpoint, for that run, including `PacBagModel_ckAssets` and `.PacBagModel_SUPPORT/_EXTERNAL_DATA`. Record the result.
4. With rows synced, turn on Airplane Mode and Reset All Data. Settings reads Deleting from iCloud. Force-quit, go online and reopen. When it reads Up to date, delete the app, reinstall and wait for the import. Nothing old returns.
5. Add rows and let them sync. In Airplane Mode reset, delete the app, go online and reinstall. Write down whether the old rows return.

## G4 script


**Two-device script (G4).** A runs the new build and B runs 1.0.1. On Development, both are dev-signed: B from `915f58c`, with `-com.apple.CoreData.CloudKitDebug 1`. On Production, B is the App Store build, and A is TestFlight. Same iCloud account, on the throwaway Apple Account. Start A on 1.0.1 with data, then upgrade it.

Scripts TM5 and TM6 in `test-release.md` cover the same ground for go and no-go. G4a in `milestones.md` is an early run of steps 4 and 7 on Development. Steps 4 and 7 only record what happens: their results feed the copy and the table of what 1.0.1 shows in section 3, and they don't stop anything.

| # | Do | Expect | If not |
|---|---|---|---|
| 1 | Upgrade A over its 1.0.1 data. Once, with 100 MB of photos on the account: first confirm B shows them, so they're on the server. Then upgrade A and record the time until Settings stays on Up to date, since it can show it between setup and import. Also record the growth in app data and any hitch on an open bag. Record only, no threshold | All rows there. Settings says "Up to date" | Stop. Migration or schema |
| 2 | B creates an item. Read it on A | Source reads legacy, estimate 0, not pending, `createdAt` nil. On Development, Download Container and run `sqlite3 PacBagModel.sqlite "SELECT ZWEIGHTSOURCE, ZCATEGORYSOURCE, ZWEIGHTESTIMATEKG, ZCREATEDAT FROM ZITEM WHERE ZNAME = '<name>'"`. On TestFlight, read what shows: a new item at 0.1 reads `unverified` and sorts with the oldest rows in Date Added, and renaming it saves with no alert | Import doesn't fill the default. Stop |
| 3 | A quick-adds "rain jacket" (catalog hit) and an unknown name. Read on B | Both show 0.0kg, since the jacket's estimate is in a field 1.0.1 can't read. No crash | Record it |
| 4 | B renames the jacket. Read on A | Name updated, **source still `catalog`, estimate still there** | **Old client erases fields.** Record it, and record whether the row reads "not weighed" or `unverified` at 100 g (section 1.4). Only copy and section 3 change |
| 5 | B changes the jacket's weight | A shows the new value, labelled "entered" | Record it |
| 6 | B opens the unknown item, Save untouched. Then the same on a second catalog hit. Then A types 12 kg on one row, 40 g on another and 650 g on a third, and B opens each, Save untouched | If the source survived: on A, the unknown item reads `unknown` and `notSorted`, the catalog hit still reads weight `estimate` whatever was written, and the 12 kg, 40 g and 650 g rows read `entered`. Record every written weight, which settles the slider question, including whether Save clamps or rounds to the 0.1 step | If the source went to 0, record it, since that's the erase case. Otherwise fix `weightState` |
| 7 | Both offline. A edits weight, B edits name. Reconnect, wait | Both survive: per-field. One lost: per-record. Record it | Nothing else changes. A per-record result goes in the copy and section 3 |
| 8 | Timing. B background, A edit, B open, timer. Then both on screen, A edit, timer | Numbers for 8.5 | |
| 8a | B on 1.0.1 has imported A's quick-add rows from step 3. Also make one bag on A and one on B, and let both reach the other device. Close B. On A, rename an item and delete both bags. Upgrade B in place with no delete | The quick-add rows and the rename read the same on both devices, with source and estimate on B. Write down which deleted bag stays on B. Apple DTS says a nil-token fetch reports deletes only for records the fetching device created (developer.apple.com/forums/thread/813286), so the bag A made may stay **[unverified]**. Edit a stale row on B and record whether it comes back on A | The result feeds Failure modes and the Reset copy, and it doesn't stop anything |
| 9 | Delete the app on B, install the new build, launch, add an item through quick add within 5 s, then wait for import. Then put 1.0.1 back on B for steps 10 and 11, which works only while the App Store still serves 1.0.1. If the App Store won't replace the TestFlight build in place, delete the app first. A fresh 1.0.1 seeds a second default set on that account (`U/CategoryManager.swift:59-65`), the case step 10 covers, so only do this on the throwaway account. Write down which route you got | Categories settle with no duplicates after reconcile, and items keep their category. Only the quick-added item moves, and A's rows stay the winners | Reconciler bug |
| 10 | Fresh 1.0.1 install on a third device or account reset, which seeds again. Read on A | A merges. B hides losers after relaunch | Same |
| 11 | A Reset All Data | B empties with no crash, and defaults come back without duplicates. B's stale `categories` array could crash on 1.0.1 **[inferred]**, so record it. Relaunch A. Settings returns to Up to date, and A's next edit reaches B | Reset copy or a release note |
| 12 | A adds a photo over 1 MB | Reaches B, no failed export on A in Console.app, Settings back on "Up to date" | Size or schema |
| 13 | Sign A out of iCloud, launch the new build, sign back in | No crash, status row correct, seed gate opens, data intact. What iOS does to local rows on sign-out isn't established | Failure mode entry |

**1.0.1 store fixture and migration test.**

Capture, by the owner. Apple won't hand over an App Store build's container, so build from the shipped commits instead. The rows are synthetic and the account is a throwaway one, never your own data, since this repo is public.

1. Build `915f58c` for a device with dev signing and iCloud on, signed in to the throwaway account. Using the UI, create the named rows in `test-release.md` section 2.8, except F3 and the archived default, plus: a trip with a bag and a sub-bag; items with weight 0.1, 2.0 and a dragged value; General; a template-applied bag, for string-only rows; a custom template saved and applied, for `"Clothes > Tops"`; a deleted custom category, for an archived row; one small photo and one large one. Make both on the Mac as noise images, send them to the device and pick them from there. Keep one under 128 KB and the other well over it, so one stays inline and one goes external (44 KB and 407 KB did **[measured, macOS]**). Don't shoot one, and don't pick anything else from the device's library.
2. In a temporary change, seed a second default set, so duplicates exist, and enough extra synthetic items to reach 1,000 rows, for the timing in section 2. The temporary change also writes what the UI can't: weight 0 on Captured Zero, and `isArchived` on the oldest row of one duplicated default that no named row uses.
3. Xcode, Devices, Download Container. Checkpoint with `sqlite3 PacBagModel.sqlite "PRAGMA wal_checkpoint(TRUNCATE);"`.
4. Before any Core Data code opens the file, run `scripts/store-manifest.sh`, which dumps counts and rows with `sqlite3 -json`, using `hex()` for UUID and blob columns. That output is the manifest. Open the store. Check that `Z_MODELCACHE` exists, that `ZITEM` holds only the synthetic names, and that the `ANSCK*` tables hold none of your own email or name. Check every photo before committing. For inline rows, take `ZPHOTODATA` and drop its first byte, a `0x01` marker **[measured, macOS]**. A row starting with `0x02` is only a pointer, so read the files in `.PacBagModel_SUPPORT/_EXTERNAL_DATA/` instead. Run each file through a short `swift -` script that prints `CGImageSourceCopyPropertiesAtIndex`. T13 doesn't exist yet at this point, so the check lives in this step. Stop if a file is unreadable, if it has `{GPS}`, `{MakerApple}`, `{IPTC}` or `{ExifAux}`, if `{Exif}` holds anything besides `ColorSpace`, `PixelXDimension` and `PixelYDimension`, or if `{TIFF}` holds `Make`, `Model`, `Software`, `HostComputer` or `DateTime`. Those three Exif keys are on clean files (`photo.md` section S7), so they aren't a stop. Open each image and look at it too. What the picker does to these files is **[unverified]**, so read the output of the first capture closely.
5. Commit under `X/stores/1.0.1/`, a folder because external blobs need one, with its row manifest. `X/` resources land flat in the test bundle **[measured, `domain-layer.md`]**, so two folders of same-named stores can't be bundled. So `MigrationTests` reads them by `#filePath`, which works from the Simulator **[measured, `domain-layer.md`]**, and both folders stay out of the synchronized group **[unverified that the exclusion works]**.
6. Repeat at the last S1 commit (`0e220ee` or earlier) for `X/stores/1.0/`, without CloudKit, since S1 stores exist (`understand/history.md`). Temporarily set `cloudKitContainerOptions = nil` at that commit, which is what the later `c9f21be` flag does.

Keep a store captured with CloudKit on, because mirroring metadata tables are part of what real users have.

`MigrationTests`, in Swift Testing, opens a copy in a temp directory through `init(storeURL:cloudKit:)`:

| Test | Asserts |
|---|---|
| `opensAndKeepsEveryRow` | Row counts per entity match a JSON manifest committed with the fixture |
| `noValueChanged` | Every `name`, `weight`, string and relationship equals the manifest |
| `everyRowIsLegacy` | Sources 0, `weightEstimateKg` 0, `createdAt` nil, `pendingFields` empty for all, `pendingFetchRequest` returns 0 |
| `readerTable` | Named rows read the expected state from section 2 |
| `nothingDirty` | `viewContext.hasChanges` false after load and relay start, `plan` non-empty only for stamps and duplicates |
| `reconcilerConverges` | Run, then run again: second plan empty. Duplicates hidden, items still linked |
| `missingModelCache` | With `Z_MODELCACHE` deleted: `loadState == .failed`, and code 134130 surfaced, no crash |
| `reloadFixedStore` | `reload()` after restoring the file gets to `.ready` |
| Also | Run the suite on a created iOS 18.5 simulator device before G4 |

**`SchemaParityTests`.** Beyond the Swift class check in `architecture.md` section 6, it compares the model with `X/schema/production-fields.json`, a list of entity, attribute or relationship, type, optional and `deployed`. A removed or changed entry fails. An unlisted new attribute or relationship fails with: "You added an attribute or relationship. Add it here with deployed false, then do the schema release steps. Every device with a synced zone then refetches it on first launch." The fastlane upload lane refuses to run while any entry says `deployed: false`, so a build can't reach TestFlight with an undeployed field. Default-value changes pass, because they don't change the hash **[measured]**.
