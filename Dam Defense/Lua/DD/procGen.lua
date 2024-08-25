if CLIENT and Game.IsMultiplayer then return end

DD.lootTables = {
	['outposttrashcan'] = {
		attempts = 3,
		chance = 0.3,
		{identifier = 'fulguriumfuelrodvolatile', weight = 0.1},
		{identifier = 'tbsyringe', weight = 0.1},
		{identifier = 'uex', weight = 0.1},
		{identifier = 'detonator', weight = 0.2},
		{identifier = 'pipegun', weight = 0.1},
		{identifier = 'flaregun', weight = 0.1},
		{identifier = 'wifitrigger', weight = 0.1},
		{identifier = 'brassknuckle', weight = 0.3},
		{identifier = 'divingknife', weight = 0.4},
		{identifier = 'redwire', weight = 0.4, maxAmount = 4},
		{identifier = 'chloralhydrate', weight = 0.4, maxAmount = 2},
		{identifier = 'meth', weight = 0.5, maxAmount = 2},
		{identifier = 'antidama2', weight = 0.3, maxAmount = 2},
		{identifier = 'rum', weight = 0.5},
		{identifier = 'nitroglycerin', weight = 0.2},
		{identifier = 'fakemoney', weight = 0.5, minAmount = 4, maxAmount = 10},
		{identifier = 'antibleeding3', weight = 1},
		{identifier = 'opium', weight = 1, maxAmount = 2},
		{identifier = 'ethanol', weight = 1, maxAmount = 2},
		{identifier = 'money', weight = 1, maxAmount = 2},
		{identifier = 'cigar', weight = 1},
		{identifier = 'bloodsampler', weight = 1},
		{identifier = 'crowbar', weight = 1},
		{identifier = 'wrench', weight = 1},
		{identifier = 'copper', weight = 1},
		{identifier = 'antibleeding1', weight = 1, maxAmount = 2},
		{identifier = 'revolverround', weight = 0.5, maxAmount = 6},
		{identifier = 'flaregunround', weight = 0.5, maxAmount = 6},
		{identifier = 'shotgunshell', weight = 0.2, maxAmount = 6},
	},
	['suppliescontainer'] = {
		attempts = 4,
		chance = 0.3,
		{identifier = 'tbsyringe', weight = 0.1},
		{identifier = 'uex', weight = 0.1},
		{identifier = 'detonator', weight = 0.2},
		{identifier = 'pipegun', weight = 0.1},
		{identifier = 'flaregun', weight = 0.1},
		{identifier = 'wifitrigger', weight = 0.1},
		{identifier = 'brassknuckle', weight = 0.3},
		{identifier = 'divingknife', weight = 0.4},
		{identifier = 'redwire', weight = 0.4, maxAmount = 4},
		{identifier = 'chloralhydrate', weight = 0.4, maxAmount = 2},
		{identifier = 'meth', weight = 0.5, maxAmount = 2},
		{identifier = 'antidama2', weight = 0.3, maxAmount = 2},
		{identifier = 'rum', weight = 0.5},
		{identifier = 'nitroglycerin', weight = 0.2},
		{identifier = 'fakemoney', weight = 0.5, minAmount = 4, maxAmount = 10},
		{identifier = 'antibleeding3', weight = 1},
		{identifier = 'opium', weight = 1, maxAmount = 2},
		{identifier = 'ethanol', weight = 1, maxAmount = 2},
		{identifier = 'money', weight = 1, maxAmount = 2},
		{identifier = 'cigar', weight = 1},
		{identifier = 'bloodsampler', weight = 1},
		{identifier = 'crowbar', weight = 1},
		{identifier = 'wrench', weight = 1},
		{identifier = 'copper', weight = 1},
		{identifier = 'antibleeding1', weight = 1, maxAmount = 2},
		{identifier = 'revolverround', weight = 0.5, maxAmount = 6},
		{identifier = 'flaregunround', weight = 0.5, maxAmount = 6},
		{identifier = 'shotgunshell', weight = 0.2, maxAmount = 6},
	},
	['cabinet'] = {
		attempts = 6,
		chance = 0.3,
		{identifier = 'tbsyringe', weight = 0.1},
		{identifier = 'uex', weight = 0.1},
		{identifier = 'detonator', weight = 0.2},
		{identifier = 'pipegun', weight = 0.1},
		{identifier = 'flaregun', weight = 0.1},
		{identifier = 'wifitrigger', weight = 0.1},
		{identifier = 'brassknuckle', weight = 0.3},
		{identifier = 'divingknife', weight = 0.4},
		{identifier = 'redwire', weight = 0.4, maxAmount = 4},
		{identifier = 'chloralhydrate', weight = 0.4, maxAmount = 2},
		{identifier = 'meth', weight = 0.5, maxAmount = 2},
		{identifier = 'antidama2', weight = 0.3, maxAmount = 2},
		{identifier = 'rum', weight = 0.5},
		{identifier = 'nitroglycerin', weight = 0.2},
		{identifier = 'fakemoney', weight = 0.5, minAmount = 4, maxAmount = 10},
		{identifier = 'antibleeding3', weight = 1},
		{identifier = 'opium', weight = 1, maxAmount = 2},
		{identifier = 'ethanol', weight = 1, maxAmount = 2},
		{identifier = 'money', weight = 1, maxAmount = 2},
		{identifier = 'cigar', weight = 1},
		{identifier = 'bloodsampler', weight = 1},
		{identifier = 'crowbar', weight = 1},
		{identifier = 'wrench', weight = 1},
		{identifier = 'copper', weight = 1},
		{identifier = 'antibleeding1', weight = 1, maxAmount = 2},
		{identifier = 'revolverround', weight = 0.5, maxAmount = 6},
		{identifier = 'flaregunround', weight = 0.5, maxAmount = 6},
		{identifier = 'shotgunshell', weight = 0.2, maxAmount = 6},
	},
	['medcontainer'] = {
		attempts = 8,
		chance = 0.3,
		{identifier = 'disposabledivingmask', weight = 0.5},
		{identifier = 'divingknife', weight = 0.2},
		{identifier = 'antibleeding3', weight = 0.5},
		{identifier = 'meth', weight = 0.5, maxAmount = 2},
		{identifier = 'antibloodloss1', weight = 1},
		{identifier = 'antibiotics', weight = 1, maxAmount = 2},
		{identifier = 'myxotoxin', weight = 2, maxAmount = 2},
		{identifier = 'opium', weight = 2, maxAmount = 4},
		{identifier = 'antibleeding1', weight = 2, maxAmount = 4},
		{identifier = 'ethanol', weight = 2, maxAmount = 4},
	},
	['extinguisherholder'] = {
		chance = 0.95,
		{identifier = 'extinguisher', weight = 19},
		{identifier = 'makeshiftflamer', weight = 1},
	},
}

DD.roundStartFunctions.procGen = function ()
	if not Game.RoundStarted then return end
	
	local delay = 10
	for item in Submarine.MainSub.GetItems(true) do
		local inventory = item.OwnInventory
		if inventory ~= nil then
			local count = inventory.Capacity - inventory.EmptySlotCount
			for tag, tbl in pairs(DD.lootTables) do
				if item.HasTag(tag) then
					for n = 1, (tbl.attempts or 1) do
						if ((tbl.chance or 1) >= math.random()) and (count > 0) then
							count = count - 1
						
							local weights = {}
							for key, value in pairs(tbl) do
								if type(value) == 'table' then
									weights[key] = value.weight
								end
							end
							local winner = DD.weightedRandom(tbl, weights)
							
							local identifier = winner.identifier
							local amount = winner.amount or 1
							local minAmount = winner.minAmount or amount
							local maxAmount = winner.maxAmount or amount
							amount = math.random(minAmount, maxAmount)
							
							if identifier ~= nil then
								for n = 1, amount do
									Timer.Wait(function ()
									Entity.Spawner.AddItemToSpawnQueue(ItemPrefab.GetItemPrefab(identifier), inventory, nil, nil, function (spawnedItem) end)
									end, delay)
									delay = delay + 10
								end
							end
						end
					end
				end
			end
		end
	end
end