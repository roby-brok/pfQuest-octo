# pfQuest (Octo DB)

A [pfQuest](https://github.com/The-Kludge-Bureau/pfQuest) database pack for the
[OctoWoW](https://octowow.st) server (WoW 1.12.1), maintained by **Roby_Brok**.
Part of my [OctoWoW addon setup](https://github.com/roby-brok/octowow-addons).

**None of the data here is mine.** This pack is two existing packs combined, nothing more —
see [Credits](#credits). It exists because running both of them at once does not work.

---

## Why this exists

pfQuest database packs assign their tables outright rather than merging into them:

```lua
pfDB["quests"]["data-turtle"] = { ... }
```

So with `pfQuest-octo` and `pfQuest-turtle` both installed, the one whose folder sorts last
simply replaces the other. `pfQuest-turtle` wins on the letter *t*, and `pfQuest-octo` is parsed
at every login and thrown away — roughly 15 MB of work for data that never gets used, and the
quest links point at the wrong server's website.

Picking one meant giving something up: the turtle pack has far more quest data, the octo pack has
the OctoWoW corrections and links. This pack is both, so there is nothing to choose between.

## What is in it

The TurtleWoW database as the base, with the Octo pack folded in on top:

| | octo pack alone | this pack |
|---|---|---|
| quests | 5,175 | **6,842** |
| units | 9,928 | **11,095** |
| objects | 15,163 | **15,857** |
| items | 9,301 | **12,672** |
| locales | 5 | **6** (deDE regained) |
| corrections | 137 | **162** |

`overwrites.lua` carries three things in order — the 23 records the Octo DB has that the
TurtleWoW build lacks, then the Octo pack's 137 corrections, then the TurtleWoW pack's own 2.
Records come first so anything indexing into them finds them present. The generated files under
`db/` are byte-identical to the TurtleWoW build; nothing there was hand-edited, so a future
database refresh will not silently drop any of it.

Quest links point at [octowow.st/db](https://octowow.st/db).

The pack's own code changes and fixes are listed in **[CHANGES-octo.md](CHANGES-octo.md)**.

## Install

**Requires [pfQuest](https://github.com/The-Kludge-Bureau/pfQuest).** This is a database pack, not
a standalone addon.

1. **[Download](https://github.com/roby-brok/pfQuest-octo/archive/refs/heads/master.zip)**
2. Unpack the zip
3. **Rename the folder `pfQuest-octo-master` to `pfQuest-octo`** — this step is not optional
4. Move `pfQuest-octo` into `Wow-Directory\Interface\AddOns`
5. Restart WoW

Step 3 matters because WoW only loads an addon when the folder name matches the `.toc` inside it.
A folder called `pfQuest-octo-master` containing `pfQuest-octo.toc` is skipped in silence — no
error, no entry in the addon list, it simply never runs.

**Remove `pfQuest-turtle` if you have it.** Its data is already included here, and leaving both
installed puts you right back in the situation this pack was built to avoid.

## Credits

Everything here is other people's work, combined and nothing else. All of it is MIT licensed,
copyright Eric Mauser (Shagu), and that licence is retained in full.

* **[Shagu](https://github.com/shagu)** — wrote pfQuest and the original database packs.
* **[The Kludge Bureau](https://github.com/The-Kludge-Bureau/pfQuest-turtle)** — the TurtleWoW
  build this pack's database comes from.
* **[paokkerkir](https://github.com/paokkerkir/pfQuest-octo)** — the Octo pack: the OctoWoW
  corrections, the extra records and the database links, which are the whole reason to combine
  rather than just use the turtle pack.
* **Gurky, Antealis, HumbleKagu, KasVital, Haaxor1689, IcemanHHW, fatpowaranga** — pack
  contributors, as credited in the original `.toc` files.
* **[VMaNGOS](https://github.com/vmangos)** — the underlying database the extractor reads.

If you maintain either source pack and would rather this did not exist, or want it credited
differently, open an issue and I will sort it out.
