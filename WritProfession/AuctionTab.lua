local _, addon = ...

WritProfessionAuctionTabMixin = {}

local ui = addon.uiText
local rowHeight = 27

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

local function createRow(parent)
    local row = CreateFrame("Button", nil, parent)
    row:SetHeight(rowHeight)
    row:SetPoint("RIGHT", parent, "RIGHT", 0, 0)
    row:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")

    row.background = row:CreateTexture(nil, "BACKGROUND")
    row.background:SetAllPoints()
    row.icon = row:CreateTexture(nil, "ARTWORK")
    row.icon:SetSize(21, 21)
    row.icon:SetPoint("LEFT", row, "LEFT", 6, 0)
    row.name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    row.name:SetPoint("LEFT", row.icon, "RIGHT", 9, 0)
    row.name:SetPoint("RIGHT", row, "RIGHT", -145, 0)
    row.name:SetJustifyH("LEFT")
    row.name:SetWordWrap(false)

    row.reputation = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.reputation:SetPoint("RIGHT", row, "RIGHT", -8, 0)
    row.reputation:SetWidth(130)
    row.reputation:SetJustifyH("RIGHT")
    row.reputation:SetTextColor(0.43, 0.83, 1)

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
        parent:GetParent():GetParent():SearchItems({ button.itemID })
    end)
    return row
end

function WritProfessionAuctionTabMixin:OnLoad()
    self.profession = 0
    self.sortedIDs = {}
    self.rows = {}
    self.professionButtons = {}
    self.requested = {}

    for itemID in pairs(addon.writs) do
        table.insert(self.sortedIDs, itemID)
    end
    table.sort(self.sortedIDs)

    createText(self, "GameFontNormalLarge", ui.profession, "TOPLEFT", "TOPLEFT", 9, -4)
    createText(self, "GameFontNormal", ui.find, "TOPLEFT", "TOPLEFT", 211, -4)

    for index = 0, #addon.professionNames do
        local button = CreateFrame("Button", nil, self, "UIPanelButtonTemplate")
        button:SetSize(181, 28)
        button:SetPoint("TOPLEFT", self, "TOPLEFT", 8, -36 - index * 37)
        button:SetText(index == 0 and ui.all or addon.professionNames[index])
        button:SetScript("OnClick", function()
            self.profession = index
            self:UpdateItems(false)
        end)
        self.professionButtons[index] = button
    end

    self.searchBox = CreateFrame("EditBox", nil, self, "InputBoxTemplate")
    self.searchBox:SetAutoFocus(false)
    self.searchBox:SetSize(310, 23)
    self.searchBox:SetPoint("TOPLEFT", self, "TOPLEFT", 219, -29)
    self.searchBox:SetScript("OnEscapePressed", function(box)
        box:ClearFocus()
    end)
    self.searchBox:SetScript("OnEnterPressed", function(box)
        box:ClearFocus()
    end)
    self.searchBox:SetScript("OnTextChanged", function()
        self:UpdateItems(false)
    end)

    self.list = CreateFrame("ScrollFrame", nil, self, "UIPanelScrollFrameTemplate")
    self.list:SetPoint("TOPLEFT", self, "TOPLEFT", 209, -62)
    self.list:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -29, 48)
    self.listContent = CreateFrame("Frame", nil, self.list)
    self.listContent:SetSize(500, 1)
    self.list:SetScrollChild(self.listContent)
    self.list:SetScript("OnSizeChanged", function(scroll)
        self.listContent:SetWidth(math.max(1, scroll:GetWidth()))
    end)

    self.count = createText(self, "GameFontHighlightSmall", "", "BOTTOMLEFT", "BOTTOMLEFT", 212, 12)
    self.progress = createText(self, "GameFontDisableSmall", "", "BOTTOMLEFT", "BOTTOMLEFT", 212, 29)
    self.searchButton = CreateFrame("Button", nil, self, "UIPanelButtonTemplate")
    self.searchButton:SetSize(205, 26)
    self.searchButton:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -23, 4)
    self.searchButton:SetText(ui.search)
    self.searchButton:SetScript("OnClick", function()
        self:SearchItems(self.filteredIDs)
    end)

    self.empty = createText(self.listContent, "GameFontDisable", ui.empty, "TOPLEFT", "TOPLEFT", 8, -12)
    self.empty:Hide()

    self:RegisterEvent("GET_ITEM_INFO_RECEIVED")
    self:SetScript("OnEvent", function(frame, _, itemID)
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
end

function WritProfessionAuctionTabMixin:UpdateItems(keepScroll)
    local oldScroll = keepScroll and self.list:GetVerticalScroll() or 0
    local search = self.searchBox:GetText():lower()
    local filtered = {}
    local loaded = 0

    for _, itemID in ipairs(self.sortedIDs) do
        if belongsToProfession(itemID, self.profession) then
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
        else
            self.professionButtons[index]:UnlockHighlight()
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
        row:SetPoint("RIGHT", self.listContent, "RIGHT", 0, 0)
        row.itemID = itemID
        row.background:SetColorTexture(0.65, 0.52, 0.27, index % 2 == 0 and 0.10 or 0.04)
        row.icon:SetTexture(getItemIcon(itemID) or "Interface\\Icons\\INV_Scroll_03")
        local name = getItemName(itemID)
        row.name:SetText(name or ui.loading:format(itemID))
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

function WritProfessionAuctionTabMixin:SearchItems(itemIDs)
    local terms = {}
    for _, itemID in ipairs(itemIDs) do
        local name = getItemName(itemID)
        if not name then
            return
        end
        table.insert(terms, '"' .. name .. '"')
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
    shopping:DoSearch(terms)
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
