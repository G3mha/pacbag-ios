#!/bin/bash
# Usage: scripts/verify.sh [<app-repo>] [<website-repo>]
# A grep ratchet over tracked files. Each MAX is today's count: a commit that removes copies lowers it, and one that adds a copy fails.
# A line ending in "// ssot-allow: why" is exempt. docs/ssot-registry.md section 3.1 owns the rules.
# Env: CLAIMS_ONLY=1 runs only the retired claims, against the website. SITE_PHASE=submit|release and STRICT=1 are set by release-check.sh.
set -u
APP=$(cd "${1:-$(git rev-parse --show-toplevel)}" && pwd)
COMMON=$(git -C "$APP" rev-parse --path-format=absolute --git-common-dir)
WEB="${2:-$(dirname "$(dirname "$COMMON")")/pacbag-website}"
fail=0
bad() { echo "FAIL $1"; fail=1; }
ok() { echo "ok   $1"; }

# rule NAME MAX REGEX ALLOW SAMPLE PATHSPEC...
rule_with() {
  local flags="$1" name="$2" max="$3" re="$4" allow="$5" sample="$6"; shift 6
  if ! printf '%s\n' "$sample" | grep -qE $flags -- "$re"; then bad "$name: its sample doesn't match its regex"; return; fi
  if [ -z "$(git -C "$APP" ls-files -- "$@" | head -1)" ]; then bad "$name: no tracked file matches $*"; return; fi
  local out rc n
  out=$(git -C "$APP" grep -nE $flags -e "$re" -- "$@"); rc=$?
  if [ "$rc" -gt 1 ]; then bad "$name: git grep failed"; return; fi
  n=$(printf '%s\n' "$out" | grep -v 'ssot-allow:' | grep -vE "${allow:-^$}" | grep -c .)
  if [ "$n" -gt "$max" ]; then bad "$name: $n > $max"; else ok "$name: $n (max $max)"; fi
}
rule() { rule_with "" "$@"; }
rule_i() { rule_with "-i" "$@"; }

claims() { # repo gate-matching phrases
  local repo="$1" gates="$2" gate phrase
  [ -d "$repo/.git" ] || [ -f "$repo/.git" ] || { echo "skip claims in $repo: not a checkout"; return; }
  while IFS='|' read -r gate phrase; do
    case "$gate" in '#'*|'') continue ;; esac
    case " $gates " in *" $gate "*) ;; *) continue ;; esac
    if git -C "$repo" grep -nFi -e "$phrase" -- ':!scripts/retired-claims.txt' ':!docs/*' >/dev/null; then
      bad "retired claim in $repo: $phrase"
    fi
  done < "$APP/scripts/retired-claims.txt"
}

RC="$APP/scripts/retired-claims.txt"
if [ "${CLAIMS_ONLY:-0}" = "1" ]; then
  gates="always"
  case "${SITE_PHASE:-}" in submit) gates="$gates site-submit" ;; release) gates="$gates site-submit site-release" ;; esac
  claims "$WEB" "$gates"
  exit $fail
fi

S='PacBag/PacBag/*.swift'
P='PacBag/*.swift'
STORE='Utilities/ItemStore\.swift'
ITEM='Models/Item\.swift'
CD='Utilities/CoreDataManager\.swift'
FMT='Utilities/WeightFormatter\.swift'
TPL='Models/PackingTemplateData\.swift'

rule item-create      4  'Item\(context:'                                   "$STORE"        'let i = Item(context: c)'                 "$S"
rule save             26 '[cC]ontext\??\.save\(\)'                          "$CD"           'try viewContext.save()'                   "$S"
rule fatal            3  'fatalError\(|preconditionFailure\('               'Utilities/Contract\.swift' 'fatalError("x")'              "$S"
rule is-packed-write  15 '\.isPacked *=[^=]|\.isPacked\.toggle'             "$STORE"        'item.isPacked = true'                     "$S"
rule item-field-write 33 '[iI]tem\.(id|createdAt|name|quantity|itemDescription|photoData|bag|categoryEntity|subcategoryEntity) *= |\.addToItems\(|\.removeFromItems\(' "$STORE|$ITEM" 'item.name = x' "$S"
rule item-delete      3  '\.delete\((item|newItem)\)'                       "$STORE|Utilities/DataReset\.swift" 'context.delete(item)'  "$S"
rule source-write     0  '(weight|category)Source *=[^=]'                   "$ITEM"         'x.weightSource = y'                       "$S"
rule mirror-write     10 '[a-zA-Z]*[iI]tem\.(category|subcategory) *=[^=]'  "$ITEM"         'newItem.category = x'                     "$S"
rule current-weight   24 'currentWeight'                                    "$CD"           'bag.currentWeight'                        "$S"
rule weight-multiply  9  '[wW]eight(Kg)? \* |knownKg \* '                   "$ITEM"         'weight * q'                               "$S"
rule weight-format    55 '%\.[0-9]f'                                        "$FMT"          'String(format: "%.1f", x)'                "$S"
rule kg-literal       28 '[0-9f ]kg[" )]'                                   "$FMT|$TPL"     '3.0 kg"'                                  "$S"
rule slider           9  'Slider\('                                         ''              'Slider(value: $x)'                        "$S"
rule no-cat-labels    18 '"(General|Uncategorized|Other)"'                  "$TPL"          'x = "General"'                            "$S"
rule image-decode     3  'UIImage\(data:|CGImageSourceCreate|CGImageDestinationCreate' 'Utilities/ImagePipeline\.swift' 'UIImage(data: d)' "$S"
rule defaults-literal 0  'forKey: "'                                        ''              'set(1, forKey: "x")'                      "$S"
rule web-url          0  'https?://'                                        'Utilities/AI/ProxyClient\.swift' 'let u = "https://x"'    "$S"
rule launch-arg       0  'PacBagDisableCloudKit|PACBAG_DISABLE_CLOUDKIT'    'PacBag/Shared/' '-PacBagDisableCloudKit'                  "$P"
rule a11y-literal     0  'accessibilityIdentifier\("'                       ''              '.accessibilityIdentifier("x")'            "$P"
rule crisis-literal   0  '988'                                              ''              'tel:988'                                  "$S" 'backend/src/*'
rule model-literal    0  'claude-(haiku|sonnet|opus)'                       'backend/src/ai/config\.ts' 'claude-opus-5-5'              "$S" 'backend/src/*.ts' 'backend/tools/*.ts'
rule spm-package      0  'XCRemoteSwiftPackageReference'                    ''              'XCRemoteSwiftPackageReference'            'PacBag/PacBag.xcodeproj/project.pbxproj'
rule init-schema      0  'initializeCloudKitSchema'                         ''              'try c.initializeCloudKitSchema()'         "$S"
rule apply-ai         0  'applyAI\('                                        "Utilities/AI/Enricher\.swift|$STORE" 'store.applyAI(x)'   "$S"
rule recipient-literal 0 'Anthropic|Claude|Railway'                         ''              'sent to Anthropic'                        "$S"
rule name-compare     3  '\.lowercased\(\) *=='                             ''              'a.lowercased() == b'                      "$S"
rule fallback-name    9 '"Unnamed'                                         "$ITEM|Models/Bag\.swift" 'x ?? "Unnamed Item"'            "$S"
rule cat-separator    3  '\) > \\\('                                        "$ITEM"         '"\(a) > \(b)"'                            "$S"
rule grams-conv       0  '/ 1000|\* 1000'                                   "$FMT"          'g / 1000'                                 "$S"
rule_i sparkle        0  'sparkle|wand\.|magicwand|apple\.intelligence|"brain' ''           'Image(systemName: "sparkles")'            "$S"

# One value, wherever it's repeated on purpose.
one() { local name="$1" n; shift; n=$("$@" | sort -u | wc -l | tr -d ' ')
  if [ "$n" -ne 1 ]; then bad "$name: $n distinct values"; else ok "$name"; fi; }
PBX="$APP/PacBag/PacBag.xcodeproj/project.pbxproj"
one marketing-version grep -oE 'MARKETING_VERSION = [^;]+' "$PBX"
one build-number      grep -oE 'CURRENT_PROJECT_VERSION = [^;]+' "$PBX"
one container-id      grep -hoE 'iCloud\.com\.[A-Za-z.]+' "$APP/PacBag/PacBag/PacBag.entitlements" "$APP/PacBag/PacBag/Utilities/CoreDataManager.swift"

# Retired claims. docs/ssot-registry.md section 3.1 owns the gates.
if [ -f "$RC" ]; then
  major=$(grep -m1 -oE 'MARKETING_VERSION = [0-9]+' "$PBX" | grep -oE '[0-9]+$')
  app_gates="always"; [ "${major:-0}" -ge 2 ] && app_gates="$app_gates 2.0"
  web_gates="always"
  case "${SITE_PHASE:-}" in submit) web_gates="$web_gates site-submit" ;; release) web_gates="$web_gates site-submit site-release" ;; esac
  claims "$APP" "$app_gates"
  claims "$WEB" "$web_gates"
else
  echo "skip retired claims: no list"
fi

# Website copy of disclosure.json, only with SITE_PHASE or STRICT=1.
D="$APP/PacBag/PacBag/Contract/disclosure.json"; WD="$WEB/website/src/data/disclosure.json"
if [ -n "${SITE_PHASE:-}" ] || [ "${STRICT:-0}" = "1" ]; then
  if [ -f "$D" ] && [ -f "$WD" ]; then
    cmp -s "$D" "$WD" && ok disclosure-copy || bad "disclosure copy differs. Fix: cp $D $WD"
  else
    bad "disclosure files missing, and a release check needs them"
  fi
else
  echo "skip disclosure-copy: no SITE_PHASE or STRICT"
fi

# Metadata length limits, in characters.
limit() { local file="$APP/fastlane/metadata/en-US/$1" n
  [ -f "$file" ] || { echo "skip metadata $1: no file"; return; }
  n=$(LC_ALL=en_US.UTF-8 wc -m < "$file" | tr -d ' ')
  if [ "$n" -gt "$2" ]; then bad "metadata $1: $n > $2"; else ok "metadata $1: $n (max $2)"; fi; }
limit name.txt 30
limit subtitle.txt 30
limit promotional_text.txt 170
limit keywords.txt 100
limit description.txt 4000
limit release_notes.txt 4000

exit $fail
