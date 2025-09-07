-- If there are too many husks, regular respawning gets disabled
DD.eventQuarantine = DD.class(DD.eventBase, nil, {
	paramType = {},
	clientKeys = {},
	public = true,
	
	name = 'quarantine',
	isMainEvent = true,
	cooldown = 60,
	weight = 0,
	goodness = -3,
	
	lateJoinSpawn = function (self, client)
		local position = DD.getLocation(function (item) return item.HasTag('dd_wetsewer') end).WorldPosition
		Entity.Spawner.AddCharacterToSpawnQueue('husk', position, function (character)
			client.SetClientCharacter(character)
		end)
		
		return true
	end,
	
	updateCharacterList = function (self)
		self.humans = {}
		self.husks = {}
		for client in Client.ClientList do
			if DD.isClientCharacterAlive(client) then
				if client.Character.SpeciesName == 'Human' then
					table.insert(self.humans, client)
				elseif DD.isCharacterHusk(client.Character) then
					table.insert(self.husks, client)
				end
			end
		end
	end,
	
	onStart = function (self)
		self.husksWon = false
		self.timer = 60 * 3
		
		self.updateCharacterList()
		
		-- Event requires atleast 1 human and 1 husk to start
		if ((#self.husks == 0) or (#self.humans == 0)) and not self.manuallyTriggered then
			self.fail('conditions to start could not be met')
			return
		else
			for client in Client.ClientList do
				if client.Character ~= nil then DD.giveAfflictionCharacter(client.Character, 'notificationfx', 999) end
			end
			DD.messageAllClients(DD.stringLocalize('quarantineMessage'), {preset = 'goodinfo'})
		end
	end,
	
	onThink = function (self)
		if (DD.thinkCounter % 30 ~= 0) or (not Game.RoundStarted) then return end
		local timesPerSecond = 2
		
		self.timer = self.timer - 1 / timesPerSecond
		if self.timer < 0 then
			self.updateCharacterList()
			if (#self.humans > #self.husks) or (#self.husks == 0) or (self.timer < -60 * 10) then
				self.finish()
			end
		end
	end,
	
	onFinish = function (self)
		-- This is the end, beautiful friend. This is the end, my only friend. The end of our elaborated plans, the end of everything that stands. The end
		if not DD.roundEnding then
			for client in Client.ClientList do
				if client.Character ~= nil then DD.giveAfflictionCharacter(client.Character, 'notificationfx', 999) end
			end
			DD.messageAllClients(DD.stringLocalize('quarantineEnd'), {preset = 'goodinfo'})
		end
	end,
	
	onFinishAlways = function (self)
	end
})

local quarantineCooldown = 60
DD.thinkFunctions.quarantine = function ()
	if (DD.thinkCounter % 60 ~= 0) or (not Game.RoundStarted) then return end
	local timesPerSecond = 1
	
	if #DD.eventDirector.getMainEvents() == 0 then
		if quarantineCooldown > 0 then
			quarantineCooldown = quarantineCooldown - 1 / timesPerSecond
			return
		end
		local humans = {}
		local husks = {}
		for client in Client.ClientList do
			if DD.isClientCharacterAlive(client) then
				if client.Character.SpeciesName == 'Human' then
					table.insert(humans, client)
				elseif DD.isCharacterHusk(client.Character) then
					table.insert(husks, client)
				end
			end
		end
		if (#husks > #humans) and (#husks >= math.ceil(#Client.ClientList / 3)) then
			quarantineCooldown = 60 * 3
			DD.eventDirector.startNewEvent(DD.eventQuarantine)
		end
	end
end