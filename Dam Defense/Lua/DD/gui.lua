if SERVER then return end

-- Wiki data
DD.wikiData = {
	-- main
	main = {
		related = {'events', 'jobs', 'items', 'creatures', 'medicalSystem', 'dams', 'credits'},
	},
	serverMessage = {
		related = {'main'}
	},
	events = {
		related = {'main'},
	},
	jobs = {
		related = {'main'},
	},
	items = {
		related = {'main'},
	},
	creatures = {
		related = {'main'},
	},
	medicalSystem = {
		related = {'main', 'radiation'},
	},
	dams = {
		related = {'main'},
	},
	credits = {
		related = {'main'},
	},
	placeholder = {
		related = {'main'},
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
	brassknuckleItem = {
		related = {'main', 'items'},
	},
	printerItem = {
		related = {'main', 'items', 'jobs'},
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

-- Called by "pageDropdown.OnSelected"
DD.loadPage = function (pageKey)
	local pageValue = DD.wikiData[pageKey]
	local pageValueName = DD.stringLocalize('wikiName_' .. pageKey) or ('wikiName_' .. pageKey)
	local pageValueText = DD.stringLocalize('wikiText_' .. pageKey) or ('wikiText_' .. pageKey)
	
	local newline = '    '
	local build = newline
	for count = 1, #pageValueText do
		build = build .. string.sub(pageValueText, count, count)
		if string.sub(build, #build, #build) == '\n' then
			build = build .. newline
		end
	end
	pageValueText = build
	
	-- change values
	pageTitle.Text = pageValueName
	pageBody.Text = pageValueText
	if (pageKey == 'serverMessage') and (Game.IsMultiplayer) then
		pageTitle.Text = Game.ServerSettings.ServerName
		pageBody.Text = Game.ServerSettings.ServerMessageText
	end
	if (pageKey == 'credits') and File.Exists(DD.path .. '/credits.txt') then
		pageBody.Text = File.Read(DD.path .. '/credits.txt')
	end
	
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
				setButtonColor(button, Color.Lerp(defaultButtonColor, Color.White, 0.5))
			end
			if value == 'openhtml' then		
				button.OnClicked = function ()
					if DD.isCSharpLoaded then
						DD.openHTML(true)
					else
						DD.loadPage(value)
					end
				end
				setButtonColor(button, Color(100, 255, 255))
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