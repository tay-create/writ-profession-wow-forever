local _, addon = ...

WritProfessionAuctionTabMixin = {}

local ui = addon.uiText
local rowHeight = 33
local reputationChoices = { 0, 75, 125, 200 }
local skillChoices = { 0, 75, 150, 225, 300 }
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

local function createFilterDropdown(parent, choices, getValue, labelFor, onChoose)
    local dropdown = CreateFrame("Frame", nil, parent, "UIDropDownMenuTemplate")
    UIDropDownMenu_SetWidth(dropdown, 132)
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
        return C_AddOns.GetAddOnMetadata("WritProfession", "Version") or "1.0.0"
    end
    if GetAddOnMetadata then
        return GetAddOnMetadata("WritProfession", "Version") or "1.0.0"
    end
    return "1.0.0"
end

local function createRow(parent)
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
    row.icon:SetPoint("LEFT", row, "LEFT", 8, 0)
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
        local frame = parent:GetParent():GetParent()
        if mouseButton == "RightButton" then
            frame:SearchRecipe(button.itemID)
        else
            frame:SearchItems({ button.itemID })
        end
    end)
    return row
end

function WritProfessionAuctionTabMixin:OnLoad()
    self.profession = 0
    self.reputationFilter = 0
    self.skillFilter = 0
    self.sortedIDs = {}
    self.rows = {}
    self.professionButtons = {}
    self.requested = {}
    self.searchSequence = 0

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
    createDivider(self.mainPanel, 12, -124, 12)

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

    local reputationLabel = createText(self.mainPanel, "GameFontNormalSmall", ui.reputationFilter, "TOPLEFT", "TOPLEFT", 17, -67)
    setReadableText(reputationLabel, 0.91, 0.78, 0.47)
    local skillLabel = createText(self.mainPanel, "GameFontNormalSmall", ui.skillFilter, "TOPLEFT", "TOPLEFT", 192, -67)
    setReadableText(skillLabel, 0.91, 0.78, 0.47)

    self.reputationDropdown = createFilterDropdown(self, reputationChoices,
        function() return self.reputationFilter end,
        function(value) return value == 0 and ui.all or "+" .. value end,
        function(value)
            self.reputationFilter = value
            self:UpdateItems(false)
        end)
    self.reputationDropdown:SetPoint("TOPLEFT", self, "TOPLEFT", 201, -86)

    self.skillDropdown = createFilterDropdown(self, skillChoices,
        function() return self.skillFilter end,
        function(value) return value == 0 and ui.all or ui.skillUpTo:format(value) end,
        function(value)
            self.skillFilter = value
            self:UpdateItems(false)
        end)
    self.skillDropdown:SetPoint("TOPLEFT", self, "TOPLEFT", 376, -86)

    self.list = CreateFrame("ScrollFrame", nil, self, "UIPanelScrollFrameTemplate")
    self.list:SetPoint("TOPLEFT", self, "TOPLEFT", 213, -141)
    self.list:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -33, 68)
    self.listContent = CreateFrame("Frame", nil, self.list)
    self.listContent:SetSize(500, 1)
    self.list:SetScrollChild(self.listContent)
    self.list:SetScript("OnSizeChanged", function(scroll)
        self.listContent:SetWidth(math.max(1, scroll:GetWidth()))
    end)

    self.count = createText(self.mainPanel, "GameFontHighlightSmall", "", "BOTTOMLEFT", "BOTTOMLEFT", 14, 12)
    setReadableText(self.count, 0.90, 0.84, 0.71)
    self.progress = createText(self.mainPanel, "GameFontHighlightSmall", "", "BOTTOMLEFT", "BOTTOMLEFT", 14, 29)
    setReadableText(self.progress, 0.90, 0.84, 0.71)
    self.searchButton = CreateFrame("Button", nil, self, "UIPanelButtonTemplate")
    self.searchButton:SetSize(205, 29)
    self.searchButton:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -19, 16)
    self.searchButton:SetText(ui.search)
    self.searchButton:SetScript("OnClick", function()
        self:SearchItems(self.filteredIDs)
    end)

    self.empty = createText(self.listContent, "GameFontHighlight", ui.empty, "TOPLEFT", "TOPLEFT", 12, -17)
    setReadableText(self.empty, 0.90, 0.84, 0.71)
    self.empty:Hide()

    self:RegisterEvent("GET_ITEM_INFO_RECEIVED")
    self:SetScript("OnEvent", function(frame, _, itemID)
        if frame.pendingRecipeItemID == itemID then
            local recipeName = getItemName(itemID)
            if recipeName then
                frame.pendingRecipeItemID = nil
                frame:SearchTerms({ recipeName }, 1, itemID)
            end
        end
        if addon.writs[itemID] and frame:IsShown() then
            frame:UpdateItems(true)
        end
    end)

    self:UpdateItems(false)
end

function WritProfessionAuctionTabMixin:OnShow()
    for _, itemID in ipairs(self.sortedIDs) do
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
    if WritProfessionSettings.lastSeenPatch ~= version then
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
    local loaded = 0

    for _, itemID in ipairs(self.sortedIDs) do
        local recipe = addon.recipeData[itemID]
        if belongsToProfession(itemID, self.profession)
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

    self.filteredIDs = filtered
    for index = 0, #addon.professionNames do
        if index == self.profession then
            self.professionButtons[index]:LockHighlight()
            self.professionButtons[index].selectedMark:Show()
            self.professionButtons[index].label:SetTextColor(1, 0.85, 0.42)
        else
            self.professionButtons[index]:UnlockHighlight()
            self.professionButtons[index].selectedMark:Hide()
            self.professionButtons[index].label:SetTextColor(0.94, 0.88, 0.74)
        end
    end

    for index, itemID in ipairs(filtered) do
        local row = self.rows[index]
        if not row then
            row = createRow(self.listContent)
            self.rows[index] = row
        end
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", self.listContent, "TOPLEFT", 0, -(index - 1) * rowHeight)
        row:SetPoint("TOPRIGHT", self.listContent, "TOPRIGHT", 0, -(index - 1) * rowHeight)
        row.itemID = itemID
        row.background:SetColorTexture(0.28, 0.20, 0.11, index % 2 == 0 and 0.60 or 0.36)
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
    end
    for index = #filtered + 1, #self.rows do
        self.rows[index]:Hide()
    end

    self.empty:SetShown(#filtered == 0)
    self.listContent:SetHeight(math.max(1, #filtered * rowHeight))
    self.list:SetVerticalScroll(oldScroll)
    self.count:SetText(ui.count:format(#filtered))
    self.progress:SetText(ui.progress:format(loaded, #filtered))
    self.searchButton:SetEnabled(#filtered > 0 and loaded == #filtered)
end

function WritProfessionAuctionTabMixin:SearchRecipe(itemID)
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

function WritProfessionAuctionTabMixin:SearchTerms(names, quantity, itemID)
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
