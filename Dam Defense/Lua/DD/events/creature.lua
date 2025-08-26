-- Spawn an attackbot
DD.eventAttackbot = DD.class(DD.eventBase, nil, {
	name = 'attackbot',
	isMainEvent = false,
	cooldown = 60 * 2,
	weight = 2,
	goodness = -3,
	minimunTimeElapsed = 12 * 60,
	
	onStart = function (self)
		local position = DD.getLocation(function (item) return item.HasTag('dd_airdropartifact') end).WorldPosition
		Entity.Spawner.AddCharacterToSpawnQueue('attackbot', position, function (character) return end)
		
		-- Warn bot has been spawned
		DD.messageAllClients(DD.stringLocalize('airdropAttackbotMessage'), {preset = 'badinfo'})
		for client in Client.ClientList do
			if client.Character ~= nil then DD.giveAfflictionCharacter(client.Character, 'notificationfx', 999) end
		end
	end
})

-- Spawn a fractal guardian
DD.eventFractalGuardian = DD.class(DD.eventBase, nil, {
	name = 'fractalGuardian',
	isMainEvent = false,
	cooldown = 60 * 2,
	weight = 1.5,
	goodness = -2,
	
	onStart = function (self)
		local location = DD.getLocation(function (item) return item.HasTag('dd_wetsewer') end)
		local locationName = tostring(location.CurrentHull.RoomName)
		if TextManager.Get(locationName) ~= nil then locationName = tostring(TextManager.Get(locationName)) end
		
		Entity.Spawner.AddCharacterToSpawnQueue('fractalguardian', location.WorldPosition, function (character)
			return
		end)
		
		-- Warn bot has been spawned
		DD.messageAllClients(DD.stringLocalize('fishMessageBoss', {fishName = 'fractal guardian', locationName = locationName}), {preset = 'badinfo'})
		for client in Client.ClientList do
			if client.Character ~= nil then DD.giveAfflictionCharacter(client.Character, 'notificationfx', 999) end
		end
	end
})