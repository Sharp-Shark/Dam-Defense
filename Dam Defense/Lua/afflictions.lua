-- Warning: how the mod interacts with husk is hard-coded since husk infection is different from the mod's diseases in some pretty fundamental ways

DD.diseaseData = {
	flu = {immune = 3, immuneVisibility = 0.5, spreadChance = 0.3},
	bacterial = {immune = 3, immuneVisibility = 0.5, spreadChance = 0.15},
	tb = {immune = 1.5, immuneVisibility = 0.5, spreadChance = 0.3}
}
local getDiseaseStat = function (diseaseName, statName)
	local stat = DD.diseaseData[diseaseName][statName]
	if stat == nil then
		if statName == 'immune' then return 2.5 end
		if statName == 'immuneVisibility' then return 1 end
		if statName == 'spreadChance' then return 0 end
	else
		return stat
	end
end

Hook.Add("DD.afflictions.bloodsample", "DD.afflictions.bloodsample", function(effect, deltaTime, item, targets, worldPosition)
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

Hook.Add("DD.afflictions.spread", "DD.afflictions.spread", function(effect, deltaTime, item, targets, worldPosition)
    if CLIENT and Game.IsMultiplayer then return end
	if targets[1] == nil then return end
	local character = targets[1]
	if character.AnimController.HeadInWater or not DD.isCharacterUsingHullOxygen(character) then return end
	
	local spreadDiseaseToCharacter = function (toCharacter, fromCharacter, diseaseName, chance)
		local amount = fromCharacter.CharacterHealth.GetAfflictionStrengthByIdentifier(diseaseName .. 'hidden', true)
		amount = amount + fromCharacter.CharacterHealth.GetAfflictionStrengthByIdentifier(diseaseName .. 'payload', true)
		amount = amount + fromCharacter.CharacterHealth.GetAfflictionStrengthByIdentifier(diseaseName .. 'infection', true)
		local infection = toCharacter.CharacterHealth.GetAfflictionStrengthByIdentifier(diseaseName .. 'infection', true)
		local hidden = toCharacter.CharacterHealth.GetAfflictionStrengthByIdentifier(diseaseName .. 'hidden', true)
		if diseaseName == 'husk' then
			amount = fromCharacter.CharacterHealth.GetAfflictionStrengthByIdentifier('huskinfection', true)
			infection = toCharacter.CharacterHealth.GetAfflictionStrengthByIdentifier('huskinfection', true)
			hidden = 0
		end
		if (infection + hidden <= 0) and (math.random() <= chance) then
			if diseaseName == 'husk' then
				DD.giveAfflictionCharacter(toCharacter, 'huskinfection', amount * math.random())
			else
				DD.giveAfflictionCharacter(toCharacter, diseaseName .. 'hidden', amount * math.random())
			end
		end
	end
	
	local hull = character.CurrentHull
	if hull == nil then return end
	
	local affectedHulls = {hull = true}
	for otherHull in character.CurrentHull.GetConnectedHulls(false, 3, true) do affectedHulls[otherHull] = true end
	
	for other in Character.CharacterList do
		if (other.SpeciesName == 'human') and (not other.AnimController.HeadInWater) and (not other.IsDead) and affectedHulls[other.CurrentHull] and DD.isCharacterUsingHullOxygen(other) and
		(Vector2.Distance(character.WorldPosition, other.WorldPosition) < 750) then
			spreadDiseaseToCharacter(other, character, 'husk', 0.15)
			for diseaseName, data in pairs(DD.diseaseData) do
				spreadDiseaseToCharacter(other, character, diseaseName, getDiseaseStat(diseaseName, 'spreadChance'))
			end
		end
	end
end)

Hook.Add("afflictionUpdate", "DD.bacterialgangrene", function (affliction, characterHealth, limb)
	local character = characterHealth.Character
	if (character.SpeciesName ~= 'human') or (character.IsDead) then return end
	
	-- End infection incubation and give payload
	if affliction.Prefab.AfflictionType == 'infectionhidden' then
		if (math.random() * 2 * 10^3 < 1) or (affliction.Strength >= affliction.Prefab.MaxStrength) then
			local name = DD.stringSplit(tostring(affliction.Prefab.Identifier), 'hidden')[1]
			DD.giveAfflictionCharacter(character, name .. 'payload', affliction.Strength * (0.5 + math.random()))
			affliction.SetStrength(0)
		end
	end

	-- Bacterial gangrene from burns and bleeding
	if (affliction.Prefab.AfflictionType ~= 'burn') and (affliction.Prefab.AfflictionType ~= 'bleeding') then return end
	local characterBurn = character.CharacterHealth.GetAfflictionStrengthByType('burn', true)
	local characterBleeding = character.CharacterHealth.GetAfflictionStrengthByIdentifier('bleeding', true)
	if (characterBurn + characterBleeding > 5) and
	(math.random() * 10^4 < 1) then
		DD.giveAfflictionCharacter(character, 'bacterialgangrene', 0.1, limb)
	end
end)

DD.thinkFunctions.afflictions = function ()
	if not Game.RoundStarted then return end

	for character in Character.CharacterList do
		if (character.SpeciesName == 'humanhusk') and (not character.IsDead) then
			if character.Vitality < 0 then
				DD.giveAfflictionCharacter(character, 'huskvulnerability', 999)
			end
		end
		if (character.SpeciesName == 'human') and (not character.IsDead) then
			local characterBacterialInfection = character.CharacterHealth.GetAfflictionStrengthByIdentifier('bacterialinfection', true)
			local characterBacterialGangrene = character.CharacterHealth.GetAfflictionStrengthByIdentifier('bacterialgangrene', true)
			
			local characterInfection = character.CharacterHealth.GetAfflictionStrengthByType('infection', true)
			characterInfection = characterInfection + math.max(0, character.CharacterHealth.GetAfflictionStrengthByIdentifier('huskinfection', true) - 35)
			
			local characterImmune = character.CharacterHealth.GetAfflictionStrengthByType('immune', true)
			characterImmune = characterImmune - character.CharacterHealth.GetAfflictionStrengthByType('immunedebuff', true)
			characterImmune = characterImmune - math.min(50, characterInfection / 2)
			characterImmune = math.max(0, characterImmune)
			
			-- Broad Bacterial Infection from bacterial gangrene (septic shock)
			if characterBacterialGangrene > 5 and
			(math.random() * 10^6 < characterBacterialGangrene ^ 2) then
				DD.giveAfflictionCharacter(character, 'bacterialpayload', characterBacterialGangrene)
			end
			-- Broad Bacterial Infection from other infections
			if (characterInfection - characterBacterialInfection > 20) and
			(math.random() * 10^6 < (character.MaxVitality - character.Vitality)) then
				DD.giveAfflictionCharacter(character, 'bacterialpayload', (character.MaxVitality - character.Vitality) * math.random())
			end
			-- Infection recognized by immune-system
			local characterInfectionRecognized = 0
			for diseaseName, data in pairs(DD.diseaseData) do
				characterInfectionRecognized = characterInfectionRecognized + character.CharacterHealth.GetAfflictionStrengthByIdentifier(diseaseName .. 'infection', true) * getDiseaseStat(diseaseName, 'immuneVisibility')
			end
			characterInfectionRecognized = characterInfectionRecognized + math.max(0, character.CharacterHealth.GetAfflictionStrengthByIdentifier('huskinfection', true) - 35)
			-- Immunu-response
			if characterInfectionRecognized > 0 then
				local amount = math.random() * (0.5 + math.max(0, character.Vitality / character.MaxVitality)) * (characterInfectionRecognized / 100) * (1/60)
				amount = amount + amount * character.CharacterHealth.GetAfflictionStrengthByIdentifier('immuneboost', true) / 50
				DD.giveAfflictionCharacter(character, 'immuneresponse', 5 * amount)
				if character.CharacterHealth.GetAfflictionStrengthByIdentifier('fever', true) < characterInfectionRecognized then
					DD.giveAfflictionCharacter(character, 'fever', 5 * amount)
				elseif character.CharacterHealth.GetAfflictionStrengthByIdentifier('fever', true) > characterInfectionRecognized + 1 then
					character.CharacterHealth.ReduceAfflictionOnAllLimbs('fever', 5 / 60, nil)
				end
				for diseaseName, data in pairs(DD.diseaseData) do
					character.CharacterHealth.ReduceAfflictionOnAllLimbs(diseaseName .. 'infection', characterImmune * (getDiseaseStat(diseaseName, 'immune') / 100) * (1/60), nil)
				end
			else
				character.CharacterHealth.ReduceAfflictionOnAllLimbs('immuneresponse', 5 / 60, nil)
				character.CharacterHealth.ReduceAfflictionOnAllLimbs('fever', 10 / 60, nil)
			end
		end
	end
end

--[[
-- If someone gives in as husk, instead they will be set to spectator and the husk will continue alive but as a NPC
Hook.Patch("Barotrauma.Character", "Kill", function(instance, ptable)
	if (instance.SpeciesName == 'humanhusk') and (instance.Vitality > 0 - instance.MaxVitality) then
		if CLIENT and Game.IsSingleplayer then
			if Character.Controlled ~= instance then return end
			Character.Controlled = nil
			ptable.PreventExecution = true
		else
			local client = DD.findClientByCharacter(instance)
			if client == nil then return end
			client.SetClientCharacter(nil)
			ptable.PreventExecution = true
		end
	end
end, Hook.HookMethodType.Before)
-]]