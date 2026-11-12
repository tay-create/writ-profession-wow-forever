# Writ Profession

World of Warcraft: Forever addon that identifies the profession, required crafted item, crafting skill, recipe and reputation associated with each **Craftsman's Writ**. With Auctionator enabled, it adds an **Escrituras / Writs** tab inside the Auction House.

## Current version

**0.3.0-alpha** for Forever 1.60.1, interface **16001**. The data includes **150** writ IDs across Alchemy, Blacksmithing, Engineering, Leatherworking and Tailoring. Two writs belong to two professions.

The writ tooltip shows the required item, recipe, crafting skill and broad recipe acquisition method (trainer, vendor, world loot, quest, dungeon or crafted recipe). Verified NPC names are displayed where available. Many recipe sources do not have an individually verified NPC or drop location and are described by source type, with unknown origins marked clearly. Some skills show the yellow-skill threshold as an estimate, rather than the minimum required skill.

The addon follows the game client language for labels and profession names. **99 recipes** have identified Classic Era recipe item IDs for localized item names and localized Auctionator searches. Some recipe names need special handling or cannot be cross-referenced directly in Classic Era data, including *Recipe: Potion of Demon Slaying* and *Recipe: Distilled Firewater* and other Forever-specific variations.

## Auctionator integration

Open the auction house and select the **Escrituras / Writs** tab. Filter by profession or writ name, then enter a quantity (1–999).

- **Left click** a writ to search that writ in the Auctionator **Shopping** tab, with the quantity encoded in Auctionator's advanced search.
- **Right click** a writ with an item recipe to search the recipe in Auctionator using its localized item name when available.
- **Search filtered writs** searches the entire filtered list using Auctionator's shopping results and native buying screen.

On Forever's *Legacy Auction House*, Auctionator's buying screen purchases **one auction stack per click**. You can buy additional stacks using its **Chain buy stacks** option and the Buy Stack button. The quantity field is a shopping/search target and does not automatically purchase exactly that number of units. Auctions can contain multiple units per stack.

Auctionator is an optional dependency. Without it, tooltips still work. There are no separate settings or SavedVariables.

## Installation

1. Extract the release ZIP into `World of Warcraft/_forever_/Interface/AddOns/`. Check that the resulting file path ends with `AddOns/WritProfession/WritProfession.toc`.
2. Restart the game after first installation or reload the interface with `/reload` after updates.
3. Verify **Writ Profession** and **Auctionator** are enabled in the AddOns list.

## In-game testing

1. Hover over a Craftsman's Writ, for instance item `264014` (Shadow Protection Potion). Verify that item, skill, recipe, source and reputation lines appear on the tooltip, in the client language where the data is available.
2. Hover over writ `264144` (Gordok Ogre Suit) and check that both Leatherworking and Tailoring appear.
3. Open **Escrituras**, filter to your profession, set quantity `5`, and click a writ. Confirm Shopping opens with results and the quantity is retained in the advanced search.
4. Right-click a writ whose recipe is sold separately, for example `264038` (Heavy Leather Ball). Confirm that Auctionator searches for the recipe and that you can open its native purchase screen from a result.
5. Try **Chain buy stacks** in Auctionator, if you want multiple stacks.
6. If there is a Lua error, enter `/console scriptErrors 1`, then `/reload`, and capture the complete error message.

## Sources and maintenance

The writ mapping and required recipe/skill data were checked against [The Forever Era: Merchant's Favor](https://theforeverera.com/en/merchants-favor/) for client build 1.60.1.70888. The recipe item IDs and broad item-source categories were cross-referenced with the [Classic Era item cache](https://github.com/Napalmsteak/WoW-Classic-Item-Caches). Vendor and drop locations may differ in Forever. Skill estimates are explicitly marked.

The addon's source files are `Data.lua`, `RecipeData.lua`, `Locales.lua`, `Core.lua`, and `AuctionTab.lua`, loaded through `WritProfession.toc`. Before a public CurseForge release, verify the current interface version and inspect the in-game behavior on a live auction house.
