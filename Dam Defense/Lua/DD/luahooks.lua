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

Hook.Add("DD.enlightened.givetalent", "DD.enlightened.givetalent", function(effect, deltaTime, item, targets, worldPosition)
    local character = targets[1]
	if character == nil then return end
	
	if character.HasTalent('enlightenedmind') then return end
    character.GiveTalent('enlightenedmind', true)
	
	local client = DD.findClientByCharacter(character)
	if client == nil then return end
	DD.messageClient(client, 'Your mind has been enlightened! Work with fellow blood cultists to enlighten others. Your grand objective is to make everyone a cultist, either by converting them all, by killing them all or a mix of the two. Long live Tchernobog!', {preset = 'crit'})
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

Hook.Add("DD.debug", "DD.debug", function(effect, deltaTime, item, targets, worldPosition)
	print(item)
	DD.tablePrint(targets, nil, 1)
end)