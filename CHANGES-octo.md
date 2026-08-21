# Changes in this pack

**This build: 1.1.1** — three NPCs the world spawns that the pack had no record of, and the missing turn-in for *Shellcoins*. Previous: 1.1.0 — the locale split: each language is now a separate load-on-demand addon, so a login parses only your own. Previous: 1.0.13 — *Poisoned Water* (6804) gains a unit objective: the Blighted Surges the Aspect of Neptulon is used on, because the actual bracer-dropper only exists mid-transformation and has spawns in no database. Previous: 1.0.12 — the 38 approved replacements: quests the server reworked after extraction now carry the server's current objectives (the pack's only non-additive change, applied on explicit approval). Previous: 1.0.11 — batch 2 of the server comparison: 35 race/class restrictions removed that the server does not have (the pack was hiding those quests from eligible players), 9 objective items appended (Valthalak chain among them). Previous: 1.0.10 — the collect batch: 197 collect quests gain item objectives (166 draw pins immediately), 20 recovered collectables. Previous: 1.0.9, the first server-authoritative batch from the full crawl of the server's own database site: 12 restored objectives and 12 restored class/race requirements, including the fix for class-restricted quests showing to the wrong class. Previous: 1.0.8 (56 quests from the name-match audit), 1.0.7 (nine Moonwhisper quests), 1.0.6 (first two), 1.0.5 (fake mount sources stripped), 1.0.4 (per-field merge fix). Safe to version this pack freely;
unlike pfQuest itself it broadcasts nothing, so a bump cannot tell other players in your
raid that an update exists.

Everything in `pfQuest-octo` that is not just the two upstream datasets copied together.
The data itself is unmodified — see [Credits](README.md#credits). This file covers the
pack's own code (`patchtable.lua`, `overwrites.lua`) and what is shipped.

## Bugs fixed

### 1.1.1 — three spawned NPCs, and somewhere to hand in *Shellcoins*

Checked against a fresh server extract rather than the database site: of 10,856 creatures with
real spawns, only **72** were absent from this pack, and of those only three carry anything a
player would look up. The other 69 are mount displays, script triggers, waypoints, and ambient
NPCs pfQuest has no business drawing. Quest coverage came out clean — 8 quests exist server-side
without an entry here, and not one of them has both a questgiver and a turn-in, so none is
obtainable.

**Elodia is the real fix.** *Shellcoins* (80381) was already in the pack with its collect item,
but with no `["end"]`. Its objective reads "return to Elodia" while the map showed nowhere to
return to. She is now recorded, and the quest points at her.

**The Mysterious Stranger is recorded but not wired.** He stands in all eight starting zones, so
he is here as a plain unit and "where is this NPC" now answers. His only quest is 80388,
*[DEPRECATED] Stay Awhile and Listen...*, the retired Immortal-mode offer — attaching it would
walk people to a dead quest, so it is deliberately left off.

**Innkeeper Warmbreeze is recorded but is not an innkeeper.** He carries the subname, but
`npc_flags 0` where 73 of this server's 80 innkeepers carry 135. He is added as an ordinary unit
and deliberately kept out of the innkeeper tracking list, which is a promise that you can bind
where it sends you.

Zone ids were learned by voting rather than read from the extract, whose `zone_id` column is 0 on
51,992 of its 53,732 spawn rows. Every NPC both sources place in exactly one zone votes; the only
runners-up were the city-inside-a-zone cases, which is the mapping working rather than noise.

### 1.1.0 — the pack stops loading five languages you do not read

Every login parsed all six locale databases — about 22 MB of Lua source — and then kept
them for the entire session. Two separate problems, both fixed here.

**They were never freed.** Base pfQuest reclaims its own unused locales through
`freelocales()`, but that walks `pfDB.locales`, whose keys are plain codes (`deDE`). This
pack stores its tables one key over, as `deDE-turtle`, so they were invisible to it and
stayed resident. Worse, base pfQuest frees its non-active `items`/`units`/`objects`
locales *before* this pack merges, so for those the merge found no base table to write
into and skipped them — the data was loaded, never read, and never released.
`patchtable.lua` now drops every `<locale>-turtle` table once the merge is done.

**They were loaded at all.** Freeing still pays the parse cost first, and that peak
arrives before any addon code can run, so no option can avoid it. Each language is now
its own `LoadOnDemand` addon (`pfQuest-octo-deDE` and friends) and `localeload.lua` pulls
in only the one matching `GetLocale()`. `enUS` stays in the main addon because the merge
falls back to `enUS-turtle` for locales with no pack data.

Nothing changes for English clients beyond the saving. Other languages keep their text by
copying one extra folder — see [Install](README.md#install); the download now carries
correctly named folders, so the old rename step is gone.


### 1.0.13 — Poisoned Water pins the Blighted Surges

A player report: *Poisoned Water* (6804, Duke Hydraxis's Eastern Plaguelands errand)
showed nothing on the map. The quest's bracers drop from **Discordant Surges, which do
not exist in the world** — one appears only when the Aspect of Neptulon is used on a
**Blighted Surge** standing in the stagnant ponds, and every database (this pack, the
server's own export, vanilla data) accordingly records zero spawns for the dropper.
The Blighted Surges themselves are well-recorded, so they are now the quest's unit
objective: the pins mark exactly where the quest happens, and the transformation
produces the dropper on the spot. The base item objective rides along because the
per-field merge replaces `["obj"]` whole.

The same report round also flagged *The Key to Karazhan IV*, *One Heir to Another*,
*Brother's Duty* and *In Need of Water* as pin-less: all four verified against the
server database as talk-to/delivery quests whose enders (Krog, Baine Bloodhoof,
Hulfnar Stonetotem, Duke Hydraxis) have spawns — their turn-in pins already draw, and
`/db checkdb` (in the pfQuest forks) now names that pin instead of red-flagging them.
No data change was needed for those four.

### 1.0.12 — the 38 reworked quests now match the server

The final batch of the server comparison, and the pack's first and only non-additive
change — applied on explicit approval rather than by doctrine: **34 quests whose
kill/interact objectives the server redesigned** after the pack data was extracted
(*Screecher Spirits* pins the right spirit now, *The Burning of Spirits* the right
totems), plus **4 where the pack listed targets the server dropped**. Their objective
tables are replaced verbatim with the server's current ones.

With this, every measurable category is server-consistent: objectives, masks,
start/end links, item sources. What remains unfixable is documented: 726 collect
quests with no source listed server-side, and the extraction holes (Moro'gai) that
exist in no data export.

### 1.0.11 — the pack was hiding 35 quests the server serves

The full pack-vs-server comparison (every quest, every field) surfaced the inverse of
the Light of An'she bug: **35 quests carry a race or class restriction in the vanilla
data that this server deliberately removed** — among them the epic-mount chains and
Winter Veil quests opened to both factions. pfQuest was filtering their pins away from
players the server offers them to. The restriction fields are removed to match the
server. Also: 9 objective items the server lists appended to existing objectives (the
Valthalak amulet pieces). Start/end links and all remaining masks verified complete —
zero further gaps.

Held for approval, not applied: 34 quests whose kill/interact objectives the server
REWORKED (the pack's pins point at the old design) and 4 where the pack lists targets
the server dropped — replacing shipped data needs a deliberate go.

### 1.0.10 — the collect batch: 197 quests, and the "absent" collectables were there all along

With the item pages of the server database crawled, every collect quest whose objective
items have a known source gets its `["I"]` objective — 197 quests, 166 of them with
sources already in the unit data, so their pins draw immediately. The 20 new item
entries are the quiet headline: the Frozen Highborne Vials, the Meteor Shard, the
Maras'ethil-era relics — all extracted long ago as ground objects that nothing
referenced, classified "genuinely absent" by the 1.0.8 audit, and now wired up with the
server's own drop data. Also recovered this way: *Taste for Hydra* (the Whispering
Hydra had 40+ coast spawns all along; an earlier search truncated past it).

726 collect quests remain unfixed for an honest reason: no source is listed even
server-side.

### 1.0.9 — first batch from the server's own database

The whole quest database on octowow.st/db (the server's data, rendered) was crawled and
parsed — all 6,889 known ids. This batch ships what needs no further waiting:

- **12 kill/interact objectives** the pack lacked, ids spawn-verified — including
  *Destroy the Deathtotem*, which the 1.0.8 name-match audit had correctly held back as
  unverifiable and the server data now settles.
- **12 class/race requirements** the pack never carried. The visible symptom, reported
  by a player: a Tauren druid saw the Tauren-priest *Light of An'she* chain pinned —
  the entries had a race mask but no class mask, so there was nothing to filter on.
  Priest, shaman and mage chains are covered.

Still queued from the same crawl: ~920 collect quests get their pins once the item
pages (drop sources) finish crawling, and 665 quests where the pack and the server
disagree on objectives get a compared review rather than a blind overwrite.

### 1.0.8 — the full audit: every no-objective quest in the database, classified

Prompted by three player reports in two days, the whole database went under the lens
instead of one zone at a time. Of **6,889 merged quests, 2,580 carry no objective data**.
The audit classified every one:

- **1,265 talk/delivery + 9 reputation quests** — no objectives is *correct* for them;
  the turn-in marker is the guidance. `/db checkdb` listing them is expected.
- **39 deprecated/unused quests** — pins would be pointless.
- **659 quests whose text names nothing that exists in the database** — the genuinely
  absent class. These need a fresh server-data extraction, not client-side work.
- **56 quests restored here.** A name-match pipeline (unit/item names from the database
  found in the quest's own objective text, spawns and drop-sources verified, quest
  enders and location mentions mechanically excluded, items only when their drop table
  intersects units the text names) proposed candidates; every surviving row was then
  reviewed by hand before shipping. Applied absent-only, like every block before it.
- **268 quests with matches but not proof** — object-only matches (the "in Ironforge"
  trap), cross-zone reuse of vanilla names by custom quests, ambiguous intent. Held for
  future verification rather than guessed at; the full list lives in the audit report.

### 1.0.7 — nine more Moonwhisper Coast quests drew no pins

Two more `/db checkdb` reports from Discord covering twenty log quests between them. Nine
had their targets in the unit data all along, hand-verified by the same doctrine as 1.0.6
(unit name matches what the objective text names, spawns in zone 5642 where the quest says):
*Hiding in the Shade* (41993 → the three Shadewalker units), *Shade Mother* (41994 →
Matriarch Ohanzee), *Wanted: Growlpaw* (41948 → Growlpaw), *Collectors of Draenethyst*
(42011 → Starshard Collector), *The Windhorn Burden* (42013 → Druid of the Moth + Disciple
of Lo'sho), *The Mighty Elekk* (42019 → Moonwhisper Elekk), *Ritual Ready* (42046 →
Azureshimmer Stagwing), *Blackroot Hold* (42064 → the nine Blackroot furbolgs the
objective line names as holders), *The Withered Den* (42069 → the withered expedition
cluster marking the den).

The rest cannot be fixed from this database: the collectable objects for *Powerless
Runestone*, *Ghosts of Maras'ethil* and *Heaven Falling Down* were never extracted, no
hydra unit carries spawns for *Taste for Hydra*, *Glowing Draenethyst Cluster* (41909) has
no data at all beyond its id, and Moro'gai Village (zone 5649) has **zero** extracted
spawns — which also strands the turn-in pins of its delivery quests (*An Ill Omen*, *The
Long Hunt*). *The Key to Karazhan IV*, *In Need of Water* and *Agent of Hydraxis* are
talk-to or reputation quests and are correct with no objective data. Full per-quest notes
sit in `overwrites.lua`.

### 1.0.6 — two Moonwhisper Coast quests drew no pins

Flagged by a player **using `/db checkdb`** — the tool doing exactly what it was built for.
*Phasmophobia* (41990) and *Fallen One Cargo* (41920) shipped with no `["obj"]` block, so
their collect/find targets never appeared on the map. Both targets exist in the data with
spawns exactly where the quests happen and are now wired up, hand-verified: the four
*Maras'ethil Relic* objects (2020322–2020325, all zone 5642 only) and *Maghan's Cargo*
(2020265, zone 5642 only). Applied only where `["obj"]` is absent. Of the other two quests
the player's checkdb flagged: *Emberstrife* (6570) is a base-database gap now corrected in
pfQuest's own `corrections.lua`, and *The Key to Karazhan IV* (40823) is a talk-to quest
that legitimately draws no pins.

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
