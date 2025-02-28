-- Crafting materials conveniently airdropped at the radio tower above the factory
DD.eventAirdrop = DD.class(DD.eventBase, function (self, spawnPosition, items, minAmount, maxAmount)
	self.spawnPosition = spawnPosition or self.spawnPosition
	self.items = items or self.items
	self.minAmount = minAmount or self.minAmount
	self.maxAmount = maxAmount or self.maxAmount
end, {
	name = 'airdrop',
	isMainEvent = false,
	cooldown = 60 * 2,
	weight = 2.5,
	goodness = 1,
	
	spawnPosition = 'dd_airdrop',
	crateIdentifier = 'metalcrate',
	items = {
		{identifier = 'phosphorus', amount = '2'},
		{identifier = 'magnesium', amount = '2'},
		{identifier = 'sodium', amount = '2'},
		{identifier = 'ethanol', amount = '2'},
		{identifier = 'organicfiber', amount = '2'},
		{identifier = 'plastic', amount = '4'},
		{identifier = 'steel', amount = '4'},
		{identifier = 'titaniumaluminiumalloy', amount = '2'},
		{identifier = 'copper', amount = '4'},
		{identifier = 'tin', amount = '2'},
		{identifier = 'lead', amount = '2'}
	},
	minAmount = 32,
	maxAmount = 40,
	message = DD.stringLocalize('airdropMessage'),
	
	onStart = function (self)
		local spawnPosition = self.spawnPosition
		local crateIdentifier = self.crateIdentifier
		local items = self.items
		local maxAmount = self.maxAmount
		local minAmount = self.minAmount
		
		local position
		if type(spawnPosition) == 'string' then
			position = DD.getLocation(function (item) return item.HasTag(spawnPosition) end).WorldPosition
		else
			position = spawnPosition
		end
		local amount = math.random(maxAmount - minAmount) + minAmount
		if maxAmount <= 0 then amount = 0 end
		
		-- Spawn crate at airdrop pos and fill it with items
		if (crateIdentifier == nil) or (crateIdentifier == 'none') then
			for n = 1, amount do
				local item = items[math.random(#items)]
				local script = item.script or function (spawnedItem) end
				for m = 1, item.amount do
					Entity.Spawner.AddItemToSpawnQueue(ItemPrefab.GetItemPrefab(item.identifier), position, nil, nil, script)
				end
			end
		else
			Entity.Spawner.AddItemToSpawnQueue(ItemPrefab.GetItemPrefab(crateIdentifier), position, nil, nil, function (spawnedItem)
				for n = 1, amount do
					local item = items[math.random(#items)]
					local script = item.script or function (spawnedItem) end
					for m = 1, item.amount do
						Entity.Spawner.AddItemToSpawnQueue(ItemPrefab.GetItemPrefab(item.identifier), spawnedItem.OwnInventory, nil, nil, script)
					end
				end
				self.item = spawnedItem
			end)
		end
		
		-- Timer until crate deletes itself (to avoid cluttering the map with crates)
		self.timer = 60 * 4
		
		-- Warn airdrop has been spawned
		DD.messageAllClients(DD.stringReplace(self.message, {amount = amount, minutes = self.timer / 60}), {preset = 'goodinfo'})
		for client in Client.ClientList do
			if client.Character ~= nil then DD.giveAfflictionCharacter(client.Character, 'notificationfx', 999) end
		end
	end,
	
	onThink = function (self)
		if (DD.thinkCounter % 30 ~= 0) or (not Game.RoundStarted) then return end
		local timesPerSecond = 2
		
		if self.timer <= 0 then
			self.finish()
		else
			self.timer = self.timer - 1 / timesPerSecond
		end
	end,
	
	onFinishAlways = function (self)
		if self.item ~= nil then
			Entity.Spawner.AddEntityToRemoveQueue(self.item)
		end
	end
})

-- Medical airdrop with crafting supplies
DD.eventAirdropMedical = DD.class(DD.eventAirdrop, nil, {
	name = 'airdropMedical',
	isMainEvent = false,
	cooldown = 60 * 2,
	weight = 1.5,
	goodness = 1.5,
	
	spawnPosition = 'dd_airdropmedical',
	crateIdentifier = 'mediccrate',
	items = {
		{identifier = 'organicfiber', amount = '4'},
		{identifier = 'ethanol', amount = '4'},
		{identifier = 'chlorine', amount = '4'},
		{identifier = 'opium', amount = '4'},
		{identifier = 'steel', amount = '4'},
		{identifier = 'sodium', amount = '2'},
		{identifier = 'adrenaline', amount = '2'},
		{identifier = 'calcium', amount = '2'},
		{identifier = 'alienblood', amount = '2'},
		{identifier = 'stabilozine', amount = '2'},
		{identifier = 'sulphuricacid', amount = '2'},
		{identifier = 'phosphorus', amount = '1'},
	},
	minAmount = 8,
	maxAmount = 12,
	message = DD.stringLocalize('airdropMedicalMessage'),
})

-- Security airdrop with guns and ammo
DD.eventAirdropSecurity = DD.class(DD.eventAirdrop, nil, {
	name = 'airdropSecurity',
	isMainEvent = false,
	cooldown = 60 * 2,
	weight = 1,
	goodness = 1.2,
	
	spawnPosition = 'dd_airdropsecurity',
	crateIdentifier = 'securemetalcrate',
	items = {
		{identifier = 'stungundart', amount = '4'},
		{identifier = 'flaregunround', amount = '6'},
		{identifier = 'revolverround', amount = '6'},
		{identifier = 'pistolmagazine', amount = '1'},
		{identifier = 'shotgunshell', amount = '5'},
		{identifier = 'shotgunshellblunt', amount = '5'},
		{identifier = 'riflebullet', amount = '6'},
		{identifier = 'pistoldrum', amount = '1'},
		{identifier = 'handcannonround', amount = '6'}
	},
	minAmount = 16,
	maxAmount = 20,
	message = DD.stringLocalize('airdropSecurityMessage'),
})

-- Separatist airdrop with guns
DD.eventAirdropSeparatist = DD.class(DD.eventAirdrop, nil, {
	name = 'airdropSeparatist',
	isMainEvent = false,
	cooldown = 60 * 2,
	weight = 1,
	goodness = -0.5,
	public = false,
	
	spawnPosition = 'dd_airdropseparatist',
	crateIdentifier = 'explosivecrate',
	items = {
		{identifier = 'clownmask', amount = '1'},
		{identifier = 'piratebodyarmor', amount = '1'},
		{identifier = 'smg', amount = '1', script = function (spawnedItem) Entity.Spawner.AddItemToSpawnQueue(ItemPrefab.GetItemPrefab('smgmagazine'), spawnedItem.OwnInventory, nil, nil, function (spawnedItem) end) end},
		{identifier = 'antiquerevolver', amount = '1', script = function (spawnedItem) for x = 1, 6 do Entity.Spawner.AddItemToSpawnQueue(ItemPrefab.GetItemPrefab('handcannonround'), spawnedItem.OwnInventory, nil, nil, function (spawnedItem) end) end end},
		{identifier = 'smgmagazine', amount = '2'},
		{identifier = 'fraggrenade', amount = '1'},
		{identifier = 'fakemoney', amount = '10'}
	},
	minAmount = 8,
	maxAmount = 12,
	message = DD.stringLocalize('airdropAntagMessage'),
})

-- Cultist airdrop with guns
DD.eventAirdropCultist = DD.class(DD.eventAirdrop, nil, {
	name = 'airdropCultist',
	isMainEvent = false,
	cooldown = 60 * 2,
	weight = 1,
	goodness = -0.5,
	public = false,
	
	spawnPosition = 'dd_airdropseparatist',
	crateIdentifier = 'explosivecrate',
	items = {
		{identifier = 'bloodcultistrobes', amount = '1', script = function (spawnedItem)
			Entity.Spawner.AddItemToSpawnQueue(ItemPrefab.GetItemPrefab('sacrificialdagger'), spawnedItem.OwnInventory, nil, nil, function (spawnedItem) end)
			Entity.Spawner.AddItemToSpawnQueue(ItemPrefab.GetItemPrefab('the1998'), spawnedItem.OwnInventory, nil, nil, function (spawnedItem) end)
		end},
		{identifier = 'tommygun', amount = '1', script = function (spawnedItem)
			Entity.Spawner.AddItemToSpawnQueue(ItemPrefab.GetItemPrefab('pistoldrum'), spawnedItem.OwnInventory, nil, nil, function (spawnedItem) end)
		end},
		{identifier = 'fakemoney', amount = '10'}
	},
	minAmount = 3,
	maxAmount = 6,
	message = DD.stringLocalize('airdropAntagMessage'),
})

-- Artifact airdrop
DD.eventAirdropArtifact = DD.class(DD.eventAirdrop, nil, {
	name = 'airdropArtifact',
	isMainEvent = false,
	cooldown = 60 * 3,
	weight = 2,
	goodness = 0.5,
	
	spawnPosition = 'dd_airdropartifact',
	crateIdentifier = 'none',
	items = {
		{identifier = 'skyholderartifact', amount = '1'},
		{identifier = 'thermalartifact', amount = '1'},
		{identifier = 'faradayartifact', amount = '1'},
		{identifier = 'nasonovartifact', amount = '1', script = function (spawnedItem) local event = DD.eventFish.new() event.silent = true event.locationTag = 'dd_dambasin' event.start(event) end},
		{identifier = 'psychosisartifact', amount = '1', script = function (spawnedItem) local event = DD.eventFish.new() event.silent = true event.locationTag = 'dd_wetsewer' event.start(event) end},
	},
	minAmount = 1,
	maxAmount = 1,
	message = DD.stringLocalize('airdropArtifactMessage'),
})