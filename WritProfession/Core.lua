local _, addon = ...

local function getCraftedItemName(recipe)
    if recipe.itemID then
        local name = GetItemInfo(recipe.itemID)
        if not name and C_Item and C_Item.GetItemNameByID then
            name = C_Item.GetItemNameByID(recipe.itemID)
        end
        if name then
            return name
        end
    end
    return recipe.name
end

local function getRecipeSource(recipe)
    local ui = addon.recipeSourceText
    if recipe.sourceNPC then
        return recipe.sourceNPC
    end
    if recipe.sourceType == "vendor" then
        return recipe.sourceLocation and ui.vendorAt:format(recipe.sourceLocation) or ui.vendor
    elseif recipe.sourceType == "drop" then
        return ui.drop
    elseif recipe.sourceType == "quest" then
        return recipe.sourceLocation and ui.questAt:format(recipe.sourceLocation) or ui.quest
    elseif recipe.sourceType == "dungeon" then
        return ui.dungeon:format(recipe.sourceLocation or ui.unknownLocation)
    elseif recipe.sourceType == "raid" then
        return ui.raid:format(recipe.sourceLocation or ui.unknownLocation)
    elseif recipe.sourceType == "crafted" then
        return ui.crafted:format(addon.professionNames[recipe.sourceProfession] or ui.unknownLocation)
    end
    return ui.unknown
end

local function showProfession(tooltip, itemID)
    if not tooltip or not tooltip.AddLine then
        return
    end

    local professions = addon.writs[itemID]
    if not professions then
        return
    end

    local names = {}
    for index = 1, #professions do
        names[index] = addon.professionNames[professions[index]]
    end

    tooltip:AddLine("|cff33ff99" .. addon.professionLabel .. ": " .. table.concat(names, " / ") .. "|r")
    local reputation = addon.GetWritReputation(itemID)
    if reputation then
        tooltip:AddLine("|cff66ccff" .. addon.reputationLabel .. ": +" .. reputation .. "|r")
    end

    local recipe = addon.recipeData[itemID]
    if recipe then
        local ui = addon.uiText
        tooltip:AddLine(" ")
        tooltip:AddLine("|cffffd466" .. ui.craftedItem .. ":|r " .. getCraftedItemName(recipe), 1, 1, 1)
        local skill = tostring(recipe.skill)
        if recipe.skillApproximate then
            skill = ui.skillApproximate:format(skill)
        end
        tooltip:AddLine("|cffffd466" .. ui.recipeSkill .. ":|r " .. skill, 1, 1, 1)

        if recipe.learnMode == "trainer" then
            tooltip:AddLine("|cffffd466" .. ui.recipe .. ":|r " .. ui.trainer, 1, 1, 1)
            tooltip:AddLine("|cffffd466" .. ui.recipeSource .. ":|r " .. ui.trainerSource, 1, 1, 1)
        else
            local recipeName = recipe.recipeItemID and GetItemInfo(recipe.recipeItemID)
            if not recipeName and recipe.recipeItemID and C_Item and C_Item.GetItemNameByID then
                recipeName = C_Item.GetItemNameByID(recipe.recipeItemID)
            end
            if not recipeName and recipe.recipeItemID and C_Item and C_Item.RequestLoadItemDataByID then
                C_Item.RequestLoadItemDataByID(recipe.recipeItemID)
            end
            tooltip:AddLine("|cffffd466" .. ui.recipe .. ":|r " .. (recipeName or recipe.recipeName), 1, 1, 1)
            tooltip:AddLine("|cffffd466" .. ui.recipeSource .. ":|r " ..
                getRecipeSource(recipe), 1, 1, 1)
        end
    end

    local delivery = addon.deliveryData[itemID]
    if delivery then
        local ui = addon.uiText
        tooltip:AddLine(" ")
        if delivery.npc then
            tooltip:AddLine("|cff8ed6ff" .. ui.deliveryNPC .. ":|r " .. delivery.npc, 1, 1, 1)
        elseif delivery.object then
            tooltip:AddLine("|cff8ed6ff" .. ui.deliveryObject .. ":|r " .. delivery.object, 1, 1, 1)
        end
        if delivery.zone then
            local location = delivery.zone
            if delivery.x and delivery.y then
                location = string.format("%s (%.1f, %.1f)", location, delivery.x, delivery.y)
            end
            tooltip:AddLine("|cff8ed6ff" .. ui.deliveryLocation .. ":|r " .. location, 1, 1, 1)
        elseif not delivery.npc and not delivery.object then
            tooltip:AddLine("|cff8ed6ff" .. ui.deliveryLocation .. ":|r " .. ui.deliveryUnconfirmed, 1, 1, 1)
        end
    end
    if tooltip.Show then
        tooltip:Show()
    end
end

-- Forever uses the modern tooltip pipeline, including item links in Auctionator.
if TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall
    and Enum and Enum.TooltipDataType and Enum.TooltipDataType.Item then
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, function(tooltip, data)
        if data and data.id then
            showProfession(tooltip, data.id)
        end
    end)
end
