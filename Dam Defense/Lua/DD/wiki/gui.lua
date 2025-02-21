if SERVER then return end

-- Wiki data
DD.wikiData = {
	-- main
	main = {
		related = {'events', 'jobs', 'items', 'medicalSystem', 'creatures', 'dams', 'credits'},
		hidden = true,
	},
	serverMessage = {
		related = {'main'},
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
		related = {'main', 'events', 'murderEvent'},
	},
	revolutionEvent = {
		related = {'main', 'events', 'airdropEvent'},
	},
	gangWarEvent = {
		related = {'main', 'events', 'bloodsamplerItem'},
	},
	bloodCultEvent = {
		related = {'main', 'events', 'airdropEvent'},
	},
	deathSquadEvent = {
		related = {'main', 'events', 'mercsEvent', 'mercsevilJob', 'midazolamItem'},
	},
	greenskinsEvent = {
		related = {'main', 'events', 'greenskinCreature', 'midazolamItem'},
	},
	-- side events
	airdropEvent = {
		related = {'main', 'events', 'revolutionEvent', 'bloodCultEvent', 'radiation'},
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
	},
	mercsEvent = {
		related = {'main', 'events', 'deathSquadEvent', 'mercsJob', 'midazolamItem'},
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
	brassknuckleItem = {
		related = {'main', 'items'},
	},
	printerItem = {
		related = {'main', 'items', 'jobs'},
	},
	bacterialsyringeItem = {
		related = {'main', 'items', 'medicalSystem', 'bacterialinfectionAffliction'},
	},
	flusyringeItem = {
		related = {'main', 'items', 'medicalSystem', 'fluantidoteItem', 'influenzainfectionAffliction'},
	},
	tbsyringeItem = {
		related = {'main', 'items', 'medicalSystem', 'tbantidoteItem', 'tbinfectionAffliction'},
	},
	fluantidoteItem = {
		related = {'main', 'items', 'medicalSystem', 'flusyringeItem', 'influenzainfectionAffliction'},
	},
	tbantidoteItem = {
		related = {'main', 'items', 'medicalSystem', 'tbsyringeItem', 'tbinfectionAffliction'},
	},
	midazolamItem = {
		related = {'main', 'items', 'medicalSystem', 'deathSquadEvent', 'greenskinsEvent', 'vipEvent', 'mercsEvent', 'bodyguardJob', 'mercsJob', 'mercsevilJob'},
	},
	myxotoxinItem = {
		related = {'main', 'items', 'medicalSystem', 'bacterialinfectionAffliction', 'tbinfectionAffliction'},
	},
	bloodsamplerItem = {
		related = {'main', 'items', 'medicalSystem', 'bacterialsyringeItem', 'flusyringeItem', 'tbsyringeItem', 'gangWarEvent'},
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
	-- misc
	radiation = {
		parents = {'medicalSystem'},
		related = {'main', 'medicalSystem', 'airdropEvent'},
	},
	-- dams (maps)
	oldeTowneDam = {
		related = {'main', 'dams'},
	},
	pioneerPointDam = {
		related = {'main', 'dams'},
	},
}
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
			local description
			local identifier
			if string.sub(key, #key - 2, #key) == 'Job' then
				identifier = DD.stringSplit(DD.stringSplit(key, '_')[2], 'Job')[1]
				description = tostring(JobPrefab.Get(identifier).Description)
			elseif string.sub(key, #key - 3, #key) == 'Item' then
				identifier = DD.stringSplit(DD.stringSplit(key, '_')[2], 'Item')[1]
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
	
	-- automatically link pages to their parent page
	if key ~= 'main' then
		table.insert(DD.wikiData[key].parents, 'main')
	end
	if string.sub(key, #key - 4, #key) == 'Event' then
		table.insert(DD.wikiData.events.related, key)
		table.insert(DD.wikiData[key].parents, 'events')
	elseif string.sub(key, #key - 2, #key) == 'Job' then
		table.insert(DD.wikiData.jobs.related, key)
		table.insert(DD.wikiData[key].parents, 'jobs')
	elseif string.sub(key, #key - 3, #key) == 'Item' then
		table.insert(DD.wikiData.items.related, key)
		table.insert(DD.wikiData[key].parents, 'items')
		local identifier = DD.stringSplit(key, 'Item')[1]
		if DD.numberToEnum(ItemPrefab.GetItemPrefab(identifier).Category)[3] then
			table.insert(DD.wikiData.medicalSystem.related, key)
			table.insert(DD.wikiData[key].parents, 'medicalSystem')
		end
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
	
	-- any page that links to medicalSystem will have the medicalSystem page link to it
	if DD.tableHas(value.related, 'medicalSystem') and not DD.tableHas(DD.wikiData.medicalSystem.related, key) then
		table.insert(DD.wikiData.medicalSystem.related, key)
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
	
	if (pageValue.related == nil) or (#pageValue.related == 0) then return end
	
	local count = 1
	local itemsPerRow = 4
	for rowIndex = 1, math.ceil(#pageValue.related / itemsPerRow) do
		local pageRow = GUI.LayoutGroup(GUI.RectTransform(Vector2(1, 0.15 / 0.75 / (1 - k) * 0.2625), pageRelated.Content.RectTransform), nil)
		pageRow.isHorizontal = true
		local items = DD.arrSub(pageValue.related, count, count + itemsPerRow - 1)
		count = count + itemsPerRow
		for value in items do
			local button = GUI.Button(GUI.RectTransform(Vector2(1 / 4, 0.05), pageRow.RectTransform), DD.stringLocalize('wikiName_' .. value), GUI.Alignment.Center, "GUITextBox")
			if DD.tableHas(pageValue.parents, value) then
				setButtonColor(button, Color.Lerp(defaultButtonColor, Color.White, 0.65))
			end
			if value == 'openhtml' then		
				button.OnClicked = function ()
					DD.generateWikiHTML()
					if DD.isCSharpLoaded then
						DD.openHTML(true)
					else
						DD.loadPage(value)
					end
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
	local mainPath = DD.path .. '/Lua/DD/wiki/main.html'
	local segmentPath = DD.path .. '/Lua/DD/wiki/segment.html'
	if not File.Exists(mainPath) then DD.warn('File needed for HTML wiki creation was not found in ' .. mainPath) return end
	if not File.Exists(segmentPath) then DD.warn('File needed for HTML wiki creation was not found in ' .. segmentPath) return end
	local main = File.Read(mainPath)
	local segment = File.Read(segmentPath)
	
	-- anchor
	local anchor = '<a href="#{key}" style="{style}">{text}</a>'
	
	-- adds a wiki entry to the HTML page
	local generatePage = function (key)
		local value = DD.wikiData[key]
		if not value.hidden then
			local tbl = getPageFields(key)
			-- key (technical)
			tbl.key = key
			-- name
			if DD.wikiData[key].category ~= nil then
				tbl.name = DD.stringReplace('{name} ({category})', {name = tbl.name, category = getPageFields(DD.wikiData[key].category).name})
			end
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
				tbl.nameStyle = 'background-color:' .. DD.colorToHex(Color.Lerp(JobPrefab.Get(job).UIColor, Color.Black, 0.25)) .. ';'
			end
			-- text (wiki entry body)
			tbl.text = '&nbsp;&nbsp;' .. string.gsub(tbl.text, '\n', '<br>&nbsp;&nbsp;')
			-- related (links)
			tbl.related = ''
			local joinString = ' '
			for related in value.related do
				if related ~= 'openhtml' then
					local style = 'margin:8px;'
					if DD.tableHas(value.parents, related) then
						style = style .. "color:black;background-color:mediumslateblue;padding:1px;"
					end
					tbl.related = tbl.related .. DD.stringReplace(anchor, {key = related, style = style, text = getPageFields(related).name})
				end
			end
			-- prepare for next wiki entry
			tbl.segment = '{segment}'
			-- apply
			local text = string.gsub(DD.stringReplace(segment, tbl), '%%', '%%%%')
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
	File.Write(DD.saving.folderPath .. 'main.html', main)
end