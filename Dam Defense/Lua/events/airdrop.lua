-- Crafting materials conveniently airdropped at the radio tower above the factory
DD.eventAirdrop = DD.class(DD.eventBase, nil, {
	name = 'airdrop',
	isMainEvent = false,
	cooldown = 60 * 2,
	weight = 2,
	goodness = 1,
	
	spawnPosition = 'dd_airdrop',
	crateIdentifier = 'metalcrate',
	items = {
		{identifier = 'phosphorus', amount = '1'},
		{identifier = 'iron', amount = '1'},
		{identifier = 'steel', amount = '1'},
		{identifier = 'carbon', amount = '1'},
		{identifier = 'silicon', amount = '1'},
		{identifier = 'copper', amount = '1'},
		{identifier = 'tin', amount = '1'},
		{identifier = 'plastic', amount = '1'},
		{identifier = 'lead', amount = '1'},
		{identifier = 'aluminium', amount = '1'},
		{identifier = 'rubber', amount = '1'},
		{identifier = 'sodium', amount = '1'},
		{identifier = 'organicfiber', amount = '1'},
		{identifier = 'ethanol', amount = '1'}
	},
	minAmount = 16,
	maxAmount = 20,
	message = 'Airdrop with {amount} items for crafting arrived at the radio tower above the factory. Crate despawns in {minutes} minutes!',
	
	onStart = function (self)
		local spawnPosition = self.spawnPosition
		local crateIdentifier = self.crateIdentifier
		local items = self.items
		local maxAmount = self.maxAmount
		local minAmount = self.minAmount
		
		local position = DD.getLocation(function (item) return item.HasTag(spawnPosition) end).WorldPosition
		local amount = math.random(maxAmount - minAmount) + minAmount
		
		-- Spawn crate at airdrop pos and fill it with items
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
		
		-- Timer until crate deletes itself (to avoid cluttering the map with crates)
		self.timer = 60 * 5
		
		-- Warn airdrop has been spawned
		DD.messageAllClients(DD.stringReplace(self.message, {amount = amount, minutes = self.timer / 60}), {preset = 'goodinfo'})
	end,
	
	onThink = function (self)
		if (DD.thinkCounter % 30 ~= 0) or (not Game.RoundStarted) then return end
		
		if self.timer <= 0 then
			Entity.Spawner.AddEntityToRemoveQueue(self.item)
			self.finish()
		else
			self.timer = self.timer - 0.5
		end
	end
})

-- Medical airdrop with crafting supplies
DD.eventAirdropMedical = DD.class(DD.eventAirdrop, nil, {
	name = 'airdropMedical',
	isMainEvent = false,
	cooldown = 60 * 2,
	weight = 2,
	goodness = 1.5,
	
	spawnPosition = 'dd_airdropmedical',
	crateIdentifier = 'mediccrate',
	items = {
		{identifier = 'organicfiber', amount = '2'},
		{identifier = 'ethanol', amount = '2'},
		{identifier = 'chlorine', amount = '2'},
		{identifier = 'opium', amount = '2'},
		{identifier = 'steel', amount = '2'},
		{identifier = 'phosphorus', amount = '1'},
		{identifier = 'sodium', amount = '1'},
		{identifier = 'adrenaline', amount = '1'},
		{identifier = 'calcium', amount = '1'},
		{identifier = 'alienblood', amount = '1'},
		{identifier = 'stabilozine', amount = '1'},
		{identifier = 'sulphuricacid', amount = '1'}
	},
	minAmount = 8,
	maxAmount = 12,
	message = 'Airdrop with {amount} items for crafting arrived at hospital rooftops. Crate despawns in {minutes} minutes!'
})

-- Security airdrop with guns and ammo
DD.eventAirdropSecurity = DD.class(DD.eventAirdrop, nil, {
	name = 'airdropSecurity',
	isMainEvent = false,
	cooldown = 60 * 2,
	weight = 1.5,
	goodness = 1.5,
	
	spawnPosition = 'dd_airdropsecurity',
	crateIdentifier = 'securemetalcrate',
	items = {
		{identifier = 'stungundart', amount = '2'},
		{identifier = 'revolverround', amount = '6'},
		{identifier = 'pistolmagazine', amount = '1'},
		{identifier = 'shotgunshell', amount = '5'},
		{identifier = 'riflebullet', amount = '3'},
		{identifier = 'shotgunshellblunt', amount = '3'},
		{identifier = 'handcannonround', amount = '3'}
	},
	minAmount = 16,
	maxAmount = 20,
	message = 'Airdrop with {amount} items worth of ammo arrived at the prison rooftops. Crate despawns in {minutes} minutes!'
})

-- Separatist airdrop with guns
DD.eventAirdropSeparatist = DD.class(DD.eventAirdrop, nil, {
	name = 'airdropSeparatist',
	isMainEvent = false,
	cooldown = 60 * 2,
	weight = 1,
	goodness = -0.5,
	
	spawnPosition = 'dd_airdropseparatist',
	crateIdentifier = 'explosivecrate',
	items = {
		{identifier = 'clownmask', amount = '1'},
		{identifier = 'piratebodyarmor', amount = '1'},
		{identifier = 'separatistrifle', amount = '1', script = function (spawnedItem) Entity.Spawner.AddItemToSpawnQueue(ItemPrefab.GetItemPrefab('762magazine'), spawnedItem.OwnInventory, nil, nil, function (spawnedItem) end) end},
		{identifier = 'antiquerevolver', amount = '1', script = function (spawnedItem) for x = 1, 6 do  Entity.Spawner.AddItemToSpawnQueue(ItemPrefab.GetItemPrefab('handcannonround'), spawnedItem.OwnInventory, nil, nil, function (spawnedItem) end) end end},
		{identifier = '762magazine', amount = '1'},
		{identifier = 'handcannonround', amount = '6'},
		{identifier = 'fraggrenade', amount = '1'}
	},
	minAmount = 8,
	maxAmount = 12,
	message = 'Airdrop with {amount} items for "crafting" (wink wink) arrived at the radio tower above the slums. Crate despawns in {minutes} minutes!'
})