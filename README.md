# Writ Profession

A lightweight World of Warcraft: Forever addon that shows the crafting profession and reputation reward for **Craftsman's Writs** directly in item tooltips. With Auctionator enabled, it also adds a **Writs / Escrituras** tab to the Auction House, with profession and name filters.

## Current status

**0.2.0-alpha — awaiting in-game verification.** The database covers 150 unique writ item IDs across Alchemy, Blacksmithing, Engineering, Leatherworking and Tailoring. Two writs are valid in two professions and display both names. Data was collated from the [Wowhead Forever Craftsman's Writ guide](https://www.wowhead.com/forever/guide/professions/craftsmans-writs-overview-recipes-rewards), consulted November 11, 2026.

The reward appears alongside each writ as **+75**, **+125**, or **+200** reputation, based on Journeyman, Expert, or Artisan tier. These reward values are also visible in the item tooltip. See the [WoW Forever reputation guide](https://www.wow-professions.com/forever/merchants-favor-durotar-supply-azeroth-commerce).

There is no settings interface. Labels follow the game client's locale (`GetLocale`), using native profession spell names where available. The addon does not modify auctions or automatically buy items. Auctionator is an optional dependency for the Auction House tab; tooltip functionality works independently.

## Installation

1. Extract the release ZIP into `World of Warcraft/_forever_/Interface/AddOns/` so the file appears at `AddOns/WritProfession/WritProfession.toc`.
2. Exit and restart the game after the first installation.
3. Confirm **Writ Profession** is enabled on the character-select AddOns screen.
4. Install/enable **Auctionator** if you want the extra **Escrituras** tab inside the Auction House.

## In-game verification

1. Hover over **Escritura do Artífice: Poção de Proteção contra a Sombra** (item ID `264014`). A Portuguese client should show **Profissão: Alquimia** as an extra colored tooltip line.
2. Hover over **Escritura do Artífice: Traje de Ogro Gordok** (item ID `264144`). The line should show both **Couraria / Alfaiataria**.
3. Check the tooltip while browsing Auctionator results and while the item is in the bags.
4. Check that the tooltip shows the reputation reward and the Auctionator **Escrituras** tab appears in the Auction House. Choose **Couraria** to see only its writs, or type part of a writ name. Clicking a row searches that writ in Auctionator.
5. If nothing displays, run `/console scriptErrors 1` and `/reload`, then report the error message and screenshot.

## Development and future CurseForge release

The addon uses no bundled external libraries. It contains Lua, XML, and TOC files. Bump the interface version in `WritProfession.toc` if the Forever client changes, validate on the live client, then package the `WritProfession` directory as the ZIP root. After a CurseForge project is created, fill its project ID in release metadata as appropriate.

All code and the dataset can be reviewed and updated in version control. Item mappings are maintained in `WritProfession/Data.lua` and profession labels in `WritProfession/Locales.lua`.
