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

local filterUI = {
    enUS = {
        reputationFilter = "Reputation", skillFilter = "Crafting skill", skillUpTo = "Up to %d",
        newsButton = "What's new", newsTitle = "Writ Profession update", newsClose = "Got it!",
        newsIntro = "Hello! We've refreshed the Writs tab and added reputation and crafting skill filters. You can combine them with profession and name searches to find what you need more easily.",
        newsDetails = "We're also working on the delivery locations. So far, we've tracked down where to turn in 107 of the 150 writs. The other 43 still need confirmation. Some writs share the same NPC, and information about WoW Forever isn't always complete. That's why some entries say 'Not confirmed' for now. We'd rather be upfront than send you to the wrong place. If you discover one of the missing locations, please share it with us. Every bit of help makes the addon better. Thanks for being here!",
    },
    ptBR = {
        reputationFilter = "Reputação", skillFilter = "Habilidade da profissão", skillUpTo = "Até %d",
        newsButton = "Novidades", newsTitle = "Novidades do Writ Profession", newsClose = "Entendi!",
        newsIntro = "Oi! A aba de Escrituras ganhou um visual renovado e dois filtros novos: reputação e habilidade da profissão. Você pode combinar tudo com a profissão escolhida e a busca por nome para encontrar suas escrituras com mais facilidade.",
        newsDetails = "Também seguimos procurando os locais de entrega. Já encontramos o destino de 107 das 150 escrituras, mas ainda faltam 43 para confirmar. Algumas são entregues ao mesmo NPC e nem sempre as informações disponíveis sobre o WoW Forever mostram todos os detalhes. Por isso, em algumas delas você vai encontrar 'Ainda não confirmado'. Preferimos ser sinceros a mandar você para o lugar errado. Se descobrir algum local que está faltando, conte pra gente! Cada ajuda faz diferença. Obrigado por acompanhar o projeto!",
    },
    esES = { reputationFilter = "Reputación", skillFilter = "Habilidad profesional", skillUpTo = "Hasta %d", newsButton = "Novedades", newsTitle = "Actualización de Writ Profession", newsClose = "Entendido" },
    frFR = { reputationFilter = "Réputation", skillFilter = "Compétence", skillUpTo = "Jusqu'à %d", newsButton = "Nouveautés", newsTitle = "Mise à jour Writ Profession", newsClose = "Compris" },
    deDE = { reputationFilter = "Ruf", skillFilter = "Berufsfertigkeit", skillUpTo = "Bis %d", newsButton = "Neuigkeiten", newsTitle = "Writ Profession Update", newsClose = "Verstanden" },
    itIT = { reputationFilter = "Reputazione", skillFilter = "Abilità professionale", skillUpTo = "Fino a %d", newsButton = "Novità", newsTitle = "Aggiornamento Writ Profession", newsClose = "Capito" },
    ruRU = { reputationFilter = "Репутация", skillFilter = "Навык профессии", skillUpTo = "До %d", newsButton = "Что нового", newsTitle = "Обновление Writ Profession", newsClose = "Понятно" },
    koKR = { reputationFilter = "평판", skillFilter = "전문 기술 숙련도", skillUpTo = "%d 이하", newsButton = "새 소식", newsTitle = "Writ Profession 업데이트", newsClose = "확인" },
    zhCN = { reputationFilter = "声望", skillFilter = "专业技能", skillUpTo = "不高于%d", newsButton = "更新内容", newsTitle = "Writ Profession 更新", newsClose = "知道了" },
    zhTW = { reputationFilter = "聲望", skillFilter = "專業技能", skillUpTo = "不高於%d", newsButton = "更新內容", newsTitle = "Writ Profession 更新", newsClose = "知道了" },
}
filterUI.enGB = filterUI.enUS
filterUI.esMX = filterUI.esES

for _, labelsForLocale in pairs(filterUI) do
    for key, value in pairs(filterUI.enUS) do
        if labelsForLocale[key] == nil then
            labelsForLocale[key] = value
        end
    end
end

local recipeUI = {
    enUS = {
        quantity = "Quantity", craftedItem = "Required item", recipeSkill = "Crafting skill",
        skillApproximate = "about %s (yellow)", recipe = "Recipe", recipeSource = "Where to learn",
        trainer = "Profession trainer", trainerSource = "Visit a profession trainer",
        scrollSource = "Recipe item: check vendors, loot, quests or Auctionator",
        rightClickRecipe = "Right-click to search the recipe in Auctionator",
    },
    ptBR = {
        quantity = "Quantidade", craftedItem = "Item solicitado", recipeSkill = "Habilidade",
        skillApproximate = "aprox. %s (amarelo)", recipe = "Receita", recipeSource = "Onde aprender",
        trainer = "Instrutor de profissão", trainerSource = "Aprenda com um instrutor da profissão",
        scrollSource = "Receita avulsa: veja vendedores, saques, missões ou leilão",
        rightClickRecipe = "Botão direito: buscar a receita no Auctionator",
    },
    esES = {
        quantity = "Cantidad", craftedItem = "Objeto necesario", recipeSkill = "Habilidad",
        skillApproximate = "aprox. %s (amarillo)", recipe = "Receta", recipeSource = "Dónde aprender",
        trainer = "Instructor de profesión", trainerSource = "Aprender con un instructor de profesión",
        scrollSource = "Receta: consultar vendedores, botín, misiones o subasta",
        rightClickRecipe = "Clic derecho para buscar la receta en Auctionator",
    },
    frFR = {
        quantity = "Quantité", craftedItem = "Objet demandé", recipeSkill = "Compétence",
        skillApproximate = "env. %s (jaune)", recipe = "Recette", recipeSource = "Où apprendre",
        trainer = "Maître de métier", trainerSource = "Apprendre auprès d'un maître de métier",
        scrollSource = "Recette à trouver : vendeurs, butin, quêtes ou enchères",
        rightClickRecipe = "Clic droit : chercher la recette dans Auctionator",
    },
    deDE = {
        quantity = "Anzahl", craftedItem = "Benötigter Gegenstand", recipeSkill = "Fertigkeit",
        skillApproximate = "ca. %s (gelb)", recipe = "Rezept", recipeSource = "Fundort",
        trainer = "Berufslehrer", trainerSource = "Beim Berufslehrer lernen",
        scrollSource = "Rezept: Händler, Beute, Quests oder Auktionshaus",
        rightClickRecipe = "Rechtsklick: Rezept in Auctionator suchen",
    },
    itIT = {
        quantity = "Quantità", craftedItem = "Oggetto richiesto", recipeSkill = "Abilità",
        skillApproximate = "circa %s (giallo)", recipe = "Ricetta", recipeSource = "Dove imparare",
        trainer = "Istruttore di professione", trainerSource = "Impara da un istruttore",
        scrollSource = "Ricetta: mercanti, bottino, missioni o casa d'aste",
        rightClickRecipe = "Clic destro: cerca la ricetta in Auctionator",
    },
    ruRU = {
        quantity = "Количество", craftedItem = "Нужный предмет", recipeSkill = "Навык",
        skillApproximate = "около %s (жёлтый)", recipe = "Рецепт", recipeSource = "Где получить",
        trainer = "Учитель профессии", trainerSource = "Обучение у учителя профессии",
        scrollSource = "Рецепт: торговцы, добыча, задания или аукцион",
        rightClickRecipe = "ПКМ: поиск рецепта в Auctionator",
    },
    koKR = {
        quantity = "수량", craftedItem = "필요한 아이템", recipeSkill = "숙련도",
        skillApproximate = "약 %s (노란색)", recipe = "도안", recipeSource = "습득 방법",
        trainer = "전문 기술 상급자", trainerSource = "전문 기술 상급자에게 배우기",
        scrollSource = "도안: 상인, 전리품, 퀘스트 또는 경매장",
        rightClickRecipe = "오른쪽 클릭: Auctionator에서 도안 검색",
    },
    zhCN = {
        quantity = "数量", craftedItem = "所需物品", recipeSkill = "技能等级",
        skillApproximate = "约 %s（黄色）", recipe = "配方", recipeSource = "获取方式",
        trainer = "专业训练师", trainerSource = "向专业训练师学习",
        scrollSource = "配方：商人、掉落、任务或拍卖行",
        rightClickRecipe = "右键在 Auctionator 搜索配方",
    },
    zhTW = {
        quantity = "數量", craftedItem = "需求物品", recipeSkill = "技能等級",
        skillApproximate = "約 %s（黃色）", recipe = "配方", recipeSource = "取得方式",
        trainer = "專業訓練師", trainerSource = "向專業訓練師學習",
        scrollSource = "配方：商人、掉落、任務或拍賣場",
        rightClickRecipe = "右鍵在 Auctionator 搜尋配方",
    },
}
recipeUI.enGB = recipeUI.enUS
recipeUI.esMX = recipeUI.esES

local sourceUI = {
    enUS = { vendor = "Vendor", vendorAt = "Vendor in %s", drop = "World loot / enemy drop", quest = "Quest reward", questAt = "Quest in %s", dungeon = "Dungeon: %s", raid = "Raid: %s", crafted = "Made through %s", unknown = "Source not confirmed", unknownLocation = "unknown location" },
    ptBR = { vendor = "Vendedor", vendorAt = "Vendedor em %s", drop = "Saque de inimigos / mundo aberto", quest = "Recompensa de missão", questAt = "Missão em %s", dungeon = "Masmorra: %s", raid = "Raide: %s", crafted = "Produzida com %s", unknown = "Origem não confirmada", unknownLocation = "local desconhecido" },
    esES = { vendor = "Vendedor", vendorAt = "Vendedor en %s", drop = "Botín de enemigos / mundo", quest = "Recompensa de misión", questAt = "Misión en %s", dungeon = "Mazmorra: %s", raid = "Banda: %s", crafted = "Elaborada con %s", unknown = "Origen sin confirmar", unknownLocation = "lugar desconocido" },
    frFR = { vendor = "Marchand", vendorAt = "Marchand à %s", drop = "Butin du monde / ennemis", quest = "Récompense de quête", questAt = "Quête à %s", dungeon = "Donjon : %s", raid = "Raid : %s", crafted = "Fabriquée via %s", unknown = "Source non confirmée", unknownLocation = "lieu inconnu" },
    deDE = { vendor = "Händler", vendorAt = "Händler in %s", drop = "Weltbeute / Gegner", quest = "Questbelohnung", questAt = "Quest in %s", dungeon = "Dungeon: %s", raid = "Schlachtzug: %s", crafted = "Hergestellt durch %s", unknown = "Herkunft unbekannt", unknownLocation = "unbekannter Ort" },
    itIT = { vendor = "Mercante", vendorAt = "Mercante a %s", drop = "Bottino del mondo / nemici", quest = "Ricompensa missione", questAt = "Missione a %s", dungeon = "Spedizione: %s", raid = "Incursione: %s", crafted = "Creata con %s", unknown = "Fonte non confermata", unknownLocation = "luogo sconosciuto" },
    ruRU = { vendor = "Торговец", vendorAt = "Торговец в %s", drop = "Добыча с противников", quest = "Награда за задание", questAt = "Задание в %s", dungeon = "Подземелье: %s", raid = "Рейд: %s", crafted = "Создается с помощью %s", unknown = "Источник не подтвержден", unknownLocation = "неизвестно" },
    koKR = { vendor = "상인", vendorAt = "%s 상인", drop = "야외 전리품", quest = "퀘스트 보상", questAt = "%s 퀘스트", dungeon = "던전: %s", raid = "공격대: %s", crafted = "%s로 제작", unknown = "획득처 미확인", unknownLocation = "불명" },
    zhCN = { vendor = "商人", vendorAt = "%s 的商人", drop = "世界掉落", quest = "任务奖励", questAt = "%s 的任务", dungeon = "地下城：%s", raid = "团队副本：%s", crafted = "通过%s制作", unknown = "来源未确认", unknownLocation = "未知地点" },
    zhTW = { vendor = "商人", vendorAt = "%s 的商人", drop = "世界掉落", quest = "任務獎勵", questAt = "%s 的任務", dungeon = "地城：%s", raid = "團隊副本：%s", crafted = "透過%s製作", unknown = "來源未確認", unknownLocation = "未知地點" },
}
sourceUI.enGB = sourceUI.enUS
sourceUI.esMX = sourceUI.esES
addon.recipeSourceText = sourceUI[locale] or sourceUI.enUS

addon.uiText = ui[locale] or ui.enUS
for key, value in pairs(filterUI[locale] or filterUI.enUS) do
    addon.uiText[key] = value
end
for key, value in pairs(recipeUI[locale] or recipeUI.enUS) do
    addon.uiText[key] = value
end

local deliveryUI = {
    enUS = { deliveryNPC = "Turn in to", deliveryObject = "Turn in at object", deliveryLocation = "Turn-in location", deliveryUnconfirmed = "Not confirmed" },
    ptBR = { deliveryNPC = "Entregar para", deliveryObject = "Entregar no objeto", deliveryLocation = "Local de entrega", deliveryUnconfirmed = "Ainda não confirmado" },
    esES = { deliveryNPC = "Entregar a", deliveryObject = "Entregar en objeto", deliveryLocation = "Lugar de entrega", deliveryUnconfirmed = "Sin confirmar" },
    frFR = { deliveryNPC = "Remettre à", deliveryObject = "Remettre à l’objet", deliveryLocation = "Lieu de remise", deliveryUnconfirmed = "Non confirmé" },
    deDE = { deliveryNPC = "Abgeben bei", deliveryObject = "Abgabe am Objekt", deliveryLocation = "Abgabeort", deliveryUnconfirmed = "Nicht bestätigt" },
    itIT = { deliveryNPC = "Consegna a", deliveryObject = "Consegna all’oggetto", deliveryLocation = "Luogo di consegna", deliveryUnconfirmed = "Non confermato" },
    ruRU = { deliveryNPC = "Сдать", deliveryObject = "Сдать у объекта", deliveryLocation = "Место сдачи", deliveryUnconfirmed = "Не подтверждено" },
    koKR = { deliveryNPC = "제출 대상", deliveryObject = "오브젝트에 제출", deliveryLocation = "제출 장소", deliveryUnconfirmed = "확인되지 않음" },
    zhCN = { deliveryNPC = "交给", deliveryObject = "在物件交付", deliveryLocation = "交付地点", deliveryUnconfirmed = "尚未确认" },
    zhTW = { deliveryNPC = "交給", deliveryObject = "在物件交付", deliveryLocation = "交付地點", deliveryUnconfirmed = "尚未確認" },
}
deliveryUI.enGB = deliveryUI.enUS
deliveryUI.esMX = deliveryUI.esES
for key, value in pairs(deliveryUI[locale] or deliveryUI.enUS) do
    addon.uiText[key] = value
end

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
