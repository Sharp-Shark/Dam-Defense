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
		related = {'main', 'events', 'jetJob', 'nukieshop1Item'},
	},
	serialKillerEvent = {
		related = {'main', 'events', 'murderEvent', 'creepymaskItem'},
	},
	revolutionEvent = {
		related = {'main', 'events', 'piratebodyarmorItem'},
	},
	bloodCultEvent = {
		related = {'main', 'events', 'the1998Item', 'sacrificialdaggerItem', 'bloodcultistrobesItem', 'cultistpitchforkItem', 'cultistshieldItem', 'cultistmaceItem', 'lifeessenceItem'},
	},
	deathSquadEvent = {
		related = {'main', 'events', 'mercsEvent', 'mercsevilJob', 'nexsuitItem', 'midazolamItem'},
	},
	greenskinsEvent = {
		related = {'main', 'events', 'greenskinCreature', 'goblinmaskItem', 'goblincrateItem', 'midazolamItem'},
	},
	-- side events
	airdropEvent = {
		related = {'main', 'events', 'faradayartifactItem', 'skyholderartifactItem', 'thermalartifactItem', 'psychosisartifactItem', 'nasonovartifactItem'},
	},
	fishEvent = {
		related = {'main', 'events', 'spitroachCreature', 'huskCreature'},
	},
	murderEvent = {
		related = {'main', 'events', 'arrestEvent', 'serialKillerEvent'},
	},
	arrestEvent = {
		related = {'main', 'events', 'murderEvent', 'handcuffsItem'},
	},
	afflictionEvent = {
		related = {'main', 'events', 'influenzainfectionAffliction', 'tbinfectionAffliction', 'anthraxinfectionAffliction'},
	},
	blackoutEvent = {
		related = {'main', 'events'},
	},
	vipEvent = {
		related = {'main', 'events', 'bodyguardJob', 'midazolamItem'},
		identifier = 'eventVIP',
	},
	wizardEvent = {
		related = {'main', 'events', 'wizardJob', 'merasmushatItem', 'merasmusrobesItem', 'merasmusstaffItem', 'merasmusfireballbookItem', 'merasmusteleportbookItem', 'merasmusblastjumpbookItem'},
	},
	gangEvent = {
		related = {'main', 'events', 'gangsterJob', 'methItem', 'uziItem', 'backwardscapItem', 'spraycanItem'},
	},
	mercsEvent = {
		related = {'main', 'events', 'deathSquadEvent', 'mercsJob', 'nexsuitItem', 'midazolamItem'},
		identifier = 'eventMERCS',
	},
	electionEvent = {
		related = {'main', 'events', 'ballotboxItem', 'captainJob', 'securityofficerJob', 'foremanJob', 'diverJob'},
	},
	withdrawEvent = {
		related = {'main', 'events', 'moneycaseItem', 'moneyItem'},
	},
	-- jobs
	captainJob = {
		related = {'main', 'jobs', 'electionEvent', 'captainspipeItem', 'pipetobaccoItem'},
		info = {isOverride = true},
	},
	diverJob = {
		related = {'main', 'jobs', 'electionEvent', 'divinghelmetItem'},
	},
	securityofficerJob = {
		related = {'main', 'jobs', 'electionEvent', 'constablehelmetItem'},
		info = {isOverride = true},
	},
	foremanJob = {
		related = {'main', 'jobs', 'electionEvent', 'hardhatheadItem'},
	},
	researcherJob = {
		related = {'main', 'jobs', 'bloodsamplerItem'},
	},
	medicaldoctorJob = {
		related = {'main', 'jobs', 'healgunItem', 'healgundrumItem'},
		info = {isOverride = true},
	},
	engineerJob = {
		related = {'main', 'jobs', 'hardhatItem', 'repairtoolItem'},
		info = {isOverride = true},
	},
	janitorJob = {
		related = {'main', 'jobs', 'hardhatjanitorItem', 'assistantclothesItem', 'flamerItem', 'trashbagItem'},
	},
	mechanicJob = {
		related = {'main', 'jobs'},
		info = {isOverride = true},
	},
	clownJob = {
		related = {'main', 'jobs', 'boombox5Item'},
	},
	assistantJob = {
		related = {'main', 'jobs'},
		info = {isOverride = true},
	},
	bodyguardJob = {
		related = {'main', 'jobs', 'vipEvent', 'midazolamItem'},
	},
	wizardJob = {
		related = {'main', 'jobs', 'wizardEvent', 'merasmushatItem', 'merasmusrobesItem', 'merasmusstaffItem', 'merasmusfireballbookItem', 'merasmusteleportbookItem', 'merasmusblastjumpbookItem'},
	},
	gangsterJob = {
		related = {'main', 'jobs', 'gangEvent', 'bosshatItem', 'bossclothesItem', 'methItem', 'uziItem', 'backwardscapItem', 'spraycanItem', 'captainspipeItem', 'pipetobaccoItem'},
	},
	jetJob = {
		related = {'main', 'jobs', 'nukiesEvent', 'jetmaskItem'},
	},
	mercsJob = {
		related = {'main', 'jobs', 'mercsevilJob', 'mercsEvent', 'nexsuitItem', 'midazolamItem'},
	},
	mercsevilJob = {
		related = {'main', 'jobs', 'mercsJob', 'deathSquadEvent', 'nexsuitItem', 'midazolamItem'},
	},
	-- items
	separatistrifleItem = {
		related = {'main', 'items', 'revolutionEvent', '762magazineItem'},
	},
	marksmanrifleItem = {
		related = {'main', 'items', 'revolutionEvent', '762magazineItem'},
	},
	['762magazineItem'] = {
		related = {'main', 'items', 'revolutionEvent', 'separatistrifleItem', 'marksmanrifleItem'},
	},
	brassknuckleItem = {
		related = {'main', 'items'},
	},
	portablegeneratorItem = {
		related = {'main', 'items'},
	},
	printerItem = {
		related = {'main', 'items', 'jobs', 'idcardItem'},
	},
	spraycanItem = {
		related = {'main', 'items', 'gangsterJob', 'gangEvent'},
		identifier = 'cyanspraycan',
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
		related = {'main', 'items', 'medicalSystem', 'bacterialsyringeItem', 'flusyringeItem', 'tbsyringeItem', 'bloodsamplerItem', 'gangsterJob', 'gangEvent'},
	},
	methItem = {
		related = {'main', 'items', 'medicalSystem', 'captainspipeItem', 'bloodsamplerItem', 'gangsterJob', 'gangEvent'},
		identifier = 'cyanmeth',
	},
	-- creatures
	spitroachCreature = {
		related = {'main', 'creatures', 'fishEvent'},
	},
	huskCreature = {
		related = {'main', 'creatures', 'fishEvent'},
		info = {isOverride = true},
	},
	greenskinCreature = {
		related = {'main', 'creatures', 'greenskinsEvent', 'goblinmaskItem', 'goblincrateItem', 'midazolamItem'},
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
		related = {'main', 'medicalSystem', 'airdropEvent', 'hazmatsuitItem', 'antiradItem', 'fuelrodItem', 'thoriumfuelrodItem', 'fulguriumfuelrodItem', 'fulguriumfuelrodvolatileItem', 'skyholderartifactItem'},
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

-- automatically add in pages for items in Dam Defense which don't have a manually created page
local autogenWhitelist = {
	weldingtoolItem = true,
}
local autogenBlacklist = {
	cyanspraycanItem = true,
	yellowspraycanItem = true,
	magentaspraycanItem = true,
	cyanmethItem = true,
	yellowmethItem = true,
	magentamethItem = true,
	outpostreactorItem = true,
	reactor1Item = true,
	fiberplantItem = true,
	elastinplantItem = true,
	aquaticpoppyItem = true,
	yeastshroomItem = true,
	slimebacteriaItem = true,
	barricadestaticItem = true,
	smgItem = true,
	smguniqueItem = true,
	nexshop2Item = true,
	nukieshop2Item = true,
}
local autogenRelated = {
	captainspipeItem = {'pipetobaccoItem'},
	assistantclothesItem = {'janitorJob', 'trashbagItem'},
	barricadeItem = {'repairtoolItem', 'weldingtoolItem'},
	flamerItem = {'janitorJob', 'corpseItem'},
	makeshiftflamerItem = {'janitorJob', 'corpseItem'},
	sacrificialdaggerItem = {'bloodCultEvent', 'lifeessenceItem'},
	foldablechairoxygeniteItem = {'foldablechairItem'},
	nukieshop1Item = {'fakemoneyItem'},
	fakemoneyItem = {'moneyItem'},
	nukieshop1Item = {'nukiesEvent'},
	secnexshopItem = {'captainJob', 'diverJob', 'securityofficerJob', 'foremanJob', 'mercsJob'},
}
local autogenRelations = {
	portablegeneratorItem = {'generatorfuel'},
	detonatorItem = {'explosive'},
	timeddetonatorItem = {'explosive'},
	extinguisherbracketItem = {'fireextinguisher'},
	ballotboxItem = {'money'},
	nexshop1Item = {'money'},
	moneycaseItem = {'money'},
}
for prefab in ItemPrefab.Prefabs do
	-- 3146664815 is the steamworkshopid of Dam Defense
	local pageName = tostring(prefab.Identifier) .. 'Item'
	if autogenWhitelist[pageName] or ((LuaUserData.TypeOf(prefab.ContentPackage) == 'Barotrauma.RegularPackage') and (prefab.ContentPackage.UgcId.StringRepresentation == '3146664815')
	and (DD.wikiData[pageName] == nil) and (not prefab.HideInMenus) and (prefab.Description ~= '') and (not autogenBlacklist[pageName])) then
		-- related
		local related = autogenRelated[pageName]
		if related == nil then related = {} end
		local categoryEnum = DD.numberToEnum(prefab.Category, DD.entityCategories)
		if categoryEnum.medical then
			table.insert(related, 1, 'medicalSystem')
		end
		table.insert(related, 1, 'items')
		table.insert(related, 1, 'main')
		-- get info
		local info = {isAutogen = true, hiddenInGame = true}
		if (prefab.ConfigElement.Parent ~= nil) and prefab.ConfigElement.Parent.IsOverride() then info.isOverride = true end
		-- add text to english localization
		if DD.localizations.english['wikiName_' .. pageName] == nil then
			DD.localizations.english['wikiName_' .. pageName] = tostring(prefab.Name)
		else
			info.isAutogen = nil
		end
		if DD.localizations.english['wikiText_' .. pageName] == nil then
			DD.localizations.english['wikiText_' .. pageName] = 'This page was automatically generated.'
		else
			info.isAutogen = nil
		end
		-- add page to wiki data
		DD.wikiData[pageName] = {identifier = tostring(prefab.Identifier), related = related, info = info}
	end
	if autogenWhitelist[pageName] or ((LuaUserData.TypeOf(prefab.ContentPackage) == 'Barotrauma.RegularPackage') and (prefab.ContentPackage.UgcId.StringRepresentation == '3146664815')
	and (not prefab.HideInMenus) and (prefab.Description ~= '') and (not autogenBlacklist[pageName])) then
		-- add ammunition to relations table
		local requiredItems = DD.elementGetByPath(prefab.ConfigElement, 'RangedWeapon.RequiredItems.Items')
		if requiredItems ~= nil then
			if autogenRelations[pageName] == nil then autogenRelations[pageName] = {} end
			for str in DD.stringSplit(requiredItems, ',') do
				table.insert(autogenRelations[pageName], str)
			end
		end
	end
end

-- add button to open browser wiki if CSharp is loaded
if DD.isCSharpLoaded then
	local tbl = {'openhtml'}
	for item in DD.wikiData.main.related do
		table.insert(tbl, item)
	end
	DD.wikiData.main.related = tbl
	
	DD.wikiData.serverMessage.related = {'openhtml', 'main'}
end

-- automatically adds an object's XML description to its wiki text
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

-- automatically links pages to their category page, if they have one
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
		if not DD.tableHas(DD.wikiData[key].related, 'items') then table.insert(DD.wikiData[key].related, 'items') end
		table.insert(DD.wikiData[key].parents, 'items')
		
		local identifier = DD.wikiData[key].identifier or DD.stringSplit(key, 'Item')[1]
		local prefab = ItemPrefab.GetItemPrefab(identifier)
		local tagsSet = {}
		for tag in prefab.Tags do
			tagsSet[tostring(tag)] = true
		end
		
		local categoryEnum = DD.numberToEnum(prefab.Category, DD.entityCategories)
		if categoryEnum.medical then
			table.insert(DD.wikiData.medicalSystem.related, key)
			table.insert(DD.wikiData[key].parents, 'medicalSystem')
		end
		
		-- relate to ammo
		for keyOther, value in pairs(autogenRelations) do
			if not DD.tableHas(DD.wikiData[key].related, keyOther) then
				for identifierOrTag in value do
					if identifier == identifierOrTag then
						table.insert(DD.wikiData[key].related, keyOther)
						break
					end
					for tag in prefab.Tags do
						if tagsSet[identifierOrTag] then
							table.insert(DD.wikiData[key].related, keyOther)
							break
						end
					end
				end
			end
		end
		-- get info
		for recipe in prefab.FabricationRecipes do
			if tostring(recipe.SuitableFabricatorIdentifiers[1]) == 'nexshop' then
				DD.wikiData[key].info.nexshopCost = recipe.RequiredItems[1].amount
				if not DD.tableHas(DD.wikiData['nexshop1Item'].related, key) then
					table.insert(DD.wikiData['nexshop1Item'].related, key)
				end
			elseif tostring(recipe.SuitableFabricatorIdentifiers[1]) == 'secnexshop' then
				DD.wikiData[key].info.secnexshopCost = recipe.RequiredItems[1].amount
				if not DD.tableHas(DD.wikiData['secnexshopItem'].related, key) then
					table.insert(DD.wikiData['secnexshopItem'].related, key)
				end
			elseif tostring(recipe.SuitableFabricatorIdentifiers[1]) == 'nukieshop' then
				DD.wikiData[key].info.nukieshopCost = recipe.RequiredItems[1].amount
				if not DD.tableHas(DD.wikiData['nukieshop1Item'].related, key) then
					table.insert(DD.wikiData['nukieshop1Item'].related, key)
				end
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