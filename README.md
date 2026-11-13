# Writ Profession

World of Warcraft: Forever addon that identifies the profession, required crafted item, crafting skill, recipe and reputation associated with each **Craftsman's Writ**. With Auctionator enabled, it adds an **Escrituras / Writs** tab inside the Auction House.

## Current version

**1.0.0 Release** for Forever 1.60.1, interface **16001**. The data includes **150** writ IDs across Alchemy, Blacksmithing, Engineering, Leatherworking and Tailoring. Two writs belong to two professions.

The writ tooltip shows the required item, recipe, crafting skill and broad recipe acquisition method (trainer, vendor, world loot, quest, dungeon or crafted recipe). Verified NPC names are displayed where available. Many recipe sources do not have an individually verified NPC or drop location and are described by source type, with unknown origins marked clearly. Some skills show the yellow-skill threshold as an estimate, rather than the minimum required skill.

The tooltip also shows quest turn-in NPCs or objects and zones for **107 writs**, including coordinates where available. These deliveries resolve to **72 distinct NPCs/objects and locations**. **19 destinations are shared by multiple writs** (54 writs total). The remaining **43 writs** show a location awaiting confirmation. Most deliveries use Forever XP quest-end records. Five additional NPC destinations are based on player-confirmed Wowhead links. Coordinates for Gilveradin Sunchaser and Atal'ai Exile are Classic-derived reference points pending in-game verification. Bor'dorc's Winterspring coordinates (64.8, 33.2) were provided by the player. Zone and NPC names may be in English even on localized clients.

The addon follows the game client language for labels and profession names. **99 recipes** have identified Classic Era recipe item IDs for localized item names and localized Auctionator searches. Some recipe names need special handling or cannot be cross-referenced directly in Classic Era data, including *Recipe: Potion of Demon Slaying* and *Recipe: Distilled Firewater* and other Forever-specific variations.

## Auctionator integration

Open the auction house and select the **Escrituras / Writs** tab. Combine filters for profession, writ name, reputation reward (+75, +125 or +200), and crafting skill (up to 75, 150, 225 or 300). The skill filter uses the recipe's stored skill value. Some recipe skill values are estimated yellow-skill thresholds, as marked in their tooltips.

The tab uses a classic WoW-style dark leather and gold layout, with profession icons and a highlighted active filter. Writ rows show the item icon, crafting skill (a `~` marks estimates) and reputation reward, with the number of visible writs and name-loading progress below the list.

The **Novidades / What's new** button opens release notes and explains why some delivery locations have not yet been confirmed. The notice opens automatically on the first visit to the tab after each addon update.

- **Left click** a writ to search that writ in Auctionator **Shopping** and open its native buying screen when an auction is available.
- **Right click** a writ with an item recipe to search for the recipe using its localized item name when available and open the native buying screen if found.
- **Search filtered writs** searches the entire filtered list using Auctionator's shopping results and native buying screen.

On Forever's *Legacy Auction House*, Auctionator's buying screen purchases **one auction stack per click**. You can buy additional stacks using its **Chain buy stacks** option and the Buy Stack button. Auctions can contain multiple units per stack.

Auctionator is an optional dependency. Without it, tooltips still work. The addon saves only the last version of the update notice you've seen in `WritProfessionSettings`.

## Installation

1. Extract the release ZIP into `World of Warcraft/_forever_/Interface/AddOns/`. Check that the resulting file path ends with `AddOns/WritProfession/WritProfession.toc`.
2. Restart the game after first installation or reload the interface with `/reload` after updates.
3. Verify **Writ Profession** and **Auctionator** are enabled in the AddOns list.

## In-game testing

1. Hover over a Craftsman's Writ, for instance item `264014` (Shadow Protection Potion). Verify that item, skill, recipe, source, reputation and turn-in lines appear on the tooltip. The turn-in location for this example is Kzixx in Duskwood (81.8, 19.8).
2. Hover over writ `264144` (Gordok Ogre Suit) and check that both Leatherworking and Tailoring appear.
3. Open **Escrituras** and confirm the **Novidades** popup appears once for this version. Close it and reopen it using the sidebar button. Combine profession, +125 reputation, and skill up to 225 filters. Confirm the filtered list and counts change. Click a writ and check that Shopping opens with results and you can buy through Auctionator.
4. Right-click a writ whose recipe is sold separately, for example `264038` (Heavy Leather Ball). Confirm that Auctionator searches for the recipe and opens its native purchase screen when an auction is available.
5. Try **Chain buy stacks** in Auctionator, if you want multiple stacks.
6. If there is a Lua error, enter `/console scriptErrors 1`, then `/reload`, and capture the complete error message.

## Sources and maintenance

The writ mapping and required recipe/skill data were checked against [The Forever Era: Merchant's Favor](https://theforeverera.com/en/merchants-favor/) for client build 1.60.1.70888. The recipe item IDs and broad item-source categories were cross-referenced with the [Classic Era item cache](https://github.com/Napalmsteak/WoW-Classic-Item-Caches). Vendor and drop locations may differ in Forever. Skill estimates are explicitly marked.

The addon's source files are `Data.lua`, `RecipeData.lua`, `DeliveryData.lua`, `Locales.lua`, `Core.lua`, and `AuctionTab.lua`, loaded through `WritProfession.toc`. Turn-in information comes from [Forever XP quest pages](https://forever-xp.com/). The author completed in-game checks for the 1.0.0 release, including the Auction House integration.
