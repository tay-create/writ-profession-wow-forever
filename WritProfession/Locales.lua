local _, addon = ...

local labels = {
    enUS = "Profession",
    enGB = "Profession",
    ptBR = "Profissão",
    esES = "Profesión",
    esMX = "Profesión",
    frFR = "Métier",
    deDE = "Beruf",
    itIT = "Professione",
    ruRU = "Профессия",
    koKR = "전문 기술",
    zhCN = "专业",
    zhTW = "專業",
}

local names = {
    enUS = { "Alchemy", "Blacksmithing", "Engineering", "Leatherworking", "Tailoring" },
    ptBR = { "Alquimia", "Ferraria", "Engenharia", "Couraria", "Alfaiataria" },
    esES = { "Alquimia", "Herrería", "Ingeniería", "Peletería", "Sastrería" },
    frFR = { "Alchimie", "Forge", "Ingénierie", "Travail du cuir", "Couture" },
    deDE = { "Alchemie", "Schmiedekunst", "Ingenieurskunst", "Lederverarbeitung", "Schneiderei" },
    itIT = { "Alchimia", "Forgiatura", "Ingegneria", "Conciatura", "Sartoria" },
    ruRU = { "Алхимия", "Кузнечное дело", "Инженерное дело", "Кожевничество", "Портняжное дело" },
    koKR = { "연금술", "대장기술", "기계공학", "가죽세공", "재봉술" },
    zhCN = { "炼金术", "锻造", "工程学", "制皮", "裁缝" },
    zhTW = { "鍊金術", "鍛造", "工程學", "製皮", "裁縫" },
}

names.enGB = names.enUS
names.esMX = names.esES

local spellIDs = { 2259, 2018, 4036, 2108, 3908 }
local locale = GetLocale() or "enUS"
local selectedNames = names[locale] or names.enUS

-- Prefer the client's native profession translations when available.
local function getProfessionName(index)
    local spellID = spellIDs[index]
    if C_Spell and C_Spell.GetSpellName then
        local spellName = C_Spell.GetSpellName(spellID)
        if spellName then
            return spellName
        end
    end
    if GetSpellInfo then
        local spellName = GetSpellInfo(spellID)
        if spellName then
            return spellName
        end
    end
    return selectedNames[index]
end

addon.professionLabel = labels[locale] or labels.enUS
addon.professionNames = {}
for index = 1, #spellIDs do
    addon.professionNames[index] = getProfessionName(index)
end
