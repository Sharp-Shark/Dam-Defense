-- Spawn fish
DD.eventFish = DD.class(DD.eventBase, nil, {
	name = 'fish',
	isMainEvent = false,
	cooldown = 60 * 2,
	weight = 4.0,
	goodness = -2,
	
	silent = false, -- if true, will not do any warning
	locationTag = nil,
	
	locationTags = {'dd_dambasin', 'dd_wetsewer'},
	locationNames = {dd_dambasin = "inside of the dam's basin", dd_wetsewer = 'deep in the underwater section of the sewers'},
	fishIdentifiers = {'crawler_hatchling', 'mudraptor_hatchling', 'tigerthresher_hatchling', 'husk', 'spitroach_hatchling'},
	fishNames = {
		crawler_hatchling = TextManager.Get('character.crawler'),
		mudraptor_hatchling = TextManager.Get('character.mudraptor'),
		tigerthresher_hatchling = TextManager.Get('character.tigerthresher'),
		hammerheadspawn = TextManager.Get('character.hammerheadspawn'),
		husk = TextManager.Get('character.husk'),
		spitroach_hatchling = TextManager.Get('character.spitroach'),
	},
	minAmount = 2,
	maxAmount = 4,
	messageKey = 'fishMessage',
	
	onStart = function (self)
		-- Location
		local locationTags = self.locationTags
		local locationTag = locationTags[math.random(#locationTags)]
		if self.locationTag ~= nil then
			locationTag = self.locationTag
		end
		local locationNames = self.locationNames
		-- Fish
		local fishTypes = self.fishIdentifiers
		local fishType = fishTypes[math.random(#fishTypes)]
		local fishNames = self.fishNames
		local fishCount = math.max(1, math.random(self.minAmount, self.maxAmount))
	
		-- Spawn [fishCount] of species [fishType] at any location marker with the tag [locationTag]
		for n = 1, fishCount do
			local position = DD.getLocation(function (item) return item.HasTag(locationTag) end).WorldPosition
			Entity.Spawner.AddCharacterToSpawnQueue(fishType, position, function (character) return end)
		end
		
		-- Get location name
		local locationName = tostring(DD.getLocation(function (item) return item.HasTag(locationTag) end).CurrentHull.RoomName)
		if TextManager.Get(locationName) ~= nil then locationName = tostring(TextManager.Get(locationName)) end
		
		-- Warn fish have been spawned
		if not self.silent then
			DD.messageAllClients(DD.stringLocalize(self.messageKey, {fishCount = fishCount, fishName = string.lower(tostring(fishNames[fishType])), locationName = locationName}), {preset = 'badinfo'})
			for client in Client.ClientList do
				if client.Character ~= nil then DD.giveAfflictionCharacter(client.Character, 'notificationfx', 999) end
			end
		end
	end
})

-- Spawns Dampwood (Gloomwood) creatures
DD.eventFishCrowmen = DD.class(DD.eventFish, nil, {
	name = 'fishCrowmen',
	weight = 2.0,
	goodness = -4,
	minimunTimeElapsed = 20 * 60,
	
	locationTags = {'dd_wetsewer'},
	fishIdentifiers = {'crowmen'},
	fishNames = {
		crowmen = TextManager.Get('character.crowmen'),
	},
	minAmount = 6,
	maxAmount = 9,
	messageKey = 'fishMessageShort',
})