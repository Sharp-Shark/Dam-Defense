-- Spawn heavily armed fellas whose objective is to explode the reactor and kill anyone who dares stand in their way
DD.eventNukies = DD.class(DD.eventBase, function (self, nukies)
	self.nukies = nukies
	if type(self.nukies) == 'table' then
		self.nukiesSet = DD.toSet(self.nukies)
	end
end, {
	paramType = {'clientList'},
	clientKeys = {'nukies'},
	
	name = 'nukies',
	isMainEvent = true,
	cooldown = 60 * 2,
	weight = 3,
	goodness = -1.5,
	minimunDeadPercentage  = 0.4,
	
	onStart = function (self)
		self.nukiesWon = false
	
		-- Find reactors
		self.reactors = {}
		for item in Submarine.MainSub.GetItems(false) do
			if item.HasTag('reactor') then
				table.insert(self.reactors, item)
			end
		end
		
		-- Pick nukies
		if self.nukies == nil then
			self.nukiesSet = {}
			self.nukies = {}
			for client in DD.arrShuffle(Client.ClientList) do
				if DD.isClientRespawnable(client) and DD.eventDirector.isClientBelowEventCap(client) then
					table.insert(self.nukies, client)
					self.nukiesSet[client] = true
				end
			end
		end
		
		if DD.tableSize(self.nukies) <= 0 then
			self.fail()
			return
		else
			-- Spawn nukies and do client messages
			for client in Client.ClientList do
				if self.nukiesSet[client] then
					local job = 'jet'
					local pos = DD.findRandomWaypointByJob(job).WorldPosition
					local character = DD.spawnHuman(client, job, pos)
					character.SetOriginalTeamAndChangeTeam(CharacterTeamType.Team1, true)
					character.UpdateTeam()
					DD.messageClient(client, 'You are a nukie! Work with your fellow nukies to explode the reactor and win the round.', {preset = 'crit'})
				else
					DD.messageClient(client, 'Intel reports nukie activity on the area. Keep the crew, and most importantly the reactor safe from them!', {preset = 'crit'})
				end
				if client.Character ~= nil then DD.giveAfflictionCharacter(client.Character, 'notificationfx', 999) end
			end
		end
	end,
	
	onThink = function (self)
		if (DD.thinkCounter % 30 ~= 0) or (not Game.RoundStarted) then return end
		local timesPerSecond = 2
	
		-- See if any reactor is unbroken
		local anyReactorIsUnbroken = false
		for reactor in self.reactors do
			if reactor.Condition > 0 then
				anyReactorIsUnbroken = true
				break
			end
		end
		
		-- See if any non-nukie is alive
		local anyNonNukieAlive = false
		for client in Client.ClientList do
			if DD.isClientCharacterAlive(client) and (client.Character.SpeciesName == 'human') and (not self.nukiesSet[client]) then
				anyNonNukieAlive = true
				break
			end
		end
		
		-- See if any nukie is alive
		local anyNukieIsAlive = false
		for key, nukie in pairs(self.nukies) do
			if DD.isClientCharacterAlive(nukie) then
				if not DD.isCharacterArrested(nukie.Character) then
					anyNukieIsAlive = true
				end
			else
				DD.messageClient(nukie, 'You have died and are not an antagonist anymore!', {preset = 'crit'})
				self.nukies[key] = nil
				self.nukiesSet[nukie] = nil
			end
		end
		
		-- Increase time pressure
		local timeToExplode = 12 * 60 -- in seconds
		for client in self.nukies do
			DD.giveAfflictionCharacter(client.Character, 'timepressure', 60/timeToExplode/timesPerSecond)
		end
		
		-- End event if all reactors are broken or all nukies are dead
		if not anyReactorIsUnbroken then
			self.nukiesWon = true
			self.finish()
			return
		end
		if not anyNonNukieAlive then
			self.nukiesWon = true
			self.finish()
			return
		end
		if not anyNukieIsAlive then
			self.finish()
		end
	end,
	
	onCharacterDeath = function (self, character)
		local client = DD.findClientByCharacter(character)
		if client == nil then return end
		if self.nukiesSet[client] then
			for key, nukie in pairs(self.nukies) do
				if not DD.isClientCharacterAlive(nukie) then
					DD.messageClient(nukie, 'You have died and are not an antagonist anymore!', {preset = 'crit'})
					self.nukies[key] = nil
					self.nukiesSet[nukie] = nil
				end
			end	
		end
	end,
	
	onFinish = function (self)
		-- This is the end, beautiful friend. This is the end, my only friend. The end of our elaborated plans, the end of everything that stands. The end
		for client in Client.ClientList do
			if client.Character ~= nil then DD.giveAfflictionCharacter(client.Character, 'notificationfx', 999) end
		end
		for client in self.nukies do
			if client.Character.CharacterHealth.GetAffliction('timepressure', true) ~= nil then
				client.Character.CharacterHealth.GetAffliction('timepressure', true).SetStrength(0)
			end
		end
		if self.nukiesWon then
			DD.messageAllClients('Nukies have won this round! Round ending in 10 seconds.', {preset = 'crit'})
			DD.roundData.roundEnding = true
			Timer.Wait(function ()
				Game.EndGame()
			end, 10 * 1000)
		else
			DD.messageAllClients('All nukies have been neutralized.', {preset = 'goodinfo'})
		end
	end
})

-- Nukies ghost role event
DD.eventGhostRoleNukies = DD.class(DD.eventGhostRole, nil, {
	paramType = {},
	clientKeys = {'volunteers'},
	
	name = 'ghostRoleNukies',
	isMainEvent = true,
	cooldown = 60 * 3,
	weight = 2,
	goodness = -1.5,
	
	eventClass = DD.eventNukies
})