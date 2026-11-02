# PacBag 2.0: single source of truth registry

Design, nothing here is built. Written 2026-11-01 against `0c10439`. Every plan file and every commit follows this. If you need a fact that isn't here, add a row before you add the fact.

**Precedence.** This file wins on owners and names. `architecture.md` wins on product and system decisions. Where a spec disagrees with this file, the spec is stale. Once the registry is copied into the repo (row "This registry" in section 1.6), `docs/ssot-registry.md` wins and this copy is frozen. P numbers are the problems in section 0. G numbers are the gates in `architecture.md` section 7, plus the early versions G4a, G5a and G6a in `milestones.md`. Both documents win over the reports in `evidence/`, including the six proposals (`design/arch-*.md`) and the "expected owner" column in `understand/dry-audit.md` (the names it replaced are in section 2.11).

**Labels.** The plan's `README.md` defines every bracket label, including **[registry]**, and it owns the numbered decisions list that **Owner's call N** refers to. If you disagree with a **[registry]** choice, change it here. A row with no label comes from `architecture.md` or from reading the code, except that any type or member name missing from `architecture.md` section 4 is [registry].

**Paths.** This file owns the shorthand, and every plan file uses it. `A/` = `PacBag/PacBag/`, `M/` = `A/Models/`, `U/` = `A/Utilities/`, `V/` = `A/Views/`, `C/` = `A/Contract/`, `T/` = `PacBag/PacBagUITests/`, `X/` = `PacBag/PacBagTests/Fixtures/`, `B/` = `backend/`, `WEB/` = `/Users/enriccogemha/Developer/pacbag-website/website/`. Line numbers are at `0c10439`. Plan files are named as they sit in the plan folder, which isn't in this repo: `architecture.md`, `milestones.md`, `commits.md`, `specs/*.md`, and the plan's `README.md`. In this file a bare `README.md` is the app repo's, and short website names like `FAQ.tsx` are under `WEB/`. The plan's `README.md` says how report citations like `understand/weight.md` resolve.

**Values in this file are seeds.** Once an owner file exists, it holds the value and this file only points at it. Don't quote a value from here in code or docs. Quota and budget values aren't in this file at all. Section 2.9 names their env vars, and their seeds live only in `specs/cost-ops.md` sections 3 and 4, which don't get copied into the repo.

**Release column.** `1.1` or `2.0` is when the owner has to exist. `now` means it exists today.

## 0. Problems found while building this

These are gaps the design had to fill. Each has an answer, and the tables below assume it. The owner can overrule any of them.

| # | Problem | What the tables assume |
|---|---|---|
| P1 | **The pending fetch and the reader rules disagree.** The fetch is "either source is `unknown`" (`architecture.md` section 5). But a row with source `unknown` and `weight == 2.0` reads as entered, because a 1.0.1 device set it. Sent as-is, it'd burn a call and then be discarded by `applyAI` | `Item.pendingFields` is the one answer: the store fetch narrows by raw source, then this computed property filters by state. `Enricher` never looks at raw source |
| P2 | **The schema-parity test would fail on `currentWeight`.** `architecture.md` deletes the accessor and keeps the attribute, and also has a test comparing entity description to Swift class | The test has an explicit allowlist of one entry: `Bag.currentWeight` |
| P3 | **`retired-claims.txt` can't be one list.** "NO SERVER" is true in 1.1 and must stay. It's only retired at 2.0 | Each line has a gate. The `2.0` lines switch on when `MARKETING_VERSION` reaches 2, and the website's lines follow `SITE_PHASE`. The full list is in section 3.1, and the draft tested `always` and `2.0` |
| P4 | **`disclosure.json` has no release.** Consent is 2.0, but the website diff, in-app legal links and `links` block are needed in 1.1 | It lands in 1.1 with `recipients: []` and `consentVersion: 0` |
| P5 | **Global microdollars need a home.** Postgres has one table, keyed by identity and day, and it wasn't shaped to hold the global reservation | `daily_counters` gets `micro_usd`. Global pools are rows with `id_hash` of `global:production` or `global:sandbox` |
| P6 | **"Always 200" doesn't cover bad input.** A bad JWS, oversized body or malformed JSON still has to return something | Non-200 with no contract body. The app treats every non-200 as transient: nothing is marked, and the next trigger retries |
| P7 | **Per-item failure has no shape.** `unusable` is request-wide, but one bad row in a batch shouldn't throw away the other two | In an `ok` response, `category: "none"` or `grams: null` on one item. `ItemStore.applyAI` sets that field's source to `skipped`, on a field with no value. A field already holding an answer keeps it and its source. Only a literal `null` or `none` from the model means this. A number out of `limits.json` `grams` or a token not in this request goes back as it came, and the client reads it as `.noAnswer` for that field, so nothing's marked and the attempt cap bounds the retries |
| P8 | **Closed. A repeat account has no outcome of its own.** The server holds one day-salted hash, so it can't recognize anyone from one day to the next (Owner's call 18) | A request over its limit gets `quota`, with the next midnight UTC as `resetsAt`, the same for everyone |
| P9 | **Recall has no source value of its own.** A recalled `entered` weight goes to `weight` with source `entered`, a recalled estimate goes to the estimate field with its source, a recalled category from a row reading `entered` gets source `entered`, and one from an estimate row copies that row's source. So renaming a recalled `entered` row keeps the old values, since a rename only flips `catalog`, `aiText`, `aiPhoto` and `skipped`, and it never touches `weight` | Accepted. A rename that changes what an item is should be rare, and the weight stays editable. No eighth enum value. Revisit if a real user hits it |
| P10 | **Text normalization exists on both sides.** The phrase list needs the same matching in Swift and TypeScript, and "same list" doesn't cover the matching rule | `X/crisis_cases.json` holds inputs and expected hits. Both suites run it. Same weaker-than-ideal tie as the wire types. `X/length_cases.json` ties a second copy the same way, `Limits.wireLength(_:)` in Swift against `normalizeInput` in TypeScript |
| P11 | **`architecture.md` replaces 5 of 9 weight sliders.** The other 4 (`V/AddBagView.swift:127,152`, `V/EditBagView.swift:53,78`) stay, still capped at 10 and 50 kg | They stay as sliders, but read their ranges from `limits.json`. Ratchet ends at 4 |
| P12 | **Container ID check.** A unit test would have to read a file outside its bundle | `verify.sh` compares the two strings. Draft tested. Same protection, no path tricks |
| P13 | **`/privacy` or `/privacy-policy`.** `APP_STORE_SUBMISSION.md:30` lists `/privacy-policy`, and the App Store Connect field wasn't read. Your audit checklist names `/privacy` | Canonical is `/privacy`. `/privacy-policy` and `/privacy-policy.html` redirect to it through `next.config.ts`, so old links keep working |
| P14 | **Batch size needs a seed.** Proposals use 25, cost tables assume a blend of 3, and typed names arrive alone (`specs/cost-ops.md` section 1) | `batchMaxNames: 25` **[assumption]**. It's a ceiling, and the cost figure is about arrivals |
| P15 | **Closed. The server can't tell which storefront a request is from.** `AppTransaction` has no storefront in Apple's library model (`specs/backend.md` decision 15) | There's no server-side storefront list. `disclosure.json` `aiOffStorefronts` is the only list, enforced on the device. G1 dumps one real payload to confirm |
| P16 | **Which crisis text does the card show?** Device and server can both supply it | `CrisisCard` always renders the bundled `crisis.json`. The server still returns `message`, so the endpoint meets your rule on its own |
| P17 | **Closed. Fake AI needs fixtures that don't ship.** Fixtures are outside the app bundle by design, and a Debug-only copy of them would be a duplicate | `FakeAIClient` reads `PACBAG_FIXTURE_DIR`, set by `PacBagUITestCase`, with no scheme edit. A hosted test read a host path in the Simulator **[measured, `specs/domain-layer.md`]**, so there's no copy phase |

## 1. The registry

One row per fact. "Collapses" names existing duplicates, so the refactor knows what goes. `commits.md` says who builds what, and in which order.

### 1.1 Weight

| Fact | Single owner | Derived or consumed by | Drift prevented by | Collapses | Rel |
|---|---|---|---|---|---|
| Stored unit: kilograms, as `Double`, per unit | `CoreDataManager` model, stated in a doc comment on `Item.weight` and `Item.weightEstimateKg` | Every Swift reader. `TemplateItem.weight` JSON is also kg | Names carry units: `...Kg` or `grams` (section 2.1). Never `weight` on a new variable | Not stated anywhere today (`understand/weight.md` section 3) | 1.1 |
| Boundary unit: integer grams per unit | `catalog.json` field `grams`, wire field `grams` | `WeightUnit.kg(fromGrams:)` is the one conversion, called by `ItemStore` | Rule `grams-conv`. Test | None today | 1.1 |
| Grams mean per unit, and a pair is one unit | `B/src/ai/prompts.ts` | Catalog tool, server, eval. App only multiplies by `quantity` | Eval rows for shoes | Sonnet looked per-shoe (`spikes/score.md` caveats) | 1.1 |
| Display unit choice | `SettingsManager.weightUnit`, key `settings_weight_unit`, raw values `kg` and `lbs` unchanged. With no stored value, a new install takes `WeightUnit.defaultUnit(for:)` and an upgrade stays on kilograms, and that's written once, so a later region change can't flip it (owner: `specs/domain-layer.md` D17) | `WeightFormatter`, `WeightField` | Rule `weight-format` | Only live reader today is `V/SettingsView.swift:53`, and it doesn't convert | 1.1 |
| kg to lb factor | `WeightUnit` | `WeightFormatter`, `WeightField` | Formatter test | `2.20462` twice in one function, `U/SettingsManager.swift:30,32` | 1.1 |
| Weight text, all surfaces including exports | `WeightFormatter` in `U/WeightFormatter.swift` | Every view, `ExportRenderer`. Words "about", `~`, "not weighed", "entered" live here too | Rules `weight-format`, `kg-literal`. `WeightFormatterTests` in `en_US` and `pt_BR` | 56 lines listed in `understand/dry-audit.md` rank 5, including 15 in `U/SharingManager.swift`, and both `"%.1f kg"` and `"%.1fkg"`. Dead `convertWeight`, `formatWeight`, `formatWeightRange`, `preferredWeightPrecision` (`U/SettingsManager.swift:217-227,327`). Literals at `V/AddTripView.swift:250`, `V/AddBagView.swift:326` | 1.1 |
| Locale decimal separator | `WeightFormatter` | Same | Same test | `specifier:` follows locale and `String(format:)` doesn't, so one screen can mix (`APP_STORE_SUBMISSION.md:74`) | 1.1 |
| Weight input | `WeightField` in `V/Components/WeightField.swift` | `ItemDetailView`, draft form, template edit, sub-bag limit | Rule `slider`, ends at 4 (P11) | Sliders at `V/AddItemView.swift:217`, `V/ItemDetailView.swift:559`, `V/EditTemplateView.swift:285,393`, `V/AddSubBagView.swift:54` | 1.1 |
| Numeric limits used on both sides or in more than one file | `C/limits.json`, read through `Limits` | App input, `B/src/validate.ts`, `ImagePipeline`, `ProxyClient`, `WeightSummary` | Both sides load the file. `ContractTests`. A number used in one file may stay private to that file (for example the 1.2 s debounce and 10-minute delay in `Enricher`) | `0.1...10.0` at 5 sites, `1...99` at `V/AddItemView.swift:197`, `V/ItemDetailView.swift:540`, `V/EditTemplateView.swift:274,382`. Bag slider ranges. Not `ItemLimits` | 1.1 |
| Item weight range | `limits.json` `grams`, seed 1 to 50,000 | `WeightField` derives its kg range from this, so input and server validation can't differ **[registry]** | Same | `architecture.md` section 4 lists "weight input range" and "grams bounds" separately. They collapse to one | 1.1 |
| Old form default, 0.1 kg | `Item.legacyDefaultKg`, read only through `Item.isLegacyDefault(kg:)`, the one comparison with 0.1. Its readers are `weightState`, recall and template apply (`specs/data-model.md` section 9) | Reader rules. An old template's 0.1 applies as `clearWeight(source: .unknown)`, so it reads "not weighed" and can fill | No new default writes it. New defaults are `weight = 0`, source `unknown` | Defaults at `V/AddItemView.swift:12`, `V/EditTemplateView.swift:238`, `M/PackingTemplate.swift:42` go | 1.1 |
| A person's weight | `Item.weight`, kg per unit. It only ever holds a person's number, and 0 means none. Written only by `Item.assignEntered` and `Item.clearWeight` | `Item.knownKg`, `Item.weightState` | Rule `raw-weight`. `ItemStoreTests`: an AI value never reaches it | Today it holds every value, including the old form default | 1.1 |
| Catalog and AI weight | `Item.weightEstimateKg`, kg per unit, and 0 means none. Written only by `Item.assignEstimate`, and cleared by `assignEntered` and `clearWeight`. Owner's call 16, reversible until the 1.1 production deploy | `Item.knownKg`, `Item.weightState` | Rule `raw-weight` | Nothing today | 1.1 |
| Weight value, read | `Item.knownKg`: the person's weight for `entered` and `unverified`, the estimate for `estimate`, 0 for `unknown` | `Item.totalWeight`, `WeightSummary`, template capture, `ItemDetailView`. Recall can't use it, because its dictionary fetch returns raw values, so it reads `Item.RecallRow` values from `Item.recallRows(normalizedName:)`, which gets each state from `Item.weightState(weightKg:source:estimateKg:)`, all in `M/Item.swift` | Rule `raw-weight`, which ends at 0 outside `M/Item.swift`. `ItemStateTests` | 21 raw reads and writes by grep today (section 3.1) | 1.1 |
| Unknown weight | `Item.weightState`, case `unknown`. No test of a raw value means "unknown" | `Item.pendingFields`, `WeightSummary`, all UI | `ItemStateTests` | Nothing today can represent it (`understand/weight.md` finding 3) | 1.1 |
| Weight provenance, stored | `Item.weightSource`, type `FieldSource`. It says where the current answer came from. Written only by the `Item` weight writers in section 2.2, which only `ItemStore` calls | `Item.weightState`, `Item.pendingFields` | Rule `source-write` | Nothing today | 1.1 |
| Weight state, read | `Item.weightState` computed from the reader table in `architecture.md` section 5, through the static `Item.weightState(weightKg:source:estimateKg:)`, which recall also calls, so the two can't disagree | All UI, `WeightSummary`, `ExportRenderer`, recall, `Enricher` | `ItemStateTests` has one case per table row. Views never read `weightSource` | `V/PackingProgressView.swift:140`, `V/BagDetailView.swift:772` style readers that disagree | 1.1 |
| Exact legacy 0.1 in the verdict | `WeightSummary` | Verdict row 5 | Owner's call 8. I recommend yes, with a per-bag "These weights are right" action | None | 1.1 |
| Item total (weight times quantity) | `Item.totalWeight`, `M/Item.swift:30`: `knownKg * quantity`, so it's 0 when `weightState == .unknown` | Everything | Rule `weight-multiply` | 9 copies: `V/AddItemView.swift:226,338,496`, `V/ItemDetailView.swift:171,566`, `M/PackingTemplate.swift:403`, `V/PackingTemplatesView.swift:462,529,662`. The last 4 are on `TemplateItem`, so they need a `TemplateItem.totalWeight` | 1.1 |
| Bag and trip totals | `Bag.itemsWeight`, `Bag.totalWeight`, `Trip.totalWeight` (`M/Bag.swift:64-73`, `M/Trip.swift:85-87`) | `WeightSummary`, all displays | Test: `E + S == Bag.totalWeight` | `V/BagDetailView.swift:152,623`, `V/TripDetailView.swift:376` left out sub-bags | now |
| Stored bag contents weight | None. `Bag.currentWeight` stays as a schema attribute, never written or read | Nobody | Rule `current-weight` ends at 0 in Swift outside `CoreDataManager`. P2 allowlist | 23 write lines: `understand/dry-audit.md` rank 3. Also `updateBagWeight()` and its pack-toggle callers | 1.1 |
| Limit status: E, S, U and verdict | `WeightSummary` in `M/WeightSummary.swift`, type `BagWeightVerdict`. `E` sums person's values, including `unverified` rows and the empty bag. `S` sums estimates of `estimate` rows. Compares in whole grams through `WeightUnit.grams(fromKg:)`, because `0.1+0.1+0.1 > 0.3` in `Double` | Bag header, trip rows, sub-bag gate, exports | Only this type returns a verdict. `WeightSummaryTests` has one case per row of `architecture.md` section 8 | `bagColor` at `V/BagDetailView.swift:231`, `V/BagListView.swift:133`. `bagIcon` at `V/BagDetailView.swift:255`, `V/BagListView.swift:157`. Weight-keyed `progressColor` at `V/BagDetailView.swift:244`, `V/SubBagView.swift:115`. Over-limit tests at `V/BagDetailView.swift:221`, `V/EditBagView.swift:124` | 1.1 |
| Estimate band | `limits.json` `estimateBand`, seed 0.20 **[assumption]** | `WeightSummary` | Gate G6 retunes it in this one place | None | 1.1 |
| Sub-bag available space | `Bag.availableKg`, uses E only | `V/AddSubBagView.swift` gate | Test | `V/AddSubBagView.swift:98,104-106` | 1.1 |
| Bag type defaults | `BagType`, moved to `M/BagType.swift` **[registry]**. Suitcase is 4.5 kg empty, 23 kg limit, new bags only | Add Bag form, `AddTripView` default bag | `T/WeightTests.swift:26-31` is the pin, and it needs rewriting when this collapses | Suitcase is 3.0/20.0 at `V/AddBagView.swift:11-12`, 4.5/23.0 at `:46,61`, and 23.0 with no empty weight at `V/AddTripView.swift:130`. Dead `SettingsManager.defaultBagWeight` (`U/SettingsManager.swift:166`) goes | 1.1 |
| `Bag.bagWeight == 0` meaning | `WeightSummary`: a top-level bag at 0 is unset (`emptyBagUnset`) and widens verdict row 5. A sub-bag at 0 means none. It still counts as entered in `E`. Without the widening, a bag that really weighs 24.5 kg can show 20 kg and read as under. Owner's call 21 | `WeightSummary` | `WeightSummaryTests` row for it, and other rows set an empty weight | 4 meanings today (`understand/weight.md` section 5) | 1.1 |
| Pack Lightest rule | `Bag.lightestItems`, leaves unknown and unverified out | `V/BagDetailView.swift:131-149` | Test | Would pick unknowns first today | 1.1 |

### 1.2 Categories

| Fact | Single owner | Derived or consumed by | Drift prevented by | Collapses | Rel |
|---|---|---|---|---|---|
| Default taxonomy: names, subcategories, order, icons, colours | `C/taxonomy.json`, read through `Taxonomy` | `CategoryManager` seeding, `CategoryReconciler`, catalog tool, `ContractTests`, server never reads it | `ContractTests`: unique keys, every category has icon and colour | 5 lists: `U/CategoryManager.swift:16-25,27-36,38-47,372-380`, 143 literals in `M/PackingTemplateData.swift`. Seed tree is a `Dictionary`, so order isn't stable | 1.1 |
| Whether Gear and Food are defaults | `taxonomy.json` | Same | Owner's call 7. I recommend yes | General holds 26 of 101 template names | 1.1 |
| Default category identity | `Category.defaultKey`, `SubCategory.defaultKey`, values from `taxonomy.json` | `CategoryReconciler`, `CategoryManager.seed`, catalog `categoryKey`, template `categoryKey` | Reconciler tests, including the archived-row case in `architecture.md` section 5 | `name` as the only cross-device key. `isDefault` can't say which default | 1.1 |
| Duplicate default rows | `CategoryReconciler`: per key, the winner is the oldest `createdDate` among active rows, then the lowest UUID | Launch and post-import | `CategoryReconcilerTests` | No dedupe today. `U/CategoryManager.swift:59-65` seeds on a local empty check | 1.1 |
| Category assignment on an item | `Item.categoryEntity` and `subcategoryEntity`, written only through `Item.assign(_:_:source:)`, called only by `ItemStore` | Everything | Rule `item-field-write`, and `fileprivate(set)` on `categoryEntity` and `subcategoryEntity` from the end of M2 | Paired writes at `V/AddItemView.swift:321-324`, `V/ItemDetailView.swift:194-197`, `U/CategoryManager.swift:219-221,226-228,238-239`. String-only at `M/PackingTemplate.swift:393`, `V/PackingTemplatesView.swift:452` | 1.1 |
| Category string mirror | `Item.category`, `Item.subcategory`: a kept copy for 1.0.1 clients, written only by `assign`. No bulk backfill | 1.0.1 clients. `categoryDisplay` as a fallback for old rows. `Item.stringOnlyCategoryNames`, so `ItemStore` and `ItemDraft` can resolve a string-only row | Rule `mirror-write` ends at 0 outside `M/Item.swift`. Never read directly outside `M/Item.swift` | Direct readers at `U/SharingManager.swift:113,188,261,303,355,421`, `V/BagDetailView.swift:772`, `V/PackingProgressView.swift:140,159` | 1.1 |
| Category text on screen and in exports | `Item.categoryDisplay`: entity, then string, then "Not sorted". Includes `" > "` for subcategories | Headers, chips, progress, exports | Rule `cat-separator`, since today's lines interpolate it. `V/CustomCategoryView.swift:63` is the one exception and stays, because it labels a category that doesn't exist yet, so no `Item` can print it | `fullCategory` at `M/Item.swift:44-62`. `" > "` at `M/SubCategory.swift:33`, `V/AddItemView.swift:143,425`. Dead `effectiveCategoryName`, `effectiveSubcategoryName`, `hasSubcategory` go (`understand/dry-audit.md` said reuse them, and `categoryDisplay` replaces them instead) | 1.1 |
| Uncategorized label | The literal "Not sorted" exists once, as `Item.notSortedLabel` | `categoryDisplay`, section sort | Rules `no-cat-labels` and `not-sorted` | `"Uncategorized"` `M/Item.swift:61`. `"Other"` `U/SharingManager.swift:303,355`. `"General"` as a fallback at `M/Item.swift:69`, `V/AddItemView.swift:256,286,429`, `V/EditTemplateView.swift:315,423`, `V/ItemDetailView.swift:72,222`, `V/PackingProgressView.swift:140,159`. General stays as a real default category, key `general`, and is never a fallback | 1.1 |
| Category state | `Item.categoryState` from `categorySource` and the reader table in `architecture.md` section 5 | UI, `pendingFields` | `ItemStateTests` | Can't tell "chose General" from "not sorted" today | 1.1 |
| Section order, "Not sorted" last | `Item.categorySortKey` **[registry]** | `V/BagDetailView.swift`, `ExportRenderer`, `V/PackingProgressView.swift` | Test | 3 alphabetical sorts: `V/BagDetailView.swift:408-409`, `V/PackingProgressView.swift:189`, `U/SharingManager.swift:302-306,354-358` | 1.1 |
| Row lookup and name matching | `CategoryManager.resolve(name:subcategory:)`: live fetch, active rows, normalized with `EntryParser.normalize` | `ItemStore`, template apply, custom templates | Test: an imported row is found by name | `category(named:)` on the stale `categories` cache `U/CategoryManager.swift:313`. Case-sensitive at `:96,349`, `V/AddItemView.swift:303`, `V/ItemDetailView.swift:73,160,223` | 1.1 |
| Icon and colour at display time | The row's `iconName` and `colorHex`. A default row gets them from `taxonomy.json` at seed | All category views | Grep for colour tables keyed by name in review | `V/PackingProgressView.swift:216-233` table. `#007AFF` vs `808080` at `U/CategoryManager.swift:39,322`. `.blue` at `M/Category.swift:43`. `availableIcons`, `availableColors` twice in `V/CategoryManagementView.swift` is listed debt | 1.1 |
| Sub-bag presets | `SubBagType`, which stays its own concept | `V/SubBagView.swift` | Listed debt, no new copies | Not connected to `Category` (`understand/categories.md` section 5). Its raw values are matched against stored bag names (`V/SubBagView.swift:206-209`, `V/AddSubBagView.swift:35`), so they don't follow taxonomy renames | now |
| Usage count | `CategoryManager.recordUse`, no save inside, called only by `ItemStore` and only on a user pick, so a recalled `entered` doesn't count. Automatic assignment never counts | Picker order, analytics | Test: one user assignment adds exactly 1 | Double count at `V/AddItemView.swift:327-332`, `V/ItemDetailView.swift:200-205`, `U/CategoryManager.swift:303`. Hidden save at `:294`. "Unused" advice at `:401` moves to `items.count` | 1.1 |
| Text classifier | `ItemResolver` with `CatalogSource` | Quick add | `suggestCategory` is deleted, so no second one | `U/CategoryManager.swift:368-389`, measured non-deterministic | 1.1 |
| Category tokens on the wire | `FillRequestBuilder` builds them per request from `CategoryManager.activeRowsDeduped()`. `c00..cNN` and `none`. Winner `objectID` captured at build time. Over `categoriesMax`: defaults by taxonomy order, then customs by `lastUsedDate`, first N. A hit is still only an estimate, so a dropped custom costs a sort. The builder cuts a label to `categoryNameMaxChars` raw scalars, only as a size guard. The server normalizes each label, drops one that hits a phrase or comes out empty, and cuts the rest to `categoryNameMaxChars` scalars, never a 400. Only `categoriesMax` stays a 400, and a request over it would retry forever | Server treats them as opaque | Fixtures, compile test in gate G5 | None | 2.0 |

### 1.3 Items, saving and templates

| Fact | Single owner | Derived or consumed by | Drift prevented by | Collapses | Rel |
|---|---|---|---|---|---|
| Item creation and mutation | `ItemStore` (`@MainActor`) in `U/ItemStore.swift`, methods in section 2.2 | All views, `Enricher`, template apply, `CategoryManager` | Rules `item-create`, `is-packed-write`, `raw-weight`, `item-field-write`, `item-delete`. `DataReset` and the Bag and Trip cascades are the planned ways an item row goes away outside `ItemStore` | Create at `V/AddItemView.swift:314`, `M/PackingTemplate.swift:390`, `V/PackingTemplatesView.swift:449`. Update and bag transfer at `V/ItemDetailView.swift:169-215`. Delete at `V/ItemDetailView.swift:228-248`, `V/BagDetailView.swift:626-644`, `V/EditBagView.swift:187-199`. Item writes at `U/CategoryManager.swift:219-239` | 1.1 |
| Item identity at insert | `ItemStore.create` sets `id` and `createdAt`. `ItemStore.requestEstimate` stamps `createdAt` on a legacy row, so eligibility stays one rule, `createdAt != nil`. That row moves in Date Added sort, and for it `createdAt` means "joined the fill pipeline" | Date Added sort, other-device delay, recall | Test: two inserts in one launch differ | `itemId.defaultValue = UUID()` runs once (`U/CoreDataManager.swift:163`). Sort by UUID at `V/BagDetailView.swift:436` | 1.1 |
| Save, and what failure does | `CoreDataManager.save() throws`, plus one merge policy `NSMergeByPropertyObjectTrumpMergePolicy`. A failure has one surface, `SaveFailureAlert`, raised from `lastSaveFailure`, and `specs/quick-add.md`'s copy deck owns its wording | All writers, for all entities | Rules `save`, `fatal` end at 0 outside the owner | 29 `.save()` lines with 3 behaviours. `fatalError` at `V/AddSubBagView.swift:122`, `V/ItemDetailView.swift:212`, `V/SettingsView.swift:481`. `saveContext` at `V/BagDetailView.swift:155,647`, `V/TripDetailView.swift:131,393`, `U/CategoryManager.swift:146`. `try?` at `V/ItemDetailView.swift:257,305,621` | 1.1 |
| Store load failure | `CoreDataManager.loadState`, shown by one failure screen | `PacBagApp` | Test with a bad store | `U/CoreDataManager.swift:43-48` only prints | 1.1 |
| UI refresh on child change | `ItemChangeRelay`, started once by `CategoryManager.startUp(using:)`. Reads inserted, updated, refreshed and deleted. Also drives `CategoryManager.refresh()` and `photoChanged` | Bag, trip, sort cache, thumbnails. From 2.0, `PhotoIntake` hears a delete through `photoChanged` while it holds the id (owner: `specs/photo.md` S3) | Probes S1 and S10 turned into a test | Sort cache `V/BagDetailView.swift:600-611`, dead `needsResort` `:446-450` | 1.1 |
| Pack state and bulk pack | `ItemStore.setPacked(_:packed:)`, `setPacked(bag:packed:)` | All pack toggles | Rule `is-packed-write` | 16 lines by grep, including 2 in preview and dead code, and 2 `toggle()` calls at `V/BagDetailView.swift:616`, `V/ItemDetailView.swift:620`. Bulk at `V/BagDetailView.swift:112-129,576-590`, `V/EditBagView.swift:202-212`, `V/TripDetailView.swift:370-391`, which use direct items only | 1.1 |
| Bag tree walk | `Bag.allItems`, `Bag.allBags` | `WeightSummary`, `ExportRenderer`, bulk pack, progress | Test | `M/Bag.swift:42-52,64-68`, `M/PackingTemplate.swift:263-285`, `V/ItemDetailView.swift:40-64`, `V/CustomTemplateCreationView.swift:169-172`, `V/PackingProgressView.swift:157` | 1.1 |
| "Items" count | `Bag.totalItemsCount` counts rows. Quantity isn't an item count | Everything. "3 not weighed" counts rows | Listed debt for `V/PackingProgressView.swift:141`, which counts quantity | Two definitions (`understand/dry-audit.md` finding 9) | 1.1 |
| Typed text parsing | `EntryParser` | `QuickAddBar`, crisis check input, recall | Parser tests, 100 hand-written rows from `spikes/` | None | 1.1 |
| Name normalization | `EntryParser.normalize(_:)`: lowercase with a fixed locale, strip diacritics, non-letters and non-digits to a space, collapse spaces, drop a trailing `s` from tokens over 3 characters unless they end in `ss`. If nothing's left, the key is the trimmed, lowercased original text. `String.trimmedOrNil` for trim and empty-to-nil. Crisis matching has its own rule and never stems | Recall, catalog, `CategoryManager.resolve`, token dedupe | Rule `trim`, a no-new-lines ratchet on `trimmingCharacters` from the day the owner exists. Rule `name-compare`. The server has no copy: `normalizeInput` and the crisis rule are different functions, with different jobs | 44 trim lines. `V/AddItemView.swift:317`, `V/ItemDetailView.swift:190` test `isEmpty` before trimming | 1.1 |
| Fallback item name | `Item.displayName`, `Bag.displayName`, and from 2.0 `Item.photoPlaceholderName` | All views | Rule `fallback-name` | 10 lines (`understand/dry-audit.md` rank 24). No row ever has an empty name, since a blank name would print blank in exports. `create` with a photo and no name stores the placeholder, and an empty edit reverts | 1.1 |
| Which source answers a field, and in what order | `ItemResolver.sources()`, one ordered array: own row reading `entered`, photo, own-row estimate, catalog. `specs/quick-add.md` owns its 1.1 build, which has no photo parameter and no photo entry. 2.0 adds `photo: PhotoAnswer? = nil`, so earlier callers don't change. Claude text isn't in the array, since it only fills what's left | Quick add, photo apply | `ItemResolverTests` on this order | None | 1.1 |
| Own-item recall rule | `YourItemsSource`, with tiers `.userValues` and `.estimates` from the start, fetching through `Item.recallRows(normalizedName:)`. `specs/quick-add.md` owns its 1.1 build | `ItemResolver` | Tests for each clause of `architecture.md` section 10 | None. See P9 | 1.1 |
| Typical item values | `C/catalog.json`, read through `Catalog`. Generated by `B/tools/catalog` and reviewed by owner, or hand-built on the branch `specs/prompts-evals-catalog.md` section 2.7 owns | `CatalogSource`, `templates.json` by key | `ContractTests`: every `categoryKey` is in the taxonomy. Catalog is never browsable | 143 template literals. First Aid Kit at 0.3, 0.5, 0.8 | 1.1 |
| Built-in templates | `C/templates.json`: catalog key, quantity, optional override. `BuiltInTemplates` builds each `TemplateItem` from its catalog row: `weight` from `WeightUnit.kg(fromGrams:)`, and `weightSource` and `categorySource` both `catalog` | Template screens, `ItemStore.apply(template:to:)` | `ContractTests`: every key is in the catalog. `TemplateStoreTests`: a built-in gives `weight` 0, the catalog value in `weightEstimateKg`, both sources `catalog` and state `estimate`. Replacing template weights is Owner's call 9. I recommend yes, new applications only | `M/PackingTemplateData.swift` | 1.1 |
| Template to item mapping | `ItemStore.apply(template:to:)`, `apply(templateItems:to:)`. Sets entity through `assign`, and weight through the `Item` weight writers. The category source comes from `TemplateItem.categorySource`, and absent means `entered`, so custom templates and old blobs keep their behaviour. No `isDefault` parameter | `M/PackingTemplate.swift`, `V/PackingTemplatesView.swift` | Rule `item-create` | `M/PackingTemplate.swift:389-405`, `V/PackingTemplatesView.swift:448-464` | 1.1 |
| Item to custom template | `TemplateItem(item:)`, category and new `subcategory` from row names only, never `categoryDisplay`. Weight comes from `knownKg`, so a captured estimate keeps its value. Provenance is `TemplateItem.weightSource: Int16?`, one field for one fact, and `specs/data-model.md` section 9 handles 0.1, a torn row and old blobs. `TemplateItem.categorySource` stays absent here | Custom templates in `CustomPackingTemplates` | Test. Old stored `"Clothes > Tops"` strings resolve by splitting on `" > "` in `resolve` | `M/PackingTemplate.swift:270` stores display text as data. `"Uncategorized"` gets captured | 1.1 |
| Item form | `ItemDetailView(mode:)`, `.saved(Item)` or `.draft(ItemDraft, in:)`, over `ItemDraft` and `ItemChanges`. A saved item has live fields, with no Edit, Save or Cancel. Each field commits on end of editing and sends only what changed through `ItemStore.update`, fields the user isn't focused on follow the live item, and photo actions commit at once. That removes the stale write and a mode. The cost is no way to cancel an edit on a saved item, which is Owner's call 17. Draft mode keeps Cancel and Add, so a details path never leaves a row behind | Add details path, every edit | Sends only changed fields to `ItemStore` | `V/AddItemView.swift` is deleted. Stale write at `V/ItemDetailView.swift:189-197`, General seed at `:72`. Template forms are listed debt | 1.1 |
| Fill state in a row | `ItemRowContent(item:compact:)` in `V/Components/ItemRowView.swift` reads `weightState`, `categoryState`, and `Enricher.inFlight` for skeletons. `ItemFillLine` is private to that file and calls `ItemFieldBusy` **[registry]**, in `V/Components/`, which holds the field rule and the 300 ms wait, since `inFlight` has no timestamps (owner: `specs/quick-add.md` section 5). Item detail shares it. Fill from photo also redacts while `PhotoIntake.filling` holds the id (owner: `specs/photo.md` S4) | `ItemRowView`, `QuickAddBar` strip, `ItemDetailView` | `inFlight` means send to result, for both kinds, never the debounce wait. It also dedupes the drain, so debounce ids would never be sent, and offline users would see skeletons. `ItemFieldBusy` reads busy once an id has been in for 300 ms, so a fast failure never flashes, and a short plain "Not sorted" before it is honest | Row variants `TemplateItemRow`, `EditableTemplateItemRow` are listed debt. `EnhancedItemPreview`, `ItemPreview` go with `AddItemView` | 1.1 / 2.0 |
| Export content | `ExportRenderer` in `U/ExportRenderer.swift`: one walker, three renderers | `ShareView` | Golden-file test per format | 6 generators, `U/SharingManager.swift:60-436`. Sub-bag items counted but not listed. Names reach Markdown and RTF raw | 1.1 |
| Erase all data | `DataReset.eraseAll() async throws` **[registry]**. Order: capture `consent.isGranted` and call `Enricher.consentChanged()`, delete all rows of 5 entities with one save, seed, notifications, `CustomPackingTemplates`, `CustomPackingTemplatesBackup`, `CustomPackingCategories`, `settings_sync_notice_dismissed`, `settings_upgrade_note_shown`, both consent keys, `SettingsManager.resetToDefaults()`, template manager, `ImagePipeline.evictAll()`, temp export files. Last, `DELETE /v1/me` only if consent was granted at step 1, best effort, so a failed erase changes nothing. It can't go by "ever granted", because after a revoke the key holds 0. The consent and `Enricher` steps, `ImagePipeline.evictAll()` and `DELETE /v1/me` join in 2.0, when their owners exist. Right after the row save it also sets the one-shot `settings_scrub_store_next_launch`, and `settings_sync_erasing_since` unless sync is off or has no account (owner: `specs/data-model.md` sections 6.3 and 10). Alert copy is `specs/data-model.md` section 10 | Settings "Reset All Data" | Test that each store is empty after | Misses custom templates today. `WEB/src/app/privacy-policy/page.tsx:130` points to "Reset App", which only resets onboarding | 1.1 |
| Pending work | Nowhere stored. `Item.pendingFetchRequest()` (`createdAt != nil` and a source is unknown, no limit, newest first so a backlog can't spend the quota ahead of what was just typed), then `Item.pendingFields` (P1). `pendingFields` is empty when `createdAt` is nil or `isPhotoPlaceholder`, and `Enricher` has no placeholder check of its own. Legacy rows join only through `requestEstimate`, so a kill mid-call retries instead of stranding the row | `Enricher`, `WaitingRow` count | No stored copy exists to drift | None | 1.1 |

### 1.4 Store, sync and photos

| Fact | Single owner | Derived or consumed by | Drift prevented by | Collapses | Rel |
|---|---|---|---|---|---|
| Data model | `CoreDataManager` code-built model | `@NSManaged` declarations repeat it, on purpose | `SchemaParityTests` walks entity descriptions against Swift classes (P2). Docs keep shape only, not attribute lists | Attribute lists in `DEVELOPMENT.md:24-30`. Empty `A/PacBag.xcdatamodeld`, removed only after an upgrade test on a 1.0.1 store | 1.1 |
| CloudKit container ID | `A/PacBag.entitlements:7`. The string in `U/CoreDataManager.swift:39` is a kept copy | `README.md:45` drops the string | `verify.sh` check `container-id` (P12). No xcconfig (`architecture.md` section 6) | `A/Info.plist:21` declares `iCloud.$(CFBundleIdentifier)`, a different ID. Looks vestigial. Remove in its own commit, then check on TestFlight | now |
| Bundle ID | `project.pbxproj` `PRODUCT_BUNDLE_IDENTIFIER` | `fastlane/Appfile:1`, `B/src/identity.ts` constant | Add a `verify.sh` check when `identity.ts` exists | `APP_STORE_SUBMISSION.md:13` becomes a pointer | now |
| Production schema step | `APP_STORE_SUBMISSION.md`, numbered release step | Release | `release-check.sh` greps the production export. The real check is the TestFlight run on production, which is also a numbered release step | No step anywhere today | 1.1 |
| Sync status | `CloudKitEventObserver` | Settings row, `CategoryReconciler` trigger, trip list line for `.quotaFull` | No hard-coded status | Hard-coded "Syncing" at `V/SettingsView.swift:439-450` | 1.1 |
| Row thumbnails | `ItemThumbnail`, reloaded by `ItemChangeRelay.photoChanged`. Memory only, keyed by `objectID`, in a cache with a count limit of 200 **[assumption]** (owner: `specs/photo.md` section S7), and the row itself never reads `photoData`. No disk cache, so hard deletion has one less file. In 1.1 it decodes through `Item.image(fromPhotoData:)` and downsizes with `UIImage.preparingThumbnail(of:)` before holding the image. In 2.0 the decode changes to `ImagePipeline.thumbnail(for:from:)`, and `ItemThumbnail`'s own cache goes, since the pipeline caches with the same limit | `ItemRowContent` | Rule `image-decode` | The `photoLoaded` latch at `V/BagDetailView.swift:701,739-741`, which never reloads a changed photo | 1.1 |
| Photo processing | `ImagePipeline` in `U/ImagePipeline.swift`. `Item.image(fromPhotoData:)` is the one decode site until 2.0 | Store, thumbnail, upload | Rule `image-decode` ends at 1 in 1.1 and 0 in 2.0, and also matches `CGImageSourceCreate`, `CGImageDestinationCreate`. Test reads properties back and finds no GPS or Exif. Stored bytes are never sent directly | Loaders at `V/AddItemView.swift:349-359`, `V/ItemDetailView.swift:250-261`. Decodes at `M/Item.swift:38-41`, `V/AddItemView.swift:369,436`, `V/BagDetailView.swift:719-743` | 2.0 |
| Photo sizes and upload bytes | `limits.json` `image` | `ImagePipeline`, server | Both sides read it | None | 2.0 |
| Document, text and face checks before upload | `PhotoPreflight`, including the keyword signal, and faces under Owner's call 19. The plan default covers faces and adds a consent clause in `disclosure.json` `consent.clauses` with `requires: photo`. Reversing the call removes both. Document words, MRZ and Luhn also exist in `B/src/validate.ts`, on purpose, because input, trigger and outcome differ (`architecture.md` section 6). Adding a language means checking both rows | Add and Fill from photo | Best-effort, stated in `architecture.md`. Test on synthetic set | None | 2.0 |
| Fixed names for documents | `DocumentKind`, Swift enum with display name ("Passport") and phrase ("a passport"). UI says "driver's license", case name stays `driversLicence` | `ItemStore.applyAI` | Fixture covers each case. Model text is ignored when kind isn't `none` | None | 2.0 |
| Camera permission text | `A/Info.plist`, one copy rather than two build settings. The text is the camera usage string in `specs/photo.md` section S9, and counsel can edit it. It's required whenever `CameraPicker` ships, and a text-only build leaves out its second sentence | `CameraPicker` | App Review | `showingCamera` never set, `V/AddItemView.swift:24,242,365` | 2.0 |

### 1.5 AI, server and contract

| Fact | Single owner | Derived or consumed by | Drift prevented by | Collapses | Rel |
|---|---|---|---|---|---|
| Consent state | UserDefaults `settings_ai_consent_version`, plus `settings_ai_consent_offered_version` used only to stop automatic offers and the camera's offer, read through `AIConsent` (`isGranted`, `shouldAutoOffer`, `grant()`, `decline()`, `revoke()`). An `Int`. Granted when it equals `disclosure.json` `consentVersion`. Absent or 0 means not granted, so "declined" and "not asked" are one state | `AIAvailability`, `ConsentSheet`, Settings toggle | `AIConsentTests`. Per device, cleared by `DataReset` | Don't reuse `smartSuggestions` or `autoPackingList` (`U/SettingsManager.swift`), which go | 2.0 |
| Consent copy | `disclosure.json` `consent`, as `clauses[]` with `requires`, filtered by `features` | `ConsentSheet` | Test: `features.photo == false` produces no photo clause. Counsel edits one file | Draft in `specs/compliance.md` section 2.1 is a seed | 2.0 |
| AI availability | `AIAvailability` in `U/AI/AIAvailability.swift`, built in the AI client work (`specs/ai-client.md`) before the consent, storefront and status line work adds to it: a value computed from consent, storefront list, identity, build features, last `paused` or `quota`. Asked per kind through `Enricher.availability(for: FillKind)`, because `quota` and `paused` holds are per kind and the wire doesn't name the kind. The first match wins, in the order `specs/ai-client.md` S5.3 owns | `Enricher`, `QuickAddBar`, Settings, photo actions | Views switch on this and never check inputs. Each row of `architecture.md` section 9 is one test, and one test revokes consent during each hold | None | 2.0 |
| What's enabled in this build | `disclosure.json` `features`: `text`, `photo` | `AIAvailability`, consent, labels, website, server (`features.photo == false` returns `paused` for photos) | Website diff | None | 2.0 |
| Kill switch | `AI_ENABLED` env var. Only exactly `true` turns AI on (section 2.9) | `POST /v1/fill`, in the chain's order (section 2.8), `/healthz` | No `/v1/config`. App learns only through a `paused` outcome | None | 2.0 |
| Photo fill switch | `PHOTO_FILL_ENABLED` env var. Only exactly `true` turns photo fills on. Anything else returns `paused`, `resetsAt: null` on a photo, like `features.photo`, so it can stop the path with the sensitive data and leave text running | `POST /v1/fill`, in the chain's order (section 2.8) | Test | None | 2.0 |
| Photo weight withheld | `PHOTO_WEIGHT_ENABLED` env var | `B/src/validate.ts` returns `grams: null` | Test | None | 2.0 |
| AI-off storefronts | `disclosure.json` `aiOffStorefronts`, ISO alpha-3, read against `Storefront.countryCode`. It's the only list, enforced on the device (P15). Anthropic's Supported Regions Policy sets the always-off part. Owner's call 5 sets the rest. While the list isn't empty, `Enricher` holds the last code it read. `storefrontOff` means the held code is on the list. A nil or unread code isn't on the list, so the consent path stays, and `ProxyClient.fill` throws `.offline` on a nil or listed code, so no name leaves (owner: `specs/ai-client.md` S5.3) | `AIAvailability`, `ProxyClient` | Website diff. `ContractTests` holds every entry to `^[A-Z]{3}$`, so `DE` can't silently match nothing | None | 2.0 |
| Model IDs | `CLAUDE_MODEL`, `CLAUDE_MODEL_PHOTO` read in `B/src/ai/config.ts`, default `claude-opus-5-5` | `llm`, `B/tools/catalog`, `B/eval` import it | Rule `model-literal`. App and policy never name a model. Moving to a cheaper model is Owner's call 2 | None | 1.1 |
| Price per model | `PRICES` and `GEO_MULTIPLIER`, in `B/src/ai/config.ts` | `quota` reservation | Server refuses to boot on a model with no price | Price tables in docs are dated analysis, not config | 1.1 |
| Request parameters | `B/src/ai/config.ts`, as `specs/backend.md` section 8: `EFFORT`, `maxTokens(kind, n)` (`1024 + 96n`, photo 2,048), `INFERENCE_GEO`, `attemptTimeoutMs(kind, n)` (text `Math.max(15_000, Math.min(8_000 + 800 * n, 30_000))`, photo 30,000 **[assumption, G5]**), `SDK_MAX_RETRIES` (0, with one manual retry in `llm.ts`), `PROMPT_TOKENS` (seeds 1,100, 1,550), `TYPICAL_TOKENS`, `typicalMicroUsd(model, kind, n)`, `reserveMicroUsd`, `BILLED_REFUSAL_CATEGORIES` (dated, because Anthropic's docs say the list may change). Text numbers settle at G5 and photo numbers at G6. `thinking` omitted. No `fallbacks` at launch, and gate G5a tests them. If they're turned on, `reserveMicroUsd` must cover the fallback model's price (Owner's call 29) | `llm`, `quota`. `B/tools/cost-model.ts` imports `TYPICAL_TOKENS` in place of constants of its own | Same module | None | 1.1 / 2.0 |
| Prompts | `B/src/ai/prompts.ts`, drafts in `specs/prompts-evals-catalog.md` section 2.5: `WEIGHT_RULES`, `TEXT_SYSTEM`, `PHOTO_SYSTEM`, `CATALOG_SYSTEM`, `renderTextMessage`, `renderPhotoMessage` | `llm`, `B/tools/catalog`, `B/eval` | App has no copy. Paid eval before any prompt change. Repo is public, Owner's call 13 | None | 1.1 |
| LLM output schema | `B/src/ai/schema.ts`, `specs/prompts-evals-catalog.md` section 2.4: `TEXT_SCHEMA`, `PHOTO_SCHEMA`, `CATALOG_SCHEMA`. Grams nullable, photo is one object | `llm` for `TEXT_SCHEMA` and `PHOTO_SCHEMA`, the catalog tool for `CATALOG_SCHEMA` | Separate from wire types because structured output rejects `minimum`, `maximum` and length bounds (`research/hosting.md`). `validate` enforces them from `limits.json` | None | 1.1 |
| API request and response shape | `B/src/wire.ts`, with `parseFillRequest` and `assertFillResponse`, and `U/AI/WireTypes.swift`, tied by `X/fill/*.json`. Kept duplicate 3 in `architecture.md` section 6 | `ProxyClient`, `FakeAIClient`, route | Swift decodes and TS validates every fixture in both suites. A fixture change fails the side you forgot. Weaker than your rule, and the alternative ends zero dependencies | None | 2.0 |
| Outcome and status codes | Section 2.8. `FillOutcome` on both sides, tied by fixtures | `Enricher`, `ItemStore.applyAI` | One fixture per outcome. Exhaustive `switch`, no `default` | None | 2.0 |
| Mapping Anthropic failures to outcomes | `B/src/ai/llm.ts`, function `outcomeFor`, with `resetsAt` per cause (`specs/cost-ops.md` section 7.2, 15 min default, `retry-after` when sent) and `upstreamPausedUntil`. `SDK_MAX_RETRIES` is 0, so `retry-after` reaches this function. `llm.ts` retries once by hand on 408, on 429 other than `enforced_spend_limit_reached`, on 5xx and on a timeout or connection error, unless the response says `x-should-retry: false` or the route deadline can't cover a full attempt (owner: `specs/backend.md` section 8). A refusal or invalid output with `n > 1` calls each name alone, concurrency 4, so one refused name can't mark its neighbours. The client never splits a batch. `max_tokens` retries once at double, then 502, because a wrong token budget is our bug and mustn't sync a permanent mark. Invalid output on one name or a photo is 502 for the same reason, and during isolation such a name is left out of `items`. If isolation leaves nothing in `items`, or any other `ok` would carry no items, the response is a 502. A timeout with `n > 6` **[assumption]** is a 502 too, with the timeout row's accounting in section 2.8, so the client's existing halving shrinks a batch that's too slow. At `n <= 6` a timeout stays `paused`, so a real outage still reaches the 15-minute hold. The client's attempt cap bounds the retries, and `fillOk` sees it, because 502 isn't `ok`. `unusable` stays for a refusal and the photo nothing-found rule. A refusal-only result counts toward `fillOk`'s streak for its kind, and once that streak is at 5 the route answers `paused`, now + 15 min, in place of the mark (owner: `specs/backend.md` section 2) | Route | A test per case: a single-name refusal is `unusable`, failed validation on one name or a photo is 502, isolation that leaves nothing in `items` is 502, a timeout at `n > 6` is 502, all other 4xx and 5xx are `paused`, including 400 workspace limit and 429 tier cap | None | 2.0 |
| Server self-test | `B/src/server.ts`, on Railway only, at boot and every 12 hours while `AI_ENABLED` is `true`: one text call through the real render, `llm` and validate paths, with a fixed name and a fixed two-row category list, no identity and no user data (owner: `specs/backend.md` section 8). Only a 200 with no usable value fails it, and `fillOk` then reads false until a pass. Until a pass, `routes/fill.ts` holds empties on the text route: a name with `grams: null` or `category: none`, refused names included, stays out of `items`, a single-name `unusable` becomes a 502, and if nothing's left the response is a 502. Photos stay out of it, since each is one tapped row | `/healthz`, the chain | Test | None | 2.0 |
| Identity | `B/src/identity.ts`, which derives one day-salted hash, `id_hash`. So the server can't recognize someone from one day to the next, and there's less to disclose and less to run. Lower quotas and the kill switch are the only tools against one repeat account until App Attest ships (Owner's call 18) | Quota, delete | `enableOnlineChecks` stays off, confirmed from the library's source (`specs/backend.md` decision 14). Gate G1 tests behaviour | None | 2.0 |
| Quota and budget numbers | Env vars in section 2.9. Not in `limits.json`, app, policy or copy | `B/src/quota.ts` | No number in UI copy, only `resetsAt`. Seeds live only in `specs/cost-ops.md` sections 3 and 4 **[assumption]**, which don't get copied into the repo. Owner's call 3 | None. Quotas stay out of `limits.json`, since attackers can read it and raising a budget would need a deploy | 2.0 |
| Sandbox multiplier | Constant `SANDBOX_QUOTA_MULTIPLIER` in `B/src/quota.ts` | Same | Test | None | 2.0 |
| In-flight ceilings | `MAX_INFLIGHT` and `MAX_INFLIGHT_PER_IDENTITY`, constants in `B/src/server.ts`, with seeds in `specs/backend.md` section 2. The per-identity count is an in-memory `Map` keyed by `id_hash`, held until the response ends or the socket closes. `/healthz` and `DELETE /v1/me` stay outside both | The chain | Test | None | 2.0 |
| Crisis text | `C/crisis.json` `message`, plain form, built in 1.1 with quick add (`specs/quick-add.md`). English (Owner's call 14). Buttons are in the same file, in the order the fixed text names them: `tel:988`, `sms:988`, the 988lifeline.org chat URL and the findahelpline.com URL. All three 988 buttons carry `regions: ["US"]`. Buttons whose regions don't include the current region move below the others, so outside the US findahelpline.com comes first. None is removed, and an unknown region keeps file order (owner: `specs/compliance.md` section 2.7). That falls under Owner's call 14 too | `CrisisGuard`, `CrisisCard`, `B/src/crisis.ts` | Rule `crisis-literal`. Both suites compare to `X/crisis_response.json`, a deliberate test-only copy that catches accidental edits. `~/.claude/CLAUDE.md` section 4 stays the rule's statement, with `**` removed for storage | Two forms in your rules docs | 1.1 |
| Crisis phrases | `C/crisis.json` `phrases`: corpus list minus `kms`, keeping `self harm` and `self-harm`. The known false hit on those two is a pasted injection string that costs a dismissible card, and missing a real one is the worse error. The matching rule is in `X/crisis_cases.json`, and the server ports it in `specs/backend.md` section 6 | `CrisisGuard`, `B/src/crisis.ts` | P10 cases run on both sides. Recall on the corpus was 53 of 61, written together, so optimistic | None | 1.1 |
| Crisis flow | `CrisisGuard` on device at quick add's commit, at the Name field's commit in `ItemDetailView` in both releases, at draft mode's Add, before each drain, on OCR text and on custom category names. A hit at the Name field calls `presentWhenActive()` and sets `ItemChanges.nameHitCrisis`, so `update` saves the name, skips the resolver and sets fields with no answer to `skipped`. `nextTicket()` keeps its check for phrases added by a later build. On server: identity, parse, then `B/src/crisis.ts` on item names, ahead of kill switch and quota, because the endpoint must halt on detection even while AI is paused. A category name that hits is dropped silently, because categories go out on every request and a halt would show the card on every later item. Then `self_harm_signal` and a phrase check on a model `name`. These readings are Owner's call 14. `CrisisCardPresenter` in `V/CrisisCard.swift` shows the card on the topmost view controller, so an open sheet needs no second window. `present() -> Bool` is for `Enricher`: it returns false when no active scene can show the card and holds nothing, and `Enricher` is the only holder of server results. `presentWhenActive()` is for device callers (the commit paths, draft mode's Add, OCR, category forms), and it keeps one flag, since they have no item state to protect. A form that closes itself on commit closes first and presents after the close, through the sheet's `onDismiss` and `onCrisisHit` (owner: `specs/ai-client.md` S6.3) | Commit path, `/v1/fill` | Chain order is fixed in `routes/fill.ts`, one route, so nothing skips it. Server converts `explicit` to `crisis`, so Swift never sees the flag | None | 1.1 / 2.0 |
| What the server logs | `B/src/logger.ts` allowlist, typed by `RequestLog` and `FatalLog`, including `daily_rollup`, which `quota.sweep()` logs for yesterday on its first run of a new UTC day, with the fields `specs/cost-ops.md` section 7.4 owns. Every POST writes the same neutral request line, whatever the result: no `outcome`, no `categories_dropped`, and no field that's set only on a crisis hit. `error_class` is the closed list in section 2.9. No `anthropic_request_id`, because with Railway's IP logs it links a person's request to content held at Anthropic (Owner's call 27). Railway's own HTTP log still keeps each request's IP, time, size and duration, so someone reading it closely might infer a crisis response while traffic is low. The policy says so, and counsel has the question (L25) | All server code | Canary test greps logs for item text. A test compares a crisis line's keys with an ordinary line's. Rule: no `console.` in `B/src` | None | 2.0 |
| Server deletion | `DELETE /v1/me` removes yesterday's counter and keeps today's, since otherwise one script can reset its cap with one extra call. That's Owner's call 18, pending counsel (lawyer item L9), and the policy says so. Sent only by `AIConsent.revoke()` and by `DataReset` when consent was granted at its first step. `quota.sweep()` runs at boot and hourly and removes rows with `day < today - 1` | `DataReset`, consent withdrawal | Test. Check `retention-copy` ties that rule to the copy's "within 3 days" | None | 2.0 |
| Input and output validation | `B/src/validate.ts`. Inbound rules are in `specs/backend.md` section 7, and outbound rules are in `specs/prompts-evals-catalog.md` section 2.6. One `normalizeInput`, run at parse. Grams: round, then range check, never clamp. A failed range or token check goes out as it came and marks nothing (P7). `MODEL_NAME_MAX_CHARS` is private to this file and caps a model's `name` (owner: `specs/prompts-evals-catalog.md` section 2.6), while `limits.json` `nameMaxChars` caps input. Document words, MRZ and Luhn also exist in `PhotoPreflight`, on purpose (`architecture.md` section 6). Adding a language means checking both rows | `routes/fill.ts` | `validate.test.ts` | None | 2.0 |
| Quota, pause and identity copy | `AIAvailability.statusLine`. Local time, no numbers, never "UTC". The strings are in `specs/cost-ops.md` section 4 | `WaitingRow`, `PhotoCopy` adds "Your photo's saved." Settings shows the `.text` line, or a photo hold's line when text has none (`specs/compliance.md` section 2.1) | Rule: one member | None | 2.0 |
| `WaitingRow` | `V/WaitingRow.swift`, built in the AI client work (`specs/ai-client.md`) before the status line and consent work adds to it. Placed by `QuickAddBar`. It asks `availability(for: .text)`, since everything it counts goes as text. Consent form shows only while `shouldAutoOffer`, since repeating it after a no is a nag. The way back is Settings, Fill from photo or Estimate. Count from `pendingFields` | Bag screen | `AIConsentTests` | None | 2.0 |
| Paid and free eval gates | `specs/prompts-evals-catalog.md` section 2.9, moved into `B/eval/` | Go and no-go | `free.test.ts` | None | 2.0 |
| Eval cost | `specs/prompts-evals-catalog.md` section 2.10, replaced by pilot `usage` | `architecture.md` section 14 points here | By hand | None | 2.0 |
| Cost tables | `B/tools/cost-model.ts`, prices imported from `config.ts`. It holds no quota or budget numbers, so it can stay public. Until it exists, `specs/cost-ops.md` holds the tables | `docs/operations.md`, with names and multiples in place of budget values. Other repo docs don't quote MAU and dollar figures | Tables say "generated on date X" | None | 2.0 |

### 1.6 Docs, website and legal

The repos can't share a file (`understand/docs-website.md` section 4), so the rule is one copy with a diff, or link instead of restating. Some rows below rest on a release-day checklist only. Those say "by hand", and they can drift.

| Fact | Single owner | Derived or consumed by | Drift prevented by | Collapses | Rel |
|---|---|---|---|---|---|
| Who receives what, and for how long | `C/disclosure.json` `recipients`, `dataCategories`. User copy says counters go "within 3 days". The 2.0 seed in `specs/compliance.md` includes the photo `nameLanguage` code | `/privacy` page renders these, filtered by `features` the same way `ConsentSheet` is. `ConsentSheet`, review notes. Through `consent.recipientLabel`, the Settings caption and `PhotoCopy` (`specs/photo.md` C47, C47a) | Website copy at `WEB/src/data/disclosure.json`, tied by `verify.sh`. No prebuild fetch, because it could block a legal fix. Check `retention-copy` ties "within 3 days" to `/privacy`, and the reply template in `docs/records-of-processing.md` stays by hand | 72 statements in `understand/docs-website.md` section 2 are the worklist | 1.1 |
| Privacy claims in prose | `WEB/src/app/privacy/page.tsx`. Everywhere else says one line and links | `README.md:78`, `fastlane/metadata/en-US/description.txt:17-19`, `promotional_text.txt:1`, `WEB/src/components/FAQ.tsx:26`, `Pricing.tsx:13-14`, `labels-markings/page.tsx:65-68,84`, `support/page.tsx:90`, `V/LandingPageView.swift:205,371,416`, `APP_STORE_SUBMISSION.md:84-86` | `retired-claims.txt` across both repos (P3) | Same list. `privacy-policy/page.tsx:94` photos claim is false today | 1.1 |
| Allowed promise after 2.0 | `disclosure.json` `promise`, text from `architecture.md` section 13 | Description, FAQ. If Landing ever shows it, it reads `Disclosure.promise` | Those places quote it by hand. Check `promise-copy` compares them, and `retired-claims.txt` catches the old ones | None | 2.0 |
| "We collect user data" statement | `/privacy` page. Not in 1.1 (Owner's call 11, I recommend waiting, since it'd be false) | Consent sheet | Pre-deploy checklist | Opposite claim at `privacy-policy/page.tsx:36,59` | 2.0 |
| AI and third-party disclosure | `disclosure.json` `recipients`, rendered on `/privacy` | Consent, the Settings caption, `PhotoCopy` | Rule: `B/package.json` runtime dependencies are checked against an allowlist in a backend test, and adding one forces a look at this row. Rule `spm-package` holds the app at zero. Rule `recipient-literal` keeps Swift copy from naming a recipient | `privacy-policy/page.tsx:147` "only uses Apple's iOS frameworks" | 2.0 |
| Privacy and Terms routes | `/privacy` (P13), `/terms`, on the shared layout `WEB/src/components/LegalPage.tsx`. URLs in `disclosure.json` `links` | Footer, in-app links, listing, sitemap | Footer and sitemap by hand. `verify.sh` could curl them, not worth it | `privacy-policy.html` stub | 1.1 |
| Contact email and URLs | `disclosure.json` `links`: `marketing`, `support`, `privacy`, `terms`, `appStore`, `contactEmail`. Read by `AppInfo` and `WEB/src/data/site.ts` | In-app links, footer, support page | Rule `web-url` (no URL in Swift, 0 today). Website diff. Check `manifest-url` ties `manifest.json:23` to `links.appStore`. In docs, one line each in `APP_STORE_SUBMISSION.md` | Email at `README.md:89`, `APP_STORE_SUBMISSION.md:88`, `labels-markings/page.tsx:119`, `privacy-policy/page.tsx:186`, `support/page.tsx:118`, `pacbag-website/README.md:62`. App Store URL at `README.md:5`, `APP_STORE_SUBMISSION.md:5`, `manifest.json:23`, `layout.tsx:12`, `AppStoreButton.tsx:7` | 1.1 |
| Version number | `MARKETING_VERSION` in `project.pbxproj`. `AppInfo.version` reads the bundle | Settings About | `verify.sh` check `marketing-version` is one value across its 6 lines. Website states no version at all | `V/SettingsView.swift:452,683` with fallback `"1.0"`. `layout.tsx:137`, `labels-markings/page.tsx:41,156`, `privacy-policy/page.tsx:220`, `support/page.tsx:141`. `APP_STORE_SUBMISSION.md:16` | now |
| Build number | `CURRENT_PROJECT_VERSION` in `project.pbxproj` | Fastlane | `verify.sh` check `build-number` | `APP_STORE_SUBMISSION.md:16,144` | now |
| Minimum iOS | `IPHONEOS_DEPLOYMENT_TARGET` in `project.pbxproj` | `WEB/src/data/site.ts`, one line in `README.md` | `verify.sh` check `min-ios` | `README.md:35,36`, `DEVELOPMENT.md:15`, `APP_STORE_SUBMISSION.md:20`, `layout.tsx:125`, `Pricing.tsx:77`, `FAQ.tsx:50`, `Footer.tsx:163`. `V/SettingsView.swift:643` says iOS 17+ | 1.1 |
| Release state | `APP_STORE_SUBMISSION.md`, one line. App Store Connect is the real source | Nobody | By hand | `:16,37-39,111-114,144-145` disagree | 1.1 |
| Feature list | `fastlane/metadata/en-US/description.txt` | `README.md:11-25` links to it. `WEB/src/components/Features.tsx` owns site wording. `layout.tsx:139-147` keeps its own short strings for JSON-LD, edited by hand. `V/LandingPageView.swift:15-34` is its own short list | By hand at each release. `retired-claims.txt` catches old claims. This is the weakest row, and I don't see a fix that's worth keeping | `ProductDemo.tsx:11-31`, `pacbag-website/README.md:11` | 1.1 |
| Template count and names | `templates.json` | Docs say "ready-made lists" and drop the number | Add "Eight ready-made" and "Eight ship with the app" to `retired-claims.txt` | `README.md:17`, `description.txt:10`, `Features.tsx:27`, `ProductDemo.tsx:19`, `FAQ.tsx:14`, `layout.tsx:142`, `V/LandingPageView.swift:22` | 1.1 |
| Export formats | `ExportFormat`, `U/SharingManager.swift:445` (moves to `U/ExportRenderer.swift`) | Docs name them in one line | Add "save it as a PDF" to `retired-claims.txt`, since `support/page.tsx:72` is wrong today | `DataExportView.ExportFormat` `V/SettingsView.swift:498` goes with the placeholder screen (Owner's call 24). `README.md:23`, `DEVELOPMENT.md:47`, `description.txt:14`, `FAQ.tsx:38`, `ProductDemo.tsx:29`, `layout.tsx:145` | 1.1 |
| Price | `APP_STORE_SUBMISSION.md` for the listing, `Pricing.tsx` for the site | `layout.tsx:129`, `FAQ.tsx:56`, `labels-markings/page.tsx:56`, `V/LandingPageView.swift:368,370` | By hand, and only matters if Owner's call 12 changes | Same list | now |
| Marketing one-liner | `description.txt:3` | `layout.tsx:15` for site metadata | By hand | `manifest.json:4`, `Footer.tsx:73`, `Hero.tsx:51-53`, `README.md:3`, `V/LandingPageView.swift:146` | now |
| Listing fields | `fastlane/metadata/en-US/` text files | `APP_STORE_SUBMISSION.md` links | `Fastfile:58-64` can't push name, subtitle or keywords as written, so this needs a lane change | `APP_STORE_SUBMISSION.md:11-31,50` | 1.1 |
| Review notes, listing copy | `fastlane/metadata/review_information/notes.txt` **[registry]**, `fastlane/metadata/en-US/`. Drafts in `specs/compliance.md` section 2.4 | Fastlane, if the lane reads it **[unverified, it doesn't today]** | `retired-claims.txt` covers "no server and no login" | `APP_STORE_SUBMISSION.md:79-88` | 1.1 |
| App Privacy label, age rating | App Store Connect. A dated copy of the answers in `APP_STORE_SUBMISSION.md` | Nobody | By hand, at submission | Not recorded today **[unverified]** | 1.1 |
| Required-reason API declaration | `A/PrivacyInfo.xcprivacy` | Build | App Store upload checks | Doesn't exist | 1.1 |
| Release steps and go/no-go | `APP_STORE_SUBMISSION.md:135-142`, with enforced items in `scripts/release-check.sh` | `DEVELOPMENT.md` links to it, and the lanes run the script | Review, and the script for enforced items | `DEVELOPMENT.md:76-79`, `APP_STORE_SUBMISSION.md:93-99` | 1.1 |
| Manual test scripts TM1 to TM12, and their run log | `docs/manual-tests.md`, written from `specs/test-release.md` section 3.4 | Go and no-go | Review | None | 1.1 |
| Runbook, rehearsals, weekly checks, usage model, incident list | `docs/operations.md`, names and multiples only | You | Public repo, so no quota values | None | 2.0 |
| How to run the server, env var names | `backend/README.md`, with a link to the runbook | You | Review | None | 2.0 |
| Records of processing, breach steps, request reply | `docs/records-of-processing.md`. The date of each request goes in a private note, since the repo is public | You | Review | None | 2.0 |
| Node version | `backend/.nvmrc` | `engines`, `Dockerfile`, `server.yml` | `deps.test.ts` | None | 2.0 |
| What's not built | `DEVELOPMENT.md:81-90` | `README.md:29` and `FAQ.tsx:14` link or drop it | `retired-claims.txt` | `pacbag-website/README.md:49,54` | 1.1 |
| This registry | This file while planning, then `docs/ssot-registry.md`, copied in M1 and kept current by the habit in section 3.3. The plan folder isn't in this repo, so in that copy the plan file names are references only | Everyone | `verify.sh` excludes `docs/` from claim greps | None | 1.1 |

### 1.7 Rules for fields and fills

The full table of what each action writes is in `architecture.md` section 5.

- Precedence for a field: own row reading `entered`, then photo, then own-row estimate, then catalog. "Reads as" is by state, never raw source. The one raw-source check: recall's `.estimates` tier answers only rows whose raw source is `aiText` or `aiPhoto` (`architecture.md` section 10). A row whose source is `catalog` answers nothing, because `CatalogSource` holds the current value for that name.
- `applyAI` writes an AI value to `weightEstimateKg` only, through `assignEstimate`, and never to `weight`. A photo fill can still recall a person's number from an own row, and that goes through `assignEntered`, the same as at Return.
- Text results fill only pending fields, and a rename drops the whole fill. Photo results may replace anything not reading `entered`. A rename protects only the name, and a changed `photoData` drops the fill, compared by a digest in `FillTicket`.
- `requestEstimate` on a legacy row stamps `createdAt` when nil and sets source `unknown` through `assignEstimate(0, source: .unknown)`. `weight` stays as it is. A legacy 0.1 then reads `unknown` and is pending, and a legacy 0 already reads `unknown`. Any other legacy row reads `entered`, so it isn't offered this action.
- Timed retry (5, 30, 120 s, at most 3 per session) and attempts (3 per item, cleared on an `.active` that returns from `.background`) live in memory and apply to text only. Photos never retry on their own.
- A `quota` or `paused` hold is keyed by `FillKind` and stops automatic drains of that kind. A tap while a hold for that kind is active shows the line and makes no call. A pause under 60 minutes has no line, so `Estimate weight` still runs `requestEstimate`, makes no call at that moment and shows one line from the `specs/quick-add.md` copy deck, and the row fills on the first trigger after the pause.
- `DELETE /v1/me` needs current consent, with two exceptions: the single call made by turning consent off, and the last step of `DataReset` when consent was granted at its first step.

## 2. Canonical names

Use these exactly. Everything listed here is new unless marked existing.

### 2.1 Naming rules

- Variables and JSON fields with a weight carry the unit: `weightKg`, `limitKg`, `grams`. Existing `Item.weight`, `Bag.maxWeight`, `Bag.bagWeight` and `Item.totalWeight` keep their names, since they're schema or widely used.
- JSON files use lowerCamelCase keys. Wire fields use the names in 2.8, which keep `document_kind` in snake case.
- "Source" means `FieldSource`. "State" means `WeightState` or `CategoryState`. "Estimate" is the word for catalog and AI values, in code and UI.
- UI words: "about", "estimate", "entered", "not weighed", "Not sorted". Never "weighed" for a typed value. No em dashes in UI copy.

### 2.2 App types, shipping in 1.1

| Type or member | File | Note |
|---|---|---|
| `CoreDataManager` (existing): `save() throws`, `loadState`, `LoadState`, `reload()`, `lastSaveFailure`, `SaveFailure`, `StoreError` (`notLoaded`), static `model`, `init(storeURL:cloudKit:)`, convenience `init(inMemory:)`, `storeDescription`, static `cloudKitContainerID` | `U/CoreDataManager.swift` | The in-memory seam. `.shared` loads the real store today (`understand/tests-build.md`). Unit tests detect `XCTestConfigurationFilePath`. `init` builds the one `storeDescription` and loads nothing, and `persistentContainer` and `reload()` both use it. On a real store it sets `secure_delete`. `CloudKitEventObserver` subscribes between creating the container and `loadPersistentStores`, only when `cloudKit` is true. `init(inMemory:)` never subscribes and reads `.off`, and `reload()` doesn't subscribe again |
| `ItemStore`: `shared`, `categories`, `create(_ draft:in:)`, `create(_ drafts:in:)`, `update(_:changes:)`, `delete(_:)`, `delete(allItemsIn:)`, `move(_:to:)`, `setPacked(_:packed:)`, `setPacked(bag:packed:)`, `setPacked(trip:packed:)`, `packLightest(in:)`, `apply(template:to:)`, `apply(templateItems:to:)`, `repoint(from:to:subcategoryMap:)` for `Category` and `repoint(from:to:)` for `SubCategory` (no save), `refreshCategoryMirrors(of:)` (no save), `markAllWeightsEntered(in:)`. `ItemStoreError`: `emptyName`, `itemGone` | `U/ItemStore.swift` | `@MainActor`, not `ObservableObject`. `categories` is the `CategoryManager` passed to `init(coreData:categories:)`, and `ItemFormModel` reads it when a field takes the live value (owner: `specs/domain-layer.md` section 2.1). `applyAI`, `requestEstimate`, `localCommits` are in 2.3. A rename runs one private `flipEstimates(_:)`. Each field whose source is `catalog`, `aiText`, `aiPhoto` or `skipped` goes to `unknown` with its answer cleared, the weight through `assignEstimate(0, source: .unknown)` and the category through `assign(nil, nil, source: .unknown)`. `weight` isn't touched, so a person's number survives. Then the resolver runs. A rename away from the photo placeholder keeps `aiPhoto` values and flips only `catalog`, `aiText` and `skipped`. A user clearing a weight is `clearWeight(source: .skipped)`. "Confirm 650 g" is `assignEntered(knownKg)`, which also covers "Confirm 100 g" on an `unverified` row. The reconciler passes its plan's map to `repoint`, and `deleteCategory`'s move passes an empty map, which clears the subcategory as today. `refreshCategoryMirrors(of:)` is the same-row refresh, per item, that `CategoryManager.rename` and subcategory removal need |
| `ItemDraft`, `ItemDraft.CategoryChoice`, `ItemDraft.Field` (`name`, `notes`, `quantity`, `weight`, `category`), `ItemChanges` (adds `confirmWeight` and `nameHitCrisis`), `ItemDraft.changes(from:)`, `ItemDraft.changes(from:only:)`, `ItemDraft.skipBlankFields()`, `ItemDraft.totalKg` | `M/ItemDraft.swift` | Plain structs, no managed object. Shape is `specs/domain-layer.md` section 2.1. `Field` is what `@FocusState` and a commit name. `changes(from:only:)` is the same diff kept to one field, and a saved item's commit calls it. `skipBlankFields()` is for a crisis hit on a draft's Add: a field with no value gets source `skipped`, and a filled one keeps its source. Row "Crisis flow" in section 1.5 says what `nameHitCrisis` does |
| `Item.assign(_:_:source:)`, `assignEntered(_:)`, `assignEstimate(_:source:)`, `clearWeight(source:)`, `knownKg`, `weightState`, static `weightState(weightKg:source:estimateKg:)`, `categoryState`, `categoryDisplay`, `categorySortKey`, `stringOnlyCategoryNames`, `pendingFields`, `pendingFetchRequest()`, static `recallRows(normalizedName:)`, `RecallRow`, `displayName`, `notSortedLabel`, `legacyDefaultKg`, `legacyUncategorizedLabel`, `isLegacyDefaultWeight`, static `isLegacyDefault(kg:)`, `weightFieldSource`, `categoryFieldSource`, `weightReason`, `categoryReason`, `image(fromPhotoData:)` | `M/Item.swift` | `assign` takes its category and subcategory unlabelled, so a call reads `assign(cat, sub, source: x)`. `assignEntered` writes `weight` and source `entered`, and clears the estimate. `assignEstimate` writes `weightEstimateKg` and source only, and never touches `weight`. A value above 0 needs source `catalog`, `aiText` or `aiPhoto`, enforced with `assert` **[registry]**, so source `unknown` or `skipped` always carries 0. `clearWeight` sets `weight` and the estimate to 0, with source `unknown` or `skipped`, and `assert`s on anything else. Only `ItemStore` calls these three. `knownKg` is the one weight read: the person's weight for `entered` and `unverified`, the estimate for `estimate`, 0 for `unknown`. `recallRows(normalizedName: String?)` **[registry]** is the dictionary fetch behind `YourItemsSource`, with nil meaning every row, and it returns `[Item.RecallRow]`. `RecallRow` **[registry]** is a plain struct with the weight's state and value, `createdAt`, `id` and the category side. `weightHasEstimateSource` and `categoryHasEstimateSource` say whether each raw source is one recall may answer from, `aiText` or `aiPhoto` (owner: `specs/data-model.md` section 1.3). The struct also holds what recall and suggestions need from raw fields, so `YourItemsSource` names none of them: the name, which estimate source a recalled estimate copies, whether a source is `entered`, since recall ranks that first, whether the row is legacy General (`isLegacyGeneral`), since recall skips it, and whether both sources are `skipped`, since suggestions leave that row out. `weightState(weightKg:source:estimateKg:)` **[registry]** turns the fetch's raw values into a state. The `weightState` property calls the same function, so recall and `weightState` can't disagree and rule `raw-weight` holds. `isLegacyDefault(kg:)` **[registry]** is the one comparison with 0.1, and `isLegacyDefaultWeight` and template apply both call it. `stringOnlyCategoryNames: (category: String, subcategory: String?)?` is non-nil only for a row with no entity, and it's how `ItemStore` and `ItemDraft` read the mirror. `weightReason` and `categoryReason` are the one copy of the reason text. `weightEstimateKg` is `fileprivate` from the start. `weight`, `weightSource`, `categorySource` and the mirror end `fileprivate` too, in one commit at the end of M2, once rule `raw-weight` is at 0 and every call site has moved. That commit also makes the `categoryEntity` and `subcategoryEntity` setters `fileprivate(set)`, and reads stay public |
| `TemplateItem` (existing): `subcategory`, `weightSource: Int16?`, `categorySource: Int16?`, `init(id:...)` on both template structs. `totalWeight`, `isEstimate` and `init(item:)` | `M/PackingTemplate.swift`. The last three are in `M/Item.swift`, since rule `weight-multiply` allows only that file | See "Built-in templates", "Template to item mapping" and "Item to custom template" in section 1.3. `isEstimate` is true when `weightSource` is `catalog`, `aiText` or `aiPhoto`, and template rows print `about` from it |
| `FieldSource`, `WeightState`, `CategoryState`, `PendingField`, `CategorySortKey` | `M/FieldSource.swift` | An unknown raw value reads as `.legacy` |
| `Bag.allItems`, `allBags`, `availableKg`, `lightestItems`, `displayName`, `weightSummary` | `M/Bag.swift` | |
| `WeightSummary` (E, S, U, verdict, `unverifiedCount`, `emptyBagUnset`, `emptyBagKg`, `highKg`, `lowKg`), `BagWeightVerdict`, `Trip.weightSummary` (verdict always `none`) | `M/WeightSummary.swift`, `M/Trip.swift` | |
| `BagType` (existing, moved) | `M/BagType.swift` | Now nested in `V/AddBagView.swift:21` |
| `WeightUnit` (existing, moved), `WeightFormatter`: `string(kg:)`, `number(kg:)`, `parse(_:)`, `rowValue(_:)`, `perUnitText(_:)`, `stateText(_:)`, `estimateText(kg:)`, `exportText(kg:state:)`, `totalLine(_:)`, `verdictLine(_:)`, `verdictBadge(_:)`, `compactTotal(_:)`, `compactCaption(_:)`, `spoken(_:)` for a `WeightSummary`, `spoken(_ item:)` for a row, `rangeLine(_:)`. `EnvironmentValues.weightFormatter` | `U/WeightFormatter.swift` | `kg(fromGrams:)`, `grams(fromKg:)` and `WeightUnit.defaultUnit(for:)` **[registry]** here. `defaultUnit(for:)` gives pounds for a locale whose measurement system is US, and kilograms otherwise. `compactCaption(_:)` **[registry]** gives a stat tile's `3 not weighed` line. A limit prints as `23.0 kg`, by the formatter's own rule. `estimateText(kg:)` is for a surface with no `Item`: template rows and totals, and category analytics totals. `rangeLine(_:)` **[registry]** lands in 2.0. It's the range text on the item detail one-tap line and nowhere else, and it returns nil until `limits.json` `estimateRangeFactor` has a factor for the row's source (`specs/prompts-evals-catalog.md` section 2.11) |
| `WeightField` | `V/Components/WeightField.swift` | |
| `KeyboardDoneToolbar` | `V/Components/KeyboardDoneToolbar.swift` | One `ToolbarContent` **[registry]** holding the keyboard Done, `itemDetail.keyboardDone`, shared by item detail and every host of `WeightField` |
| `CategoryManager` (existing): `init(coreData:canImport:sleep:)`, static `defaultCanImport`, `startUp(using:)`, `refresh()`, `resolve(name:subcategory:)`, `row(forKey:)`, `recordUse(_:)`, `seed()`, `rename(_:to:using:)`, `deleteCategory(_:moveItemsTo:using:)`, `isSeedGateHolding` | `U/CategoryManager.swift` | `@MainActor`. `coreData` defaults to `.shared`, `canImport` defaults to `defaultCanImport`, which wraps `LaunchOption.isCloudKitDisabled` and `accountStatus`, and `sleep` defaults too, so a test can drive the seed gate with `ManualSleep`, the test actor in `specs/ai-client.md` S8.1 (owner: `specs/data-model.md` section 4.2). `isSeedGateHolding` **[registry]** is published while that gate holds, and the trip list reads it for its placeholder. The context comes from `coreData`, so a per-test instance saves to its own store. `startUp(using:)`, `rename(_:to:using:)` and `deleteCategory(_:moveItemsTo:using:)` take the `ItemStore`, which cuts the dependency loop between the two. `startUp(using:)` passes it to `CategoryReconciler.run(using:)`, and the `.import` trigger keeps it for later runs |
| `CategoryReconciler`: `init(coreData: CoreDataManager = .shared)`, `plan(rows:)`, `run(using:)` | `U/CategoryReconciler.swift` | The context comes from `coreData`, the same as `CategoryManager`. `plan(rows: [CategoryRow]) -> ReconcilePlan` is a pure function on plain structs, and `run(using:)` takes the `ItemStore` the way `deleteCategory(_:moveItemsTo:using:)` does (owner: `specs/data-model.md` section 4.3) |
| `ItemChangeRelay`: `shared`, `start(context:)`, `changedBags`, `photoChanged` | `U/ItemChangeRelay.swift` | |
| `CloudKitEventObserver`, `SyncStatus` (`off`, `noAccount`, `syncing`, `upToDate(Date)`, `quotaFull`, `failed`, `erasing`) | `U/CloudKitEventObserver.swift` | |
| `EntryParser`: `normalize(_:)`, `parse(_:) -> ParsedEntry`, `splitEntries(_:)`. `String.trimmedOrNil` | `U/EntryParser.swift` | `String.trimmedOrNil` **[registry]** lands with `normalize(_:)`, and rule `trim` allows this file for it |
| `ItemResolver` (`resolve(name:excluding:)`, `sources()`), `ResolvedItem`, `EstimateQuery`, protocol `EstimateSource`, `ItemDraft.fillBlanks(from:)` | `U/ItemResolver.swift` | `fillBlanks(from:)` **[registry]** is an `ItemDraft` extension, and the one helper that writes a `ResolvedItem`'s answers into a draft's blank fields, by the table in `specs/quick-add.md` section 1.8. The bar, a draft's Add and `PhotoIntake` all call it. No photo parameter in 1.1, and section 2.3 has what 2.0 adds. `EstimateSource` is synchronous. Apple's slot, if ever used, is an `AIClient` conformer in `Enricher`, still one file and one entry |
| `YourItemsSource` (adds `suggestions(prefix:limit:)`), `CatalogSource` | `U/YourItemsSource.swift`, `U/CatalogSource.swift` | `suggestions(prefix:limit:)` reads every row through `Item.recallRows(normalizedName: nil)`, so rule `raw-weight` holds |
| `ContractFile` (the one JSON loader), `Taxonomy`, `Catalog`, `BuiltInTemplates`, `Limits` (adds `itemKgRange`, derived from `grams`, `wireLength(_:)` and `cutToNameLimit(_:)`), `Disclosure` | `U/Contract.swift` | One file, one generic loader. `wireLength(_:)` **[registry]** runs every `normalizeInput` step in order, using `isVariationSelector` for the variation selector step (owner of the steps: `specs/backend.md` section 7), then counts `unicodeScalars`. It lands in 1.1 with `QuickAddBar`. `cutToNameLimit(_:)` **[registry]** is the one name cut, used by `QuickAddCommitter` and `ItemFormModel.add(to:)` |
| `CrisisGuard` (`matches(_:) -> Bool`), `CrisisResponse` | `U/CrisisGuard.swift` | `CrisisGuard` follows the same steps as `normalizeForCrisis` in `B/src/crisis.ts`, using `isVariationSelector` for the variation selector step (owner: `specs/backend.md` section 6) |
| `CrisisCard`, `CrisisCardPresenter` | `V/CrisisCard.swift` | Ships in 1.1 |
| `QuickAddBar`, `ItemSections`, `ItemListEntry`, `QuickAddCommitter` | `V/QuickAddBar.swift`, `M/ItemSections.swift`, `U/QuickAddCommitter.swift` | `QuickAddCommitter` **[registry]** holds the commit order in `specs/quick-add.md` section 1.4, with one entry for a line and one for pasted pieces. It calls `crisis` once per commit, so a test can count it |
| `BagWeightHeader`, `BagWeightBar`, `BagVerdictBadge`, `CategoryChip`, `ItemThumbnail`, `ItemRowView`, `ItemRowContent`, `ItemFormFields`, `ItemActionTitle`, `SaveFailureAlert`, `StoreFailureView`, `ItemFormModel` | `V/Components/`, `V/ItemDetailView.swift`, `V/StoreFailureView.swift` | `BagHeaderView`, `WeightBreakdownItem`, `ItemStatsSection`, `ItemActionsSection` go. `ItemFormModel` **[registry]** is a struct in `V/ItemDetailView.swift`, held in `@State`. It holds `draft` and `baseline`, and has `follow(_:except:categories:)`, `commit(_:field:store:crisis:)` and `add(to:store:crisis:)`, so a unit test can drive the commit path (owner: `specs/domain-layer.md` section 2.1). `follow` and `commit` return `ItemFormModel.Outcome` (`done`, `gone`), and `gone` means the row's been deleted, so the view calls `dismiss()` |
| `ItemDetailView` (existing): `init(mode:onAdded:onCrisisHit:)`, private `commitField(of:_:)` | `V/ItemDetailView.swift` | `onAdded` and `onCrisisHit` are for a `.draft`'s owner only. `onAdded` lets the bar clear its text and append to the strip. `onCrisisHit` sets a flag, and the sheet's `onDismiss` reads it and calls `presentWhenActive()` (owner of the rule: `specs/ai-client.md` S6.3). `commitField(of:_:)` commits one field of a `.saved` item through `ItemFormModel.commit` (owner: `specs/domain-layer.md` section 2.1) |
| `ExportRenderer`, `ExportDocument`, `ExportFormat` (existing, moved) | `U/ExportRenderer.swift` | `U/SharingManager.swift` is deleted |
| `AppInfo`, `DataReset` | `U/AppInfo.swift`, `U/DataReset.swift` | `AppInfo` reads the bundle and `disclosure.json` `links` |
| `LaunchOption` (with `isCloudKitDisabled`, `usesInMemoryStore`, `skipsOnboarding`, `fakeAIScenario`, `initCloudKitSchema`), `AccessibilityID` | `PacBag/Shared/` | New synchronized folder on the app and UI test targets **[measured, `specs/domain-layer.md`]** |
| `DebugSeed` (`#if DEBUG`) | `U/DebugSeed.swift` | Writes through `ItemStore`. The one exception is a raw field no `ItemStore` path can write, such as the legacy 0.1 row in `bagWithMixedItems`. `DebugSeed` and tests set those by KVC under `#if DEBUG`, and `DebugSeed`'s lines carry `ssot-allow` |

### 2.3 App types, added in 2.0

| Type | File |
|---|---|
| `AIConsent` | `U/AI/AIConsent.swift` |
| `AIAvailability` (adds `statusLine: String?`, the only owner of quota, pause and identity copy) | `U/AI/AIAvailability.swift` |
| `AIClient` (protocol: `fill(_:)`, `deleteMyData()`, and `confirmIdentity()` for a tap's retry, owner: `specs/ai-client.md` S1.1 and S5.1), `AIClientError`, `ProxyClient`, `FakeAIClient` (`#if DEBUG`) | `U/AI/AIClient.swift`, `U/AI/ProxyClient.swift`, `U/AI/FakeAIClient.swift` |
| `ItemFill`, `FieldAnswer`, `ApplyReport`, `FillTicket` (adds `FillTicket.digest(of:)`, the one hash of a photo's stored bytes), `FillRequestBuilder` | `U/AI/ItemFill.swift`, `U/AI/FillRequestBuilder.swift` |
| `ItemStore.applyAI(_:) -> ApplyReport`, `requestEstimate(_:)`, `localCommits` | `U/ItemStore.swift`, ship with their first caller |
| `FillRequest`, `FillResponse`, `FillKind`, `FillOutcome`, `DocumentKind` | `U/AI/WireTypes.swift` |
| `Enricher`: `shared`, `start()`, `availability(for:)`, `heldStorefront` (the last code read, section 1.5), `scenePhaseChanged(_:)`, `consentChanged()`, `retryIdentity()` (a tap while availability reads `noIdentity`, owner: `specs/ai-client.md` S5.1), `fillFromPhoto(_:upload:sourceDigest:) async -> PhotoFillResult`, `decline(_ id: NSManagedObjectID)` (builds `ItemFill.declined` with the current photo digest and calls `applyAI`, so an OCR crisis on Fill from photo can mark a row and rule `apply-ai` still holds), `pendingItems()`, `inFlight`, `Trigger`, `quotaUntil`, `pausedUntil` (holds a `PausedHold`), `identityMissing`. `PhotoFillResult` (cases in section 2.4) | `U/AI/Enricher.swift` |
| `ImagePipeline`: `store`, `upload(from:covering:)`, `display`, `thumbnail(for:from:)`, `evict`, `evictAll`. `PhotoPreflight`, `PreflightResult`, `PreflightVision` (closures `barcodes`, `text` and `faces`, default `.live`, owner: `specs/photo.md` S5) | `U/ImagePipeline.swift`, `U/PhotoPreflight.swift` |
| `PhotoIntake` (its `preparing` drives an extra entry in the `QuickAddBar` strip, its `filling` redacts fields during Fill from photo, and `QuickAddBar` appends its `createdItem: PassthroughSubject<NSManagedObjectID, Never>` to `entries` when it's for this bag. Both pickers land first in `loading(for:from:_:)`, which takes the nested `PickSource` (`camera`, `library`), because the camera path skips the wait in `specs/photo.md` S3. `stopPreparing()` backs strip Undo while a photo waits, and `stopFill(_:)` backs `Stop` on Fill from photo. Its entry points are `addFromPhoto(bag:typedEntry:openSource:)`, `fill(_:openSource:)`, `attach(_:to:)` and `received(_:for:from:tile:)`. Its nested `Target` says which row a pick is for, its nested `PickSource` says where a pick came from, and `notice` and `documentPrompt` publish the two prompts, owner: `specs/photo.md` S2), `PhotoNotice`, `DocumentPrompt`, `PhotoCopy`, `PhotoSource`, `PhotoAnswer`, `PhotoNextStep` | `U/PhotoIntake.swift`, `U/PhotoCopy.swift`, `U/ItemResolver.swift`, `M/FieldSource.swift` |
| `ItemResolver.resolve(name:excluding:photo:)` and `sources(photo:)`, with `photo: PhotoAnswer? = nil`, so earlier callers don't change | `U/ItemResolver.swift` |
| `PhotoSourceMenu` (a button plus `.photoSourceDialog(isPresented:canSend:onPayload:)`, which lives in the same file), `ItemPhotoSection` | `V/Components/` |
| `Item.photoPlaceholderName`, `isPhotoPlaceholder`, `photoNextStep`, `wasFilledFromPhoto`, `fillNeedsNewPhoto` | `M/Item.swift` |
| `CameraPicker`, `ConsentSheet`, `WaitingRow`, `ItemFieldBusy` | `V/CameraPicker.swift`, `V/ConsentSheet.swift`, `V/WaitingRow.swift`, `V/Components/` |
| `CategoryManager.activeRowsDeduped()` | `U/CategoryManager.swift` |

### 2.4 Enums and cases

| Enum | Cases | Note |
|---|---|---|
| `FieldSource: Int16` | `legacy = 0`, `entered = 1`, `catalog = 2`, `aiText = 3`, `aiPhoto = 4`, `unknown = 5`, `skipped = 6` | Same for weight and category. Raw values are synced and permanent. Head-noun category answers use `catalog` |
| `WeightState` | `entered`, `estimate`, `unverified`, `unknown` | `skipped` reads as `unknown` on screen. Whether it's pending is `pendingFields`' job |
| `CategoryState` | `entered`, `estimate`, `notSorted` | |
| `PendingField` | `weight`, `category` | |
| `BagWeightVerdict` | `none`, `over`, `probablyOver`, `close`, `cantTell`, `looksUnder`, `under` | Rows 1 to 7 of `architecture.md` section 8, in order |
| `WeightUnit` (existing) | `kilograms = "kg"`, `pounds = "lbs"` | Raw values are stored, so they stay |
| `ExportFormat` (existing) | `plainText`, `markdown`, `richText` | |
| `AIAvailability` | `available`, `needsConsent`, `storefrontOff`, `noIdentity`, `notInThisBuild`, `paused(until: Date?)`, `quotaUsed(until: Date, kind: FillKind)` | Asked per `FillKind`. The first match wins, in the order `specs/ai-client.md` S5.3 owns. `statusLine` is nil for a pause under 60 minutes, and section 1.7 says what `Estimate weight` does then. `paused(nil)` clears on `.active`, otherwise after 15 minutes |
| `FillKind` | `text`, `photo` | Wire values |
| `FillOutcome` | `ok`, `crisis`, `unusable`, `quota`, `paused` | Wire values |
| `DocumentKind` | `none`, `passport`, `boardingPass`, `paymentCard`, `insuranceCard`, `driversLicence`, `otherDocument` **[registry, from `research/llm-safety.md` table]** | Wire values use snake case: `boarding_pass` |
| `PhotoNextStep` | `none`, `fill`, `nameIt` | `M/FieldSource.swift` |
| `PhotoFillResult` | `filled(DocumentKind?)`, `offline`, `transient`, `unusable`, `quota`, `paused`, `crisis`, `dropped`, `notSent` | What `Enricher.fillFromPhoto` returns, and the photo notices switch on it. `fillFromPhoto` starts by checking `availability(for: .photo)` and returns `notSent` unless it's `available`. `PhotoIntake` hashes the stored bytes when it reads them, before preflight, and passes that as `sourceDigest` |
| `self_harm_signal` | `none`, `explicit` | Server only. Never in Swift |

### 2.5 Core Data attributes

| Entity | Attribute | Type | Default | Rule |
|---|---|---|---|---|
| Item | `weightSource` | Int16 | 0 | Says where the current weight answer came from. Written only by the `Item` weight writers, which only `ItemStore` calls |
| Item | `weightEstimateKg` | Double, non-optional | 0 | Catalog and AI values, in kg per unit. 0 means none. Written only by the `Item` weight writers |
| Item | `categorySource` | Int16 | 0 | Written only by `Item.assign`, which only `ItemStore` calls |
| Item | `createdAt` | Date, optional | none | Set by `ItemStore.create`, and by `requestEstimate` on a legacy row |
| Category | `defaultKey` | String, optional | none | Set by seed and `CategoryReconciler` |
| SubCategory | `defaultKey` | String, optional | none | Same |

That's 6 new attributes and 8 new CloudKit fields, since a string attribute adds an `_ckAsset` twin **[inferred, the deploy step checks it against the Console]**. All six are Owner's call 16, with a plan default of yes. It can be reversed until the 1.1 production deploy, because a deployed field can't be taken back. `specs/data-model.md` section 1.4 lists the options.

- `Item.weight` (existing) only ever holds a person's number, in kg per unit, and 0 means none. Raw `weight` and `weightEstimateKg` reads outside `M/Item.swift` end at 0, under rule `raw-weight`.
- A 1.0.1 client shows estimate rows as 0.0 kg, and its totals run low with no marker, the same as unknown rows there. That's accepted.
- Key format: `clothes`, `electronics`, and for subcategories `clothes.tops`, `medication.over-the-counter`, `medication.first-aid`. Lowercase, hyphens for spaces. `taxonomy.json` holds the actual list **[registry]**.
- Kept forever, no accessor: `Bag.currentWeight`.
- Kept forever, written only by `assign`: `Item.category`, `Item.subcategory`.
- Existing and unchanged: all other attributes in `understand/data-model.md` section 1.
- Don't add: `aiInputHash`, stored ranges, `ai*` shadow fields, queue or attempt state (`architecture.md` section 18).

### 2.6 Contract files

All in `C/`. Ship in the bundle. Railway reads them by relative path from the repo root.

| File | Top-level keys **[registry]** |
|---|---|
| `taxonomy.json` | `categories[]`: `key`, `name`, `icon`, `colorHex`, `order`, `subcategories[]` of `key`, `name` |
| `catalog.json` | `items[]`: `key`, `name`, `aliases[]`, `categoryKey`, `grams`. `unitNote` isn't in this file. It's a review-only aid in `B/tools/catalog/review.csv` |
| `templates.json` | `templates[]`: `id`, `name`, `description`, `tripType`, `duration`, `season`, `icon`, `color`, `items[]` of `catalogKey`, `quantity`, `essential`, optional `gramsOverride` (count pinned at 0 by `ContractTests`) |
| `crisis.json` | `message`, `actions[]` of `label`, `url`, optional `regions` (labels and order per `specs/compliance.md` section 2.7), `phrases[]` |
| `limits.json` | `estimateBand`, `estimateRangeFactor`{`catalog`,`aiText`,`aiPhoto`, each number or null}, `grams`{`min`,`max`}, `quantity`{`min`,`max`}, `bagEmptyKg`, `bagLimitKg`, `subBagLimitKg` (each `min`,`max`,`step`), `image`{`storeMaxEdgePx`,`uploadMaxEdgePx`,`uploadMaxBytes`}, `bodyMaxBytes`, `batchMaxNames`, `categoriesMax` (seed 40), `nameMaxChars` (seed 120), `categoryNameMaxChars` (seed 40), `requestDeadlineMs`{`text` 60000, `photo` 70000}. `ProxyClient` adds 5 s to the deadline. `nameMaxChars` and `categoryNameMaxChars` count Unicode scalars of the text after all `normalizeInput` steps |
| `disclosure.json` | `consentVersion`, `features`{`text`,`photo`}, `consent`{`title`,`clauses[]` of `heading?`,`text`,`requires?`, `waitingOne`,`waitingMany`,`changeNote`,`accept`,`decline`,`policyLinkLabel`,`termsLinkLabel`,`recipientLabel`}, `recipients[]` of `id`,`name`,`role`,`country`,`retention`,`url`, `dataCategories[]` of `id`,`label`,`sentTo[]`,`keptByUs`,`requires?`, `aiOffStorefronts[]`, `promise`, `links`{`marketing`,`support`,`privacy`,`terms`,`appStore`,`contactEmail`} |

The server reads `crisis.json`, `limits.json` and `disclosure.json` (for `features`) at boot. Tools and evals read `catalog.json` and `taxonomy.json` through the same `contract.ts`.

Fixtures in `X/`: `fill/request_text.json`, `fill/request_photo.json`, `fill/response_ok_text.json`, `fill/response_ok_photo.json` (`none`), `fill/response_ok_photo_document.json` (`passport`), `fill/response_ok_photo_boarding_pass.json`, `fill/response_ok_photo_payment_card.json`, `fill/response_ok_photo_insurance_card.json`, `fill/response_ok_photo_drivers_licence.json`, `fill/response_ok_photo_other_document.json`, `fill/response_ok_partial.json`, `fill/response_ok_missing_id.json`, `fill/response_ok_bad_values.json`, `fill/response_crisis.json`, `fill/response_crisis_no_ids.json`, `fill/response_unusable.json`, `fill/response_unusable_batch.json` (a client guard, the server doesn't send it), `fill/response_quota.json`, `fill/response_paused.json`, `fill/response_paused_no_date.json`, `fill/response_future_outcome.json`, `fill/fake_table.json`, `fill/invalid/*.json`, `crisis_cases.json`, `crisis_response.json`, `length_cases.json` (an emoji label, a flag, a ZWJ emoji, an ellipsis, `™` at the limit, a tab inside a name, a zero-width-only name, and U+200B space U+200B, U+2764 U+FE0F, and a name holding only variation selectors), `eval/text_truth.csv`, `eval/weighed.csv`, `eval/g3_names.csv`, `photos/` (synthetic only), `schema/production-fields.json`, `stores/1.0/` and `stores/1.0.1/`, each with a row manifest from `scripts/store-manifest.sh`.

A photo `ok` holds one item, so each `DocumentKind` case has its own fixture. Store fixtures hold synthetic data from a throwaway account, since the repo is public. `X/` lands flat in the test bundle, so fixture base names must be unique, and the two store folders are read by `#filePath` and kept out of the synchronized group **[unverified that the exclusion works]**.

### 2.7 UserDefaults keys

All strings live in one `enum DefaultsKey` in `U/SettingsManager.swift`, which is the existing private `Keys` made internal. Member names such as `upgradeNoteShown` are in `specs/domain-layer.md` section 2.1. `DefaultsKeyTests` pins each string. The `SettingsKey<T>` table from the audit stays out, as listed debt (Owner's call 10).

| Key | Status |
|---|---|
| `settings_ai_consent_version`, `settings_ai_consent_offered_version` | New in 2.0. Cleared by `DataReset` |
| `settings_weight_unit`, `settings_app_theme`, `settings_default_item_sort_order`, `settings_sort_ascending` | Existing, live |
| `hasCompletedOnboarding` | Existing, live. Moves into `DefaultsKey`, and its string can't change |
| `CustomPackingTemplates`, `CustomPackingTemplatesBackup` (raw bytes, written once before an overwrite after a failed decode) | Existing and new, user content. Cleared by `DataReset` |
| `settings_analytics_enabled`, `settings_auto_packing_list`, `settings_smart_suggestions`, `settings_show_weight_in_lists`, `settings_default_packing_days_before_trip`, `settings_default_bag_weight`, `settings_default_reminder_days`, `settings_first_launch`, `settings_onboarding_completed` | Remove the properties. Removing `settings_default_reminder_days` and its picker is Owner's call 24. Removal of the rest follows `architecture.md` section 7 |
| `settings_sync_notice_dismissed` | New in 1.1. Set when someone dismisses the trip list's `.quotaFull` line. A later successful `.export` clears it, so the next episode shows again. `DataReset` clears it too |
| `settings_upgrade_note_shown` **[registry]** | New in 1.1. Set when the first bag opened after an upgrade shows its one line. A launch that finds the stored `hasCompletedOnboarding` false sets it too, so a fresh install never shows the line (owner: `specs/quick-add.md` section 1.1). Cleared by `DataReset` |
| `settings_scrub_store_next_launch` **[registry]** | New in 1.1. One-shot. `DataReset` sets it, and the next launch scrubs the store and clears it (owner: `specs/data-model.md` section 10). `DataResetTests`' "each key gone" exempts it |
| `settings_sync_erasing_since` **[registry]** | New in 1.1. Holds the date `DataReset` finished its row save, so `.erasing` survives a relaunch. `CloudKitEventObserver` removes it when `.erasing` ends (owner: `specs/data-model.md` section 6.3). `DataReset` doesn't clear it, and `DataResetTests`' "each key gone" exempts it |
| `CustomPackingCategories` | Dropped. Read removed, last writer removed before 1.0. `DefaultsKey.retired` lists it and `DataReset` clears it |

### 2.8 Endpoints, wire shape and codes

Base URL `https://api.pacbag.app` **[registry, assumption]**. A custom domain means changing host needs no app release. Constant in `U/AI/ProxyClient.swift`, the only `https://` allowed in Swift. The host stays DNS only on Cloudflare, with the proxy off, because a proxied host would give Cloudflare names, photos, the JWS and the user's IP, and `recipients` doesn't name it (owner: `specs/backend.md` owner action 11). `scripts/smoke-server.sh` and `healthz.yml` fail on a `cf-ray` response header.

| Route | Purpose | Auth |
|---|---|---|
| `POST /v1/fill` | The one AI route | Header `X-App-Transaction`, the JWS |
| `DELETE /v1/me` | Delete yesterday's counter and keep today's (row "Server deletion" in section 1.5). Returns 204, or 503 if Postgres is down | Same |
| `GET /healthz` | `{"up":true,"aiEnabled":true,"budgetTripped":false,"fillOk":true,"dbOk":true}`. Always 200. A `setInterval` in `server.ts`, every 30 s and unref'd, reads today's `global:production` row through `quota.ts` with pg's per-query `query_timeout: 1000`, and stores `dbOk` and the budget result. It catches every rejection, because `unhandledRejection` exits the process. The route only reads the stored values, and `budgetTripped` is the stored budget result or the in-memory `upstreamPausedUntil`. The first read runs after the boot `CREATE TABLE` and finishes before `listen`. If it fails, `dbOk` starts false and boot continues. No user data | None. App never calls it |

Rejected names, don't bring back: `/v1/estimate`, `/v1/photo`, `/v1/enroll`, `/v1/config`.

Request **[registry]**:

```json
{"kind":"text","consentVersion":1,"items":[{"id":"i0","name":"rain jacket"}],"categories":[{"token":"c00","name":"Clothes"}]}
{"kind":"photo","consentVersion":2,"nameLanguage":"pt","items":[{"id":"i0"}],"categories":[{"token":"c00","name":"Clothes"}],"image":"<base64 JPEG>"}
```

Response, always 200 once identity and parsing pass:

| `outcome` | Other fields | App effect |
|---|---|---|
| `ok` | `items[]`: `id`, `category` (token or `none`), `grams` (int or null). Photo adds `name` (string or null), `quantity` (int, never null, default 1), `document_kind` (other fields still apply) | `ItemStore.applyAI`. `none` or null sets that field `skipped`, on a field with no value (P7). A number out of range or a token not in this request is no answer for that field, so nothing's marked (P7). **An id absent from `items` changes nothing and goes out on the next drain** |
| `crisis` | `message`, `ids[]` | Fields with no value on listed ids go `skipped`, `CrisisCard` once with bundled text (P16). Others go on the next drain |
| `unusable` | `ids[]`. The server sends it only for a refusal on one name or a photo, or for a photo with nothing found | Fields with no value on listed ids go `skipped`. Never the crisis card. More than one id marks nothing and halves the send size |
| `quota` | `resetsAt` | Nothing marked. `AIAvailability.quotaUsed` in memory, for that kind |
| `paused` | `resetsAt` or null. Also `MIN_CONSENT_VERSION` not met, `features.photo` false | Nothing marked. `AIAvailability.paused` in memory, for that kind |

Non-200 **[registry, P6]**, no contract body, all treated by the app as transient with nothing marked: `400` malformed, over `categoriesMax`, or a name or decoded image over its limit, `401` bad or missing JWS, `404`, `405`, `413` over `bodyMaxBytes`, `502` truncated twice, odd `stop_reason`, invalid output on one name or a photo, isolation that leaves nothing in `items`, any other `ok` that would carry no items, a timeout with `n > 6`, or a single-name `unusable` while the self-test is failing, `503` over either in-flight ceiling, draining, or store failure on delete, `5xx`. A server test covers each. On the device, the identity read gives `.offline` for `StoreKitError.networkError`, a `.systemError` wrapping a `URLError`, or a `URLError` connectivity code, and `.cancelled` for `CancellationError`. Any other throw, or an `.unverified` result, gives `AIAvailability.noIdentity`, read as "Couldn't confirm your App Store account." with a retry on the next tap, and no call is made (owner: `specs/ai-client.md` S1.1).

Postgres: `daily_counters(id_hash, day, names, photos, micro_usd)`, the only table. Global pool ids are in P5. `micro_usd` is also written on identity rows, for the runbook.

**Chain in `routes/fill.ts`:** method and size, identity, per-identity in-flight ceiling, parse, phrase check on item names, `MIN_CONSENT_VERSION`, kill switch, `features.photo` and `PHOTO_FILL_ENABLED`, `upstreamPausedUntil`, reserve, Claude, validate, settle.

**What each result does to a reservation:**

| Result | Identity count | Global |
|---|---|---|
| Phrase `crisis`, 400, 401, anything before reserving | Never reserved | Never reserved |
| `ok`, `unusable` | Kept, since a refund on `unusable` would make probing free | Settled from `usage`. A refusal that wasn't billed settles to 0, by `BILLED_REFUSAL_CATEGORIES` |
| Model `crisis` | Kept for all `n`, the same as any billed result, so a loop of any batch size hits the quota | Settled from `usage` |
| `paused` in place of a refusal mark, while that kind's streak is at 5 | Kept, so probing stays metered | Settled from `usage` |
| 502, or `paused` from Anthropic 4xx or 5xx | Refunded only if no call was billed. If a call was billed, as on a retry or invalid output, the count stays, the same as a model crisis, so one name can't spend global at no identity cost | Refunded in full if no call was billed, or settled from `usage` if a call was billed |
| Timeout, abort at the route deadline, or any connection error not in the next row | Kept, the same as a billed call, so a loop hits the quota. An outage can use up a day's names, and that's accepted | Settled to `typicalMicroUsd(model, kind, n)`, since Anthropic charges a request that times out on its way to succeeding (**[fetched]** https://support.claude.com/en/articles/8977456-how-do-i-pay-for-my-claude-api-usage) and the real cost isn't known. The same amount goes on the identity row's `micro_usd`, so the runbook sees who holds it |
| Connection error whose cause shows nothing was sent: `ECONNREFUSED`, `ENOTFOUND` or `EAI_AGAIN` on `err.cause.cause.code` **[shape from memory, the first compile settles it]** | Refunded | Refunded |
| Isolation singles, after a refusal or invalid output | Not counted again | Each reserves its own |
| Server self-test | None, since it has no identity | Reserves on `global:production`, settled from `usage` |

A connect timeout comes back as `APIConnectionTimeoutError` with no cause, so it follows the timeout row.

With the one manual retry, each attempt counts on its own and global settles to the sum. An attempt that answered costs its `usage`, one that timed out or lost its connection costs typical, and one that ended in an HTTP error or sent nothing costs nothing. If any attempt timed out or lost its connection, the identity count follows the timeout row.

For `kind: photo`, once a request has gone out to Anthropic, the photo count stays on every result, billed or not, because the upload has already gone out. A budget miss or store error at the reserve step still rolls back, since nothing went out.

When a route throws, `routes/fill.ts` applies this table to every reservation it holds. With `usage` known it settles from it and keeps the identity count, a call sent with no `usage` follows the timeout row, and with no call sent it refunds both.

### 2.9 Backend layout and env vars

```
backend/src/server.ts            routes wired here
backend/src/routes/fill.ts       the chain, in order
backend/src/routes/me.ts
backend/src/routes/healthz.ts
backend/src/identity.ts
backend/src/quota.ts
backend/src/crisis.ts
backend/src/validate.ts
backend/src/logger.ts
backend/src/wire.ts
backend/src/contract.ts          loads ../PacBag/PacBag/Contract/*.json
backend/src/ai/config.ts         model line, prices, request parameters
backend/src/ai/llm.ts            call plus outcomeFor
backend/src/ai/prompts.ts
backend/src/ai/schema.ts
backend/tools/catalog/generate.ts, review.csv
backend/tools/cost-model.ts
backend/eval/run.ts, grade.ts, calibrate.ts, free.test.ts, cases/, tools/prep_photos.swift
backend/.railway/railway.ts      Railway settings, no quota values
backend/Dockerfile               no test stage
backend/package.json, tsconfig.json, .nvmrc
backend/certs/AppleRootCA-G3.cer
backend/test/
.github/workflows/server.yml     tests on Linux with real Postgres, sets TEST_DATABASE_URL, continue-on-error on npm audit, Railway waits for it
```

The private `pacbag-ops` repo holds the scheduled checks and a push workflow that tests `healthz.yml`'s filter. The `verify` run clones the two public repos read-only:

```
.github/workflows/healthz.yml    cron 17 1/2 * * *, fails on up, budgetTripped, fillOk, dbOk, a cf-ray header (owner: specs/cost-ops.md section 7.5)
.github/workflows/verify.yml     daily, runs scripts/verify.sh from the clones (owner: specs/test-release.md section 2.4)
.github/workflows/healthz-filter.yml    on push, runs healthz.yml's jq filter against fixture bodies (owner: specs/cost-ops.md T20)
```

`server.yml` is the only deploy gate. The `Dockerfile` has no test stage, because that image can't run the Postgres tests. Railway waits on every Actions run on a commit, so `server.yml` stays the only workflow in the public repo, and `continue-on-error: true` on `npm audit` stops a fresh advisory from skipping a fix.

`specs/cost-ops.md` section 7.5 owns `healthz.yml`, including what it doesn't fail on. Keeping it and the daily `verify` run in `pacbag-ops` is Owner's call 25. A red run there can't stop Railway's deploy. GitHub's 60-day rule covers public repos, so they need no commits to stay on. Failures reach you by GitHub's failure email.

Railway watch paths: `backend/**`, `crisis.json`, `limits.json`, `disclosure.json`, so a catalog edit doesn't redeploy. `server.yml` paths stay a superset. Service name `pacbag-api`.

| Env var | Meaning | Secret |
|---|---|---|
| `ANTHROPIC_API_KEY` | API key | Yes |
| `DATABASE_URL` | Postgres | Yes |
| `ID_HMAC_SECRET` | Key for `id_hash` **[registry]**. Boot refuses it under 32 bytes | Yes |
| `CLAUDE_MODEL` | Model, default in `config.ts` | No |
| `CLAUDE_MODEL_PHOTO` | Optional override | No |
| `CLAUDE_MODEL_REFUSAL_RETRY` | Only if Owner's call 2 picks Haiku with a one-time re-send. Optional and unset by default, and boot refuses it with no entry in `PRICES` (owner: `specs/prompts-evals-catalog.md` section 2.10) | No |
| `AI_ENABLED` | Kill switch. Only exactly `true` turns AI on. `False`, `0`, `off`, empty and unset all read as off, and `/healthz` reports the same parsed value. Anything other than `true` or `false` logs `error_class: unsafe_config` at boot and still boots, because a refused boot leaves the old AI-on deployment serving | No |
| `PHOTO_FILL_ENABLED` | Photo fill switch **[registry]**. Only exactly `true` turns photo fills on | No |
| `PHOTO_WEIGHT_ENABLED` | Withhold photo weight. Boot refuses anything but exactly `true` or `false`, because a bad value read as off would write a lasting `skipped` | No |
| `MIN_CONSENT_VERSION` | Default 1. Below it returns `paused` with null | No |
| `IDENTITY_ACCEPT_XCODE` | Local server only. Boot refuses it on Railway | No |
| `EVAL_PHOTO_DIR`, `TEST_DATABASE_URL` | Local tools and tests | No |
| `QUOTA_NAMES_PER_DAY`, `QUOTA_PHOTOS_PER_DAY` | Per identity **[registry names]**. Boot refuses a missing or invalid value, and each must be a positive integer | Kept out of the repo |
| `BUDGET_DAILY_USD`, `BUDGET_SANDBOX_DAILY_USD` | Global pools, converted once to microdollars **[registry names]**. Boot refuses a missing or invalid value, and each must be a finite positive number | Kept out of the repo |

Rejected: `LLM_MODEL`. There's no server-side storefront list (P15). The app has no env vars in production.

`ErrorClass` is a closed list, and `B/src/logger.ts` accepts only these values: `upstream_400_spend_limit`, `upstream_400_credit`, `upstream_400_other`, `upstream_401`, `upstream_402`, `upstream_403`, `upstream_404`, `upstream_413`, `upstream_429`, `upstream_429_tier_cap`, `upstream_5xx`, `upstream_529`, `upstream_timeout`, `upstream_connection`, `upstream_other` (408, 409, 422 and any status not listed), `store_error`, `invalid_output`, `truncated`, `bad_request`, `unsafe_config`, `handler_threw`, `inflight_identity`, `inflight_global`. `llm.ts` sets `upstream_400_credit` when the status is 400 and the message starts `Your credit balance is too low`, and it never logs the message.

### 2.10 Launch arguments and accessibility identifiers

Owner `LaunchOption` in `PacBag/Shared/LaunchOption.swift`. `-PacBagDisableCloudKit` and `PACBAG_DISABLE_CLOUDKIT=1` keep their spelling, because `U/CoreDataManager.swift:19-20`, `T/WeightTests.swift:15` and `T/ScreenshotTests.swift:17` use them and they all move to this type.

| Argument | Effect | Build |
|---|---|---|
| `-PacBagDisableCloudKit` (existing) | No mirroring | All, as now |
| `-PacBagInMemoryStore` | `CoreDataManager(inMemory: true)`. `LaunchOption.usesInMemoryStore` is also true for a hosted test (`XCTestConfigurationFilePath`) and a preview (`XCODE_RUNNING_FOR_PREVIEWS`, not run) | `#if DEBUG` |
| `-PacBagFakeAI <scenario>` | `FakeAIClient`, through `LaunchOption.fakeAI` (the argument string) and `LaunchOption.fakeAIScenario` (the read, nil in Release), where the scenario is a fixture name such as `response_quota`, `table` uses `fake_table.json`, `offline` throws, and `no_identity` throws `.noIdentity` | `#if DEBUG` |
| `-PacBagFakeAIDelayMs <ms>` | Delay in the fake | `#if DEBUG` |
| `-PacBagFakePhoto <fixture>` | Hooks `.photoSourceDialog`, so every path returns that fixture | `#if DEBUG` |
| `-PacBagFakeStorefront <code>` | `Enricher` reads this alpha-3 code in place of `Storefront.current`, and `none` gives nil | `#if DEBUG` |
| `-PacBagFeatures text` | `features.photo` reads false | `#if DEBUG` |
| `-PacBagResetDefaults` | Runs `removePersistentDomain` for the bundle id first thing in `PacBagApp.init`, ahead of `DebugSeed.apply`, so a `_consented` seed still grants. `PacBagUITestCase.launch` always passes it, and `relaunch()` drops it | `#if DEBUG` |
| `-PacBagPinKilograms` **[registry]** | With no stored unit, reads kilograms whatever the locale. `PacBagUITestCase.launch` always passes it | `#if DEBUG` |
| `-PacBagFailSaveNamed <name>` | Just before `try context.save()`, an inserted or updated object with that `name` gets a nil name, so the save throws the real validation error and the existing catch runs (owner: `specs/data-model.md` section 6.2) | `#if DEBUG` |
| `-PacBagSkipOnboarding` | Read by `OnboardingManager`, through `LaunchOption.skipsOnboarding` | `#if DEBUG` |
| `-PacBagInitCloudKitSchema` | Runs `initializeCloudKitSchema` once, from scheme `PacBag-InitSchema`, when `LaunchOption.initCloudKitSchema` is true | `#if DEBUG` |
| `PACBAG_API_BASE` (env) | Points a debug build at a local server | `#if DEBUG` |
| `-PacBagSeed <name>` | Screenshot and UI test data, `DebugSeed`. Names include `smoke`, `screenshots`, and a `_consented` suffix | `#if DEBUG` |
| `PACBAG_FIXTURE_DIR` (env) | Folder with fixtures, P17 | `#if DEBUG` |
| `-com.apple.CoreData.ConcurrencyDebug 1` | Set on the scheme's launch action, and hosted tests inherit it. `PacBagUITestCase` adds it for UI runs | Debug |

**Accessibility identifiers.** None exist today (0 grep hits), and UI tests find text. New UI uses `AccessibilityID` in `PacBag/Shared/AccessibilityID.swift`. Format `screen.element`, lowerCamelCase, static constants, with a function for per-row ids. Rule `a11y-literal` bans string literals in `.accessibilityIdentifier(`.

| Id | Element |
|---|---|
| `quickAdd.field`, `quickAdd.undo`, `quickAdd.strip`, `quickAdd.stripRow`, `quickAdd.details`, `quickAdd.quantity`, `quickAdd.suggestion`, `quickAdd.splitAdd`, `quickAdd.splitKeep`, `quickAdd.splitClear`, `quickAdd.photo`, `quickAdd.done`, `quickAdd.upgradeLine` | Quick add bar |
| `bagDetail.total`, `bagDetail.verdict`, `bagDetail.breakdown`, `bagDetail.setEmptyWeight`, `bagDetail.confirmWeights`, `bagDetail.confirmWeightsCount`, `bagDetail.confirmWeightsCancel`, `bagDetail.showNotWeighed`, `bagDetail.heaviestFirst`, `bagDetail.waitingRow` | Bag screen. `bagDetail.addItem` tags the header Add Item button until the commit that points every entry at quick add, which removes the button and the id |
| `itemRow.` plus the trimmed, lowercased name, built inside `AccessibilityID.itemRow(_:)`, so app and tests pass the raw name, `itemRow.toggle`, `itemRow.categoryChip`, `itemRow.fillFromPhoto(_:)` | Item rows |
| `itemDetail.nameField`, `itemDetail.weightField`, `itemDetail.notesField`, `itemDetail.keyboardDone`, `itemDetail.nextNotWeighed` (only with `Next` in `specs/quick-add.md` section 5), `itemDetail.categoryChip`, `itemDetail.subcategoryPicker`, `itemDetail.fillFromPhoto`, `itemDetail.estimate`, `itemDetail.confirmWeight`, `itemDetail.addPhoto`, `itemDetail.removePhoto`, `itemDetail.save` (the draft's Add) and `itemDetail.cancel`, both in draft mode only | Item screen |
| `consent.accept`, `consent.decline`, `consent.policyLink`, `consent.termsLink` | Consent sheet |
| `crisis.card`, `crisis.call`, `crisis.text`, `crisis.chat`, `crisis.findHelpline`, `crisis.dismiss` | Crisis card |
| `photoDialog.take`, `photoDialog.choose`, `photoDialog.withoutPhoto`, `photoDialog.withPhoto`, `photoDialog.override`, `photoDialog.cancel`, `photoNotice.line` | Photo flow |
| `landing.privacyLink`, `landing.termsLink` | Landing |
| `settings.aiToggle`, `settings.privacyLink`, `settings.termsLink` | Settings |

### 2.11 Names replaced

| Don't use | Use | Came from |
|---|---|---|
| `CategoryTaxonomy`, `M/CategoryTaxonomy.swift` | `Taxonomy`, `taxonomy.json` | Audit rank 4 |
| `ItemLimits` | `Limits`, `limits.json` | Audit rank 6 |
| `ItemPhoto` | `ImagePipeline` | Audit rank 9 |
| `Category.fallbackName` | `Item.notSortedLabel` | Audit rank 11 |
| `Item.categoryPath`, `fullCategory`, `effectiveCategoryName`, `effectiveSubcategoryName`, `hasSubcategory` | `Item.categoryDisplay` | Audit rank 12, `M/Item.swift` |
| `privacy-policy/page.tsx` as owner | `disclosure.json` for facts, `/privacy` for prose | Audit rank 21 |
| `SettingsKey<T>` | `DefaultsKey` | Audit rank 19 |
| `suggestCategory` | `ItemResolver` | `U/CategoryManager.swift:368` |
| `updateBagWeight`, `currentWeight` in Swift | Nothing | `V/BagDetailView.swift`, `M/Bag.swift:18` |
| `PersistenceController`, `AppIconManager`, `IconSetupManager`, `BagListView` | Deleted | Dead files, audit |
| `AddItemView`, `EnhancedItemPreview`, `ItemPreview` | `QuickAddBar`, `ItemDraft`, `ItemDetailView` | `architecture.md` section 4 |
| `contract/` at repo root, `facts.json`, generated Swift | `C/`, no generator | `design/arch-ssot-first.md`, rejected |

Names dropped while the specs were merged are listed in `design/conflicts.md`. Plan files don't use them.

## 3. Rules that stop duplication coming back

There are three layers and nothing else: a grep script, tests in the suites that already run, and one habit. No new program and no generated code.

### 3.1 `scripts/verify.sh`

A tested draft is at `evidence/scripts/verify-draft.sh`. I ran it on this repo at `0c10439` and the website's checkout at `2b944cc`, per the docs report. It passes, used about 1.5 s of CPU and needs only `git`, `grep` and `cmp`. The draft doesn't have `raw-weight`, `not-sorted`, `trim`, `init-schema`, `apply-ai`, `ui-em-dash`, `sparkle`, `item-field-write`, `item-delete`, `recipient-literal`, `name-compare`, `fallback-name`, `cat-separator`, `grams-conv`, `min-ios`, `retention-copy`, `promise-copy`, `manifest-url` or the two `site-` gates. It has no rule samples and no `CLAIMS_ONLY`, and some of its patterns and scopes differ from the ones here. `verify.sh` follows this file. I re-ran every count in the table at `0c10439` with `git grep -E`, case-sensitive unless the row says otherwise, using each cell as printed, and they all match.

**It's a ratchet.** Each rule has a number that matches today's count, so it passes on day one. A commit that removes copies lowers the number. A commit that adds one fails. That's the part a solo developer keeps, since nothing has to be finished first.

A line ending in `// ssot-allow: <why>` is exempt, for real exceptions such as a percentage that uses `%.1f`.

Each pattern is an ERE for `git grep -E`, searched over the pathspec `A/*.swift`, whose `*` crosses `/` in `git grep`, unless the row names another scope. Commas separate patterns. Each one goes in its own `-e`, and a line that hits two counts once. No pattern cell holds a `|`, so the text pastes as printed.

| Rule | Pattern | Allowed in | Today | Ends at |
|---|---|---|---|---|
| `item-create` | `Item\(context:` | `ItemStore.swift` | 5 | 0 |
| `save` | `[cC]ontext\??\.save\(\)` | `CoreDataManager.swift` | 28 | 0 |
| `fatal` | `fatalError\(`, `preconditionFailure\(` | `Contract.swift` for the one `ContractFile.required` trap | 5 | 0 |
| `is-packed-write` | `\.isPacked *=[^=]`, `\.isPacked\.toggle` | `ItemStore.swift` | 16 | 0 |
| `item-field-write` | `[iI]tem\.id *= `, `[iI]tem\.createdAt *= `, `[iI]tem\.name *= `, `[iI]tem\.quantity *= `, `[iI]tem\.itemDescription *= `, `[iI]tem\.photoData *= `, `[iI]tem\.bag *= `, `[iI]tem\.categoryEntity *= `, `[iI]tem\.subcategoryEntity *= `, `\.addToItems\(`, `\.removeFromItems\(` | `ItemStore.swift`, `M/Item.swift` | 36 **[measured]** | 0 |
| `item-delete` | `\.delete\(item\)`, `\.delete\(newItem\)` | `ItemStore.swift`, `DataReset.swift` | 3 **[measured]** | 0 |
| `source-write` | `weightSource *=[^=]`, `categorySource *=[^=]` | `M/Item.swift`. `ssot-allow` on plain-struct fields of the same name, such as `ItemDraft`'s and `TemplateItem`'s | 0 | 0 |
| `mirror-write` | `[a-zA-Z]*[iI]tem\.category *=[^=]`, `[a-zA-Z]*[iI]tem\.subcategory *=[^=]` | `M/Item.swift` | 11 | 0 |
| `current-weight` | `currentWeight` | `CoreDataManager.swift` | 24 | 0 |
| `weight-multiply` | `[wW]eight(Kg)? \* `, `knownKg \* ` | `M/Item.swift`. `ssot-allow` on `ItemDraft.totalKg`, which multiplies unsaved values | 9 | 0, with `TemplateItem.totalWeight` in that file |
| `raw-weight` | `[[:alnum:]_]\.weight[^[:alnum:]_]`, `[[:alnum:]_]\.weight$`, `weightEstimateKg` | `M/Item.swift`, and `CoreDataManager.swift` for the attribute description. `ssot-allow` on the `TemplateItem.weight` lines left in `V/EditTemplateView.swift`, `V/PackingTemplatesView.swift`, `M/PackingTemplate.swift` and `U/ItemStore.swift`, a different field that grep can't tell apart | 21 **[measured]** | 0, and it joins `verify.sh` there |
| `weight-format` | `%\.[0-9]f` | `WeightFormatter.swift` | 58 | 0, plus `ssot-allow` on non-weights like `V/CategoryAnalyticsView.swift:131` |
| `kg-literal` | `[0-9f ]kg[" )]` | `WeightFormatter.swift`, template data | 28 | 0 |
| `slider` | `Slider\(` | | 9 | 4 (P11) |
| `no-cat-labels` | `"General"`, `"Uncategorized"`, `"Other"` | Template data until it's JSON. `Item.legacyUncategorizedLabel` in `M/Item.swift`. `ssot-allow` at `V/SubBagView.swift:153` | 19 | 0 |
| `not-sorted` | `"Not sorted"` | `M/Item.swift` | 0 **[measured]** | 0, and it joins `verify.sh` with `Item.categorySortKey` |
| `image-decode` | `UIImage\(data:`, `CGImageSourceCreate`, `CGImageDestinationCreate` | `ImagePipeline.swift` | 3 | 1 in 1.1, the line in `M/Item.swift`. 0 in 2.0 |
| `defaults-literal` | `forKey: "` | `ssot-allow` on the KVC lines in `U/DebugSeed.swift`, and on the `setPrimitiveValue(nil, forKey: "name")` line in the `#if DEBUG` hook in `U/CoreDataManager.swift` | 2 | 0 |
| `web-url` | `https?://` | `ProxyClient.swift` | 0 | 0 |
| `launch-arg` | `PacBagDisableCloudKit`, `PACBAG_DISABLE_CLOUDKIT`, in `PacBag/*.swift` | `PacBag/Shared/` | 6 | 0 |
| `a11y-literal` | `accessibilityIdentifier\("`, in `PacBag/*.swift` | | 0 | 0 |
| `crisis-literal` | `988`, in `A/*.swift` and `B/src` | | 0 | 0 |
| `model-literal` | `claude-haiku`, `claude-sonnet`, `claude-opus`, in `A/*.swift` and in `.ts` files under `B/src` and `B/tools`. `B/test`, `B/eval` and `B/tools/catalog/review.csv` are out of scope, because a test's model table, recorded response bodies and the sidecar's `model` column hold model names | `B/src/ai/config.ts` | 0 | 0 |
| `spm-package` | `XCRemoteSwiftPackageReference`, in pbxproj | | 0 | 0 |
| `init-schema` | `initializeCloudKitSchema` | Its one `#if DEBUG` block | 0 | 1 |
| `apply-ai` | `applyAI\(` | `U/AI/Enricher.swift`, `U/ItemStore.swift` | 0 | 0 |
| `ui-em-dash` | The em dash character, in `A/*.swift`, `A/Info.plist`, `C/*.json`, `fastlane/metadata`, and `WEB/src` when the website path is set | | 3 **[measured: `description.txt:8`, `FAQ.tsx:32,38`]**, and it joins `verify.sh` at 1, once the website's first corrections clear `FAQ.tsx` | 0 |
| `sparkle` | `sparkle`, `wand\.`, `magicwand`, `apple\.intelligence`, `"brain`, case-insensitive | | 0 **[measured]** | 0 |
| `trim` | `trimmingCharacters` | `U/EntryParser.swift`, for `String.trimmedOrNil` | 44 **[measured]** | No end value. It joins `verify.sh` with `String.trimmedOrNil` at its count that day, as a no-new-lines ratchet |
| `recipient-literal` | `Anthropic`, `Claude`, `Railway` | | 0 **[measured]** | 0 |
| `name-compare` | `\.lowercased\(\) *==` | | 3 **[measured]** | 0 |
| `fallback-name` | `"Unnamed` | `M/Item.swift`, `M/Bag.swift` | 10 **[measured]** | 0 |
| `cat-separator` | `\) > \\\(` | `M/Item.swift`. `ssot-allow` at `V/CustomCategoryView.swift:63` | 4 **[measured]** | 0 |
| `grams-conv` | `/ 1000`, `\* 1000` | `WeightFormatter.swift` | 0 **[measured]** | 0 |

**A rule has to show it can fail.** `verify.sh` takes `rule NAME MAX REGEX ALLOW SAMPLE PATHSPEC...`, where SAMPLE is one known bad line. On every run a rule fails if SAMPLE doesn't match REGEX, if `git grep` exits above 1, so the draft's `2>/dev/null` goes, or if none of its pathspecs match a tracked file. A scratch prototype passed healthy rules at 5 and at 0 and a rule with a path that doesn't exist yet, and it failed a path typo, an unbalanced paren and a valid but wrong regex **[measured, not on the real script, and the prototype isn't saved in `evidence/`]**. A new rule can't be added without a sample. A check that doesn't run prints a `skip` line. The website path defaults to `../pacbag-website` from the parent of `git rev-parse --path-format=absolute --git-common-dir`, so a worktree reaches it.

The `is-packed-write` count differs from the "11" in `architecture.md` section 4 because grep includes previews and dead code. The `save` count is 28 rather than its 29 because the allowed file is excluded, and its one line goes into the new owner. The `no-cat-labels` count leaves out only template data, since `Item.legacyUncategorizedLabel` and the `V/SubBagView.swift:153` allowance don't exist yet. The `raw-weight` pattern catches writes as well as reads, and it skips enum cases like `case .weight:`. The `trim` count covers `A/` only, so the 2 lines in `T/SnapshotHelper.swift` aren't in its 44. Grep is a tripwire for honest mistakes, so a rename can get past it. That's fine for one developer.

Other checks in the same script:

| Check | How |
|---|---|
| `marketing-version`, `build-number` | One distinct value across pbxproj |
| `container-id` | Same string in entitlements and `CoreDataManager.swift` |
| Retired claims | `scripts/retired-claims.txt`, lines of `gate\|phrase`, case-insensitive. Gates: `always` (both repos), `2.0` (app repo, on when `MARKETING_VERSION` major is 2 or more), `site-submit` (website, `SITE_PHASE` is `submit` or `release`), `site-release` (website, `SITE_PHASE` is `release`). Excludes `docs/` and the list itself. A line searches every other tracked file in its repo, comments and tests included, so `always\|Usage Analytics` also hits the comment at `M/CategoryAnalytics.swift:3`, and a test that holds a retired phrase trips its own line. Once the marketing cut is live, the `site-submit` and `site-release` lines move to `always`, so they run on every website push and every daily `verify` run |
| `disclosure-copy` | `cmp` of the app and website copies, only when `SITE_PHASE` is set or `STRICT=1`. Lane `beta` sets `STRICT=1` on a 1.x build and neither on a 2.0 build, and `release-check.sh external` sets both. A 1.x build skips it once the website copy's `consentVersion` is above the app's, and says so in its output, because after the legal cut a 1.1.x patch would otherwise fail and the `cp` would overwrite the website's copy. The failure message prints the `cp` to run |
| Bundle and app ids | Compare `BUNDLE_ID` and `APP_APPLE_ID` in `B/src/identity.ts` to pbxproj and to `links.appStore` |
| Metadata | Length limits, `plutil -lint` on the manifest |
| `min-ios` | `IPHONEOS_DEPLOYMENT_TARGET` in pbxproj equals the minimum iOS in `WEB/src/data/site.ts`. Skipped until `site.ts` exists, the way `disclosure-copy` skips without `STRICT=1` |
| `retention-copy` | `C/disclosure.json` contains "within 3 days", and under `SITE_PHASE` so does `WEB/src/app/privacy/page.tsx`. The failure message names the reply template in `docs/records-of-processing.md`, which nothing checks, and the consent version bump a longer retention needs |
| `promise-copy` | `disclosure.json` `promise` appears by `grep -F` in `fastlane/metadata/en-US/description.txt`, and from release day on in `FAQ.tsx`, which holds it on one line in a double-quoted string, so its apostrophe stays plain. It runs from `release-check.sh submit` and `release` and not from `external`, because the description holds photo words ahead of `promise` |
| `manifest-url` | The `related_applications` `url` in `WEB/public/manifest.json` equals `disclosure.json` `links.appStore`. Skipped until `C/disclosure.json` exists |

Starting lines for `retired-claims.txt`. Each `always` line is added by the commit that clears its last copy, because it fails as soon as its phrase exists in either repo. The `site-submit` and `site-release` lines stay off until their phase, so they can land ahead of the commit that clears them:

```
always|save it as a PDF
always|stored in your iCloud Photo Library
always|Usage Analytics
always|iOS 17+
always|Eight ready-made
always|Eight ship with the app
always|nothing guessing what you should bring
always|find out you're over at home
always|over at home instead of at the airport
always|overweight at home
always|intelligent organization
always|Reset App&quot; in settings
always|Photo access requires your explicit permission
always|revoke photo access
always|Built with iOS accessibility features
always|Meets all Apple App Store Review Guidelines
always|testimonial
always|aggregateRating
2.0|NO ACCOUNT, NO SERVER
2.0|There's no server
2.0|There is no server and no login
2.0|Every feature works offline
2.0|label: "Data collected"
2.0|No server, no sign-up
2.0|Your lists stay in your own iCloud
2.0|everything in your iCloud
2.0|go nowhere else
site-submit|collect any personal data
site-submit|collect personal data
site-submit|talk to any server of ours
site-submit|No third-party data sharing
site-submit|only uses Apple
site-submit|We do not collect, store, or access
site-submit|No personal data collection
site-submit|All your data is stored privately
site-submit|All data stays in your iCloud
site-submit|cannot access your information
site-submit|cannot see, access, or retrieve
site-submit|collect personal information
site-release|Into your own iCloud account, and nowhere else
site-release|There is no PacBag server
site-release|no free tier and nothing held back
site-release|No server, no sign-up
```

I checked each phrase with a case-insensitive fixed-string search at `0c10439` and website `2b944cc`, and each hits at least one repo, except for two pairs. `collect personal data` and `talk to any server of ours` have 0 hits, and I checked them against the replacement sentences in `specs/compliance.md` section 2.3, so they start hitting when the corrected policy goes live. `testimonial` and `aggregateRating` have 0 hits, and they're there to keep a fake review out. `collect any personal data` and `only uses Apple` drop to 0 when that same correction lands, and after that they only stop the old wording coming back. Website apostrophes are HTML entities, which is why two phrases are cut short. The rest of the 72 rows in `understand/docs-website.md` section 2 get a line when they're rewritten, if they could come back.

**When it runs.**
1. A `pre-push` git hook, one line. Worktrees share hooks, so it's installed once.
2. Inside `scripts/release-check.sh`, called by fastlane lanes `ios beta` and `ios candidate`, with `SITE_PHASE` and `STRICT` per phase and the website path set, so a release can't skip it. It sets `SITE_PHASE` only when `MARKETING_VERSION` major is 2 or more, and a 1.x build runs with `STRICT=1` alone, because the `site-submit` lines retire claims that stay true through 1.1. `specs/test-release.md` section 2.6 has the table. `scripts/concurrency-check.sh` (the Swift 6 shadow compile) runs there too, not in the hook, so `verify.sh` stays at `git`, `grep` and `cmp`. `STRICT=1` fails if the website copy is missing. Without it, the script skips that one check, which is what a plain worktree needs.
3. `release-check.sh external`, by hand, right before a build goes to the external TestFlight group, because that's a click in App Store Connect and no lane sees it. It runs `verify.sh` with `SITE_PHASE=submit STRICT=1`, plus the live site checks in `specs/test-release.md` section 2.6.
4. A one-line `pre-push` hook in the website repo, with `A` set to the app's absolute path: `unset GIT_DIR; [ -x "$A/scripts/verify.sh" ] || exit 0; CLAIMS_ONLY=1 "$A/scripts/verify.sh" "$A" "$PWD"`. `CLAIMS_ONLY=1` runs only the retired-claims loop against the website, with no ratchets, no `disclosure-copy` and no search of the app repo, so an app edit can't block a site fix. A Vercel rollback or a GitHub web edit gets past it.
5. A daily `verify` run in the private `pacbag-ops` repo, on read-only clones of both public repos. It sets no `STRICT` or `SITE_PHASE`, so `disclosure-copy` and the `site-` lines stay with the lanes until the marketing cut moves those lines to `always`. It skips `plutil` when that's absent **[not run on Linux]**. It reads the website's `main`, so an `always` line waits for the website merge. Failures reach you by GitHub's failure email.

The local pre-push hook is the push gate. The public repos run no CI for this script, so `server.yml` stays the only workflow on a commit there. `server.yml` covers the server, and `healthz.yml` and the daily `verify` run are the scheduled checks. iOS tests stay local through `scripts/test.sh`.

### 3.2 Tests

These run in `xcodebuild test` and `npm test`, so they don't need a habit. **First commit has to add `PacBagTests` to the shared scheme**, because `xcodebuild test -scheme PacBag` doesn't run unit tests today. The scheme's test action carries `language` and `region`. Concurrency debug sits on the launch action, and hosted tests inherit it. Unit tests get the in-memory store by detecting `XCTestConfigurationFilePath`. UI tests get locale, in-memory store and portrait from `T/Support/PacBagUITestCase.swift`.

| Test | Side | Stops |
|---|---|---|
| `ContractTests` | Swift | Every JSON decodes. Catalog keys are in the taxonomy, template keys are in the catalog, no duplicate keys, sane limits. Every `aiOffStorefronts` entry matches `^[A-Z]{3}$`. `features.photo` matches the Photos type in `PrivacyInfo.xcprivacy`, and the camera string's second sentence is there exactly when `features.photo` is true |
| `SchemaParityTests` | Swift | Attribute without a declaration, or the reverse. Allowlist: `Bag.currentWeight`. Also compares against `X/schema/production-fields.json`, a deliberate test-only pin |
| `ItemStateTests` | Swift | One case for every row of the reader tables in `architecture.md` section 5, plus `knownKg` and `pendingFields` (P1) |
| `WeightSummaryTests` | Swift | One case for every row of `architecture.md` section 8, and `E + S == Bag.totalWeight` |
| `WeightFormatterTests` | Swift | kg, lb, grams under 1 kg, `en_US` and `pt_BR`, estimate and unknown marks |
| `ItemStoreTests` | Swift | `applyAI` skips deleted rows, follows the text and photo rules in section 1.7, and never writes an AI value to `weight`. A name change flips sources, clears the estimate and keeps a person's number. Two inserts differ. Runs with `-com.apple.CoreData.ConcurrencyDebug 1` |
| `CategoryReconcilerTests` | Swift | Winner choice, archived rows excluded |
| `MigrationTests` | Swift | Opens `X/stores/1.0/` and `X/stores/1.0.1/`, against the manifests `scripts/store-manifest.sh` writes (owner: `specs/data-model.md` section 8.6) |
| `WireFixtureTests`, `wire.test.ts`, `validate.test.ts` | Both | Each fixture in `X/fill/` decodes on each side. `X/length_cases.json` gives the same length from `Limits.wireLength(_:)` and `normalizeInput` |
| `CrisisTests`, `crisis.test.ts` | Both | `crisis_cases.json` gives the same hits, `message` matches `crisis_response.json` byte for byte |
| `outcome.test.ts` | Server | Anthropic failure mapping, non-200s, chain order, 200 union only |
| `logger.test.ts` | Server | Canary item text never reaches logs |
| `deps.test.ts` | Server | `package.json` runtime dependencies equal the three allowed, `@apple/app-store-server-library` pinned exactly, `engines` and `Dockerfile` match `.nvmrc`. Adding one means updating `disclosure.json` |
| `ProxyClientTests`, `CatalogSourceTests`, `CatalogCoverageTests`, `ParserTruthTests`, `ExportRendererTests`, `EntryParserTests`, `ItemResolverTests`, `YourItemsSourceTests`, `EnricherTests`, `AIAvailabilityTests`, `AIConsentTests`, `DataResetTests`, `TemplateStoreTests`, `CategoryManagerTests`, `CoreDataManagerTests`, `ItemChangeRelayTests`, `CloudKitEventObserverTests`, `ItemDraftTests`, `WeightFieldTests`, `DefaultsKeyTests`, `TemplateItemCodingTests`, `ItemSectionsTests`, `BagTests`, `ImagePipelineTests`, `ItemThumbnailTests`, `PhotoPreflightTests`, `PhotoIntakeTests`, `ItemPhotoStateTests`, `ItemFormModelTests`, `OnboardingManagerTests` | Swift | Their owners' rules. `CatalogCoverageTests` reads the constant `G3Policy.enforced` (owner: `specs/prompts-evals-catalog.md` section 4). `ManualSleep` and `ScriptedClient` are test helpers, not suites (owner: `specs/ai-client.md` S8.1) |
| `WeightChainTests`, `PackCountTests`, `CategoryTextTests`, `TemplateApplyTests`, `TemplateCaptureTests`, `ExportGoldenTests` | Swift | Today's behaviour, pinned before anything moves (`specs/domain-layer.md` section 2.4) |
| `fill.test.ts`, `quota.test.ts`, `identity.test.ts`, `validate.test.ts`, `me.test.ts`, `prompts.test.ts`, `catalog.test.ts`, `free.test.ts` | Server | Chain order and reservation table in 2.8, the validator rows in `specs/prompts-evals-catalog.md` section 2.6 and `specs/backend.md` section 7. Free gates run in `npm test` |
| `SmokeTests` in `T/SmokeTests.swift`, `T/ItemFlowUITests`, `scripts/smoke-server.sh` (`specs/test-release.md` section 3.6) | Swift, server | The core flows break in the UI, or a deployed server doesn't answer or answers through Cloudflare's proxy |

Free eval gates and paid runs are defined in `specs/prompts-evals-catalog.md` section 2.9. They guard accuracy, not duplication.

### 3.3 The habit

When you add a fact, add a row to `docs/ssot-registry.md` in the same commit. If you can't name one owner, don't add the fact yet. That's review discipline, and nothing enforces it.

### 3.4 Left out on purpose

These were proposed or are obvious ideas, and I don't think you'd keep them running: a code generator, a cross-repo prebuild fetch, SwiftLint or any lint dependency, an OpenAPI toolchain, a check that the feature list matches across surfaces, screenshot diffing of copy, automatic checks of the App Privacy label, and live link checks.

Debt that's listed and left, under Owner's call 10: 7 packing `progressColor` copies, 8 stat tiles, 6 empty states, 85 style pairs, the settings key table, `NavigationView`, bag, trip and category forms, template row variants, `SubBagType`. The rule there is no new copies. Only some of that has a grep behind it.
