local _, addon = ...

WritProfessionAuctionTabMixin = {}

local ui = addon.uiText
local rowHeight = 33
local crateRowHeight = 36
local sectionHeaderHeight = 24
local reputationChoices = { 0, 75, 125, 200 }
local skillChoices = { 0, 75, 150, 225, 300 }
local continentChoices = { "all", "kalimdor", "easternKingdoms" }
local regionChoices = { "all" }
local categoryChoices = { "all", "herbs", "ore", "textiles", "curiosities", "fabrics", "ingots", "parts" }
local tierChoices = { "all", "apprentice", "journeyman", "expert", "artisan" }
local moneyChoices = { "all", "upTo5", "5To10", "over10" }
local continentLabels = {
    kalimdor = ui.continentKalimdor,
    easternKingdoms = ui.continentEasternKingdoms,
}
local zoneContinents = {
    ["Alterac Mountains"] = "easternKingdoms",
    ["Arathi Highlands"] = "easternKingdoms",
    Ashenvale = "kalimdor",
    Badlands = "easternKingdoms",
    ["Deadwind Pass"] = "easternKingdoms",
    Desolace = "kalimdor",
    Duskwood = "easternKingdoms",
    ["Dustwallow Marsh"] = "kalimdor",
    Felwood = "kalimdor",
    Feralas = "kalimdor",
    ["Hillsbrad Foothills"] = "easternKingdoms",
    Moonglade = "kalimdor",
    ["Mount Hyjal"] = "kalimdor",
    Riverglades = "easternKingdoms",
    ["Searing Gorge"] = "easternKingdoms",
    ["Stonetalon Mountains"] = "kalimdor",
    ["Stranglethorn Vale"] = "easternKingdoms",
    ["Swamp of Sorrows"] = "easternKingdoms",
    Tanaris = "kalimdor",
    ["The Hinterlands"] = "easternKingdoms",
    ["Thousand Needles"] = "kalimdor",
    ["Un'Goro Crater"] = "kalimdor",
    Wetlands = "easternKingdoms",
    Winterspring = "kalimdor",
}
local function updateRegionChoices(continent)
    local zones = {}
    for zone, zoneContinent in pairs(zoneContinents) do
        if zoneContinent == continent then
            table.insert(zones, zone)
        end
    end
    table.sort(zones)

    for index = #regionChoices, 2, -1 do
        regionChoices[index] = nil
    end
    for _, zone in ipairs(zones) do
        table.insert(regionChoices, zone)
    end
end
local categoryLabels = {
    all = ui.crateTypeAll,
    herbs = ui.crateTypeHerbs,
    ore = ui.crateTypeOre,
    textiles = ui.crateTypeTextiles,
    curiosities = ui.crateTypeCuriosities,
    fabrics = ui.crateTypeFabrics,
    ingots = ui.crateTypeIngots,
    parts = ui.crateTypeParts,
}
local tierLabels = {
    all = ui.crateTierAll,
    apprentice = ui.crateTierApprentice,
    journeyman = ui.crateTierJourneyman,
    expert = ui.crateTierExpert,
    artisan = ui.crateTierArtisan,
}
local moneyLabels = {
    all = ui.crateMoneyAll,
    upTo5 = ui.crateMoneyUpTo5,
    ["5To10"] = ui.crateMoney5To10,
    over10 = ui.crateMoneyOver10,
}
local professionIcons = {
    [0] = "Interface\\Icons\\INV_Scroll_03",
    "Interface\\Icons\\Trade_Alchemy",
    "Interface\\Icons\\Trade_BlackSmithing",
    "Interface\\Icons\\Trade_Engineering",
    "Interface\\Icons\\Trade_LeatherWorking",
    "Interface\\Icons\\Trade_Tailoring",
}

local function getItemName(itemID)
    local name = GetItemInfo(itemID)
    if not name and C_Item and C_Item.GetItemNameByID then
        name = C_Item.GetItemNameByID(itemID)
    end
    return name
end

local function getItemIcon(itemID)
    if C_Item and C_Item.GetItemIconByID then
        return C_Item.GetItemIconByID(itemID)
    end
    if GetItemIcon then
        return GetItemIcon(itemID)
    end
end

local function belongsToProfession(itemID, index)
    if index == 0 then
        return true
    end
    for _, profession in ipairs(addon.writs[itemID]) do
        if profession == index then
            return true
        end
    end
    return false
end

local function createText(parent, font, text, point, relativePoint, x, y)
    local label = parent:CreateFontString(nil, "OVERLAY", font)
    label:SetPoint(point, parent, relativePoint, x, y)
    label:SetText(text)
    return label
end

local function setReadableText(label, red, green, blue)
    label:SetTextColor(red, green, blue, 1)
    label:SetShadowColor(0, 0, 0, 0.9)
    label:SetShadowOffset(1, -1)
end

local function createPanel(parent, name)
    local template = BackdropTemplateMixin and "BackdropTemplate" or nil
    local panel = CreateFrame("Frame", name, parent, template)
    local background = panel:CreateTexture(nil, "BACKGROUND")
    background:SetPoint("TOPLEFT", panel, "TOPLEFT", 3, -3)
    background:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -3, 3)
    background:SetColorTexture(0.09, 0.065, 0.045, 0.93)

    if panel.SetBackdrop then
        panel:SetBackdrop({
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 },
        })
        panel:SetBackdropBorderColor(0.72, 0.52, 0.25, 0.95)
    else
        local border = panel:CreateTexture(nil, "BORDER")
        border:SetPoint("TOPLEFT", panel, "TOPLEFT", 2, -2)
        border:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -2, -2)
        border:SetHeight(2)
        border:SetColorTexture(0.60, 0.42, 0.19, 0.8)
    end

    return panel
end

local function createDivider(parent, x, y, rightInset)
    local line = parent:CreateTexture(nil, "ARTWORK")
    line:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    line:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -rightInset, y)
    line:SetHeight(1)
    line:SetColorTexture(0.67, 0.46, 0.18, 0.55)
    return line
end

local function createFilterDropdown(parent, choices, getValue, labelFor, onChoose, width)
    local dropdown = CreateFrame("Frame", nil, parent, "UIDropDownMenuTemplate")
    UIDropDownMenu_SetWidth(dropdown, width or 132)
    UIDropDownMenu_Initialize(dropdown, function(_, level)
        for _, value in ipairs(choices) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = labelFor(value)
            info.checked = getValue() == value
            info.func = function()
                onChoose(value)
                UIDropDownMenu_SetSelectedValue(dropdown, value)
                UIDropDownMenu_SetText(dropdown, labelFor(value))
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end)
    UIDropDownMenu_SetSelectedValue(dropdown, getValue())
    UIDropDownMenu_SetText(dropdown, labelFor(getValue()))
    return dropdown
end

local function getAddonVersion()
    if C_AddOns and C_AddOns.GetAddOnMetadata then
        return C_AddOns.GetAddOnMetadata("WritProfession", "Version") or "1.1.3"
    end
    if GetAddOnMetadata then
        return GetAddOnMetadata("WritProfession", "Version") or "1.1.3"
    end
    return "1.1.3"
end

local function createRow(parent, frame)
    local row = CreateFrame("Button", nil, parent)
    row:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    row:SetHeight(rowHeight)
    row:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, 0)
    row:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")

    row.background = row:CreateTexture(nil, "BACKGROUND")
    row.background:SetAllPoints()
    row.border = row:CreateTexture(nil, "BORDER")
    row.border:SetPoint("BOTTOMLEFT", row, "BOTTOMLEFT", 4, 0)
    row.border:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", -4, 0)
    row.border:SetHeight(1)
    row.border:SetColorTexture(0.56, 0.39, 0.16, 0.30)
    row.icon = row:CreateTexture(nil, "ARTWORK")
    row.icon:SetSize(24, 24)
    row.icon:SetPoint("LEFT", row, "LEFT", 34, 0)
    row.checkbox = CreateFrame("CheckButton", nil, row, "UICheckButtonTemplate")
    row.checkbox:SetSize(24, 24)
    row.checkbox:SetPoint("LEFT", row, "LEFT", 5, 0)
    row.checkbox:SetScript("OnClick", function(checkbox)
        local checked = checkbox:GetChecked()
        frame.selectedIDs[row.itemID] = checked and true or nil
        if checked then
            frame:RequestRelatedItemNames(row.itemID)
        end
        frame:UpdateSelectionState()
    end)
    row.iconBorder = row:CreateTexture(nil, "OVERLAY")
    row.iconBorder:SetTexture("Interface\\Buttons\\UI-Quickslot2")
    row.iconBorder:SetSize(33, 33)
    row.iconBorder:SetPoint("CENTER", row.icon, "CENTER", 0, 0)
    row.iconBorder:SetVertexColor(0.85, 0.68, 0.40)
    row.name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    row.name:SetPoint("LEFT", row.icon, "RIGHT", 10, 0)
    row.name:SetPoint("RIGHT", row, "RIGHT", -217, 0)
    row.name:SetJustifyH("LEFT")
    row.name:SetWordWrap(false)

    row.skill = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.skill:SetPoint("RIGHT", row, "RIGHT", -153, 0)
    row.skill:SetWidth(60)
    row.skill:SetJustifyH("RIGHT")
    row.skill:SetTextColor(0.91, 0.75, 0.49)

    row.repBackground = row:CreateTexture(nil, "BORDER")
    row.repBackground:SetPoint("RIGHT", row, "RIGHT", -7, 0)
    row.repBackground:SetSize(139, 24)
    row.repBackground:SetColorTexture(0.14, 0.23, 0.12, 0.43)
    row.reputation = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.reputation:SetPoint("RIGHT", row, "RIGHT", -12, 0)
    row.reputation:SetWidth(129)
    row.reputation:SetJustifyH("RIGHT")
    row.reputation:SetTextColor(0.71, 0.88, 0.54)

    row:SetScript("OnEnter", function(button)
        GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
        if GameTooltip.SetItemByID then
            GameTooltip:SetItemByID(button.itemID)
        else
            GameTooltip:SetHyperlink("item:" .. button.itemID)
        end
        local recipe = addon.recipeData[button.itemID]
        if recipe and recipe.learnMode == "item" then
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine(ui.rightClickRecipe, 0.45, 0.95, 0.45)
        end
        GameTooltip:Show()
    end)
    row:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    row:SetScript("OnClick", function(button, mouseButton)
        if mouseButton == "RightButton" then
            frame:SearchRecipe(button.itemID)
        else
            frame:SearchItems({ button.itemID })
        end
    end)
    return row
end

local function createCrateRow(parent, frame)
    local row = CreateFrame("Button", nil, parent)
    row:RegisterForClicks("LeftButtonUp")
    row:SetHeight(crateRowHeight)
    row:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")

    row.background = row:CreateTexture(nil, "BACKGROUND")
    row.background:SetAllPoints()
    row.checkbox = CreateFrame("CheckButton", nil, row, "UICheckButtonTemplate")
    row.checkbox:SetSize(24, 24)
    row.checkbox:SetPoint("LEFT", row, "LEFT", 5, 0)
    row.checkbox:SetScript("OnClick", function(checkbox)
        local checked = checkbox:GetChecked()
        frame.selectedCrateIDs[row.itemID] = checked and true or nil
        if checked then
            frame:RequestCrateItemNames(row.itemID)
        end
        frame:UpdateSelectionState()
    end)
    row.icon = row:CreateTexture(nil, "ARTWORK")
    row.icon:SetSize(24, 24)
    row.icon:SetPoint("LEFT", row, "LEFT", 34, 0)

    row.name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    row.name:SetPoint("LEFT", row.icon, "RIGHT", 9, 0)
    row.name:SetPoint("RIGHT", row, "RIGHT", -244, 0)
    row.name:SetJustifyH("LEFT")
    row.name:SetWordWrap(false)

    row.tier = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.tier:SetPoint("RIGHT", row, "RIGHT", -170, 0)
    row.tier:SetWidth(78)
    row.tier:SetJustifyH("RIGHT")
    row.tier:SetTextColor(0.91, 0.75, 0.49)

    row.favor = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.favor:SetPoint("RIGHT", row, "RIGHT", -91, 0)
    row.favor:SetWidth(65)
    row.favor:SetJustifyH("RIGHT")
    row.favor:SetTextColor(0.71, 0.88, 0.54)

    row.money = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.money:SetPoint("RIGHT", row, "RIGHT", -9, 0)
    row.money:SetWidth(76)
    row.money:SetJustifyH("RIGHT")
    row.money:SetTextColor(0.95, 0.83, 0.48)

    row:SetScript("OnEnter", function(button)
        GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
        if GameTooltip.SetItemByID then
            GameTooltip:SetItemByID(button.itemID)
        else
            GameTooltip:SetHyperlink("item:" .. button.itemID)
        end
        GameTooltip:Show()
    end)
    row:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    row:SetScript("OnClick", function(button)
        frame:SearchCrate(button.itemID)
    end)

    return row
end

local function createSectionHeader(parent, text)
    local header = CreateFrame("Frame", nil, parent)
    header:SetHeight(sectionHeaderHeight)
    header.background = header:CreateTexture(nil, "BACKGROUND")
    header.background:SetPoint("TOPLEFT", header, "TOPLEFT", 0, -2)
    header.background:SetPoint("BOTTOMRIGHT", header, "BOTTOMRIGHT", 0, 1)
    header.background:SetColorTexture(0.24, 0.17, 0.09, 0.55)
    header.label = header:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    header.label:SetPoint("LEFT", header, "LEFT", 10, 0)
    header.label:SetText(text)
    header.label:SetTextColor(1, 0.82, 0.46)
    return header
end

function WritProfessionAuctionTabMixin:OnLoad()
    self.profession = 0
    self.reputationFilter = 0
    self.skillFilter = 0
    self.continentFilter = "all"
    self.regionFilter = "all"
    self.category = "all"
    self.tier = "all"
    self.moneyFilter = "all"
    self.showWrits = true
    self.showCrates = true
    self.sortedIDs = {}
    self.sortedCrates = {}
    self.selectedIDs = {}
    self.selectedCrateIDs = {}
    self.rows = {}
    self.zoneSectionHeaders = {}
    self.crateRows = {}
    self.professionButtons = {}
    self.requested = {}
    self.searchSequence = 0
    self.crateSearchSequence = 0

    if Auctionator and Auctionator.EventBus and Auctionator.Shopping and Auctionator.Shopping.Tab then
        Auctionator.EventBus:Register(self, {
            Auctionator.Shopping.Tab.Events.SearchStart,
            Auctionator.Shopping.Tab.Events.SearchEnd,
        })
    end

    for itemID in pairs(addon.writs) do
        table.insert(self.sortedIDs, itemID)
    end
    table.sort(self.sortedIDs)
    for _, crate in ipairs(addon.crates or {}) do
        table.insert(self.sortedCrates, crate)
    end
    table.sort(self.sortedCrates, function(left, right)
        return left.itemID < right.itemID
    end)

    self.sidebarPanel = createPanel(self)
    self.sidebarPanel:SetPoint("TOPLEFT", self, "TOPLEFT", 2, -8)
    self.sidebarPanel:SetPoint("BOTTOMRIGHT", self, "BOTTOMLEFT", 198, 7)

    self.mainPanel = createPanel(self)
    self.mainPanel:SetPoint("TOPLEFT", self, "TOPLEFT", 201, -8)
    self.mainPanel:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -3, 7)

    -- Keep labels on the panel's overlay layer so the panel background cannot dim them.
    local professionTitle = createText(self.sidebarPanel, "GameFontNormalLarge", ui.profession, "TOPLEFT", "TOPLEFT", 14, -11)
    setReadableText(professionTitle, 1, 0.82, 0)
    local searchTitle = createText(self.mainPanel, "GameFontNormalLarge", ui.find, "TOPLEFT", "TOPLEFT", 17, -11)
    setReadableText(searchTitle, 1, 0.82, 0)
    createDivider(self.sidebarPanel, 12, -43, 12)
    self.filterDivider = createDivider(self.mainPanel, 12, -171, 12)

    for index = 0, #addon.professionNames do
        local button = CreateFrame("Button", nil, self, "UIPanelButtonTemplate")
        button:SetSize(170, 32)
        button:SetPoint("TOPLEFT", self, "TOPLEFT", 15, -64 - index * 39)
        button:SetText("")
        local normalTexture = button:GetNormalTexture()
        if normalTexture then
            normalTexture:SetVertexColor(0.85, 0.62, 0.47)
        end
        button.icon = button:CreateTexture(nil, "ARTWORK")
        button.icon:SetSize(21, 21)
        button.icon:SetPoint("LEFT", button, "LEFT", 10, 0)
        button.icon:SetTexture(professionIcons[index])
        button.label = button:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        button.label:SetPoint("LEFT", button.icon, "RIGHT", 9, 0)
        button.label:SetPoint("RIGHT", button, "RIGHT", -7, 0)
        button.label:SetJustifyH("LEFT")
        button.label:SetWordWrap(false)
        button.label:SetText(index == 0 and ui.all or addon.professionNames[index])
        button.selectedMark = button:CreateTexture(nil, "OVERLAY")
        button.selectedMark:SetPoint("LEFT", button, "LEFT", 2, 0)
        button.selectedMark:SetSize(3, 22)
        button.selectedMark:SetColorTexture(1, 0.80, 0.35)
        button:SetScript("OnClick", function()
            if not self.showWrits then
                return
            end
            self.profession = index
            self:UpdateItems(false)
        end)
        self.professionButtons[index] = button
    end

    self.newsButton = CreateFrame("Button", nil, self, "UIPanelButtonTemplate")
    self.newsButton:SetSize(170, 28)
    self.newsButton:SetPoint("TOPLEFT", self, "TOPLEFT", 15, -313)
    self.newsButton:SetText(ui.newsButton)
    self.newsButton:SetScript("OnClick", function()
        self:ShowPatchNotes()
    end)

    self.hint = createText(self.sidebarPanel, "GameFontHighlightSmall", ui.hint, "BOTTOMLEFT", "BOTTOMLEFT", 15, 17)
    setReadableText(self.hint, 0.90, 0.84, 0.71)
    self.hint:SetWidth(165)
    self.hint:SetJustifyH("LEFT")
    self.hint:SetWordWrap(true)

    self.searchBox = CreateFrame("EditBox", nil, self, "InputBoxTemplate")
    self.searchBox:SetAutoFocus(false)
    self.searchBox:SetHeight(23)
    self.searchBox:SetPoint("TOPLEFT", self, "TOPLEFT", 221, -38)
    self.searchBox:SetPoint("TOPRIGHT", self, "TOPRIGHT", -24, -38)
    self.searchBox:SetScript("OnEscapePressed", function(box)
        box:ClearFocus()
    end)
    self.searchBox:SetScript("OnEnterPressed", function(box)
        box:ClearFocus()
    end)
    self.searchBox:SetScript("OnTextChanged", function()
        self:UpdateItems(false)
    end)
    local updateFilterVisibility

    self.reputationLabel = createText(self.mainPanel, "GameFontNormalSmall", ui.reputationFilter, "TOPLEFT", "TOPLEFT", 17, -65)
    setReadableText(self.reputationLabel, 0.91, 0.78, 0.47)
    self.skillLabel = createText(self.mainPanel, "GameFontNormalSmall", ui.skillFilter, "TOPLEFT", "TOPLEFT", 192, -65)
    setReadableText(self.skillLabel, 0.91, 0.78, 0.47)

    self.reputationDropdown = createFilterDropdown(self, reputationChoices,
        function() return self.reputationFilter end,
        function(value) return value == 0 and ui.all or "+" .. value end,
        function(value)
            self.reputationFilter = value
            self:UpdateItems(false)
        end)
    self.reputationDropdown:SetPoint("TOPLEFT", self, "TOPLEFT", 201, -83)

    self.skillDropdown = createFilterDropdown(self, skillChoices,
        function() return self.skillFilter end,
        function(value) return value == 0 and ui.all or ui.skillUpTo:format(value) end,
        function(value)
            self.skillFilter = value
            self:UpdateItems(false)
        end)
    self.skillDropdown:SetPoint("TOPLEFT", self, "TOPLEFT", 376, -83)

    self.continentLabel = createText(self.mainPanel, "GameFontNormalSmall", ui.continentFilter,
        "TOPLEFT", "TOPLEFT", 367, -65)
    setReadableText(self.continentLabel, 0.91, 0.78, 0.47)

    self.continentDropdown = createFilterDropdown(self, continentChoices,
        function() return self.continentFilter end,
        function(value) return value == "all" and ui.all or continentLabels[value] end,
        function(value)
            self.continentFilter = value
            self.regionFilter = "all"
            updateRegionChoices(value)
            UIDropDownMenu_SetSelectedValue(self.regionDropdown, "all")
            UIDropDownMenu_SetText(self.regionDropdown, ui.regionAll)
            updateFilterVisibility()
            self:UpdateItems(false)
        end, 125)
    self.continentDropdown:SetPoint("TOPLEFT", self, "TOPLEFT", 551, -83)

    self.regionLabel = createText(self.mainPanel, "GameFontNormalSmall", ui.regionFilter,
        "TOPLEFT", "TOPLEFT", 17, -137)
    setReadableText(self.regionLabel, 0.91, 0.78, 0.47)
    self.regionDropdown = createFilterDropdown(self, regionChoices,
        function() return self.regionFilter end,
        function(value) return value == "all" and ui.regionAll or value end,
        function(value)
            self.regionFilter = value
            self:UpdateItems(false)
        end, 180)
    self.regionDropdown:SetPoint("TOPLEFT", self, "TOPLEFT", 201, -155)

    self.categoryLabel = createText(self.mainPanel, "GameFontNormalSmall", ui.crateFilterType,
        "TOPLEFT", "TOPLEFT", 17, -101)
    setReadableText(self.categoryLabel, 0.91, 0.78, 0.47)
    self.tierLabel = createText(self.mainPanel, "GameFontNormalSmall", ui.crateFilterTier,
        "TOPLEFT", "TOPLEFT", 192, -101)
    setReadableText(self.tierLabel, 0.91, 0.78, 0.47)

    self.categoryDropdown = createFilterDropdown(self, categoryChoices,
        function() return self.category end,
        function(value) return categoryLabels[value] end,
        function(value)
            self.category = value
            self:UpdateItems(false)
        end)
    self.categoryDropdown:SetPoint("TOPLEFT", self, "TOPLEFT", 201, -119)

    self.tierDropdown = createFilterDropdown(self, tierChoices,
        function() return self.tier end,
        function(value) return tierLabels[value] end,
        function(value)
            self.tier = value
            self:UpdateItems(false)
        end)
    self.tierDropdown:SetPoint("TOPLEFT", self, "TOPLEFT", 376, -119)

    self.moneyLabel = createText(self.mainPanel, "GameFontNormalSmall", ui.crateFilterMoney,
        "TOPLEFT", "TOPLEFT", 367, -101)
    setReadableText(self.moneyLabel, 0.91, 0.78, 0.47)
    self.moneyDropdown = createFilterDropdown(self, moneyChoices,
        function() return self.moneyFilter end,
        function(value) return moneyLabels[value] end,
        function(value)
            self.moneyFilter = value
            self:UpdateItems(false)
        end, 125)
    self.moneyDropdown:SetPoint("TOPLEFT", self, "TOPLEFT", 551, -119)

    updateFilterVisibility = function()
        local showWritFilters = self.showWrits
        self.reputationLabel:SetShown(showWritFilters)
        self.reputationDropdown:SetShown(showWritFilters)
        self.skillLabel:SetShown(showWritFilters)
        self.skillDropdown:SetShown(showWritFilters)
        self.continentLabel:SetShown(showWritFilters)
        self.continentDropdown:SetShown(showWritFilters)

        local showRegionFilter = showWritFilters and self.continentFilter ~= "all"
        self.regionLabel:SetShown(showRegionFilter)
        self.regionDropdown:SetShown(showRegionFilter)

        local showCrateFilters = self.showCrates
        self.categoryLabel:SetShown(showCrateFilters)
        self.categoryDropdown:SetShown(showCrateFilters)
        self.tierLabel:SetShown(showCrateFilters)
        self.tierDropdown:SetShown(showCrateFilters)
        self.moneyLabel:SetShown(showCrateFilters)
        self.moneyDropdown:SetShown(showCrateFilters)

        local controlsY = showRegionFilter and -181 or -145
        local controlsLabelY = showRegionFilter and -177 or -141
        self.selectVisible:ClearAllPoints()
        self.selectVisible:SetPoint("TOPLEFT", self, "TOPLEFT", 214, controlsY)
        self.selectVisibleLabel:ClearAllPoints()
        self.selectVisibleLabel:SetPoint("TOPLEFT", self.mainPanel, "TOPLEFT", 42, controlsLabelY)
        self.showWritsCheckbox:ClearAllPoints()
        self.showWritsCheckbox:SetPoint("TOPLEFT", self, "TOPLEFT", 395, controlsY)
        self.showWritsLabel:ClearAllPoints()
        self.showWritsLabel:SetPoint("TOPLEFT", self.mainPanel, "TOPLEFT", 223, controlsLabelY)
        self.showCratesCheckbox:ClearAllPoints()
        self.showCratesCheckbox:SetPoint("TOPLEFT", self, "TOPLEFT", 510, controlsY)
        self.showCratesLabel:ClearAllPoints()
        self.showCratesLabel:SetPoint("TOPLEFT", self.mainPanel, "TOPLEFT", 338, controlsLabelY)

        local dividerY = showRegionFilter and -207 or -171
        self.filterDivider:ClearAllPoints()
        self.filterDivider:SetPoint("TOPLEFT", self.mainPanel, "TOPLEFT", 12, dividerY)
        self.filterDivider:SetPoint("TOPRIGHT", self.mainPanel, "TOPRIGHT", -12, dividerY)
        self.list:ClearAllPoints()
        self.list:SetPoint("TOPLEFT", self, "TOPLEFT", 213, showRegionFilter and -214 or -178)
        self.list:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -33, 68)
    end

    self.list = CreateFrame("ScrollFrame", nil, self, "UIPanelScrollFrameTemplate")
    self.list:SetPoint("TOPLEFT", self, "TOPLEFT", 213, -178)
    self.list:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -33, 68)
    self.listContent = CreateFrame("Frame", nil, self.list)
    self.listContent:SetSize(500, 1)
    self.list:SetScrollChild(self.listContent)
    self.list:SetScript("OnSizeChanged", function(scroll)
        self.listContent:SetWidth(math.max(1, scroll:GetWidth()))
    end)

    self.selectVisible = CreateFrame("CheckButton", nil, self, "UICheckButtonTemplate")
    self.selectVisible:SetSize(22, 22)
    self.selectVisible:SetPoint("TOPLEFT", self, "TOPLEFT", 214, -145)
    self.selectVisible:SetScript("OnClick", function(checkbox)
        local checked = checkbox:GetChecked()
        for _, itemID in ipairs(self.showWrits and self.filteredIDs or {}) do
            self.selectedIDs[itemID] = checked and true or nil
            if checked then
                self:RequestRelatedItemNames(itemID)
            end
        end
        self:UpdateSelectionState()
    end)
    self.selectVisibleLabel = createText(self.mainPanel, "GameFontHighlightSmall", ui.selectVisible,
        "TOPLEFT", "TOPLEFT", 42, -141)
    setReadableText(self.selectVisibleLabel, 0.90, 0.84, 0.71)

    self.showWritsCheckbox = CreateFrame("CheckButton", nil, self, "UICheckButtonTemplate")
    self.showWritsCheckbox:SetSize(22, 22)
    self.showWritsCheckbox:SetPoint("TOPLEFT", self, "TOPLEFT", 395, -145)
    self.showWritsCheckbox:SetChecked(true)
    self.showWritsCheckbox:SetScript("OnClick", function(checkbox)
        self.showWrits = checkbox:GetChecked()
        updateFilterVisibility()
        self:UpdateItems(true)
    end)
    self.showWritsLabel = createText(self.mainPanel, "GameFontHighlightSmall", ui.showWrits,
        "TOPLEFT", "TOPLEFT", 223, -141)
    setReadableText(self.showWritsLabel, 0.90, 0.84, 0.71)

    self.showCratesCheckbox = CreateFrame("CheckButton", nil, self, "UICheckButtonTemplate")
    self.showCratesCheckbox:SetSize(22, 22)
    self.showCratesCheckbox:SetPoint("TOPLEFT", self, "TOPLEFT", 510, -145)
    self.showCratesCheckbox:SetChecked(true)
    self.showCratesCheckbox:SetScript("OnClick", function(checkbox)
        self.showCrates = checkbox:GetChecked()
        updateFilterVisibility()
        self:UpdateItems(true)
    end)
    self.showCratesLabel = createText(self.mainPanel, "GameFontHighlightSmall", ui.showCrates,
        "TOPLEFT", "TOPLEFT", 338, -141)
    setReadableText(self.showCratesLabel, 0.90, 0.84, 0.71)

    updateFilterVisibility()

    self.writSectionHeader = createSectionHeader(self.listContent, ui.writSection)
    self.crateSectionHeader = createSectionHeader(self.listContent, ui.crateSection)

    self.count = createText(self.mainPanel, "GameFontHighlightSmall", "", "BOTTOMLEFT", "BOTTOMLEFT", 14, 12)
    setReadableText(self.count, 0.90, 0.84, 0.71)
    self.progress = createText(self.mainPanel, "GameFontHighlightSmall", "", "BOTTOMLEFT", "BOTTOMLEFT", 14, 29)
    setReadableText(self.progress, 0.90, 0.84, 0.71)
    self.searchButton = CreateFrame("Button", nil, self, "UIPanelButtonTemplate")
    self.searchButton:SetSize(205, 29)
    self.searchButton:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -19, 16)
    self.searchButton:SetScript("OnClick", function()
        self:SearchSelected()
    end)

    self.empty = createText(self.listContent, "GameFontHighlight", ui.combinedEmpty, "TOPLEFT", "TOPLEFT", 12, -17)
    setReadableText(self.empty, 0.90, 0.84, 0.71)
    self.empty:Hide()

    self:RegisterEvent("GET_ITEM_INFO_RECEIVED")
    self:SetScript("OnEvent", function(frame, _, itemID, success)
        if frame.pendingRecipeItemID == itemID then
            local recipeName = getItemName(itemID)
            if recipeName then
                frame.pendingRecipeItemID = nil
                frame:SearchTerms({ recipeName }, 1, itemID)
            end
        end
        frame:OnCrateSearchItemLoaded(itemID, success)
        if (addon.writs[itemID] or addon.cratesByID[itemID]) and frame:IsShown() then
            frame:UpdateItems(true)
        elseif next(frame.selectedCrateIDs) then
            frame:UpdateSelectionState()
        end
    end)

    self:UpdateItems(false)
end

function WritProfessionAuctionTabMixin:OnShow()
    local itemIDs = {}
    for _, itemID in ipairs(self.sortedIDs) do
        table.insert(itemIDs, itemID)
    end
    for _, crate in ipairs(self.sortedCrates) do
        table.insert(itemIDs, crate.itemID)
    end
    for _, itemID in ipairs(itemIDs) do
        if not self.requested[itemID] then
            self.requested[itemID] = true
            if C_Item and C_Item.RequestLoadItemDataByID then
                C_Item.RequestLoadItemDataByID(itemID)
            elseif Item and Item.CreateFromItemID then
                Item:CreateFromItemID(itemID):ContinueOnItemLoad(function()
                    if self:IsShown() then
                        self:UpdateItems(true)
                    end
                end)
            end
        end
    end
    self:UpdateItems(true)
    if type(WritProfessionSettings) ~= "table" then
        WritProfessionSettings = {}
    end
    local version = getAddonVersion()
    if self.autoPatchNotesShownVersion ~= version and WritProfessionSettings.lastSeenPatch ~= version then
        self.autoPatchNotesShownVersion = version
        WritProfessionSettings.lastSeenPatch = version
        self:ShowPatchNotes()
    end
end

function WritProfessionAuctionTabMixin:ShowPatchNotes()
    if not self.patchNotes then
        local popup = createPanel(UIParent, "WritProfessionPatchNotesFrame")
        popup:SetSize(550, 365)
        popup:SetPoint("CENTER", UIParent, "CENTER", 0, 45)
        popup:SetFrameStrata("DIALOG")
        popup:SetClampedToScreen(true)
        popup:EnableMouse(true)
        popup:SetMovable(true)
        popup:RegisterForDrag("LeftButton")
        popup:SetScript("OnDragStart", popup.StartMoving)
        popup:SetScript("OnDragStop", popup.StopMovingOrSizing)

        local title = createText(popup, "GameFontNormalLarge", ui.newsTitle, "TOPLEFT", "TOPLEFT", 25, -24)
        title:SetTextColor(1, 0.82, 0.46)
        createDivider(popup, 22, -53, 22)

        local intro = createText(popup, "GameFontHighlight", ui.newsIntro, "TOPLEFT", "TOPLEFT", 26, -70)
        intro:SetWidth(498)
        intro:SetJustifyH("LEFT")
        intro:SetJustifyV("TOP")
        intro:SetWordWrap(true)

        local details = createText(popup, "GameFontHighlight", ui.newsDetails, "TOPLEFT", "TOPLEFT", 26, -141)
        details:SetWidth(498)
        details:SetJustifyH("LEFT")
        details:SetJustifyV("TOP")
        details:SetWordWrap(true)

        local close = CreateFrame("Button", nil, popup, "UIPanelCloseButton")
        close:SetPoint("TOPRIGHT", popup, "TOPRIGHT", -5, -6)
        local ok = CreateFrame("Button", nil, popup, "UIPanelButtonTemplate")
        ok:SetSize(135, 28)
        ok:SetPoint("BOTTOMRIGHT", popup, "BOTTOMRIGHT", -23, 17)
        ok:SetText(ui.newsClose)
        ok:SetScript("OnClick", function() popup:Hide() end)

        if UISpecialFrames then
            table.insert(UISpecialFrames, "WritProfessionPatchNotesFrame")
        end
        self.patchNotes = popup
    end
    self.patchNotes:Show()
end

function WritProfessionAuctionTabMixin:UpdateItems(keepScroll)
    local oldScroll = keepScroll and self.list:GetVerticalScroll() or 0
    local search = self.searchBox:GetText():lower()
    local filtered = {}
    local filteredCrates = {}
    local loaded = 0

    for _, itemID in ipairs(self.sortedIDs) do
        local recipe = addon.recipeData[itemID]
        local delivery = addon.deliveryData[itemID]
        local matchesContinent = self.continentFilter == "all"
            or not (delivery and delivery.zone)
            or zoneContinents[delivery.zone] == self.continentFilter
        local matchesRegion = self.regionFilter == "all"
            or (delivery and delivery.zone == self.regionFilter)
        if belongsToProfession(itemID, self.profession)
            and matchesContinent
            and matchesRegion
            and (self.reputationFilter == 0 or addon.GetWritReputation(itemID) == self.reputationFilter)
            and (self.skillFilter == 0 or (recipe and recipe.skill and recipe.skill <= self.skillFilter)) then
            local name = getItemName(itemID)
            if name and (search == "" or name:lower():find(search, 1, true)) or (not name and search == "") then
                table.insert(filtered, itemID)
                if name then
                    loaded = loaded + 1
                end
            end
        end
    end

    for _, crate in ipairs(self.sortedCrates) do
        local matchesCategory = self.category == "all" or crate.category == self.category
        local matchesTier = self.tier == "all" or crate.tier == self.tier
        local matchesMoney = self.moneyFilter == "all"
            or (self.moneyFilter == "upTo5" and crate.moneyCopper and crate.moneyCopper <= 500)
            or (self.moneyFilter == "5To10" and crate.moneyCopper and crate.moneyCopper > 500 and crate.moneyCopper <= 1000)
            or (self.moneyFilter == "over10" and crate.moneyCopper and crate.moneyCopper > 1000)
        if matchesCategory and matchesTier and matchesMoney then
            local name = getItemName(crate.itemID)
            if (name and (search == "" or name:lower():find(search, 1, true))) or (not name and search == "") then
                table.insert(filteredCrates, crate)
            end
        end
    end

    self.filteredIDs = filtered
    self.filteredCrates = filteredCrates
    local visibleWrits = self.showWrits and filtered or {}
    local visibleCrates = self.showCrates and filteredCrates or {}
    for index = 0, #addon.professionNames do
        local button = self.professionButtons[index]
        button:SetEnabled(self.showWrits)
        button:SetAlpha(self.showWrits and 1 or 0.48)
        button.icon:SetVertexColor(self.showWrits and 1 or 0.55, self.showWrits and 1 or 0.55,
            self.showWrits and 1 or 0.55)
        if self.showWrits and index == self.profession then
            button:LockHighlight()
            button.selectedMark:Show()
            button.label:SetTextColor(1, 0.85, 0.42)
        else
            button:UnlockHighlight()
            button.selectedMark:Hide()
            local textColor = self.showWrits and 0.94 or 0.55
            button.label:SetTextColor(textColor, self.showWrits and 0.88 or 0.55,
                self.showWrits and 0.74 or 0.55)
        end
    end

    local position = 0
    local renderIndex = 0
    local writIndex = 0
    local visibleZoneHeaders = 0

    local function renderWrit(itemID)
        writIndex = writIndex + 1
        local row = self.rows[writIndex]
        if not row then
            row = createRow(self.listContent, self)
            self.rows[writIndex] = row
        end
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", self.listContent, "TOPLEFT", 0, -position)
        row:SetPoint("TOPRIGHT", self.listContent, "TOPRIGHT", 0, -position)
        row.itemID = itemID
        renderIndex = renderIndex + 1
        row.background:SetColorTexture(0.28, 0.20, 0.11, renderIndex % 2 == 0 and 0.60 or 0.36)
        row.icon:SetTexture(getItemIcon(itemID) or "Interface\\Icons\\INV_Scroll_03")
        local name = getItemName(itemID)
        row.name:SetText(name or ui.loading:format(itemID))
        local recipe = addon.recipeData[itemID]
        row.skill:SetText(recipe and recipe.skill and ((recipe.skillApproximate and "~" or "") .. recipe.skill) or "-")
        row.reputation:SetText("+" .. addon.GetWritReputation(itemID) .. " " .. addon.reputationLabel)
        if name then
            row:Enable()
        else
            row:Disable()
        end
        row:Show()
        position = position + rowHeight
    end

    if #visibleWrits > 0 then
        self.writSectionHeader:ClearAllPoints()
        self.writSectionHeader:SetPoint("TOPLEFT", self.listContent, "TOPLEFT", 0, -position)
        self.writSectionHeader:SetPoint("TOPRIGHT", self.listContent, "TOPRIGHT", 0, -position)
        self.writSectionHeader:Show()
        position = position + sectionHeaderHeight
    else
        self.writSectionHeader:Hide()
    end

    if self.continentFilter == "all" then
        for _, itemID in ipairs(visibleWrits) do
            renderWrit(itemID)
        end
    else
        local groupsByZone = {}
        local writGroups = {}
        local unconfirmedWrits = {}
        for _, itemID in ipairs(visibleWrits) do
            local delivery = addon.deliveryData[itemID]
            local zone = delivery and delivery.zone
            if zone then
                local group = groupsByZone[zone]
                if not group then
                    group = { zone = zone, itemIDs = {} }
                    groupsByZone[zone] = group
                    table.insert(writGroups, group)
                end
                table.insert(group.itemIDs, itemID)
            else
                table.insert(unconfirmedWrits, itemID)
            end
        end

        table.sort(writGroups, function(left, right)
            return left.zone < right.zone
        end)

        for _, group in ipairs(writGroups) do
            visibleZoneHeaders = visibleZoneHeaders + 1
            local header = self.zoneSectionHeaders[visibleZoneHeaders]
            if not header then
                header = createSectionHeader(self.listContent, group.zone)
                self.zoneSectionHeaders[visibleZoneHeaders] = header
            end
            header.label:SetText(group.zone)
            header:ClearAllPoints()
            header:SetPoint("TOPLEFT", self.listContent, "TOPLEFT", 0, -position)
            header:SetPoint("TOPRIGHT", self.listContent, "TOPRIGHT", 0, -position)
            header:Show()
            position = position + sectionHeaderHeight

            for _, itemID in ipairs(group.itemIDs) do
                renderWrit(itemID)
            end
        end

        if #unconfirmedWrits > 0 then
            visibleZoneHeaders = visibleZoneHeaders + 1
            local header = self.zoneSectionHeaders[visibleZoneHeaders]
            if not header then
                header = createSectionHeader(self.listContent, ui.deliveryUnconfirmed)
                self.zoneSectionHeaders[visibleZoneHeaders] = header
            end
            header.label:SetText(ui.deliveryUnconfirmed)
            header:ClearAllPoints()
            header:SetPoint("TOPLEFT", self.listContent, "TOPLEFT", 0, -position)
            header:SetPoint("TOPRIGHT", self.listContent, "TOPRIGHT", 0, -position)
            header:Show()
            position = position + sectionHeaderHeight

            for _, itemID in ipairs(unconfirmedWrits) do
                renderWrit(itemID)
            end
        end
    end

    for index = visibleZoneHeaders + 1, #self.zoneSectionHeaders do
        self.zoneSectionHeaders[index]:Hide()
    end
    for index = writIndex + 1, #self.rows do
        self.rows[index]:Hide()
    end

    if #visibleCrates > 0 then
        self.crateSectionHeader:ClearAllPoints()
        self.crateSectionHeader:SetPoint("TOPLEFT", self.listContent, "TOPLEFT", 0, -position)
        self.crateSectionHeader:SetPoint("TOPRIGHT", self.listContent, "TOPRIGHT", 0, -position)
        self.crateSectionHeader:Show()
        position = position + sectionHeaderHeight
    else
        self.crateSectionHeader:Hide()
    end

    for index, crate in ipairs(visibleCrates) do
        local row = self.crateRows[index]
        if not row then
            row = createCrateRow(self.listContent, self)
            self.crateRows[index] = row
        end
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", self.listContent, "TOPLEFT", 0, -position)
        row:SetPoint("TOPRIGHT", self.listContent, "TOPRIGHT", 0, -position)
        row.itemID = crate.itemID
        row.checkbox:SetChecked(self.selectedCrateIDs[crate.itemID] or false)
        renderIndex = renderIndex + 1
        row.background:SetColorTexture(0.28, 0.20, 0.11, renderIndex % 2 == 0 and 0.60 or 0.36)
        row.icon:SetTexture(getItemIcon(crate.itemID) or "Interface\\Icons\\INV_Misc_Crate_01")
        row.name:SetText(getItemName(crate.itemID) or ui.crateLoading:format(crate.itemID))
        row.tier:SetText(tierLabels[crate.tier])
        row.favor:SetText(crate.favor and tostring(crate.favor) or ui.crateUnknown)
        local moneyText = crate.moneyCopper and GetCoinTextureString and GetCoinTextureString(crate.moneyCopper)
        if moneyText and crate.moneyEstimated then
            moneyText = "~" .. moneyText
        end
        row.money:SetText(moneyText or ui.crateUnknown)
        row:Show()
        position = position + crateRowHeight
    end
    for index = #visibleCrates + 1, #self.crateRows do
        self.crateRows[index]:Hide()
    end

    self.empty:SetShown(#visibleWrits + #visibleCrates == 0)
    self.listContent:SetHeight(math.max(1, position))
    self.list:SetVerticalScroll(oldScroll)
    self.progress:SetText(ui.progress:format(loaded, #filtered))
    self:UpdateSelectionState()
end

function WritProfessionAuctionTabMixin:RequestRelatedItemNames(itemID)
    local recipe = addon.recipeData[itemID]
    if not recipe or not C_Item or not C_Item.RequestLoadItemDataByID then
        return
    end
    if recipe.itemID then
        C_Item.RequestLoadItemDataByID(recipe.itemID)
    end
    if recipe.learnMode == "item" and recipe.recipeItemID then
        C_Item.RequestLoadItemDataByID(recipe.recipeItemID)
    end
end

function WritProfessionAuctionTabMixin:RequestCrateItemNames(itemID)
    local crate = addon.cratesByID[itemID]
    if not crate then
        return
    end

    local itemIDs = { crate.itemID }
    for _, materialID in ipairs(crate.materials or {}) do
        table.insert(itemIDs, materialID)
    end

    for _, requiredID in ipairs(itemIDs) do
        if not getItemName(requiredID) and not self.requested[requiredID] then
            self.requested[requiredID] = true
            if C_Item and C_Item.RequestLoadItemDataByID then
                C_Item.RequestLoadItemDataByID(requiredID)
            elseif Item and Item.CreateFromItemID then
                local item = Item:CreateFromItemID(requiredID)
                if item and item.ContinueOnItemLoad then
                    item:ContinueOnItemLoad(function()
                        if self:IsShown() then
                            self:UpdateItems(true)
                        end
                    end)
                end
            end
        end
    end
end

function WritProfessionAuctionTabMixin:UpdateSelectionState()
    local selectedCount = 0
    local namesReady = true
    for _, itemID in ipairs(self.sortedIDs) do
        if self.selectedIDs[itemID] then
            selectedCount = selectedCount + 1
            if not getItemName(itemID) then
                namesReady = false
            end
        end
    end
    for _, crate in ipairs(self.sortedCrates) do
        if self.selectedCrateIDs[crate.itemID] then
            selectedCount = selectedCount + 1
            if not getItemName(crate.itemID) then
                namesReady = false
            end
            for _, materialID in ipairs(crate.materials or {}) do
                if not getItemName(materialID) then
                    namesReady = false
                end
            end
        end
    end

    local visibleSelected = 0
    local visibleWrits = self.showWrits and self.filteredIDs or {}
    for _, itemID in ipairs(visibleWrits) do
        if self.selectedIDs[itemID] then
            visibleSelected = visibleSelected + 1
        end
    end
    for _, row in ipairs(self.rows) do
        if row:IsShown() then
            row.checkbox:SetChecked(self.selectedIDs[row.itemID] or false)
        end
    end
    for _, row in ipairs(self.crateRows) do
        if row:IsShown() then
            row.checkbox:SetChecked(self.selectedCrateIDs[row.itemID] or false)
        end
    end

    self.selectVisible:SetEnabled(#visibleWrits > 0)
    self.selectVisible:SetChecked(#visibleWrits > 0 and visibleSelected == #visibleWrits)
    local visibleCrateCount = self.showCrates and #self.filteredCrates or 0
    self.count:SetText(ui.count:format(#visibleWrits) .. "  |  " .. ui.crateCount:format(visibleCrateCount)
        .. "  |  " .. ui.selectedCount:format(selectedCount))
    self.searchButton:SetText(ui.searchSelected:format(selectedCount))
    self.searchButton:SetEnabled(selectedCount > 0 and namesReady)
end

function WritProfessionAuctionTabMixin:SearchSelected()
    self:CancelPendingCrateSearch()
    self.pendingRecipeItemID = nil
    local terms = {}
    local seen = {}
    local function addTerm(name)
        if name and name ~= "" and not seen[name:lower()] then
            seen[name:lower()] = true
            table.insert(terms, name)
        end
    end

    for _, itemID in ipairs(self.sortedIDs) do
        if self.selectedIDs[itemID] then
            local writName = getItemName(itemID)
            if not writName then
                return
            end
            addTerm(writName)

            local recipe = addon.recipeData[itemID]
            if recipe then
                addTerm((recipe.itemID and getItemName(recipe.itemID)) or recipe.name)
                if recipe.learnMode == "item" then
                    addTerm((recipe.recipeItemID and getItemName(recipe.recipeItemID)) or recipe.recipeName)
                end
            end
        end
    end

    for _, crate in ipairs(self.sortedCrates) do
        if self.selectedCrateIDs[crate.itemID] then
            local crateName = getItemName(crate.itemID)
            if not crateName then
                return
            end
            addTerm(crateName)
            for _, materialID in ipairs(crate.materials or {}) do
                local materialName = getItemName(materialID)
                if not materialName then
                    return
                end
                addTerm(materialName)
            end
        end
    end

    self:SearchTerms(terms, 1)
end

function WritProfessionAuctionTabMixin:SearchRecipe(itemID)
    self:CancelPendingCrateSearch()
    self.pendingRecipeItemID = nil
    local recipe = addon.recipeData[itemID]
    if not recipe or recipe.learnMode ~= "item" then
        return
    end
    if recipe.recipeItemID then
        local localizedName = getItemName(recipe.recipeItemID)
        if localizedName then
            self:SearchTerms({ localizedName }, 1, recipe.recipeItemID)
            return
        end
        if C_Item and C_Item.RequestLoadItemDataByID then
            self.pendingRecipeItemID = recipe.recipeItemID
            C_Item.RequestLoadItemDataByID(recipe.recipeItemID)
            return
        end
        if Item and Item.CreateFromItemID then
            self.pendingRecipeItemID = recipe.recipeItemID
            Item:CreateFromItemID(recipe.recipeItemID):ContinueOnItemLoad(function()
                if self.pendingRecipeItemID == recipe.recipeItemID then
                    self.pendingRecipeItemID = nil
                    self:SearchTerms({ getItemName(recipe.recipeItemID) or recipe.recipeName }, 1, recipe.recipeItemID)
                end
            end)
            return
        end
    end
    self:SearchTerms({ recipe.recipeName }, 1)
end

function WritProfessionAuctionTabMixin:SearchItems(itemIDs)
    self:CancelPendingCrateSearch()
    self.pendingRecipeItemID = nil
    local terms = {}
    for _, itemID in ipairs(itemIDs) do
        local name = getItemName(itemID)
        if not name then
            return
        end
        table.insert(terms, name)
    end
    self:SearchTerms(terms, 1, #itemIDs == 1 and itemIDs[1] or nil)
end

function WritProfessionAuctionTabMixin:CancelPendingCrateSearch()
    self.crateSearchSequence = (self.crateSearchSequence or 0) + 1
    self.pendingCrateSearch = nil
end

function WritProfessionAuctionTabMixin:SearchCrate(itemID)
    self:CancelPendingCrateSearch()
    self.pendingRecipeItemID = nil

    local crate = addon.cratesByID[itemID]
    if not crate then
        return
    end

    local pending = {
        sequence = self.crateSearchSequence,
        itemIDs = {},
        names = {},
        waiting = {},
        waitingIDs = {},
        remaining = 0,
    }
    local seenIDs = {}
    local function addItem(itemIDToAdd)
        if not itemIDToAdd or seenIDs[itemIDToAdd] then
            return
        end
        seenIDs[itemIDToAdd] = true
        table.insert(pending.itemIDs, itemIDToAdd)

        local name = getItemName(itemIDToAdd)
        if name and name ~= "" then
            pending.names[itemIDToAdd] = name
        else
            pending.waiting[itemIDToAdd] = true
            table.insert(pending.waitingIDs, itemIDToAdd)
            pending.remaining = pending.remaining + 1
        end
    end

    addItem(crate.itemID)
    for _, materialID in ipairs(crate.materials or {}) do
        addItem(materialID)
    end

    self.pendingCrateSearch = pending
    if pending.remaining == 0 then
        self:CompleteCrateSearch(pending)
        return
    end

    if C_Item and C_Item.RequestLoadItemDataByID then
        for _, waitingID in ipairs(pending.waitingIDs) do
            C_Item.RequestLoadItemDataByID(waitingID)
        end
    elseif Item and Item.CreateFromItemID then
        for _, waitingID in ipairs(pending.waitingIDs) do
            local item = Item:CreateFromItemID(waitingID)
            if item and item.ContinueOnItemLoad then
                item:ContinueOnItemLoad(function()
                    self:OnCrateSearchItemLoaded(waitingID, true)
                end)
            else
                self:CancelPendingCrateSearch()
                return
            end
        end
    else
        self:CancelPendingCrateSearch()
    end
end

function WritProfessionAuctionTabMixin:OnCrateSearchItemLoaded(itemID, success)
    local pending = self.pendingCrateSearch
    if not pending or pending.sequence ~= self.crateSearchSequence or not pending.waiting[itemID] then
        return
    end
    if success == false then
        self:CancelPendingCrateSearch()
        return
    end

    local name = getItemName(itemID)
    if not name or name == "" then
        self:CancelPendingCrateSearch()
        return
    end

    pending.waiting[itemID] = nil
    pending.names[itemID] = name
    pending.remaining = pending.remaining - 1
    if pending.remaining == 0 then
        self:CompleteCrateSearch(pending)
    end
end

function WritProfessionAuctionTabMixin:CompleteCrateSearch(pending)
    if self.pendingCrateSearch ~= pending or pending.sequence ~= self.crateSearchSequence then
        return
    end

    local names = {}
    local seenNames = {}
    for _, itemID in ipairs(pending.itemIDs) do
        local name = pending.names[itemID]
        if not name then
            self:CancelPendingCrateSearch()
            return
        end
        local normalizedName = name:lower()
        if not seenNames[normalizedName] then
            seenNames[normalizedName] = true
            table.insert(names, name)
        end
    end

    self.pendingCrateSearch = nil
    self:SearchTerms(names, 1)
end

function WritProfessionAuctionTabMixin:SearchTerms(names, quantity, itemID)
    self:CancelPendingCrateSearch()
    local terms = {}
    for _, name in ipairs(names) do
        if Auctionator and Auctionator.Search and Auctionator.Search.ReconstituteAdvancedSearch then
            table.insert(terms, Auctionator.Search.ReconstituteAdvancedSearch({
                searchString = name,
                isExact = true,
                quantity = quantity,
            }))
        else
            table.insert(terms, '"' .. name .. '"')
        end
    end

    if #terms == 0 then
        return
    end

    local tab = _G.AuctionatorTabs_Shopping
    local shopping = _G.AuctionatorShoppingFrame
    if not tab or not shopping or not shopping.DoSearch then
        return
    end

    tab:Click()
    shopping.singleSearch = #terms == 1
    if #terms == 1 then
        shopping.SearchOptions:SetSearchTerm(terms[1])
    end
    self.searchSequence = self.searchSequence + 1
    self.pendingPurchase = #terms == 1 and {
        sequence = self.searchSequence,
        itemID = itemID,
        name = names[1]:lower(),
    } or nil
    self.startingWritSearch = true
    shopping:DoSearch(terms)
    self.startingWritSearch = false
end

function WritProfessionAuctionTabMixin:ReceiveEvent(eventName, results)
    if eventName == Auctionator.Shopping.Tab.Events.SearchStart then
        if not self.startingWritSearch then
            self:CancelPendingCrateSearch()
            self.searchSequence = self.searchSequence + 1
            self.pendingPurchase = nil
        end
        return
    end

    local pending = self.pendingPurchase
    self.pendingPurchase = nil
    if not pending or not Auctionator.Buying or not Auctionator.Buying.Events then
        return
    end

    local isLegacy = Auctionator.Constants and Auctionator.Constants.IsLegacyAH
    for _, rowData in ipairs(results or {}) do
        local itemID
        local available
        if isLegacy then
            available = rowData.entries and #rowData.entries > 0
            if rowData.itemString then
                if C_Item and C_Item.GetItemInfoInstant then
                    itemID = C_Item.GetItemInfoInstant(rowData.itemString)
                end
                itemID = itemID or tonumber(rowData.itemString:match("item:(%d+)"))
            end
        else
            itemID = rowData.itemKey and rowData.itemKey.itemID
            available = itemID and rowData.totalQuantity and rowData.totalQuantity > 0
        end

        if available then
            local matches = pending.itemID and itemID == pending.itemID
            if not pending.itemID then
                local name = rowData.plainItemName or (itemID and getItemName(itemID))
                if not name and isLegacy and rowData.entries[1].itemLink then
                    name = Auctionator.Utilities.GetNameFromLink(rowData.entries[1].itemLink)
                end
                matches = name and name:lower() == pending.name
            end
            if matches then
                C_Timer.After(0, function()
                    local shopping = _G.AuctionatorShoppingFrame
                    if self.searchSequence ~= pending.sequence or not shopping or not shopping:IsShown() then
                        return
                    end

                    local event
                    local info
                    if isLegacy then
                        event = Auctionator.Buying.Events.ShowForShopping
                    else
                        if not C_AuctionHouse or not C_AuctionHouse.GetItemKeyInfo then
                            return
                        end
                        info = C_AuctionHouse.GetItemKeyInfo(rowData.itemKey)
                        if not info then
                            return
                        end
                        event = info.isCommodity and Auctionator.Buying.Events.ShowCommodityBuy
                            or Auctionator.Buying.Events.ShowItemBuy
                    end
                    Auctionator.EventBus:RegisterSource(self, "Writ Profession")
                    Auctionator.EventBus:Fire(self, event, rowData, info)
                    Auctionator.EventBus:Fire(self, Auctionator.Shopping.Tab.Events.BuyScreenShown)
                    Auctionator.EventBus:UnregisterSource(self)
                end)
                return
            end
        end
    end
end

if Auctionator and Auctionator.Tabs and Auctionator.Tabs.Register then
    Auctionator.Tabs.Register({
        name = "WritProfession",
        textLabel = ui.tab,
        tabTemplate = "WritProfessionAuctionTabTemplate",
        tabHeader = ui.header,
        tabFrameName = "WritProfessionAuctionFrame",
        tabOrder = 5,
    })
end
