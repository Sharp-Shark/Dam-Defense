if CLIENT and Game.IsMultiplayer then return end

DD.speciesData = {
	tigerthresher = {initialBreedTimer = 180, eggIdentifer = 'tigerthresheregg', populationName = 'thresher', populationCap = 6},
	tigerthresher_hatchling = {initialGrowTimer = 120, populationName = 'thresher'},
	
	crawler_large = {populationName = 'crawler'},
	crawler = {initialGrowTimer = 210, grownIdentifier = 'crawler_large', initialBreedTimer = 90, eggIdentifer = 'crawleregg', populationName = 'crawler', populationCap = 12},
	crawler_hatchling = {initialGrowTimer = 90, populationName = 'crawler'},
	
	spitroach = {initialBreedTimer = 180, eggIdentifer = 'spitroachegg', populationName = 'spitroach', populationCap = 6},
	spitroach_hatchling = {initialGrowTimer = 120, populationName = 'spitroach'},
	
	mudraptor_veteran = {populationName = 'mudraptor'},
	mudraptor = {initialGrowTimer = 240, grownIdentifier = 'mudraptor_veteran', initialBreedTimer = 90, eggIdentifer = 'largemudraptoregg', populationName = 'mudraptor', populationCap = 6},
	mudraptor_unarmored = {initialGrowTimer = 120, grownIdentifier = 'mudraptor', initialBreedTimer = 60, eggIdentifer = 'largemudraptoregg', populationName = 'mudraptor', populationCap = 6},
	mudraptor_hatchling = {initialGrowTimer = 120, grownIdentifier = 'mudraptor_unarmored', populationName = 'mudraptor'},
	
	hammerheadspawn = {initialBreedTimer = 45, hatchlingIdentifier = 'hammerheadspawn', populationName = 'hammerhead', populationCap = 60}
}

DD.spawnEggWithSaline = function (identifier, pos)
	Entity.Spawner.AddItemToSpawnQueue(ItemPrefab.GetItemPrefab(identifier), pos, nil, nil, function (spawnedItem)
		Entity.Spawner.AddItemToSpawnQueue(ItemPrefab.GetItemPrefab('antibloodloss1'), spawnedItem.OwnInventory, nil, nil, function (spawnedItem) end)
		return spawnedItem
	end)
end

DD.growCharacter = function (character)
	local speciesName = string.lower(tostring(character.SpeciesName))
	
	-- If species does not have defined grow timer return
	if (DD.speciesData[speciesName] == nil) or (DD.speciesData[speciesName].initialGrowTimer == nil) or (character.IsDead) then return end
	
	-- Update timer
	if DD.roundData.creatureGrowthTimer[character] == nil then
		DD.roundData.creatureGrowthTimer[character] = DD.speciesData[speciesName].initialGrowTimer * (0.5 + math.random())
	end
	if DD.roundData.creatureGrowthTimer[character] <= 0 then
		-- When timer reaches 0, grow
		DD.roundData.creatureGrowthTimer[character] = nil
		-- Create new grown up character
		local grownSpeciesName = DD.speciesData[speciesName].grownIdentifier or string.sub(speciesName, 1, #speciesName - 10)
		Entity.Spawner.AddCharacterToSpawnQueue(grownSpeciesName, character.WorldPosition, function (newCharacter)
			-- Pass over client control from old character to new one
			local client = DD.findClientByCharacter(character)
			if client ~= nil then
				client.SetClientCharacter(newCharacter)
			end
			-- Remove old character
			Entity.Spawner.AddEntityToRemoveQueue(character)
			
			return newCharacter
		end)
	else
		DD.roundData.creatureGrowthTimer[character] = DD.roundData.creatureGrowthTimer[character] - 0.5
	end
	
	return character
end

DD.breedCharacter = function (character)
	local speciesName = string.lower(tostring(character.SpeciesName))
	
	-- If species doesn't have a defined breed timer return
	if (DD.speciesData[speciesName] == nil) or (DD.speciesData[speciesName].initialBreedTimer == nil) or (character.IsDead) then return end
	
	-- Update timer
	if (DD.roundData.creatureBreedTimer[character] == nil) or (character.IsDead) then
		DD.roundData.creatureBreedTimer[character] = DD.speciesData[speciesName].initialBreedTimer * (0.5 + math.random())
	end
	if DD.roundData.creatureBreedTimer[character] <= 0 then
		-- When timer reaches 0, breed and reset breed timer
		DD.roundData.creatureBreedTimer[character] = DD.speciesData[speciesName].initialBreedTimer * (0.5 + math.random())
		-- If egg is defined, spawn an egg
		if DD.speciesData[speciesName].eggIdentifer ~= nil then
			DD.spawnEggWithSaline(DD.speciesData[speciesName].eggIdentifer, character.WorldPosition)
		-- If no egg is defined but a hatchling is, spawn a hatchling
		elseif DD.speciesData[speciesName].hatchlingIdentifier ~= nil then
			Entity.Spawner.AddCharacterToSpawnQueue(DD.speciesData[speciesName].hatchlingIdentifier, character.WorldPosition, function (newCharacter) end)
		-- If no egg or hatchling is defined, make a copy
		else
			Entity.Spawner.AddCharacterToSpawnQueue(speciesName, character.WorldPosition, function (newCharacter) end)
		end
	else
		DD.roundData.creatureBreedTimer[character] = DD.roundData.creatureBreedTimer[character] - 0.5
	end
	
	return character
end

DD.updateNature = function ()
	-- Update population count
	for populationName, population in pairs(DD.roundData.populations) do
		DD.roundData.populations[populationName] = 0
	end
	for character in Character.CharacterList do
		local speciesName = string.lower(tostring(character.SpeciesName))
		if (character.Submarine == Submarine.MainSub) and (not character.IsDead) and (DD.speciesData[speciesName] ~= nil) then
			local populationName = DD.speciesData[speciesName].populationName or 'misc'
			if DD.roundData.populations[populationName] == nil then
				DD.roundData.populations[populationName] = 0
			end
			DD.roundData.populations[populationName] = DD.roundData.populations[populationName] + 1
		end
	end
	-- Nature update
	for character in Character.CharacterList do
		local speciesName = string.lower(tostring(character.SpeciesName))
		if (character.Submarine == Submarine.MainSub) and (not character.IsDead) and (DD.speciesData[speciesName] ~= nil) then
			local populationName = DD.speciesData[speciesName].populationName or 'misc'
			DD.growCharacter(character)
			local populationCap = DD.speciesData[speciesName].populationCap or 0
			if (#Character.CharacterList < 150) and (DD.roundData.populations[populationName] < populationCap) then
				DD.breedCharacter(character)
			end
		end
	end
end

DD.thinkFunctions.nature = function ()
	if (DD.thinkCounter % 30 ~= 0) or (not Game.RoundStarted) or (DD.roundData.roundEnding) then return end

	DD.updateNature()
end

DD.roundStartFunctions.nature = function ()
	DD.roundData.creatureGrowthTimer = {}
	DD.roundData.creatureBreedTimer = {}
	DD.roundData.populations = {}
end

DD.characterDeathFunctions.corpseCleanUp = function (character)
	DD.roundData.creatureGrowthTimer[character] = nil
	DD.roundData.creatureBreedTimer[character] = nil
	
	local despawnBlacklist = {'human', 'humanhusk', 'humangoblin', 'humantroll'}
	if not DD.tableHas(despawnBlacklist, string.lower(tostring(character.SpeciesName))) then
		Timer.Wait(function ()
			Entity.Spawner.AddEntityToRemoveQueue(character)
		end, 60*1000)
	end

	return true
end