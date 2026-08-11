# Changes in this pack

**This build: 1.0.5** — strips the fake mount drop sources (below). Previous: 1.0.4, the per-field merge fix. Safe to version this pack freely;
unlike pfQuest itself it broadcasts nothing, so a bump cannot tell other players in your
raid that an update exists.

Everything in `pfQuest-octo` that is not just the two upstream datasets copied together.
The data itself is unmodified — see [Credits](README.md#credits). This file covers the
pack's own code (`patchtable.lua`, `overwrites.lua`) and what is shipped.

## Bugs fixed

### 1.0.5 — 21 custom mounts claimed to drop from hundreds of ordinary mobs

Reported in Discord with a screenshot: a level-6 Venture Co. Lumber Worker on the goblin
starter island showing *Onyxian Drake 2.50%* in its pfExtend loot tooltip, plus "mounts on
non possible creatures". The extracted data attributes 21 custom mount items (riding
crabs, thunder lizards, scorpids, both drakes, Admiral Grumbleshell, Big Blizzard Bear) to
**240–977 units each** at uniform template chances — unit 6, *Kobold Vermin*, included.
The custom mounts with real drop sources (30000–30007) list 1–7 specific units, so the
artifact class is unmistakable. `overwrites.lua` now strips the `["U"]` table of those 21
items before the merge; vendor and object sources stay, and world-drop materials,
pickpocket pouches and the jewelcrafting plans seeded into shared recipe pools are
deliberately untouched. Pairs with pfExtend keying its cached loot DB to this pack's
version, so existing installs rebuild on their first login after updating.

### The pack was deleting quest data it never meant to touch

`patchtable.lua` merged the pack into pfQuest's base database entry by entry:

```lua
base[k] = v   -- v is the whole [questid] = { ... } record
```

The pack is not a diff, though — it is a **full redump**, and a large number of its records
are truncated copies of the base record. Assigning the whole entry therefore replaced a
complete vanilla record with an incomplete one, deleting fields that neither dataset had
ever intended to change.

Measured against the base database across the 4,198 quests present in both:

| field lost | quests | what breaks |
|---|---|---|
| `obj` | 785 | **no objective pins at all** |
| `I` | 643 | quest-starter item not found |
| `pre` | 366 | prerequisite chains, and the "Part X of Y" tooltip |
| `class` | 279 | class-restricted quests shown to everyone |
| `end` | 121 | **no turn-in pin** |
| `close` | 120 | quests not auto-completed by their chain |

1,230 entries lost at least one field. **1,206 of them are pure truncation** — every field
present in both is byte-identical and the rest are simply absent. Of the 24 that do change
a value, not one changes a field it also omits.

Reported as: *Shizzle's Flyer* (quest 4503, Un'Goro) showing no objective pins. Its base
record carries `obj.I = {11830, 11831}` — the two webbed scales, which between them drop
from six mobs across 237 spawn points. The pack's record is that same record with `obj`
missing, so every one of those pins disappeared.

Fixed by merging **per field** instead of per entry, for the four databases whose entries
are maps of named fields (`quests`, `units`, `items`, `objects`). The pack still wins
wherever it actually says something; the base record fills in what it stays silent about.
Deletion keeps an explicit sentinel at both levels — `[id] = "_"` removes an entry,
`["pre"] = "_"` removes a single field — so a real removal can still be expressed.

`zones`, `minimap`, `refloot`, `quests-itemreq` and `professions` deliberately keep
whole-entry replacement: they store positional arrays (`{ 406, 7.49, 7.49, 49.55, 61.98 }`)
or plain values, where a per-field merge would splice two records together index by index
instead of replacing one with the other.

Verified by running both merge functions over the real databases: entry count unchanged at
6,701, `obj` 3,449 → 4,234, `pre` 3,306 → 3,672, `end` 6,451 → 6,572.

This is the same class of bug as the locale merge fixed earlier in this file's history —
there, whole-entry assignment silently discarded 14 quest descriptions — but on the data
tables, where the damage was two orders of magnitude larger.

## Local changes

- **All six locales are shipped.** An earlier revision dropped everything but enUS to
  save 21.7 MB of login parsing; it was reverted because pfQuest's `[Translate]` button
  reads the pack's locale tables too, and without them a Turtle- or Octo-added quest
  falls back to English while a vanilla one translates. See pfQuest's changelog for the
  `[Translate]` fix and the **Quest Text Translations** option that frees this data for
  anyone who would rather have the memory.
- **Pack version is printed on load**, and a loud warning is shown if `overwrites.lua` did
  not finish, so a bug report against the Octo data has a version to quote.
- **Quest tooltips** gain a "Part X of Y" chain position and an "Introduced in: *patch*"
  line; NPC tooltips gain a rank marker, averaged coordinates for single-zone spawns, and
  the same patch tag.
