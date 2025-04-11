if SERVER then return end

-- Wiki data
DD.wikiData = {
	-- main
	main = {
		related = {'events', 'jobs', 'items', 'medicalSystem', 'creatures', 'dams', 'credits'},
		unforcedReciprocalRelations = true,
		hidden = true,
	},
	serverMessage = {
		related = {'main'},
		unforcedReciprocalRelations = true,
		hidden = true,
	},
	events = {
		related = {'main'},
		isCategory = true,
	},
	jobs = {
		related = {'main'},
		isCategory = true,
	},
	items = {
		related = {'main'},
		isCategory = true,
	},
	medicalSystem = {
		related = {'main', 'radiation'},
		isCategory = true,
	},
	creatures = {
		related = {'main'},
		isCategory = true,
	},
	dams = {
		related = {'main'},
		isCategory = true,
	},
	credits = {
		related = {'main'},
		isCategory = true,
	},
	placeholder = {
		related = {'main'},
		hidden = true,
	},
	-- main events
	nukiesEvent = {
		related = {'main', 'events', 'jetJob'},
	},
	serialKillerEvent = {
		related = {'main', 'events', 'murderEvent', 'creepymaskItem'},
	},
	revolutionEvent = {
		related = {'main', 'events'},
	},
	bloodCultEvent = {
		related = {'main', 'events', 'the1998Item', 'sacrificialdaggerItem', 'bloodcultistrobesItem'},
	},
	deathSquadEvent = {
		related = {'main', 'events', 'mercsEvent', 'mercsevilJob', 'midazolamItem'},
	},
	greenskinsEvent = {
		related = {'main', 'events', 'greenskinCreature', 'midazolamItem'},
	},
	-- side events
	airdropEvent = {
		related = {'main', 'events', 'radiation'},
	},
	fishEvent = {
		related = {'main', 'events', 'spitroachCreature', 'huskCreature'},
	},
	murderEvent = {
		related = {'main', 'events', 'arrestEvent', 'serialKillerEvent'},
	},
	arrestEvent = {
		related = {'main', 'events', 'murderEvent'},
	},
	afflictionEvent = {
		related = {'main', 'events', 'influenzainfectionAffliction', 'tbinfectionAffliction'},
	},
	blackoutEvent = {
		related = {'main', 'events'},
	},
	vipEvent = {
		related = {'main', 'events', 'bodyguardJob', 'midazolamItem'},
		identifier = 'eventVIP',
	},
	wizardEvent = {
		related = {'main', 'events'},
	},
	gangEvent = {
		related = {'main', 'events', 'bloodsamplerItem'},
	},
	mercsEvent = {
		related = {'main', 'events', 'deathSquadEvent', 'mercsJob', 'midazolamItem'},
		identifier = 'eventMERCS',
	},
	electionEvent = {
		related = {'main', 'events', 'captainJob', 'securityofficerJob', 'foremanJob', 'diverJob'},
	},
	withdrawEvent = {
		related = {'main', 'events'},
	},
	-- jobs
	captainJob = {
		related = {'main', 'jobs', 'electionEvent'},
	},
	engineerJob = {
		related = {'main', 'jobs'},
	},
	securityofficerJob = {
		related = {'main', 'jobs', 'electionEvent'},
	},
	medicaldoctorJob = {
		related = {'main', 'jobs'},
	},
	assistantJob = {
		related = {'main', 'jobs'},
	},
	mechanicJob = {
		related = {'main', 'jobs'},
	},
	janitorJob = {
		related = {'main', 'jobs'},
	},
	clownJob = {
		related = {'main', 'jobs'},
	},
	foremanJob = {
		related = {'main', 'jobs', 'electionEvent'},
	},
	researcherJob = {
		related = {'main', 'jobs'},
	},
	diverJob = {
		related = {'main', 'jobs', 'electionEvent'},
	},
	bodyguardJob = {
		related = {'main', 'jobs', 'vipEvent', 'midazolamItem'},
	},
	jetJob = {
		related = {'main', 'jobs', 'nukiesEvent'},
	},
	mercsJob = {
		related = {'main', 'jobs', 'mercsevilJob', 'mercsEvent', 'midazolamItem'},
	},
	mercsevilJob = {
		related = {'main', 'jobs', 'mercsJob', 'deathSquadEvent', 'midazolamItem'},
	},
	-- items
	separatistrifleItem = {
		related = {'main', 'items', 'nukiesEvent', 'revolutionEvent', 'jetJob', 'sovietmagazineItem'},
	},
	marksmanrifleItem = {
		related = {'main', 'items', 'nukiesEvent', 'revolutionEvent', 'jetJob', 'sovietmagazineItem'},
	},
	sovietmagazineItem = {
		related = {'main', 'items', 'nukiesEvent', 'revolutionEvent', 'jetJob', 'separatistrifleItem', 'marksmanrifleItem'},
		identifier = '762magazine',
	},
	brassknuckleItem = {
		related = {'main', 'items'},
	},
	portablegeneratorItem = {
		related = {'main', 'items'},
	},
	printerItem = {
		related = {'main', 'items', 'jobs'},
	},
	-- items (medical)
	bacterialsyringeItem = {
		related = {'main', 'items', 'medicalSystem', 'bacterialinfectionAffliction'},
	},
	flusyringeItem = {
		related = {'main', 'items', 'medicalSystem', 'fluantidoteItem', 'influenzainfectionAffliction'},
	},
	tbsyringeItem = {
		related = {'main', 'items', 'medicalSystem', 'tbantidoteItem', 'tbinfectionAffliction'},
	},
	anthraxsyringeItem = {
		related = {'main', 'items', 'medicalSystem', 'anthraxantidoteItem', 'anthraxinfectionAffliction'},
	},
	fluantidoteItem = {
		related = {'main', 'items', 'medicalSystem', 'flusyringeItem', 'influenzainfectionAffliction'},
	},
	tbantidoteItem = {
		related = {'main', 'items', 'medicalSystem', 'tbsyringeItem', 'tbinfectionAffliction'},
	},
	anthraxantidoteItem = {
		related = {'main', 'items', 'medicalSystem', 'anthraxsyringeItem', 'anthraxinfectionAffliction'},
	},
	midazolamItem = {
		related = {'main', 'items', 'medicalSystem', 'deathSquadEvent', 'greenskinsEvent', 'vipEvent', 'mercsEvent', 'bodyguardJob', 'mercsJob', 'mercsevilJob'},
	},
	myxotoxinItem = {
		related = {'main', 'items', 'medicalSystem', 'bacterialinfectionAffliction', 'tbinfectionAffliction'},
	},
	bloodsamplerItem = {
		related = {'main', 'items', 'medicalSystem', 'bacterialsyringeItem', 'flusyringeItem', 'tbsyringeItem', 'gangEvent'},
	},
	-- creatures
	spitroachCreature = {
		related = {'main', 'creatures', 'fishEvent'},
	},
	huskCreature = {
		related = {'main', 'creatures', 'fishEvent'},
	},
	greenskinCreature = {
		related = {'main', 'creatures', 'greenskinsEvent', 'midazolamItem'},
	},
	-- afflictions
	bacterialinfectionAffliction = {
		related = {'main', 'medicalSystem', 'bacterialsyringeItem', 'myxotoxinItem'},
	},
	influenzainfectionAffliction = {
		related = {'main', 'medicalSystem', 'afflictionEvent', 'flusyringeItem', 'fluantidoteItem'},
	},
	tbinfectionAffliction = {
		related = {'main', 'medicalSystem', 'afflictionEvent', 'tbsyringeItem', 'tbantidoteItem', 'myxotoxinItem'},
	},
	anthraxinfectionAffliction = {
		related = {'main', 'medicalSystem', 'afflictionEvent', 'anthraxsyringeItem', 'anthraxantidoteItem', 'myxotoxinItem'},
	},
	-- misc
	radiation = {
		parents = {'main', 'medicalSystem'},
		related = {'main', 'medicalSystem', 'airdropEvent'},
	},
	-- dams (maps)
	oldeTowneDam = {
		related = {'main', 'dams'},
	},
	pioneerPointDam = {
		related = {'main', 'dams'},
	},
	cliffhangerDam = {
		related = {'main', 'dams'},
	},
}
-- Automatically add in pages for items in Dam Defense which don't have a manually created page
for prefab in ItemPrefab.Prefabs do
	-- 3146664815 is the steamworkshopid of Dam Defense
	local pageName = tostring(prefab.Identifier) .. 'Item'
	if (LuaUserData.TypeOf(prefab.ContentPackage) == 'Barotrauma.RegularPackage') and (prefab.ContentPackage.UgcId.StringRepresentation == '3146664815') and (DD.wikiData[pageName] == nil)
	and (not prefab.HideInMenus) and (prefab.Description ~= nil) and (prefab.Description ~= '') then
		-- get info
		local info = {isAutogen = true}
		if (prefab.ConfigElement.Parent ~= nil) and prefab.ConfigElement.Parent.IsOverride() then info.isOverride = true end
		-- add text to english localization
		if DD.localizations.english['wikiName_' .. pageName] == nil then DD.localizations.english['wikiName_' .. pageName] = tostring(prefab.Name) end
		if DD.localizations.english['wikiText_' .. pageName] == nil then DD.localizations.english['wikiText_' .. pageName] = 'This page was automatically generated.' end
		-- add page to wiki data
		DD.wikiData[pageName] = {identifier = tostring(prefab.Identifier), related = {'main'}, parent = {'main'}, info = info}
	end
end
-- Add button to open browser wiki if CSharp is loaded
if DD.isCSharpLoaded then
	local tbl = {'openhtml'}
	for item in DD.wikiData.main.related do
		table.insert(tbl, item)
	end
	DD.wikiData.main.related = tbl
	
	DD.wikiData.serverMessage.related = {'openhtml', 'main'}
end
-- Automatically adds an object's XML description to its wiki text
for localization in DD.localizations do
	for key, value in pairs(localization) do
		if string.sub(key, 1, #'wikiText_') == 'wikiText_' then
			local wikiIdentifier = DD.stringSplit(key, '_')
			table.remove(wikiIdentifier, 1)
			wikiIdentifier = DD.tableJoin(wikiIdentifier, '_')
			local description
			local identifier
			if string.sub(key, #key - 2, #key) == 'Job' then
				identifier = DD.stringSplit(wikiIdentifier, 'Job')[1]
				description = tostring(JobPrefab.Get(identifier).Description)
			elseif string.sub(key, #key - 3, #key) == 'Item' then
				identifier = DD.wikiData[wikiIdentifier].identifier or DD.stringSplit(wikiIdentifier, 'Item')[1]
				description = tostring(ItemPrefab.GetItemPrefab(identifier).Description)
			end
			if description ~= nil then
				localization[key] = DD.stringReplace(localization['wiki_description'], {description = description}) .. localization[key]
			end
		end
	end
end
-- Automatically links pages to their category page, if they have one
for key, value in pairs(DD.wikiData) do
	if value.related == nil then DD.wikiData[key].related = {} end
	if value.parents == nil then DD.wikiData[key].parents = {} end
	if value.info == nil then DD.wikiData[key].info = {} end
	
	-- automatically link pages to their parent page
	if (key ~= 'main') and not DD.tableHas(DD.wikiData[key].parents, 'main') then
		table.insert(DD.wikiData[key].parents, 'main')
	end
	if string.sub(key, #key - 4, #key) == 'Event' then
		table.insert(DD.wikiData.events.related, key)
		table.insert(DD.wikiData[key].parents, 'events')
		-- get info
		local identifier
		if DD.wikiData[key].identifier ~= nil then
			identifier = DD.wikiData[key].identifier
		else
			identifier = string.sub(key, 1, #key - #'event')
			identifier = 'event' .. string.upper(string.sub(identifier, 1, 1)) .. string.sub(identifier, 2 , #key)
		end
		DD.wikiData[key].info.main = DD.toBool(DD[identifier].tbl.isMainEvent)
		DD.wikiData[key].info.public = DD.toBool(DD[identifier].tbl.public)
	elseif string.sub(key, #key - 2, #key) == 'Job' then
		table.insert(DD.wikiData.jobs.related, key)
		table.insert(DD.wikiData[key].parents, 'jobs')
		-- get info
		local identifier = string.sub(key, 1, #key - #'job')
		DD.wikiData[key].info.antagSafe = DD.toBool(DD.antagSafeJobs[identifier])
		DD.wikiData[key].info.security = DD.toBool(DD.securityJobs[identifier])
		DD.wikiData[key].info.proletariat = DD.toBool(DD.proletariatJobs[identifier])
		DD.wikiData[key].info.medical = DD.toBool(DD.medicalJobs[identifier])
	elseif string.sub(key, #key - 3, #key) == 'Item' then
		table.insert(DD.wikiData.items.related, key)
		table.insert(DD.wikiData[key].parents, 'items')
		local identifier = DD.wikiData[key].identifier or DD.stringSplit(key, 'Item')[1]
		local categoryEnum = DD.numberToEnum(ItemPrefab.GetItemPrefab(identifier).Category, DD.entityCategories)
		if categoryEnum.medical then
			table.insert(DD.wikiData.medicalSystem.related, key)
			table.insert(DD.wikiData[key].parents, 'medicalSystem')
		end
		-- get info
		for recipe in ItemPrefab.GetItemPrefab(identifier).FabricationRecipes do
			if tostring(recipe.SuitableFabricatorIdentifiers[1]) == 'nexshop' then
				DD.wikiData[key].info.nexshopCost = recipe.RequiredItems[1].amount
			elseif tostring(recipe.SuitableFabricatorIdentifiers[1]) == 'nukieshop' then
				DD.wikiData[key].info.nukieshopCost = recipe.RequiredItems[1].amount
			end
		end
		DD.wikiData[key].info.categories = categoryEnum
	elseif string.sub(key, #key - 2, #key) == 'Dam' then
		table.insert(DD.wikiData.dams.related, key)
		table.insert(DD.wikiData[key].parents, 'dams')
	elseif string.sub(key, #key - 7, #key) == 'Creature' then
		table.insert(DD.wikiData.creatures.related, key)
		table.insert(DD.wikiData[key].parents, 'creatures')
	elseif string.sub(key, #key - 9, #key) == 'Affliction' then
		table.insert(DD.wikiData.medicalSystem.related, key)
		table.insert(DD.wikiData[key].parents, 'medicalSystem')
	end
end
-- ensure related reciprocity
for key, value in pairs(DD.wikiData) do
	if (not value.unforcedReciprocalRelations) and (key ~= 'openhtml') then
		for related in DD.wikiData[key].related do
			if (related ~= 'openhtml') and (not DD.wikiData[related].unforcedReciprocalRelations) and (not DD.tableHas(DD.wikiData[related].related, key)) then
				table.insert(DD.wikiData[related].related, key)
			end
		end
	end
end

-- returns the children of a component
local GetChildren = function (comp)
    local tbl = {}
    for value in comp.GetAllChildren() do
        table.insert(tbl, value)
    end
    return tbl
end

-- set button color
local defaultButtonColor = Color(169, 212, 187)
local setButtonColor = function (button, color)
	button.TextColor = color
	button.HoverTextColor = color
	button.SelectedTextColor = color
	button.Color = color
	button.HoverColor = Color(255, 255, 255)
	button.PressedColor = color
end

-- main frame
local frame = GUI.Frame(GUI.RectTransform(Vector2(1, 1)), nil)
frame.CanBeFocused = false

-- menu frame
local menu = GUI.Frame(GUI.RectTransform(Vector2(1, 1), frame.RectTransform, GUI.Anchor.Center), nil)
menu.CanBeFocused = false
menu.Visible = false

-- put a button that goes behind the menu content, so we can close it when we click outside
local closeButton = GUI.Button(GUI.RectTransform(Vector2(1, 1), menu.RectTransform, GUI.Anchor.Center), "", GUI.Alignment.Center, nil)
closeButton.OnClicked = function ()
	menu.Visible = not menu.Visible
end

-- Make it so the GUI is updated in lobby, game and sub editor
Hook.Patch("Barotrauma.NetLobbyScreen", "AddToGUIUpdateList", function()
    frame.AddToGUIUpdateList()
end, Hook.HookMethodType.After)
Hook.Patch("Barotrauma.GameScreen", "AddToGUIUpdateList", function()
    frame.AddToGUIUpdateList()
end)
Hook.Patch("Barotrauma.SubEditorScreen", "AddToGUIUpdateList", function()
    frame.AddToGUIUpdateList()
end)

-- setup wiki

-- Menu frame and menu list
local menuContent = GUI.Frame(GUI.RectTransform(Vector2(0.57, 0.83), menu.RectTransform, GUI.Anchor.Center))
local menuList = GUI.ListBox(GUI.RectTransform(Vector2(0.95, 0.9), menuContent.RectTransform, GUI.Anchor.Center))

-- label
local text = GUI.TextBlock(GUI.RectTransform(Vector2(1, 0.05), menuContent.RectTransform), "Dam Defense Wiki", nil, nil, GUI.Alignment.Center)
text.CanBeFocused = false
text.textScale = 1.25
	
-- Text
local text = GUI.TextBlock(GUI.RectTransform(Vector2(1, 0.05), menuList.Content.RectTransform), "All Wiki Pages", nil, nil, GUI.Alignment.BottomLeft)
text.CanBeFocused = false

-- Dropdown for selecting prefab
local pageDropdown = GUI.DropDown(GUI.RectTransform(Vector2(1, 0.05), menuList.Content.RectTransform), "-", 3, nil, false)
pageDropdown.ButtonTextColor = Color(169, 212, 187)
for key, value in pairs(DD.wikiData) do
	pageDropdown.AddItem(DD.stringLocalize('wikiName_' .. key) or ('wikiName_' .. key), key)
end

-- page root space : page links space
local k = 0.79

-- Page root (title, body and such)
local pageTitle = GUI.TextBlock(GUI.RectTransform(Vector2(1, 0.05), menuList.Content.RectTransform), '-', nil, nil, GUI.Alignment.Left)
pageTitle.CanBeFocused = false
pageTitle.TextScale = 1.5

local pageRoot = GUI.ListBox(GUI.RectTransform(Vector2(1, 0.75 * k), menuList.Content.RectTransform))
pageRoot.ScrollBarVisible = true
	
local pageBody = GUI.TextBlock(GUI.RectTransform(Vector2(1, 1), pageRoot.Content.RectTransform), '-', nil, nil, GUI.Alignment.TopLeft)
pageBody.CanBeFocused = false
pageBody.Wrap = true

-- Page links (buttons that lead you to related pages)
local text = GUI.TextBlock(GUI.RectTransform(Vector2(1, 0.05), menuList.Content.RectTransform), "Related Pages", nil, nil, GUI.Alignment.BottomLeft)
text.CanBeFocused = false
text.TextScale = 1.5

local pageRelated = GUI.ListBox(GUI.RectTransform(Vector2(1, 0.75 * (1 - k)), menuList.Content.RectTransform))
pageRelated.ScrollBarVisible = true

-- gets the name (title), text (body) and other relevant fields of a wiki page
local getPageFields = function (pageKey)
	local tbl = {
		name = DD.stringLocalize('wikiName_' .. pageKey) or ('wikiName_' .. pageKey),
		text = DD.stringLocalize('wikiText_' .. pageKey) or ('wikiText_' .. pageKey),
	}
	if (pageKey == 'serverMessage') and (Game.IsMultiplayer) then
		tbl.name = Game.ServerSettings.ServerName
		tbl.text = Game.ServerSettings.ServerMessageText
	end
	if (pageKey == 'credits') and File.Exists(DD.path .. '/credits.txt') then
		tbl.text = File.Read(DD.path .. '/credits.txt')
	end
	
	local newline = '    '
	local build = newline
	for count = 1, #tbl.text do
		build = build .. string.sub(tbl.text, count, count)
		if string.sub(build, #build, #build) == '\n' then
			build = build .. newline
		end
	end
	tbl.text = build
	
	return tbl
end

-- Called by "pageDropdown.OnSelected"
DD.loadPage = function (pageKey)
	local pageValue = DD.wikiData[pageKey]
	
	-- change values
	local pageFields = getPageFields(pageKey)
	pageTitle.Text = pageFields.name
	pageBody.Text = pageFields.text
	
	-- link to related pages
	pageRelated.ClearChildren()
	
	-- get amount of related pages (autogenerated pages are not counted)
	if pageValue.related == nil then return end
	local relatedCount = 0
	for related in pageValue.related do
		if (DD.wikiData[related] == nil) or (DD.wikiData[related].info == nil) or (not DD.wikiData[related].info.isAutogen) then
			relatedCount = relatedCount + 1
		end
	end
	if relatedCount == 0 then return end
	
	local count = 1
	local itemsPerRow = 4
	for rowIndex = 1, math.ceil(relatedCount / itemsPerRow) do
		local pageRow = GUI.LayoutGroup(GUI.RectTransform(Vector2(1, 0.15 / 0.75 / (1 - k) * 0.2625), pageRelated.Content.RectTransform), nil)
		pageRow.isHorizontal = true
		local items = DD.arrSub(pageValue.related, count, count + itemsPerRow - 1)
		count = count + itemsPerRow
		for value in items do
			if (DD.wikiData[value] == nil) or (DD.wikiData[value].info == nil) or (not DD.wikiData[value].info.isAutogen) then
				local button = GUI.Button(GUI.RectTransform(Vector2(1 / 4, 0.05), pageRow.RectTransform), DD.stringLocalize('wikiName_' .. value), GUI.Alignment.Center, "GUITextBox")
				if DD.tableHas(pageValue.parents, value) then
					setButtonColor(button, Color.Lerp(defaultButtonColor, Color.White, 0.65))
				end
				if value == 'openhtml' then		
					button.OnClicked = function ()
						DD.openHTML(true)
					end
					setButtonColor(button, Color.Lerp(Color(123, 104, 238), Color.White, 0.65))
				else
					button.OnClicked = function ()
						DD.loadPage(value)
					end
				end
			end
		end
	end
end
-- Adds function to pageDropdown onSelect
pageDropdown.OnSelected = function (guiComponent, object)
	DD.loadPage(object)
end
-- Open "main" page
pageDropdown.SelectItem('main')

-- inside close button
local closeButton = GUI.Button(GUI.RectTransform(Vector2(1, 0.05), menuList.Content.RectTransform), "Close Wiki", GUI.Alignment.Center, "GUIButton")
closeButton.OnClicked = function ()
	menu.Visible = not menu.Visible
end

-- Show button to open menu
Hook.Patch("Barotrauma.GUI", "TogglePauseMenu", {}, function ()
    if GUI.GUI.PauseMenuOpen then
		menu.Visible = false
        local frame = GUI.GUI.PauseMenu
        local list = GetChildren(GetChildren(frame)[2])[1]
		local button = GUI.Button(GUI.RectTransform(Vector2(1, 0.1), list.RectTransform), 'DD Wiki', GUI.Alignment.Center, "GUIButton")
		button.OnClicked = function ()
			GUI.GUI.TogglePauseMenu()
			menu.Visible = true
		end
	end
end, Hook.HookMethodType.After)

-- Override server message button to open wiki
if Game.NetLobbyScreen ~= nil then
	local descriptionButton
	for value in Game.NetLobbyScreen.Frame.GetAllChildren() do
		if value.GetType() == GUI.Button and value.Text == 'Description' then
			value.OnClicked = function ()
				menu.Visible = true
				DD.loadPage('serverMessage')
			end
		end
	end
end

-- Generates HTML pages
DD.generateWikiHTML = function ()
	-- guard clauses and retrieve needed file text
	if not File.DirectoryExists(DD.saving.folderPath) then
        File.CreateDirectory(DD.saving.folderPath)
		print('Data folder not found, so one was created at ' .. DD.saving.folderPath)
	end
	local mainPath = DD.path .. '/Lua/DD/gui/main.html'
	local segmentPath = DD.path .. '/Lua/DD/gui/segment.html'
	if not File.Exists(mainPath) then DD.warn('File needed for HTML wiki creation was not found in ' .. mainPath) return end
	if not File.Exists(segmentPath) then DD.warn('File needed for HTML wiki creation was not found in ' .. segmentPath) return end
	local main = File.Read(mainPath)
	local segment = File.Read(segmentPath)
	
	-- anchor
	local anchor = '<a href="#{key}" style="{style}">{text}</a>'
	local sidebar = '<a href="#{key}" style="margin:10px;">{text}</a>'
	local headerInfo = ' <b style="{style}">{text}</b>'
	
	-- adds a wiki entry to the HTML page
	local generatePage = function (key)
		local value = DD.wikiData[key]
		if not value.hidden then
			local tbl = getPageFields(key)
			tbl.class = ''
			-- key (technical)
			tbl.key = key
			-- name
			if DD.wikiData[key].category ~= nil then
				tbl.name = DD.stringReplace('{name} ({category})', {name = tbl.name, category = getPageFields(DD.wikiData[key].category).name})
			end
			-- add info to header (name)
			local nameAppend = ''
			local info = DD.wikiData[key].info or {}
			for key,value in pairs(info) do
				if key == 'main' then
					if value then
						nameAppend = nameAppend .. DD.stringReplace(headerInfo, {text = 'Major', style = 'color:tomato;'})
					else
						nameAppend = nameAppend .. DD.stringReplace(headerInfo, {text = 'Minor', style = 'color:gold;'})
					end
				elseif key == 'public' then
					if value then
						nameAppend = nameAppend .. DD.stringReplace(headerInfo, {text = 'Public', style = 'color:lime;'})
					else
						nameAppend = nameAppend .. DD.stringReplace(headerInfo, {text = 'Secret', style = 'color:magenta;'})
					end
				elseif key == 'antagSafe' then
					if value then
						nameAppend = nameAppend .. DD.stringReplace(headerInfo, {text = 'Safe', style = 'color:lime;'})
					else
						nameAppend = nameAppend .. DD.stringReplace(headerInfo, {text = 'Unsafe', style = 'color:tomato;'})
					end
				elseif key == 'security' then
					if value then
						nameAppend = nameAppend .. DD.stringReplace(headerInfo, {text = 'Security', style = 'color:tan;'})
					end
				elseif key == 'proletariat' then
					if value then
						nameAppend = nameAppend .. DD.stringReplace(headerInfo, {text = 'Proletariat', style = 'color:lightsteelblue;'})
					end
				elseif key == 'medical' then
					if value then
						nameAppend = nameAppend .. DD.stringReplace(headerInfo, {text = 'Medical', style = 'color:salmon;'})
					end
				elseif key == 'nexshopCost' then
					if value then
						nameAppend = nameAppend .. DD.stringReplace(headerInfo, {text = value .. ' Credits', style = 'color:cyan;'})
					end
				elseif key == 'nukieshopCost' then
					if value then
						nameAppend = nameAppend .. DD.stringReplace(headerInfo, {text = value .. ' Credits', style = 'color:orange;'})
					end
				end
			end
			if info.isAutogen then
				nameAppend = nameAppend .. DD.stringReplace(headerInfo, {text = 'Autogenerated', style = 'color:limegreen;'})
				tbl.class = tbl.class .. 'autogen '
			end
			if info.isOverride then
				nameAppend = nameAppend .. DD.stringReplace(headerInfo, {text = 'Overriden', style = 'color:mediumorchid;'})
				tbl.class = tbl.class .. 'override '
			end
			tbl.name = tbl.name .. nameAppend
			-- style for name (header/title)
			tbl.nameStyle = ''
			if (DD.wikiData[key].category ~= nil) and (DD.wikiData[DD.wikiData[key].category].color ~= nil) then
				local color = DD.wikiData[DD.wikiData[key].category].color
				if type(color) == 'userdata' then
					color = DD.colorToHex(color)
				end
				tbl.nameStyle = 'background-color:' .. color .. ';'
			end
			if string.lower(string.sub(key, #key - 2, #key)) == 'job' then
				local job = string.sub(key, 1, #key - 3)
				tbl.nameStyle = 'background-color:' .. DD.colorToHex(Color.Lerp(JobPrefab.Get(job).UIColor, Color.Black, 0.3)) .. ';'
			end
			-- text (wiki entry body)
			tbl.text = '&nbsp;&nbsp;' .. string.gsub(tbl.text, '\n', '<br>&nbsp;&nbsp;')
			-- related (links)
			tbl.related = ''
			local joinString = ' '
			for related in value.related do
				if related ~= 'openhtml' then
					local style = 'margin:0px 3px;'
					if DD.tableHas(value.parents, related) then
						style = style .. "color:black;background-color:mediumslateblue;padding:1px;"
					end
					tbl.related = tbl.related .. DD.stringReplace(anchor, {key = related, style = style, text = getPageFields(related).name}) .. joinString
				end
			end
			tbl.related = string.sub(tbl.related, 1, #tbl.related - #joinString)
			-- prepare for next wiki entry
			tbl.segment = '{segment}'
			-- sidebar
			tbl.class = string.sub(tbl.class, 1, #tbl.class - 1)
			local sidebarTbl =  {key = key, text = getPageFields(key).name}
			local sidebarText = DD.stringReplace(sidebar, sidebarTbl)
			local sidebarStyle = ''
			if info.isAutogen then
				sidebarText = sidebarText .. '<b style="color:limegreen;">•</b>'
			end
			if info.isOverride then
				sidebarText = sidebarText .. '<b style="color:mediumorchid;">•</b>'
			end
			if DD.wikiData[key].category ~= nil then
				sidebarText = '&nbsp;&nbsp;↪' .. sidebarText
			end
			sidebarText = DD.stringReplace('<div id={id} class="{class}" style="{style}">{text}<br></div>', {id = 'sidebar_' .. string.gsub(string.lower(getPageFields(key).name), ' ', '_'), text = sidebarText, class = tbl.class, style = sidebarStyle}) .. '{sidebar}'
			-- apply
			local text = string.gsub(DD.stringReplace(segment, tbl), '%%', '%%%%')
			main = string.gsub(main, '{sidebar}', sidebarText)
			main = string.gsub(main, '{segment}', text)
		end
	end
	
	-- discord invite
	main = string.gsub(main, '{discordInvite}', DD.discordInvite)
	-- main wiki entry has a custom implementation
	main = string.gsub(main, '{mainText}', '&nbsp;&nbsp;' .. string.gsub(getPageFields('main').text, '\n', '<br>&nbsp;&nbsp;'))
	local mainRelated = ''
	for related in DD.wikiData.main.related do
		if related ~= 'openhtml' then
			mainRelated = mainRelated .. DD.stringReplace(anchor, {key = related, style = '', text = getPageFields(related).name}) .. ' | '
		end
	end
	mainRelated = string.sub(mainRelated, 1 , #mainRelated - 3)
	main = string.gsub(main, '{mainRelated}', mainRelated)
	-- order wiki entries
	local tbl = {}
	for key, value in pairs(DD.wikiData) do
		if value.isCategory then
			tbl[key] = {key}
		elseif type(value.parents) == 'table' then
			local chosenParent
			for parent in value.parents do
				chosenParent = parent
			end
			if (chosenParent ~= nil) and (chosenParent ~= 'main') then
				table.insert(tbl[chosenParent], key)
				DD.wikiData[key].category = chosenParent
			end
		end
	end
	-- generate wiki entries
	for category, subtbl in pairs(tbl) do
		for item in subtbl do
			generatePage(item)
		end
	end
	-- final
	main = string.gsub(main, '{segment}', '')
	main = string.gsub(main, '{sidebar}', '')
	File.Write(DD.saving.folderPath .. 'main.html', main)
	return DD.saving.folderPath .. 'main.html'
end

-- set up GUI table
DD.gui = {
	debugLine = {
		point1 = Vector2(),
		point2 = Vector2()
	},
	characterRole = {}
}

-- get text to be displayed below name
local getInfoText = function (character, pov)
	local pov = pov or Character.Controlled
	local text = ''
	local priotiy = 0
	local assignText = function (thisText, thisPriotiy)
		if (thisPriotiy or 0) >= priotiy then
			text = thisText
			priotiy = thisPriotiy or 0
		end
	end
	local characterHasRole = function (character, role)
		if DD.gui.characterRole[tostring(character.ID)] == nil then return end
		return DD.gui.characterRole[tostring(character.ID)][role]
	end
	-- for spectators
	if pov == nil then
		if characterHasRole(character, 'arresttarget') then
			assignText('wanted', 1)
		end
		if character.TeamID ~= CharacterTeamType.Team1 then
			if character.TeamID == CharacterTeamType.FriendlyNPC then
				assignText('friendly', 2)
			else
				assignText('hostile', 2)
			end
		end
		if DD.isCharacterSecurity(character) then
			assignText('security')
		elseif DD.isCharacterMedical(character) then
			assignText('medical')
		end
		if characterHasRole(character, 'rebel') then
			assignText('rebel', 3)
		end
		if DD.tableHas(character.CharacterHealth.GetActiveAfflictionTags(), 'enlightened') then
			assignText('cultist', 3)
		end
		if DD.tableHas(character.CharacterHealth.GetActiveAfflictionTags(), 'serialkiller') then
			assignText('serialkiller', 3)
		end
		if character.JobIdentifier == 'gangster' then
			assignText('gangleader', 3)
		end
		if DD.tableHas(character.CharacterHealth.GetActiveAfflictionTags(), 'wizard') then
			assignText('wizard', 3)
		end
		return text
	end
	-- for the living
	if DD.tableHas(pov.CharacterHealth.GetActiveAfflictionTags(), 'enlightened') then
		if DD.tableHas(character.CharacterHealth.GetActiveAfflictionTags(), 'enlightened') then
			assignText('comradecultist', 3)
		else
			assignText('target', 1)
		end
	end
	if DD.tableHas(pov.CharacterHealth.GetActiveAfflictionTags(), 'serialkiller') then
		assignText('target', 1)
	end
	if characterHasRole(character, 'victim') then
		assignText('target', 1)
	end
	if characterHasRole(character, 'arresttarget') and not character.Info.IsDisguisedAsAnother then
		assignText('wanted', 1)
	end
	if character.TeamID == CharacterTeamType.FriendlyNPC then
		assignText('friendly', 2)
	end
	if characterHasRole(character, 'rebel') then
		if characterHasRole(Character.Controlled, 'rebel') then
			assignText('comrade', 2)
		elseif not character.Info.IsDisguisedAsAnother then
			assignText('rebel', 2)
		end
	end
	if characterHasRole(character, 'goon') then
		if characterHasRole(Character.Controlled, 'boss') then
			assignText('subordinate', 2)
		else
			assignText('comrade', 2)
		end
	end
	if DD.isCharacterSecurity(character) and characterHasRole(Character.Controlled, 'rebel') then
		assignText('target', 1)
	end
	if character.IsOnFriendlyTeam(pov) then
		if character.TeamID == CharacterTeamType.Team1 then
			assignText('neutral')
		else
			assignText('comrade', 2)
		end
	else
		assignText('hostile', 2)
	end
	if DD.tableHas(character.CharacterHealth.GetActiveAfflictionTags(), 'wizard') then
		assignText('wizard', 3)
	end
	if characterHasRole(character, 'guard') then
		assignText('bodyguard', 3)
	end
	if character.JobIdentifier == 'gangster' then
		assignText('gangleader', 3)
	end
	if characterHasRole(character, 'boss') then
		assignText('boss', 3)
	end
	if characterHasRole(character, 'vip') then
		assignText('protect', 3)
	end
	local job = tostring(character.JobIdentifier)
	if (character.Info ~= nil) and character.Info.IsDisguisedAsAnother then
		if character.Inventory.GetItemInLimbSlot(InvSlotType.Card) ~= nil then
			local identifier = tostring(character.Inventory.GetItemInLimbSlot(InvSlotType.Card).GetComponentString('IdCard').OwnerJobId)
			if DD.securityJobs[identifier] then
				assignText('security')
			elseif DD.medicalJobs[identifier] then
				assignText('medical')
			end
		end
	end
	if DD.isCharacterSecurity(character) then
		assignText('security')
	elseif DD.isCharacterMedical(character) then
		assignText('medical')
	end
	
	return text
end
-- override getNameColor. Name color is also used for color of text below name
GameMain = LuaUserData.CreateStatic('Barotrauma.GameMain')
GUIColor = LuaUserData.RegisterType('Barotrauma.GUIColor')
local guiCharacterInfoTextColorTable = {
	[''] = GUI.GUIStyle.TextColorNormal,
	neutral = GUI.GUIStyle.TextColorNormal,
	hostile = GUI.GUIStyle.Red,
	friendly = Color.SkyBlue,
	comrade = Color.SkyBlue,
	comradecultist = Color(160, 120, 200),
	target = GUI.GUIStyle.Yellow,
	cultist = Color(160, 120, 200),
	rebel = GUI.GUIStyle.Orange,
	wizard = Color(120, 200, 160),
	wanted = GUI.GUIStyle.Orange,
	bodyguard = Color.SkyBlue,
	protect = Color.SkyBlue,
	gangleader = GUI.GUIStyle.Orange,
	boss = Color.SkyBlue,
	subordinate = Color.SkyBlue,
	security = Color.Lerp(JobPrefab.Get('securityofficer').UIColor, GUI.GUIStyle.TextColorNormal, 0.25),
	medical = Color.Lerp(JobPrefab.Get('medicaldoctor').UIColor, GUI.GUIStyle.TextColorNormal, 0.25),
}
local guiCharacterInfoText = {}
local guiCharacterInfoColor = {}
Hook.Patch("Barotrauma.Character", "GetNameColor", function(instance, ptable)
	ptable.PreventExecution = true
	local color = guiCharacterInfoColor[instance] or GUI.GUIStyle.TextColorNormal
	ptable['ReturnValue'] = color
	return color
end, Hook.HookMethodType.Before)

-- main gui hook
local DefaultHudInfoHeight = 78
local hudInfoHeights = {}
Hook.Patch("Barotrauma.GUI", "Draw", function (instance, ptable)
	local spriteBatch = ptable["spriteBatch"]
	-- debug line
	if DD.debugMode then
		GUI.GUI.DrawLine(spriteBatch, Screen.Selected.Cam.WorldToScreen(DD.gui.debugLine.point1), Screen.Selected.Cam.WorldToScreen(DD.gui.debugLine.point2), Color.Red, 0, 1)
	end
	-- update hud info height
	for character in Character.CharacterList do
		local paddingBelowCeiling = 30.0;
		if hudInfoHeights[character] == nil then hudInfoHeights[character] = DefaultHudInfoHeight end
		if ((character.CurrentHull ~= nil) and (character.DrawPosition.Y + DefaultHudInfoHeight > character.CurrentHull.WorldRect.Y - paddingBelowCeiling)) then
			local lowerAmount = (character.DrawPosition.Y + DefaultHudInfoHeight) - (character.CurrentHull.WorldRect.Y - paddingBelowCeiling);
			hudInfoHeights[character] = DD.lerp(0.1, hudInfoHeights[character], DefaultHudInfoHeight - lowerAmount);
			hudInfoHeights[character] = math.max(hudInfoHeights[character], 20.0);
		else
			hudInfoHeights[character] = DD.lerp(0.1, hudInfoHeights[character], DefaultHudInfoHeight);
		end
	end
end)
local requestUpdateGUICharacterRoleCooldown = 60 * 5
local updateCharacterInfo = 0
Hook.Patch("Barotrauma.Character", "DrawFront", function (instance, ptable)
	-- send network request for character role information
	if Game.IsMultiplayer then
		if requestUpdateGUICharacterRoleCooldown > 0 then
			requestUpdateGUICharacterRoleCooldown = requestUpdateGUICharacterRoleCooldown - 1
		else
			local message = Networking.Start("requestUpdateGUICharacterRole")
			Networking.Send(message)
			requestUpdateGUICharacterRoleCooldown = 60 * 5
		end
	end
	-- update character name info
	if updateCharacterInfo > 0 then
		updateCharacterInfo = updateCharacterInfo - 1
	else
		updateCharacterInfo = 60
		
		for character in Character.CharacterList do
			local text = getInfoText(character) or ''
			if text == '' then
				guiCharacterInfoText[character] = ''
			else
				guiCharacterInfoText[character] = DD.stringLocalize('gui_' .. text)
			end
			guiCharacterInfoColor[character] = guiCharacterInfoTextColorTable[text]
		end
	end
	-- declare variables
	local character = instance
	local spriteBatch = ptable["spriteBatch"]
	local cam = ptable['cam']
	local screenSize = Vector2(GameMain.GraphicsWidth, GameMain.GraphicsHeight);
	local viewportSize = Vector2(cam.WorldView.Width, cam.WorldView.Height);
	if hudInfoHeights[character] == nil then hudInfoHeights[character] = DefaultHudInfoHeight end
	-- verify text should be rendered
	if GUI.DisableHUD or character.IsDead or (character.InvisibleTimer > 0) or (character.SpeciesName ~= 'human') and (character.SpeciesName ~= 'humanundead') or (cam.Zoom <= 0.4) then return end
	if Character.Controlled ~= nil then
		if (Character.Controlled.FocusedCharacter == character) or (Character.Controlled == character) then return end
		if (character.WorldPosition.X > cam.WorldView.X and character.WorldPosition.X < cam.WorldView.Right and
		character.WorldPosition.Y < cam.WorldView.Y and character.WorldPosition.Y > cam.WorldView.Y - cam.WorldView.Height) then
			if not Character.Controlled.CanSeeTarget(character) then return end
		else
			return
		end
		if Character.Controlled.Submarine then
			local yPos = Character.Controlled.AnimController.FloorY - 1.5
			if Character.Controlled.AnimController.Stairs ~= nil then
				yPos = Character.Controlled.AnimController.Stairs.SimPosition.Y - Character.Controlled.AnimController.Stairs.RectHeight * 0.5;
			end
			if character.AnimController.FloorY < yPos then return end
		end
	end
	-- get localized text and text color
	local text = guiCharacterInfoText[character] or ''
	if text == '' then return end
	local textColor = character.GetNameColor()
	-- get transparency
	local hoverRange = 300;
	local fadeOutRange = 200;
	local cursorDist = Vector2.Distance(character.WorldPosition, cam.ScreenToWorld(PlayerInput.MousePosition));
	local hudInfoAlpha = math.min(math.max((1.0 - (cursorDist - (hoverRange - fadeOutRange)) / fadeOutRange), 0.2), 1.0)
	-- get position
	local size = GUI.GUIStyle.Font.MeasureString(text)
	local pos = character.DrawPosition
	pos.Y = pos.Y + hudInfoHeights[character] + size.Y * 0.7 / cam.Zoom
	pos.Y = -pos.Y
	local textPos = Vector2(pos.X, pos.Y - 5.0 - (5.0 / cam.Zoom)) - size * 0.5 / cam.Zoom
	textPos.X = textPos.X - cam.WorldView.X
	textPos.Y = textPos.Y + cam.WorldView.Y
	textPos = textPos * screenSize / viewportSize
	textPos.X = math.floor(textPos.X)
	textPos.Y = math.floor(textPos.Y)
	textPos = textPos * viewportSize / screenSize
	textPos.X = textPos.X + cam.WorldView.X
	textPos.Y = textPos.Y - cam.WorldView.Y
	-- draw
	GUI.GUIStyle.Font.DrawString(spriteBatch, text, textPos + Vector2(1.0 / cam.Zoom, 1.0 / cam.Zoom), Color.Black, 0.0, Vector2.Zero, 1.0 / cam.Zoom, 0, 0.001)
	GUI.GUIStyle.Font.DrawString(spriteBatch, text, textPos, textColor * hudInfoAlpha, 0.0, Vector2.Zero, 1.0 / cam.Zoom, 0, 0.0)
end)