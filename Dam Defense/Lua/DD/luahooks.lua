if CLIENT and Game.IsMultiplayer then return end

-- blood sampler
Hook.Add("DD.bloodsampler.bloodsample", "DD.bloodsampler.bloodsample", function(effect, deltaTime, item, targets, worldPosition)
	local user = item.ParentInventory
	if user == nil then return end
	user = user.Owner
	local userClient = DD.findClientByCharacter(user)
	
	if targets[1] == nil then return end
	local character = targets[1]
	local client = DD.findClientByCharacter(character)
	
	-- item has been used and thus will be deleted
	Entity.Spawner.AddEntityToRemoveQueue(item)
	
	local speciesName = string.lower(tostring(character.SpeciesName))
	if speciesName ~= 'human' then
		if DD.isCharacterHusk(character) then
			local inventory = item.ParentInventory
			Entity.Spawner.AddEntityToRemoveQueue(item)
			Entity.Spawner.AddItemToSpawnQueue(ItemPrefab.GetItemPrefab('huskeggs'), inventory, nil, nil, function (spawnedItem) end)
		end
		return
	end
	
	local characterInfection = character.CharacterHealth.GetAfflictionStrengthByType('infection', true)
	local characterHusk = character.CharacterHealth.GetAfflictionStrengthByIdentifier('huskinfection', true)
	if characterHusk < 35 then characterHusk = 0 end
	
	local getCharacterInfection = function (character, diseaseName)
		local total = 0
		total = total + character.CharacterHealth.GetAfflictionStrengthByIdentifier(diseaseName .. 'payload', true)
		total = total + character.CharacterHealth.GetAfflictionStrengthByIdentifier(diseaseName .. 'infection', true)
		return total
	end
	
	local inventory = item.ParentInventory
	
	local testResults = {['Crystal meth'] = false, ['Husk infection'] = false}
	for event in DD.eventDirector.events do
		if event.name == 'gangWar' then
			if event.gang1Set[client] or event.gang2Set[client] then
				testResults['Crystal meth'] = true
			end
		end
	end
	if character.CharacterHealth.GetAfflictionStrengthByIdentifier('huskinfection', true) > 0 then
		testResults['Husk infection'] = true
	end
	
	local characterInfections = {}
	characterInfections.husk = character.CharacterHealth.GetAfflictionStrengthByIdentifier('huskinfection', true)
	for diseaseName, data in pairs(DD.diseaseData) do
		characterInfections[diseaseName] = getCharacterInfection(character, diseaseName)
		if characterInfections[diseaseName] > 0 then
			testResults[diseaseName .. ' infection'] = true
		else
			testResults[DD.diseaseData[diseaseName].displayName .. ' infection'] = false
		end
	end
	
	local winnerName = ''
	local winnerStrength = 0
	for infectionName, infectionStrength in pairs(characterInfections) do
		if infectionStrength > winnerStrength then
			winnerName = infectionName
			winnerStrength = infectionStrength
		end
	end
	
	if userClient ~= nil then
		local text = ''
		for name, value in pairs(testResults) do
			local bool = value
			if not DD.isCharacterMedical(user) then
				bool = DD.xor(bool, math.random() < 1/3)
			end
			if bool then
				text = text .. name .. ': ' .. 'positive. '
			end
		end
		text = string.sub(text, 1, #text - 1)
		if text == '' then text = 'Negative on all tests.' end
		DD.messageClient(userClient, text, {preset = 'bloodsample'})
	end
	
	if winnerName == '' then return end
	local itemIdentifier = winnerName .. 'syringe'
	if winnerName == 'husk' then itemIdentifier = 'huskeggs' end
	
	if characterInfection + characterHusk <= 0 then return end
	Entity.Spawner.AddItemToSpawnQueue(ItemPrefab.GetItemPrefab(itemIdentifier), inventory, nil, nil, function (spawnedItem) end)
end)

-- attaches generator to wall
Hook.Add("DD.portablegenerator.attach", "DD.portablegenerator.attach", function(effect, deltaTime, item, targets, worldPosition)
	item.GetComponentString('Holdable').AttachToWall()
end)

-- changes the job of an idcard or clothing
Hook.Add("DD.idcardprinter.apply", "DD.idcardprinter.apply", function(effect, deltaTime, item, targets, worldPosition)
	local containedItem = targets[1]
	if (containedItem == nil) or ((containedItem.Prefab.Identifier ~= 'idcard') and (not containedItem.HasTag('clothing'))) then return end
	local tags = item.tags
	if (tags == nil) or (#DD.stringSplit(tostring(tags), ',') < 2) then return end
	tags = tostring(tags)
	
	-- get needed data from printer tags
	local characterName
	local identifier
	for tag in DD.stringSplit(tostring(tags), ',') do
		if string.sub(tag, 1, 5) == 'name:' then
			characterName = string.sub(tag, 6, #tag)
		elseif tag ~= 'light' then
			identifier = DD.tableJoin(DD.stringSplit(string.lower(tag), ' '))
		end
	end
	
	-- special case scenario for renaming ID card without changing the job
	if identifier == nil then
		if containedItem.Prefab.Identifier == 'idcard' then
			local tags = ''
			for tag in DD.stringSplit(containedItem.Tags, ',') do
				if string.sub(tag, 1, 5) ~= 'name:' then
					tags = tags .. tag .. ','
				end
			end
			containedItem.tags = tags .. 'name:' .. characterName
			-- Sync changes for clients
			if SERVER then
				local item = containedItem
				local tags = item.SerializableProperties[Identifier("Tags")]
				Networking.CreateEntityEvent(item, Item.ChangePropertyEventData(tags, item))
			end
		end
		return
	end
	
	-- custom cards that do not have a job related to them
	local customCards = {
		shop = {
			name = 'Shopkeeper',
			tags = 'id_shop,id_laborer',
			clothing = {'commonerclothes1'},
			color = Color(55, 155, 0),
			trueColor = true,
			shortcuts = {
				'shop',
				'shopowner',
				'shopkeep',
				'shopkeeper',
				'store',
				'storeowner',
				'storekeep',
				'storekeeper',
				'vendor',
				'merchant',
				'retailer',
				'trader',
				'clerk',
				'seller',
			}
		},
		miner = {
			name = 'Miner',
			tags = 'id_miner,id_laborer',
			clothing = {'minerclothes'},
			color = Color(100, 10, 24),
			shortcuts = {
				'miner',
			}
		},
		vip = {
			clothing = {'vipclothes1', 'vipclothes2', 'vipclothes3'},
			clothingOnly = true,
			shortcuts = {
				'vip',
			}
		},
		admin = {
			clothing = {'administratorclothes'},
			clothingOnly = true,
			shortcuts = {
				'administrator',
				'admin',
				'nazi',
			}
		},
		cultist = {
			clothing = {'faultycultistrobes'},
			clothingOnly = true,
			shortcuts = {
				'huskcultist',
				'cultist',
				'cultie',
				'cult',
				'zealot',
				'husk',
			}
		},
	}
	local customCard
	for key, value in pairs(customCards) do
		if DD.tableHas(value.shortcuts, identifier) then
			customCard = value
		end
	end
	
	-- alternative names for jobs
	local shortcuts = {
		-- mayor
		mayor = 'captain',
		cap = 'captain',
		-- diver
		div = 'diver',
		-- foreman
		headengineer = 'foreman',
		headengi = 'foreman',
		headeng = 'foreman',
		chiefengineer = 'foreman',
		chiefengi = 'foreman',
		chiefeng = 'foreman',
		-- researcher
		res = 'researcher',
		scientist = 'researcher',
		sci = 'researcher',
		-- medical doctor
		doctor = 'medicaldoctor',
		doc = 'medicaldoctor',
		medic = 'medicaldoctor',
		med = 'medicaldoctor',
		-- security officer
		enforcer = 'securityofficer',
		security = 'securityofficer',
		officer = 'securityofficer',
		sec = 'securityofficer',
		cop = 'securityofficer',
		police = 'securityofficer',
		-- engineer
		engi = 'engineer',
		eng = 'engineer',
		-- janitor
		jani = 'janitor',
		jan = 'janitor',
		-- bodyguard
		guard = 'bodyguard',
		goon = 'bodyguard',
		bouncer = 'bodyguard',
		bg = 'bodyguard',
		-- mechanic
		laborer = 'mechanic',
		labor = 'mechanic',
		labo = 'mechanic',
		lab = 'mechanic',
		mech = 'mechanic',
		mec = 'mechanic',
		worker = 'mechanic',
		work = 'mechanic',
		-- convict
		convict = 'assistant',
		prisoner = 'assistant',
		inmate = 'assistant',
		-- mercs
		merc = 'mercs',
		-- mercs evil
		mercevil = 'mercsevil',
		deathsquad = 'mercsevil',
	}
	if (shortcuts[identifier] ~= nil) and (customCard == nil) then identifier = shortcuts[identifier] end
	
	-- handle containedItem possibly being clothing
	local idcard
	if containedItem.Prefab.Identifier ~= 'idcard' then
		if customCard then
			if customCard.clothing == nil then return end
			identifier = customCard.clothing[math.random(#customCard.clothing)]
		else
			local waypoint = DD.findRandomWaypointByJob(identifier)
			if waypoint == nil then return end
			
			local jobPrefab = JobPrefab.Get(identifier)
			local itemSet = jobPrefab.JobItems[math.random(0, #jobPrefab.JobItems)]
			
			for value in itemSet do
				if value.Outfit then
					identifier = value.ItemIdentifier
					break
				end
			end
		end
		
		if containedItem.OwnInventory ~= nil then
			for slot = 0, containedItem.OwnInventory.Capacity do
				local count = 99
				while containedItem.OwnInventory.GetItemAt(slot) ~= nil do
					containedItem.OwnInventory.GetItemAt(slot).Drop()
					-- safety agaisnt infinite looping
					count = count - 1
					if count <= 0 then break end
				end
			end
		end
		
		Entity.Spawner.AddEntityToRemoveQueue(containedItem)
		Timer.Wait(function ()
			Entity.Spawner.AddItemToSpawnQueue(ItemPrefab.GetItemPrefab(identifier), item.OwnInventory, nil, nil, function (spawnedItem) end)
		end, 1)
		
		return
	else
		idcard = containedItem
	end
	
	-- get character name from ID card
	if characterName == nil then
		for tag in DD.stringSplit(idcard.Tags, ',') do
			if string.sub(tag, 1, 5) == 'name:' then
				characterName = string.sub(tag, 6, #tag)
				break
			end
		end
		characterName = characterName or CharacterInfo('human', 'John Doe').GetRandomName(1)
	end
	
	-- give idcard tags
	local jobPrefab
	if customCard == nil then
		-- find a spawnpoint to see what idcard tags are associated with the job
		local waypoint = DD.findRandomWaypointByJob(identifier)
		if waypoint == nil then return end
		idcard.tags = DD.tableJoin(waypoint.IdCardTags, ',')
		jobPrefab = JobPrefab.Get(waypoint.AssignedJob.Identifier)
	else
		if customCard.clothingOnly then return end
		idcard.tags = customCard.tags
	end
	
	-- Set the idcard's color to be the job's UIColor
	local color = jobPrefab and jobPrefab.UIColor or customCard.color
	if (customCard == nil) or (not customCard.trueColor) then color = Color.Lerp(color, Color.White, 0.25) end
	idcard.SpriteColor = color
	idcard['set_InventoryIconColor'](color)
	
	-- Set the name and jobid tags
	idcard.tags = idcard.tags .. ',name:' .. characterName .. ',jobid:' .. identifier
			
	-- Sync changes for clients
	if SERVER then
		local item = idcard
		local tags = item.SerializableProperties[Identifier("Tags")]
		Networking.CreateEntityEvent(item, Item.ChangePropertyEventData(tags, item))
		local sprcolor = item.SerializableProperties[Identifier("SpriteColor")]
		Networking.CreateEntityEvent(item, Item.ChangePropertyEventData(sprcolor, item))
		local invColor = item.SerializableProperties[Identifier("InventoryIconColor")]
		Networking.CreateEntityEvent(item, Item.ChangePropertyEventData(invColor, item))
	end
end)

-- deletes raw material to create an idcard/clothing
Hook.Add("DD.idcardprinter.create", "DD.idcardprinter.create", function(effect, deltaTime, item, targets, worldPosition)
	local containedItem = targets[1]
	if containedItem == nil then return end
	
	local identifier
	if containedItem.Prefab.Identifier == 'plastic' then
		identifier = 'idcard'
	elseif containedItem.Prefab.Identifier == 'organicfiber' then
		identifier = 'commonerclothes2'
	end
	if identifier == nil then return end
	
	Entity.Spawner.AddEntityToRemoveQueue(containedItem)
	Timer.Wait(function ()
		Entity.Spawner.AddItemToSpawnQueue(ItemPrefab.GetItemPrefab(identifier), item.OwnInventory, nil, nil, function (spawnedItem) end)
	end, 1)
end)

-- deletes idcard/clothing to create raw material
Hook.Add("DD.idcardprinter.delete", "DD.idcardprinter.delete", function(effect, deltaTime, item, targets, worldPosition)
	local containedItem = targets[1]
	if containedItem == nil then return end
	
	local identifier
	if containedItem.Prefab.Identifier == 'idcard' then
		identifier = 'plastic'
	elseif containedItem.HasTag('clothing') then
		identifier = 'organicfiber'
	end
	if identifier == nil then return end
	
	if containedItem.OwnInventory ~= nil then
		for slot = 0, containedItem.OwnInventory.Capacity do
			local count = 99
			while containedItem.OwnInventory.GetItemAt(slot) ~= nil do
				containedItem.OwnInventory.GetItemAt(slot).Drop()
				-- safety agaisnt infinite looping
				count = count - 1
				if count <= 0 then break end
			end
		end
	end
	
	Entity.Spawner.AddEntityToRemoveQueue(containedItem)
	Timer.Wait(function ()
		Entity.Spawner.AddItemToSpawnQueue(ItemPrefab.GetItemPrefab(identifier), item.OwnInventory, nil, nil, function (spawnedItem) end)
	end, 1)
end)

-- wifi trigger
Hook.Add("DD.wifitrigger.use", "DD.wifitrigger.use", function(effect, deltaTime, item, targets, worldPosition)
	component = item.GetComponentString('WifiComponent').TransmitSignal(Signal('true'), false)
end)

-- whaling gun uses powder when fired
Hook.Add("DD.whalinggun.use", "DD.whalinggun.use", function(effect, deltaTime, item, targets, worldPosition)
	local powder = targets[#targets]
	if powder.HasTag('whalinggunpowder') or powder.HasTag('munition_propulsion') then
		powder.Condition = powder.Condition - 50
	end
end)

-- some armor absorbs damage, but in return, will break down
Hook.Patch("Barotrauma.Character", "ApplyAttack", function(instance, ptable)
    local character = instance
	local hitLimb = ptable['targetLimb']
	if hitLimb == nil then return end
	local afflictions = ptable['attack'].Afflictions
	local penetration = ptable['penetration']
	local multiplier = 1.0
	
    if character.Inventory == nil then return end
    local armor
	if hitLimb.type == LimbType.Head then
		armor = character.Inventory.GetItemAt(DD.invSlots.head)
		multiplier = 2.0
	else
		armor = character.Inventory.GetItemAt(DD.invSlots.suit)
	end
	if armor == nil then return end
	local set = {
		ironhelmet = true,
		makeshiftarmor = true,
	}
	if not set[tostring(armor.Prefab.Identifier)] then return end

    local damage = 0

    for affliction, value in pairs(afflictions) do
		if affliction.Identifier == 'gunshotwound' then
			damage = damage + affliction.Strength * (1 - penetration) * multiplier
		end
    end

    armor.Condition = armor.Condition - damage

    if armor.Condition <= 0 then
        Entity.Spawner.AddEntityToRemoveQueue(armor)
    end
end, Hook.HookMethodType.Before)

-- toggles repairtool between wrench and screwdriver mode
Hook.Add("DD.repairtool.toggle", "DD.repairtool.toggle", function(effect, deltaTime, item, targets, worldPosition)
	if item == nil then return end
	if item.HasTag('wrench') then
		local tags = ''
		for tag in item.GetTags() do
			if tag ~= 'wrench' then tags = tags .. ',' .. tostring(tag) end
		end
		tags = tags .. ',screwdriver'
		item.Tags = tags
	else
		local tags = ''
		for tag in item.GetTags() do
			if tag ~= 'screwdriver' then tags = tags .. ',' .. tostring(tag) end
		end
		tags = tags .. ',wrench'
		item.Tags = tags
	end
	if SERVER then
		local tags = item.SerializableProperties[Identifier("Tags")]
		Networking.CreateEntityEvent(item, Item.ChangePropertyEventData(tags, item))
	end
end)

-- fistful of frags
Hook.Add("DD.brassknuckle.disarm", "DD.brassknuckle.disarm", function(effect, deltaTime, item, targets, worldPosition)
	local character = item
	local limb = targets[1]
	local limbSlot
	if limb.type == LimbType.LeftHand then
		limbSlot = InvSlotType.LeftHand
	elseif limb.type == LimbType.RightHand then
		limbSlot = InvSlotType.RightHand
	else
		return
	end
	local item = character.Inventory.GetItemInLimbSlot(limbSlot)
	if item == nil then return end
	if item.Prefab.Identifier == 'brassknuckle' then return end
	item.Drop(character, true, true)
end)

-- more intense and better blast jumping
Hook.Add("DD.jumpergrenade.blastjump", "DD.jumpergrenade.blastjump", function(effect, deltaTime, item, targets, worldPosition)
	local character = effect.user
	local vector = Vector2.Normalize(character.WorldPosition - item.WorldPosition)
	local distance = Vector2.Distance(character.WorldPosition, item.WorldPosition)
	local scaler = 5000 / math.max(1, distance - 300)
	character.AnimController.MainLimb.body.ApplyForce(vector * scaler)
end)

-- displacer cannon teleport
Hook.Add("DD.displacercannon.teleport", "DD.displacercannon.teleport", function(effect, deltaTime, item, targets, worldPosition)
	local item = targets[1]
	effect.user.TeleportTo(item.WorldPosition)
end)

-- displacer cannon light component responds to item condition
Hook.Add("DD.displacercannon.update", "DD.displacercannon.teleport", function(effect, deltaTime, item, targets, worldPosition)
	local lerpFactor = (item.Condition / 100) ^ 2
	item.GetComponentString('LightComponent').LightColor = Color(Byte(70), Byte(200), Byte(250), Byte(DD.lerp(lerpFactor, 0, 255)))
	item.GetComponentString('LightComponent').Range = DD.lerp(lerpFactor, 0, 80)
	if SERVER then
		local prop = item.GetComponentString('LightComponent').SerializableProperties[Identifier("LightColor")]
		Networking.CreateEntityEvent(item, Item.ChangePropertyEventData(prop, item.GetComponentString('LightComponent')))
		local prop = item.GetComponentString('LightComponent').SerializableProperties[Identifier("Range")]
		Networking.CreateEntityEvent(item, Item.ChangePropertyEventData(prop, item.GetComponentString('LightComponent')))
	end
end)

-- spraycan pepperspray
Hook.Add("DD.spraycan.use", "DD.spraycan.use", function(effect, deltaTime, item, targets, worldPosition)
	local limb = targets[1]
	if limb == nil then return end
	
	local character = limb.character
	if limb.type == LimbType.Head then
		local afflictionIdentifier = DD.stringSplit(tostring(item.Prefab.Identifier), 'spraycan')[1] .. 'paint'
		DD.giveAfflictionCharacter(character, afflictionIdentifier, 0.5 * deltaTime, limb)
		if character.CharacterHealth.GetAfflictionStrengthByIdentifier('airborneprotection', true) < 1 then
			DD.giveAfflictionCharacter(character, 'noxiousspray', 0.5 * deltaTime, limb)
		end
	end
end)

-- smoking crystal meth makes user join the respective gang
Hook.Add("DD.meth.use", "DD.meth.use", function(effect, deltaTime, item, targets, worldPosition)
	if item.ParentInventory == nil then return end
	local pipe = item.ParentInventory.Owner
	if pipe.ParentInventory == nil then return end
	local character = pipe.ParentInventory.Owner
	local client = DD.findClientByCharacter(character)
	if client == nil then return end
	
	if (character.SpeciesName ~= 'human') or DD.isCharacterSecurity(character) then return end
	
	local color = DD.stringSplit(tostring(item.Prefab.Identifier), 'meth')[1]
	
	for event in DD.eventDirector.events do
		if event.name == 'gangWar' then
			local gangNumber
			if event.gang1Color == color then
				event.addClientToGang(client, event.gang1)
			elseif event.gang2Color == color then
				event.addClientToGang(client, event.gang2)
			end
		end
	end
end)

-- blood cult enlightened
Hook.Add("DD.enlightened.givetalent", "DD.enlightened.givetalent", function(effect, deltaTime, item, targets, worldPosition)
    local character = targets[1]
	if character == nil then return end
	
	-- talent
	if character.HasTalent('enlightenedmind') then return end
    character.GiveTalent('enlightenedmind', true)
	
	-- play tchernobog sfx and flashes a image 1 second after player transforms
	Timer.Wait(function ()
		DD.giveAfflictionCharacter(character, 'enlightenedfx', 999)
	end, 1000)
	
	-- resets the time pressure for all cultists
	for character in Character.CharacterList do
		if character.CharacterHealth.GetAfflictionStrengthByIdentifier('enlightened', true) >= 99 then
			if character.CharacterHealth.GetAffliction('timepressure', true) ~= nil then
				character.CharacterHealth.GetAffliction('timepressure', true).SetStrength(0)
			end
		end
	end
	
	-- return
	if character.SpeciesName == 'humanundead' then
		DD.messageClient(client, DD.stringLocalize('undeadInfo'))
		return
	end
	
	-- pop-up
	local client = DD.findClientByCharacter(character)
	if client == nil then return end
	DD.messageClient(client, 'Your mind has been enlightened! Work with fellow blood cultists to enlighten others. Your objective is to have no non-cultist alive. You can convert others using "The 1998". You can extract "Life Essence" from the unconcious or the recently deceased using a "Sacrificial Dagger". Conversion and consuming "Life Essence" both lower your "Time Pressure". You can also craft a "Blood Cultist Robe" which heals, cures diseases and can bring you back from the dead. Long live Tchernobog! Do /cultists to get a list of fellow worshippers and /whisper to message them all.', {preset = 'crit'})

	-- notify other cultists
	for otherClient in Client.ClientList do
		if (client ~= otherClient) and DD.isClientCharacterAlive(otherClient) and (otherClient.Character.SpeciesName == 'human') and (otherClient.Character.CharacterHealth.GetAfflictionStrengthByIdentifier('enlightened') > 99) then
			DD.messageClient(otherClient, DD.stringLocalize('bloodCultRecruitmentNotice', {name = client.Name}), {preset = 'goodinfo'})
		end
	end
end)

-- blood cult sacrificial dagger
Hook.Add("DD.sacrificialdagger.sacrifice", "DD.sacrificialdagger.sacrifice", function(effect, deltaTime, item, targets, worldPosition)
    if CLIENT and Game.IsMultiplayer then return end
	
	if targets[1] == nil then return end
	local character = targets[1]
	
	if character.SpeciesName == 'humanUndead' then return end
	if character.Vitality > 0 then return end
	if character.CharacterHealth.GetAfflictionStrengthByIdentifier('cardiacarrest', true) >= 1 then return end
	
	local inventory = item.ParentInventory
	if (inventory.Owner == nil) or (inventory.Owner.CharacterHealth.GetAfflictionStrengthByIdentifier('enlightened', true) < 99) then return end
	
	DD.giveAfflictionCharacter(character, 'cardiacarrest', 999)
	if SERVER then
		Networking.CreateEntityEvent(character, Character.CharacterStatusEventData.__new(true))
	end
	if inventory.Owner.SpeciesName == 'humanundead' then
		Entity.Spawner.AddItemToSpawnQueue(ItemPrefab.GetItemPrefab('lifeessence'), inventory.Owner.WorldPosition, nil, nil, function (spawnedItem) end)
	else
		Entity.Spawner.AddItemToSpawnQueue(ItemPrefab.GetItemPrefab('lifeessence'), inventory, nil, nil, function (spawnedItem) end)
	end
end)

-- When a cultist dies, he will come back as a zombie
DD.characterDeathFunctions.cultistDeath = function (character)
	if character.SpeciesName ~= 'human' then return end
	if character.CharacterHealth.GetAfflictionStrengthByIdentifier('timepressure', true) >= 59 then return end
	if character.CharacterHealth.GetAfflictionStrengthByIdentifier('enlightened', true) < 99 then return end
	if (character.Inventory.GetItemAt(DD.invSlots.innerclothing) == nil) or (tostring(character.Inventory.GetItemAt(DD.invSlots.innerclothing).Prefab.Identifier.Value) ~= 'bloodcultistrobes') then return end
	local client = DD.findClientByCharacter(character)
	
	-- Find items to be regiven (clothing, ID Card, etc)
	local slotItems = {}
	for itemCount = 0, character.Inventory.Capacity do
		local item = character.Inventory.GetItemAt(itemCount)
		if (item ~= nil) and (itemCount ~= DD.invSlots.lefthand) and (itemCount ~= DD.invSlots.righthand) and (tostring(item.Prefab.Identifier.Value) ~= 'handcuffs') and (tostring(item.Prefab.Identifier.Value) ~= 'bodybag') then
			slotItems[itemCount] = item
		end
		if (item ~= nil) and ((itemCount == DD.invSlots.lefthand) or (itemCount == DD.invSlots.righthand)) then
			item.Drop()
		end
	end
	
	local newCharacter = DD.spawnHuman(client, 'undeadjob', character.WorldPosition, character.Name, nil, 'humanUndead')
	
    -- Spawn a duffel bag at the player's feet to put the dropped items inside
	local duffelbag
	Entity.Spawner.AddItemToSpawnQueue(ItemPrefab.GetItemPrefab('duffelbag'), character.WorldPosition, nil, nil, function (spawnedItem)
		duffelbag = spawnedItem
	end)
	-- Give items back to player after a delay
	Timer.Wait(function ()
		-- Give clothing items to their correct slot
		for itemCount, item in pairs(slotItems) do
			newCharacter.Inventory.TryPutItem(item, itemCount, true, true, newCharacter, true, true)
			if itemCount == DD.invSlots.innerclothing then
				for itemCount = 0, item.OwnInventory.Capacity do
					local item = item.OwnInventory.GetItemAt(itemCount)
					duffelbag.OwnInventory.TryPutItem(item, character, nil, true, true)
				end
				item.NonInteractable = true
				if SERVER then
					local tags = item.SerializableProperties[Identifier("NonInteractable")]
					Networking.CreateEntityEvent(item, Item.ChangePropertyEventData(tags, item))
				end
			end
		end
		-- Delete old character
		Entity.Spawner.AddEntityToRemoveQueue(character)
	end, 100)
end

-- Give undead items
Hook.Add("character.created", 'DD.giveUndeadItems', function(createdCharacter)
	if createdCharacter.SpeciesName ~= 'humanUndead' then return end
	if createdCharacter.JobIdentifier ~= 'undeadjob' then
		Timer.Wait(function ()
			local client = DD.findClientByCharacter(createdCharacter)
			local character = DD.spawnHuman(client, createdCharacter.JobIdentifier, createdCharacter.WorldPosition, createdCharacter.Name)
			if Game.IsMultiplayer then client.SetClientCharacter(character) end
			Entity.Spawner.AddEntityToRemoveQueue(createdCharacter)
		end, 100)
		return
	end
	Timer.Wait(function ()
		DD.giveAfflictionCharacter(createdCharacter, 'stun', 2)
		DD.giveAfflictionCharacter(createdCharacter, 'enlightened', 999)
		-- Give undead weapons
		local weapons = {
			{identifier = 'sacrificialdagger', offhand = 'sacrificialdagger'},
			{identifier = 'cultistmace', offhand = 'cultistshield'},
			{identifier = 'boardingaxe'},
			{identifier = 'cultistpitchfork'},
			{identifier = 'tommygun', script = function (spawnedItem) Entity.Spawner.AddItemToSpawnQueue(ItemPrefab.GetItemPrefab('pistoldrum'), spawnedItem.OwnInventory) end},
		}
		local weapon = weapons[math.random(#weapons)]
		Entity.Spawner.AddItemToSpawnQueue(ItemPrefab.GetItemPrefab(weapon.identifier), createdCharacter.Inventory, nil, nil, function (spawnedItem)
			Timer.Wait(function ()
				createdCharacter.Inventory.TryPutItem(spawnedItem, DD.invSlots.righthand, true, true, createdCharacter, true, true)
			end, 1)
			if weapon.script ~= nil then weapon.script(spawnedItem) end
		end)
		if weapon.offhand ~= nil then
			Entity.Spawner.AddItemToSpawnQueue(ItemPrefab.GetItemPrefab(weapon.offhand), createdCharacter.Inventory, nil, nil, function (spawnedItem)
				Timer.Wait(function ()
					createdCharacter.Inventory.TryPutItem(spawnedItem, DD.invSlots.lefthand, true, true, createdCharacter, true, true)
				end, 1)
			end)
			if weapon.script ~= nil then weapon.script(spawnedItem) end
		end
		
		if createdCharacter.Inventory.GetItemAt(DD.invSlots.innerclothes) == nil then
			DD.giveAfflictionCharacter(createdCharacter, 'enlightened', 999)
			Entity.Spawner.AddItemToSpawnQueue(ItemPrefab.GetItemPrefab('bloodcultistrobes'), createdCharacter.Inventory, nil, nil, function (spawnedItem)
				Timer.Wait(function ()
					createdCharacter.Inventory.TryPutItem(spawnedItem, DD.invSlots.innerclothes, true, true, createdCharacter, true, true)
				end, 1)
			end)
		end
	end, 100)
end)

-- time pressure
Hook.Add("DD.timepressure.explode", "DD.timepressure.explode", function(effect, deltaTime, item, targets, worldPosition)
    local character = targets[1]
	if character == nil then return end
	
	if character.CharacterHealth.GetAffliction('timepressure', true) ~= nil then
		character.CharacterHealth.GetAffliction('timepressure', true).SetStrength(0)
	end
	
	-- head goes kaboom
	for index, limb in pairs(character.AnimController.Limbs) do
		if index == 2 then
			Game.Explode(limb.WorldPosition, 1, 999, 999, 0, 0, 0, 0)
		end
	end
end)

-- Execute when a human puts on a goblin mask
Hook.Add("DD.goblinMask.wear", "DD.goblinMask.wear", function (effect, deltaTime, item, targets, worldPosition)
	-- Guard clause
	local character = targets[1]
	if (character == nil) or (character.SpeciesName ~= 'human') then return end
	
	-- Reset time pressure for all the trolls and goblins
	for character in Character.CharacterList do
		if (character.SpeciesName == 'humanGoblin') or (character.SpeciesName == 'humanTroll') then
			if character.CharacterHealth.GetAffliction('timepressure', true) ~= nil then
				character.CharacterHealth.GetAffliction('timepressure', true).SetStrength(0)
			end
		end
	end
	
	-- Is Troll
	local conversionTrollPercentage = 20
	local isTroll = math.random(100) <= conversionTrollPercentage
	
	-- For safety
	local greenskinInfo = DD.stringLocalize('greenskinInfo')
	local client = DD.findClientByCharacter(character)
	if client ~= nil then
		DD.messageClient(client, greenskinInfo, {preset = 'crit'})
	end
	
	-- Find items to be regiven (clothing, ID Card, etc)
	local slotItems = {}
	for itemCount = 0, character.Inventory.Capacity do
		local item = character.Inventory.GetItemAt(itemCount)
		if ((item == nil) or ((tostring(item.Prefab.Identifier.Value) ~= 'handcuffs') and (tostring(item.Prefab.Identifier.Value) ~= 'bodybag'))) and ((DD.tableHas({0, 1, 3, 4, 5, 6, 7}, itemCount) and (not isTroll)) or (DD.tableHas({0, 1, 3, 4, 7}, itemCount) and isTroll)) then
			local conversion = {[0] = 0, [1] = 1, [3] = 2, [4] = 3, [5] = 4, [6] = 6, [7] = 6}
			slotItems[conversion[itemCount]] = item
		end
	end
	-- Find items to drop
	local dropItems = {}
	local hasRemovedMask = false
	for item in character.Inventory.AllItems do
		if not DD.tableHas(slotItems, item) then
			if (item.Prefab.identifier ~= 'goblinmask') or hasRemovedMask then
				table.insert(dropItems, item)
			else
				hasRemovedMask = true
			end
		end
	end
	
	-- Make goblin (or troll)
	local speciesName = 'humanGoblin'
	if isTroll then speciesName = 'humanTroll' end
	local newCharacter = DD.spawnHuman(client, 'greenskinjob', character.WorldPosition, character.Name, nil, speciesName)

    -- Spawn a duffel bag at the player's feet to put the dropped items inside
	local duffelbag
	Entity.Spawner.AddItemToSpawnQueue(ItemPrefab.GetItemPrefab('duffelbag'), character.WorldPosition, nil, nil, function (spawnedItem)
		duffelbag = spawnedItem
	end)
	-- Give items back to player after a delay
	Timer.Wait(function ()
		-- Remove goblin card
		Entity.Spawner.AddEntityToRemoveQueue(newCharacter.Inventory.GetItemAt(0))
		-- Give clothing items to their correct slot
		for itemCount, item in pairs(slotItems) do
			--newCharacter.Inventory.ForceToSlot(item, itemCount)
			newCharacter.Inventory.TryPutItem(item, itemCount, true, true, newCharacter, true, true)
		end
		-- Put other items in the duffel bag
		for item in dropItems do
			if not foundSlot then
				duffelbag.OwnInventory.TryPutItem(item, character, nil, true, true)
			end
		end
		-- Delete old character
		Entity.Spawner.AddEntityToRemoveQueue(character)
	end, 100)
	
end)

-- Remove goblin/troll and spawn his mask on the floor
DD.characterDeathFunctions.greenskinDeath = function (character)
	if (character.SpeciesName ~= 'humanGoblin') and (character.SpeciesName ~= 'humanTroll') then return end
	if character.JobIdentifier ~= 'greenskinjob' then return end

	local client = DD.findClientByCharacter(character)
	if client ~= nil then
		client.SetClientCharacter(nil)
	end
	Entity.Spawner.AddItemToSpawnQueue(ItemPrefab.GetItemPrefab('goblinmask'), character.WorldPosition)
	Entity.Spawner.AddEntityToRemoveQueue(character)

	return true
end

-- Give goblin/troll the greenskin talent(s) + fix to a bug introduced by the Summer Update (Barotrauma v1.5.7.0)
Hook.Add("character.created", 'DD.greenskinTalent', function(createdCharacter)
	if (createdCharacter.SpeciesName ~= 'humanGoblin') and (createdCharacter.SpeciesName ~= 'humanTroll') then return end
	
	Timer.Wait(function ()
		if createdCharacter.JobIdentifier ~= 'greenskinjob' then
			local client = DD.findClientByCharacter(createdCharacter)
			local character = DD.spawnHuman(client, createdCharacter.JobIdentifier, createdCharacter.WorldPosition, createdCharacter.Name)
			if Game.IsMultiplayer then client.SetClientCharacter(character) end
			Entity.Spawner.AddEntityToRemoveQueue(createdCharacter)
		else
			createdCharacter.GiveTalent('greenskinknowledge', true)
			local items = {
				humangoblin = {
					'idcard',
					'bikehorn',
					'midazolam',
					'midazolam',
					'meth',
					'meth',
					'goblincrate',
					'goblincrate',
					'goblincrate',
					'goblincrate',
					'goblincrate',
					'goblincrate',
					'goblincrate',
					'goblincrate',
					'goblinmask'
				},
				humantroll = {
					'idcard',
					'midazolam',
					'midazolam',
					'meth',
					'meth',
					'goblincrate',
					'goblincrate',
					'goblincrate',
					'goblincrate',
					'goblincrate',
					'goblincrate',
					'goblincrate',
					'goblincrate',
					'goblinmask',
					'goblinmask'
				}
			}
			for item in items[string.lower(tostring(createdCharacter.SpeciesName))] do
				Entity.Spawner.AddItemToSpawnQueue(ItemPrefab.GetItemPrefab(item), createdCharacter.Inventory, nil, nil, function (spawnedItem) end)
			end
		end
	end, 100)
end)

-- Sends a message to husks telling them about their objective and abilities
Hook.Add("character.created", "DD.huskMessage", function (createdCharacter)
	if createdCharacter.SpeciesName ~= 'humanhusk' then return end
	Timer.Wait(function()
		local client = DD.findClientByCharacter(createdCharacter)
		if client == nil then return end
		DD.messageClient(client, DD.stringLocalize('huskInfo'), {preset = 'crit'})
	end, 100)
end)

-- radiation
local fuelrodDecayNetworkCooldown = {}
Hook.Add("DD.fuelrod.decay", "DD.fuelrod.decay", function(effect, deltaTime, item, targets, worldPosition)
	local containerMultiplier = {
		artifactcontainer = 0.0,
		exosuit = 0.0,
		clownexosuit = 0.0,
		nucleargun = 0.5,
		reactor1 = 0.5,
		outpostreactor = 0.5,
	}
	local multiplier = 1.0
	if (item.ParentInventory ~= nil) and (LuaUserData.TypeOf(item.ParentInventory.Owner) == 'Barotrauma.Item') and
	(containerMultiplier[tostring(item.ParentInventory.Owner.Prefab.Identifier)] ~= nil) then
		multiplier = multiplier * containerMultiplier[tostring(item.ParentInventory.Owner.Prefab.Identifier)]
	end
	
	if item.Condition <= 2 then
		if (item.ParentInventory ~= nil) and (LuaUserData.TypeOf(item.ParentInventory.Owner) == 'Barotrauma.Item') then
			item.Condition = 0
		else
			item.Condition = 2
		end
	end
	
	local lerpFactor = item.Health / item.Prefab.Health
	local minAlpha = 0
	local maxAlpha = 255
	local minRange = 0
	local maxRange = 400
	if item.Prefab.Identifier == 'fulguriumfuelrodvolatile' then
		minAlpha = 64
		minRange = 100
	end
	if item.Prefab.Identifier == 'skyholderartifact' then
		lerpFactor = 0
	end
	local range = DD.lerp(lerpFactor, maxRange, minRange)
	local alpha = DD.lerp(lerpFactor, maxAlpha, minAlpha)
	item.GetComponentString('LightComponent').IsOn = true
	item.GetComponentString('LightComponent').LightColor = Color(Byte(70), Byte(200), Byte(250), Byte(alpha))
	item.GetComponentString('LightComponent').Range = range * 2
	if SERVER then
		if (fuelrodDecayNetworkCooldown[item] ~= nil) and (fuelrodDecayNetworkCooldown[item] > 0) then
			fuelrodDecayNetworkCooldown[item] = fuelrodDecayNetworkCooldown[item] - 1
		else
			local prop = item.GetComponentString('LightComponent').SerializableProperties[Identifier("IsOn")]
			Networking.CreateEntityEvent(item, Item.ChangePropertyEventData(prop, item.GetComponentString('LightComponent')))
			local prop = item.GetComponentString('LightComponent').SerializableProperties[Identifier("LightColor")]
			Networking.CreateEntityEvent(item, Item.ChangePropertyEventData(prop, item.GetComponentString('LightComponent')))
			local prop = item.GetComponentString('LightComponent').SerializableProperties[Identifier("Range")]
			Networking.CreateEntityEvent(item, Item.ChangePropertyEventData(prop, item.GetComponentString('LightComponent')))
			
			fuelrodDecayNetworkCooldown[item] = 30
		end
	end
	
	local maxAmount = item.Prefab.Health - item.Health
	if item.Prefab.Identifier == 'fulguriumfuelrodvolatile' then
		maxAmount = maxAmount + 50
	end
	if item.Prefab.Identifier == 'skyholderartifact' then
		maxAmount = 300
	end
	maxAmount = maxAmount * multiplier
	local minDistance = 50
	local maxDistance = math.sqrt(maxAmount / 0.005)
	for character in Character.CharacterList do
		local limb = character.AnimController.Limbs[1]
		local distance = Vector2.Distance(item.WorldPosition, limb.WorldPosition)
		if item.InWater then distance = distance * 2 end
		if distance <= maxDistance then
			distance = math.max(minDistance, distance)
			local amount = maxAmount / distance ^ 2
			local attackResult = limb.AddDamage(limb.SimPosition, {AfflictionPrefab.Prefabs['radiationsickness'].Instantiate(amount * #character.AnimController.Limbs)}, false, 1, 0.0, nil)
			character.CharacterHealth.ApplyDamage(limb, attackResult, nil)
			-- geiger counter visual effect
			local amountfx = DD.clamp((1 - lerpFactor) * DD.invLerp(distance, maxDistance, minDistance))
			local affliction = character.CharacterHealth.GetAffliction('geigerfx', true)
			if (affliction ~= nil) and (amountfx >= affliction.Strength) then
				affliction.SetStrength(amountfx)
			else
				DD.giveAfflictionCharacter(character, 'geigerfx', amountfx)
			end
		end
	end
end)

-- ballot box
local vote = function (bool, targets)
	local count = 0
	for target in targets do
		count = count + 1
		Entity.Spawner.AddItemToRemoveQueue(target)
	end
	if count == 0 then return end
	
	for event in DD.eventDirector.events do
		if event.name == 'election' then
			if bool then
				event.yesVotes = event.yesVotes + count
			else
				event.noVotes = event.noVotes + count
			end
		end
	end
	if SERVER then DD.messageAllClients(DD.stringLocalize('electionVoteCast'), {preset = 'info'}) end
end
Hook.Add("DD.ballotbox.voteYes", "DD.ballotbox.voteYes", function(effect, deltaTime, item, targets, worldPosition)
	vote(true, targets)
end)
Hook.Add("DD.ballotbox.voteNo", "DD.ballotbox.voteNo", function(effect, deltaTime, item, targets, worldPosition)
	vote(false, targets)
end)

-- for debugging/testing
Hook.Add("DD.debug", "DD.debug", function(effect, deltaTime, item, targets, worldPosition)
	print(item)
	DD.tablePrint(targets, nil, 1)
end)

-- fix from evil factory for goblin/troll respawn bug
if SERVER then
local characterInfoDictRedux = {}
Hook.Patch("Barotrauma.Networking.GameServer", "UpdateCharacterInfo", function(instance, ptable)
	local sender = ptable["sender"]
	characterInfoDictRedux[sender] = sender.CharacterInfo
end, Hook.HookMethodType.After)
Hook.Patch("Barotrauma.Networking.RespawnManager", "DispatchShuttle", function(instance, ptable)
	for client in Client.ClientList do
		if not client.Character or client.Character.IsDead then
			if characterInfoDictRedux[client] then
				client.CharacterInfo = characterInfoDictRedux[client]
			end
		end
	end
end, Hook.HookMethodType.Before)
end