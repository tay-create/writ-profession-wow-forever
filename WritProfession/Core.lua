local _, addon = ...

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
