-- Waylaid Crate item data for WoW Forever client build 1.60.1.70888.
-- Apprentice, Journeyman and Expert rewards are confirmed from live reports.
-- Artisan Favor is confirmed as 20/40. Its 10s/20s silver payout is an estimate.
local _, addon = ...

addon.crates = {
    { itemID = 248682, category = "herbs", tier = "apprentice", level = 10, quality = "common", favor = 5, moneyCopper = 250, materials = { 2447, 765, 2449, 785, 2450 } },
    { itemID = 248683, category = "ore", tier = "apprentice", level = 10, quality = "common", favor = 5, moneyCopper = 250, materials = { 2770, 2771 } },
    { itemID = 248684, category = "textiles", tier = "apprentice", level = 10, quality = "common", favor = 5, moneyCopper = 250, materials = { 2589, 2318 } },
    { itemID = 248685, category = "curiosities", tier = "apprentice", level = 10, quality = "common", favor = 5, moneyCopper = 250, materials = { 10940, 10939, 10978, 11084 } },
    { itemID = 248702, category = "fabrics", tier = "apprentice", level = 10, quality = "uncommon", favor = 10, moneyCopper = 500, materials = { 4231, 2996 } },
    { itemID = 248703, category = "ingots", tier = "apprentice", level = 10, quality = "uncommon", favor = 10, moneyCopper = 500, materials = { 2840, 3576, 2841 } },
    { itemID = 248704, category = "parts", tier = "apprentice", level = 10, quality = "uncommon", favor = 10, moneyCopper = 500, materials = { 4359, 4361, 4363 } },

    { itemID = 248686, category = "herbs", tier = "journeyman", level = 10, quality = "common", favor = 10, moneyCopper = 500, materials = { 3820, 2453, 3355, 3369, 3356 } },
    { itemID = 248687, category = "ore", tier = "journeyman", level = 10, quality = "common", favor = 10, moneyCopper = 500, materials = { 2775, 2772 } },
    { itemID = 248688, category = "textiles", tier = "journeyman", level = 10, quality = "common", favor = 10, moneyCopper = 500, materials = { 2592, 4306, 2319 } },
    { itemID = 248689, category = "curiosities", tier = "journeyman", level = 10, quality = "common", favor = 10, moneyCopper = 500, materials = { 11083, 11082, 11138, 11139 } },
    { itemID = 248705, category = "fabrics", tier = "journeyman", level = 10, quality = "uncommon", favor = 20, moneyCopper = 1000, materials = { 2997, 4305, 4233 } },
    { itemID = 248706, category = "ingots", tier = "journeyman", level = 10, quality = "uncommon", favor = 20, moneyCopper = 1000, materials = { 2842, 3575 } },
    { itemID = 248707, category = "parts", tier = "journeyman", level = 10, quality = "uncommon", favor = 20, moneyCopper = 1000, materials = { 4371, 4375, 4382, 10558 } },

    { itemID = 248690, category = "herbs", tier = "expert", level = 20, quality = "common", favor = 15, moneyCopper = 750, materials = { 3357, 3818, 3821, 3358 } },
    { itemID = 248691, category = "herbs", tier = "expert", level = 20, quality = "common", favor = 15, moneyCopper = 750, materials = { 3819, 4625, 8831, 8836 } },
    { itemID = 248692, category = "ore", tier = "expert", level = 20, quality = "common", favor = 15, moneyCopper = 750, materials = { 2776, 3858 } },
    { itemID = 248693, category = "textiles", tier = "expert", level = 20, quality = "common", favor = 15, moneyCopper = 750, materials = { 4338, 4234 } },
    { itemID = 248694, category = "curiosities", tier = "expert", level = 20, quality = "common", favor = 15, moneyCopper = 750, materials = { 11137, 11135, 11177, 11178 } },
    { itemID = 248708, category = "fabrics", tier = "expert", level = 20, quality = "uncommon", favor = 30, moneyCopper = 1500, materials = { 4339, 4236 } },
    { itemID = 248709, category = "ingots", tier = "expert", level = 20, quality = "uncommon", favor = 30, moneyCopper = 1500, materials = { 3860, 3859, 3577 } },
    { itemID = 248710, category = "parts", tier = "expert", level = 20, quality = "uncommon", favor = 30, moneyCopper = 1500, materials = { 4387, 10559, 10560, 10561 } },

    { itemID = 248695, category = "herbs", tier = "artisan", level = 35, quality = "common", favor = 20, moneyCopper = 1000, moneyEstimated = true, materials = { 13464, 8838, 8839, 8845, 8846 } },
    { itemID = 248696, category = "herbs", tier = "artisan", level = 35, quality = "common", favor = 20, moneyCopper = 1000, moneyEstimated = true, materials = { 13463, 13465, 13466, 13467 } },
    { itemID = 248697, category = "ore", tier = "artisan", level = 35, quality = "common", favor = 20, moneyCopper = 1000, moneyEstimated = true, materials = { 7911, 10620, 11099 } },
    { itemID = 248698, category = "textiles", tier = "artisan", level = 35, quality = "common", favor = 20, moneyCopper = 1000, moneyEstimated = true, materials = { 14047, 4304, 8170 } },
    { itemID = 248699, category = "curiosities", tier = "artisan", level = 35, quality = "common", favor = 20, moneyCopper = 1000, moneyEstimated = true, materials = { 11176, 11175, 14343, 14344 } },
    { itemID = 248711, category = "fabrics", tier = "artisan", level = 35, quality = "uncommon", favor = 40, moneyCopper = 2000, moneyEstimated = true, materials = { 14048, 8172 } },
    { itemID = 248712, category = "ingots", tier = "artisan", level = 35, quality = "uncommon", favor = 40, moneyCopper = 2000, moneyEstimated = true, materials = { 11371, 6037, 12359 } },
    { itemID = 248713, category = "parts", tier = "artisan", level = 35, quality = "uncommon", favor = 40, moneyCopper = 2000, moneyEstimated = true, materials = { 15994, 18631, 16000 } },
}

addon.cratesByID = {}
for _, crate in ipairs(addon.crates) do
    addon.cratesByID[crate.itemID] = crate
end
