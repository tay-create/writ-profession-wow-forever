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

local ui = {
    enUS = { tab = "Writs", header = "Craftsman's Writs", profession = "Profession", all = "All", find = "Filter names", search = "Search filtered writs", hint = "Click a writ to search it in Auctionator.", loading = "Loading item %d...", progress = "%d/%d names loaded", count = "%d writs", empty = "No matching writs" },
    ptBR = { tab = "Escrituras", header = "Escrituras do Artífice", profession = "Profissão", all = "Todas", find = "Filtrar nomes", search = "Buscar escrituras filtradas", hint = "Clique numa escritura para pesquisá-la no Auctionator.", loading = "Carregando item %d...", progress = "%d/%d nomes carregados", count = "%d escrituras", empty = "Nenhuma escritura encontrada" },
    esES = { tab = "Encargos", header = "Encargos de artesano", profession = "Profesión", all = "Todas", find = "Filtrar nombres", search = "Buscar encargos filtrados", hint = "Haz clic en un encargo para buscarlo en Auctionator.", loading = "Cargando objeto %d...", progress = "%d/%d nombres cargados", count = "%d encargos", empty = "No hay encargos" },
    frFR = { tab = "Commandes", header = "Commandes d'artisan", profession = "Métier", all = "Tous", find = "Filtrer les noms", search = "Chercher les commandes", hint = "Cliquez sur une commande pour la rechercher dans Auctionator.", loading = "Chargement de l'objet %d...", progress = "%d/%d noms chargés", count = "%d commandes", empty = "Aucune commande" },
    deDE = { tab = "Aufträge", header = "Handwerkeraufträge", profession = "Beruf", all = "Alle", find = "Namen filtern", search = "Aufträge suchen", hint = "Auftrag anklicken, um ihn in Auctionator zu suchen.", loading = "Lade Gegenstand %d...", progress = "%d/%d Namen geladen", count = "%d Aufträge", empty = "Keine Aufträge gefunden" },
    itIT = { tab = "Incarichi", header = "Incarichi dell'artigiano", profession = "Professione", all = "Tutti", find = "Filtra nomi", search = "Cerca incarichi", hint = "Seleziona un incarico per cercarlo in Auctionator.", loading = "Caricamento oggetto %d...", progress = "%d/%d nomi caricati", count = "%d incarichi", empty = "Nessun incarico" },
    ruRU = { tab = "Заказы", header = "Заказы ремесленников", profession = "Профессия", all = "Все", find = "Фильтр названий", search = "Найти заказы", hint = "Нажмите на заказ для поиска в Auctionator.", loading = "Загрузка предмета %d...", progress = "%d/%d названий загружено", count = "%d заказов", empty = "Заказы не найдены" },
    koKR = { tab = "주문서", header = "장인 주문서", profession = "전문 기술", all = "전체", find = "이름 필터", search = "주문서 검색", hint = "주문서를 누르면 Auctionator에서 검색합니다.", loading = "아이템 %d 불러오는 중...", progress = "%d/%d 이름 불러옴", count = "주문서 %d개", empty = "일치하는 주문서 없음" },
    zhCN = { tab = "委托书", header = "工匠委托书", profession = "专业", all = "全部", find = "筛选名称", search = "搜索委托书", hint = "点击委托书可在 Auctionator 中搜索。", loading = "载入物品 %d...", progress = "已载入 %d/%d 个名称", count = "%d 份委托书", empty = "没有匹配的委托书" },
    zhTW = { tab = "委託書", header = "工匠委託書", profession = "專業", all = "全部", find = "篩選名稱", search = "搜尋委託書", hint = "點擊委託書可在 Auctionator 中搜尋。", loading = "載入物品 %d...", progress = "已載入 %d/%d 個名稱", count = "%d 份委託書", empty = "沒有符合的委託書" },
}

ui.enGB = ui.enUS
ui.esMX = ui.esES
addon.uiText = ui[locale] or ui.enUS

local reputationLabels = {
    enUS = "Reputation",
    enGB = "Reputation",
    ptBR = "Reputação",
    esES = "Reputación",
    esMX = "Reputación",
    frFR = "Réputation",
    deDE = "Ruf",
    itIT = "Reputazione",
    ruRU = "Репутация",
    koKR = "평판",
    zhCN = "声望",
    zhTW = "聲望",
}

addon.reputationLabel = _G.REPUTATION or reputationLabels[locale] or reputationLabels.enUS
