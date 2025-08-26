-- Spawn attackbots
DD.eventAttackbot = DD.class(DD.eventBase, nil, {
	name = 'attackbot',
	isMainEvent = false,
	cooldown = 60 * 2,
	weight = 2,
	goodness = -3,
	minimunTimeElapsed = 12 * 60,
	
	onStart = function (self)
		local position = DD.getLocation(function (item) return item.HasTag('dd_wetsewer') end).WorldPosition
		Entity.Spawner.AddCharacterToSpawnQueue('fractalguardian', position, function (character) return end)
		
		-- Warn bot has been spawned
		DD.messageAllClients(DD.stringLocalize('airdropAttackbotMessage'), {preset = 'badinfo'})
		for client in Client.ClientList do
			if client.Character ~= nil then DD.giveAfflictionCharacter(client.Character, 'notificationfx', 999) end
		end
	end
})