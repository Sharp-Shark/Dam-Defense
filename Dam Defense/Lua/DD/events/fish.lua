-- Spawn fish
DD.eventFish = DD.class(DD.eventBase, nil, {
	name = 'fish',
	isMainEvent = false,
	cooldown = 60 * 3,
	weight = 2,
	goodness = -1,
	
	onStart = function (self)
		-- Location
		local locationTags = {'dd_dambasin', 'dd_wetsewer'}
		local locationTag = locationTags[math.random(#locationTags)]
		local locationNames = {dd_dambasin = "inside of the dam's basin", dd_wetsewer = 'deep in the underwater section of the sewers'}
		-- Fish
		local fishTypes = {'crawler_hatchling', 'mudraptor_hatchling', 'tigerthresher_hatchling', 'husk', 'spitroach'}
		local fishType = fishTypes[math.random(#fishTypes)]
		local fishNames = {
			crawler_hatchling = 'crawler hatchlings',
			mudraptor_hatchling = 'mudraptor hatchlings',
			tigerthresher_hatchling = 'thresher hatchlings',
			hammerheadspawn = 'hammerhead spawn',
			husk = 'husks',
			spitroach = 'spitroach'
		}
		local fishCount = 1 + math.random(3)
	
		-- Spawn [fishCount] of species [fishType] at any location marker with the tag [locationTag]
		for n = 1, fishCount do
			local position = DD.getLocation(function (item) return item.HasTag(locationTag) end).WorldPosition
			Entity.Spawner.AddCharacterToSpawnQueue(fishType, position, function (character) return end)
		end
		
		-- Warn fish have been spawned
		DD.messageAllClients('A total of ' .. fishCount .. ' ' .. fishNames[fishType] .. ' have been spotted ' .. locationNames[locationTag] .. '! It is adviced to kill them before they grow in numbers.', {preset = 'badinfo'})
	end
})