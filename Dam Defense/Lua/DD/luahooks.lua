if CLIENT and Game.IsMultiplayer then return end

Hook.Add("DD.bloodsampler.bloodsample", "DD.bloodsampler.bloodsample", function(effect, deltaTime, item, targets, worldPosition)
    if CLIENT and Game.IsMultiplayer then return end
	
	if targets[1] == nil then return end
	local character = targets[1]
	
	local speciesName = string.lower(tostring(character.SpeciesName))
	if speciesName ~= 'human' then
		if string.sub(speciesName, #speciesName - 3, #speciesName) == 'husk' then
			local inventory = item.ParentInventory
			Entity.Spawner.AddEntityToRemoveQueue(item)
			Entity.Spawner.AddItemToSpawnQueue(ItemPrefab.GetItemPrefab('huskeggs'), inventory, nil, nil, function (spawnedItem) end)
		end
		return
	end
	
	local characterInfection = character.CharacterHealth.GetAfflictionStrengthByType('infection', true)
	local characterHusk = character.CharacterHealth.GetAfflictionStrengthByIdentifier('huskinfection', true)
	if characterHusk < 35 then characterHusk = 0 end
	if characterInfection + characterHusk <= 0 then return end
	
	local getCharacterInfection = function (character, diseaseName)
		local total = 0
		total = total + character.CharacterHealth.GetAfflictionStrengthByIdentifier(diseaseName .. 'payload', true)
		total = total + character.CharacterHealth.GetAfflictionStrengthByIdentifier(diseaseName .. 'infection', true)
		return total
	end
	
	local inventory = item.ParentInventory
	
	local characterInfections = {}
	characterInfections.husk = character.CharacterHealth.GetAfflictionStrengthByIdentifier('huskinfection', true)
	for diseaseName, data in pairs(DD.diseaseData) do
		characterInfections[diseaseName] = getCharacterInfection(character, diseaseName)
	end
	
	local winnerName = ''
	local winnerStrength = 0
	for infectionName, infectionStrength in pairs(characterInfections) do
		if infectionStrength > winnerStrength then
			winnerName = infectionName
			winnerStrength = infectionStrength
		end
	end
	
	if winnerName == '' then return end
	local itemIdentifier = winnerName .. 'syringe'
	if winnerName == 'husk' then itemIdentifier = 'huskeggs' end
	
	Entity.Spawner.AddEntityToRemoveQueue(item)
	Entity.Spawner.AddItemToSpawnQueue(ItemPrefab.GetItemPrefab(itemIdentifier), inventory, nil, nil, function (spawnedItem) end)
end)

Hook.Add("DD.wifitrigger.use", "DD.wifitrigger.use", function(effect, deltaTime, item, targets, worldPosition)
	component = item.GetComponentString('WifiComponent').TransmitSignal(Signal('true'), false)
end)

Hook.Add("DD.whalinggun.use", "DD.whalinggun.use", function(effect, deltaTime, item, targets, worldPosition)
	local powder = targets[#targets]
	if powder.HasTag('whalinggunpowder') or powder.HasTag('munition_propulsion') then
		powder.Condition = powder.Condition - 50
	end
end)

Hook.Add("DD.spraycan.use", "DD.spraycan.use", function(effect, deltaTime, item, targets, worldPosition)
	local limb = targets[1]
	if limb == nil then return end
	
	local character = limb.character
	if limb.type == LimbType.Head then
		local afflictionIdentifier = DD.stringSplit(tostring(item.Prefab.Identifier), 'spraycan')[1] .. 'paint'
		DD.giveAfflictionCharacter(character, afflictionIdentifier, 0.5 * deltaTime, limb)
		if DD.isCharacterUsingHullOxygen(character) then
			DD.giveAfflictionCharacter(character, 'noxiousspray', 0.5 * deltaTime, limb)
		end
	end
end)

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
	
	-- pop-up
	local client = DD.findClientByCharacter(character)
	if client == nil then return end
	DD.messageClient(client, 'Your mind has been enlightened! Work with fellow blood cultists to enlighten others. Your objective is to have no non-cultist alive. You can convert others using "The 1998". You can extract "Life Essence" from the unconcious or the recently deceased using a "Sacrificial Dagger". Conversion and consuming "Life Essence" both lower your "Time Pressure". Long live Tchernobog! Do /cultists to get a list of fellow worshippers and /whisper to message them all.', {preset = 'crit'})
end)

Hook.Add("DD.sacrificialdagger.sacrifice", "DD.sacrificialdagger.sacrifice", function(effect, deltaTime, item, targets, worldPosition)
    if CLIENT and Game.IsMultiplayer then return end
	
	if targets[1] == nil then return end
	local character = targets[1]
	
	if character.Vitality > 0 then return end
	if character.CharacterHealth.GetAfflictionStrengthByIdentifier('cardiacarrest', true) >= 1 then return end
	
	local inventory = item.ParentInventory
	if (inventory.Owner == nil) or (inventory.Owner.CharacterHealth.GetAfflictionStrengthByIdentifier('enlightened', true) < 99) then return end
	
	DD.giveAfflictionCharacter(character, 'cardiacarrest', 999)
	Entity.Spawner.AddItemToSpawnQueue(ItemPrefab.GetItemPrefab('lifeessence'), inventory, nil, nil, function (spawnedItem) end)
end)

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
	local newCharacter = DD.spawnHuman(client, 'assistant', character.worldPosition, character.Name, nil, speciesName)

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

	local client = DD.findClientByCharacter(character)
	if client ~= nil then
		client.SetClientCharacter(nil)
	end
	if #DD.eventDirector.getEventInstances('greenskins') > 0 then
		Entity.Spawner.AddItemToSpawnQueue(ItemPrefab.GetItemPrefab('goblinmask'), character.WorldPosition)
	end
	Entity.Spawner.AddEntityToRemoveQueue(character)

	return true
end

-- Give goblin/troll the greenskin talent(s) + fix to a bug introduced by the Summer Update (Barotrauma v1.5.7.0)
Hook.Add("character.created", 'DD.greenskinTalent', function(createdCharacter)
	if (createdCharacter.SpeciesName ~= 'humanGoblin') and (createdCharacter.SpeciesName ~= 'humanTroll') then return end
	
	Timer.Wait(function ()
		if createdCharacter.JobIdentifier ~= 'assistant' then
			local client = DD.findClientByCharacter(createdCharacter)
			local character = DD.spawnHuman(client, createdCharacter.JobIdentifier, createdCharacter.WorldPosition, createdCharacter.Name)
			client.SetClientCharacter(character)
			Entity.Spawner.AddEntityToRemoveQueue(createdCharacter)
		else
			createdCharacter.GiveTalent('greenskinknowledge', true)
		end
	end, 100)
end)

-- Remove goblin masks outside of goblin event to prevent bugs
Hook.Add("item.created", 'DD.goblinmaskRemove', function(item)
	if (item.Prefab.Identifier == 'goblinmask') and (#DD.eventDirector.getEventInstances('greenskins') <= 0) then
		Entity.Spawner.AddItemToRemoveQueue(item)
	end
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

Hook.Add("DD.debug", "DD.debug", function(effect, deltaTime, item, targets, worldPosition)
	print(item)
	DD.tablePrint(targets, nil, 1)
end)