# Changelog

## 0.3.0-alpha - 2026-11-11

- Adds the crafted item, crafting skill, recipe name and acquisition-source type to writ tooltips.
- Includes recipe metadata for all 150 writs; 99 Classic Era recipe-item IDs for localization and lookup (including a normalized spelling), and explicitly marks sources that could not be verified.
- Adds a quantity field (1–999), forwarding the target to Auctionator Shopping as an advanced search parameter.
- Right-clicking a writ searches its separate recipe item through Auctionator; item names are localized when available.
- Retains Auctionator's native buying flow and documents the one-stack-per-click behavior on the Legacy Auction House.


## 0.2.0-alpha - 2026-11-11

- Adds an Auctionator Auction House tab for filtering writs by profession or name.
- Clicking a writ searches it in Auctionator; the search button queries all filtered writs.
- Shows +75 / +125 / +200 reputation per writ in the tab and item tooltips.
- Localizes the filter UI and reputation label to the game client's locale.

## 0.1.0-alpha - 2026-11-11

- First test build for WoW Forever 1.60.1 (interface 16001).
- Identifies the profession(s) for 150 Craftsman's Writ item IDs.
- Adds a localized profession line to item tooltips using the modern tooltip API.
- No settings, external libraries, or SavedVariables.
