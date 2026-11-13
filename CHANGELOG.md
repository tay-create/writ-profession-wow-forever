# Changelog

## 1.0.0 - 2026-11-13

- First stable release for WoW Forever 1.60.1, following in-game validation by the author.
- Includes the redesigned Writs Auction House tab, readable filters and labels, and Auctionator shopping searches.
- Catalogues all 150 Craftsman's Writs, with profession, recipe, crafting skill, and reputation details.
- Identifies 107 writ turn-ins across 72 distinct destinations. The remaining 43 are clearly marked as awaiting confirmation.
- Includes the What's New notice and filters for profession, name, reputation and crafting skill.

## 0.4.1-alpha - 2026-11-13

- Improves contrast and corrects panel layering for profession, search, reputation and crafting skill labels, plus footer hints and counters.
- Refreshes the Writ Profession Auctionator tab with dark, gold-trimmed panels, profession icons, active-filter indicators, clearer writ rows and reputation badges.
- Adjusts search, scroll-list and footer spacing while preserving writ/recipe searches and the native Auctionator buying flow.
- Adds combinable reputation and crafting skill dropdown filters and shows skill values in writ rows (`~` marks estimated thresholds).
- Adds a classic WoW-style patch notice explaining the 43 unconfirmed turn-in locations in friendly language. The notice appears once per version and can be reopened from the Writs tab.

## 0.4.0-alpha - 2026-11-13

- Shows 107 turn-in NPCs or objects (72 distinct destinations), with a clear fallback for the remaining 43. Adds five player-confirmed Wowhead NPC links, reusing two existing delivery locations.
- Removes the quantity input from the custom Auctionator tab.
- Opens Auctionator's native buy screen after a successful single-writ or recipe search, including Legacy Auction House results.
- Preserves the existing Auctionator search and buying interface and updates localization for delivery labels.

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
