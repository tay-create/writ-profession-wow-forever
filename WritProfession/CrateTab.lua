local _, addon = ...

WritProfessionCrateTabMixin = {}

local ui = addon.uiText
local rowHeight = 36
local categoryChoices = {
    "all",
    "herbs",
    "ore",
    "textiles",
    "curiosities",
    "fabrics",
    "ingots",
    "parts",
}
local tierChoices = { "all", "apprentice", "journeyman", "expert", "artisan" }
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

local function createPanel(parent)
    local template = BackdropTemplateMixin and "BackdropTemplate" or nil
    local panel = CreateFrame("Frame", nil, parent, template)
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

local function createDivider(parent, y)
    local line = parent:CreateTexture(nil, "ARTWORK")
    line:SetPoint("TOPLEFT", parent, "TOPLEFT", 12, y)
    line:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -12, y)
    line:SetHeight(1)
    line:SetColorTexture(0.67, 0.46, 0.18, 0.55)
end

local function createFilterDropdown(parent, choices, getValue, labelFor, onChoose)
    local dropdown = CreateFrame("Frame", nil, parent, "UIDropDownMenuTemplate")
    UIDropDownMenu_SetWidth(dropdown, 142)
    UIDropDownMenu_Initialize(dropdown, function(_, level)
        for _, value in ipairs(choices) do
            local choice = value
            local info = UIDropDownMenu_CreateInfo()
            info.text = labelFor(choice)
            info.checked = getValue() == choice
            info.func = function()
                onChoose(choice)
                UIDropDownMenu_SetSelectedValue(dropdown, choice)
                UIDropDownMenu_SetText(dropdown, labelFor(choice))
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end)
    UIDropDownMenu_SetSelectedValue(dropdown, getValue())
    UIDropDownMenu_SetText(dropdown, labelFor(getValue()))
    return dropdown
end

local function createRow(parent)
    local row = CreateFrame("Button", nil, parent)
    row:RegisterForClicks("LeftButtonUp")
    row:SetHeight(rowHeight)
    row:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")

    row.background = row:CreateTexture(nil, "BACKGROUND")
    row.background:SetAllPoints()
    row.icon = row:CreateTexture(nil, "ARTWORK")
    row.icon:SetSize(24, 24)
    row.icon:SetPoint("LEFT", row, "LEFT", 9, 0)

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
        local auctionFrame = _G.WritProfessionAuctionFrame
        if auctionFrame and auctionFrame.SearchItems then
            auctionFrame:SearchItems({ button.itemID })
        end
    end)

    return row
end

function WritProfessionCrateTabMixin:OnLoad()
    self.category = "all"
    self.tier = "all"
    self.sortedCrates = {}
    self.rows = {}
    self.categoryButtons = {}
    self.requested = {}

    for _, crate in ipairs(addon.crates) do
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

    local categoryTitle = createText(self.sidebarPanel, "GameFontNormalLarge", ui.cratesHeader,
        "TOPLEFT", "TOPLEFT", 14, -11)
    setReadableText(categoryTitle, 1, 0.82, 0)
    createDivider(self.sidebarPanel, -43)
    local categoryLabel = createText(self.sidebarPanel, "GameFontNormalSmall", ui.crateFilterType,
        "TOPLEFT", "TOPLEFT", 14, -51)
    setReadableText(categoryLabel, 0.91, 0.78, 0.47)

    for index, category in ipairs(categoryChoices) do
        local categoryValue = category
        local button = CreateFrame("Button", nil, self, "UIPanelButtonTemplate")
        button:SetSize(170, 28)
        button:SetPoint("TOPLEFT", self, "TOPLEFT", 15, -66 - (index - 1) * 30)
        button:SetText("")
        local normalTexture = button:GetNormalTexture()
        if normalTexture then
            normalTexture:SetVertexColor(0.85, 0.62, 0.47)
        end
        button.label = button:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        button.label:SetPoint("LEFT", button, "LEFT", 10, 0)
        button.label:SetPoint("RIGHT", button, "RIGHT", -7, 0)
        button.label:SetJustifyH("LEFT")
        button.label:SetWordWrap(false)
        button.label:SetText(categoryLabels[categoryValue])
        button.selectedMark = button:CreateTexture(nil, "OVERLAY")
        button.selectedMark:SetPoint("LEFT", button, "LEFT", 2, 0)
        button.selectedMark:SetSize(3, 20)
        button.selectedMark:SetColorTexture(1, 0.80, 0.35)
        button:SetScript("OnClick", function()
            self.category = categoryValue
            self:UpdateItems(false)
        end)
        self.categoryButtons[categoryValue] = button
    end

    self.hint = createText(self.sidebarPanel, "GameFontHighlightSmall", ui.crateHint,
        "BOTTOMLEFT", "BOTTOMLEFT", 14, 17)
    setReadableText(self.hint, 0.90, 0.84, 0.71)
    self.hint:SetWidth(166)
    self.hint:SetJustifyH("LEFT")
    self.hint:SetWordWrap(true)

    local searchTitle = createText(self.mainPanel, "GameFontNormalLarge", ui.find,
        "TOPLEFT", "TOPLEFT", 17, -11)
    setReadableText(searchTitle, 1, 0.82, 0)
    createDivider(self.mainPanel, -124)

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

    local tierLabel = createText(self.mainPanel, "GameFontNormalSmall", ui.crateFilterTier,
        "TOPLEFT", "TOPLEFT", 17, -67)
    setReadableText(tierLabel, 0.91, 0.78, 0.47)
    self.tierDropdown = createFilterDropdown(self, tierChoices,
        function() return self.tier end,
        function(value) return tierLabels[value] end,
        function(value)
            self.tier = value
            self:UpdateItems(false)
        end)
    self.tierDropdown:SetPoint("TOPLEFT", self, "TOPLEFT", 201, -85)

    local nameHeader = createText(self.mainPanel, "GameFontNormalSmall", ui.crateNameColumn,
        "TOPLEFT", "TOPLEFT", 54, -139)
    setReadableText(nameHeader, 0.91, 0.78, 0.47)
    local tierHeader = createText(self.mainPanel, "GameFontNormalSmall", ui.crateFilterTier,
        "TOPRIGHT", "TOPRIGHT", -204, -139)
    tierHeader:SetWidth(78)
    tierHeader:SetJustifyH("RIGHT")
    setReadableText(tierHeader, 0.91, 0.78, 0.47)
    local favorHeader = createText(self.mainPanel, "GameFontNormalSmall", ui.crateFavorShort,
        "TOPRIGHT", "TOPRIGHT", -124, -139)
    favorHeader:SetWidth(65)
    favorHeader:SetJustifyH("RIGHT")
    setReadableText(favorHeader, 0.91, 0.78, 0.47)
    local moneyHeader = createText(self.mainPanel, "GameFontNormalSmall", ui.crateMoneyColumn,
        "TOPRIGHT", "TOPRIGHT", -42, -139)
    moneyHeader:SetWidth(76)
    moneyHeader:SetJustifyH("RIGHT")
    setReadableText(moneyHeader, 0.91, 0.78, 0.47)

    self.list = CreateFrame("ScrollFrame", nil, self, "UIPanelScrollFrameTemplate")
    self.list:SetPoint("TOPLEFT", self, "TOPLEFT", 213, -157)
    self.list:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -33, 55)
    self.listContent = CreateFrame("Frame", nil, self.list)
    self.listContent:SetSize(500, 1)
    self.list:SetScrollChild(self.listContent)
    self.list:SetScript("OnSizeChanged", function(scroll)
        self.listContent:SetWidth(math.max(1, scroll:GetWidth()))
    end)

    self.count = createText(self.mainPanel, "GameFontHighlightSmall", "",
        "BOTTOMLEFT", "BOTTOMLEFT", 14, 12)
    setReadableText(self.count, 0.90, 0.84, 0.71)
    self.empty = createText(self.listContent, "GameFontHighlight", ui.crateEmpty,
        "TOPLEFT", "TOPLEFT", 12, -17)
    setReadableText(self.empty, 0.90, 0.84, 0.71)
    self.empty:Hide()

    self:RegisterEvent("GET_ITEM_INFO_RECEIVED")
    self:SetScript("OnEvent", function(frame, _, itemID)
        if addon.cratesByID[itemID] and frame:IsShown() then
            frame:UpdateItems(true)
        end
    end)

    self:UpdateItems(false)
end

function WritProfessionCrateTabMixin:OnShow()
    for _, crate in ipairs(self.sortedCrates) do
        if not self.requested[crate.itemID] then
            self.requested[crate.itemID] = true
            if C_Item and C_Item.RequestLoadItemDataByID then
                C_Item.RequestLoadItemDataByID(crate.itemID)
            elseif Item and Item.CreateFromItemID then
                Item:CreateFromItemID(crate.itemID):ContinueOnItemLoad(function()
                    if self:IsShown() then
                        self:UpdateItems(true)
                    end
                end)
            end
        end
    end
    self:UpdateItems(true)
end

function WritProfessionCrateTabMixin:UpdateItems(keepScroll)
    local oldScroll = keepScroll and self.list:GetVerticalScroll() or 0
    local search = self.searchBox:GetText():lower()
    local filtered = {}

    for _, crate in ipairs(self.sortedCrates) do
        local matchesCategory = self.category == "all" or crate.category == self.category
        local matchesTier = self.tier == "all" or crate.tier == self.tier
        if matchesCategory and matchesTier then
            local name = getItemName(crate.itemID)
            if (name and (search == "" or name:lower():find(search, 1, true))) or (not name and search == "") then
                table.insert(filtered, crate)
            end
        end
    end

    self.filteredCrates = filtered
    for category, button in pairs(self.categoryButtons) do
        if category == self.category then
            button:LockHighlight()
            button.selectedMark:Show()
            button.label:SetTextColor(1, 0.85, 0.42)
        else
            button:UnlockHighlight()
            button.selectedMark:Hide()
            button.label:SetTextColor(0.94, 0.88, 0.74)
        end
    end

    for index, crate in ipairs(filtered) do
        local row = self.rows[index]
        if not row then
            row = createRow(self.listContent)
            self.rows[index] = row
        end
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", self.listContent, "TOPLEFT", 0, -(index - 1) * rowHeight)
        row:SetPoint("TOPRIGHT", self.listContent, "TOPRIGHT", 0, -(index - 1) * rowHeight)
        row.itemID = crate.itemID
        row.background:SetColorTexture(0.28, 0.20, 0.11, index % 2 == 0 and 0.60 or 0.36)
        row.icon:SetTexture(getItemIcon(crate.itemID) or "Interface\\Icons\\INV_Misc_Crate_01")
        row.name:SetText(getItemName(crate.itemID) or ui.crateLoading:format(crate.itemID))
        row.tier:SetText(tierLabels[crate.tier])
        row.favor:SetText(crate.favor and tostring(crate.favor) or ui.crateUnknown)
        local moneyText = crate.moneyCopper and GetCoinTextureString and GetCoinTextureString(crate.moneyCopper)
        if moneyText and crate.moneyEstimated then
            moneyText = "~" .. moneyText
        end
        row.money:SetText(moneyText or ui.crateUnknown)
        if getItemName(crate.itemID) then
            row:Enable()
        else
            row:Disable()
        end
        row:Show()
    end
    for index = #filtered + 1, #self.rows do
        self.rows[index]:Hide()
    end

    self.empty:SetShown(#filtered == 0)
    self.listContent:SetHeight(math.max(rowHeight, #filtered * rowHeight))
    self.list:SetVerticalScroll(oldScroll)
    self.count:SetText(ui.crateCount:format(#filtered))
end

if Auctionator and Auctionator.Tabs and Auctionator.Tabs.Register then
    Auctionator.Tabs.Register({
        name = "WritProfessionCrates",
        textLabel = ui.cratesTab,
        tabTemplate = "WritProfessionCrateTabTemplate",
        tabHeader = ui.cratesHeader,
        tabFrameName = "WritProfessionCrateFrame",
        tabOrder = 6,
    })
end
