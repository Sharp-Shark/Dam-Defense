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
	cooldown = 60 * 6,
	weight = 3,
	goodness = -4,
	minimunDeadPercentage = 0.1,
	minimunTimeElapsed = 12 * 60,
	
	respawnTickets = 0,
	lateJoinBlacklistSet = {},
	lateJoinSpawn = function (self, client)
		if self.lateJoinBlacklistSet[client.AccountId.StringRepresentation] then return end
		if self.respawnTickets < 1 then
			DD.messageClient(client, DD.stringLocalize('lateJoinMessageNoTickets'), {preset = 'crit'})
			return true
		end
		self.lateJoinBlacklistSet[client.AccountId.StringRepresentation] = true
		
		local job = 'jet'
		local pos = DD.findRandomWaypointByJob(job).WorldPosition
		local character = DD.spawnHuman(client, job, pos, nil, 0)
		character.SetOriginalTeamAndChangeTeam(CharacterTeamType.Team2, true)
		character.UpdateTeam()
		
		table.insert(self.nukies, client)
		self.nukiesSet[client] = true
		
		self.respawnTickets = self.respawnTickets - 1
		DD.messageAllClients(DD.stringLocalize('nukiesTicketLost', {tickets = self.respawnTickets}), {preset = 'info'})
		
		return true
	end,
	
	onStart = function (self)
		self.nukiesWon = false
		self.respawnTickets = 0
		
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
			self.fail('conditions to start could not be met')
			return
		else
			-- Spawn nukies and do client messages
			for client in Client.ClientList do
				if self.nukiesSet[client] then
					local job = 'jet'
					local pos = DD.findRandomWaypointByJob(job).WorldPosition
					local character = DD.spawnHuman(client, job, pos, nil, 0)
					character.SetOriginalTeamAndChangeTeam(CharacterTeamType.Team2, true)
					character.UpdateTeam()
					DD.messageClient(client, DD.stringLocalize('nukiesMessageNukies'), {preset = 'crit'})
				else
					DD.messageClient(client, DD.stringLocalize('nukiesMessagePublic'), {preset = 'crit'})
				end
				if client.Character ~= nil then DD.giveAfflictionCharacter(client.Character, 'announcementfx', 999) end
			end
		end
	end,
	
	onThink = function (self)
		if (DD.thinkCounter % 30 ~= 0) or (not Game.RoundStarted) then return end
		local timesPerSecond = 2
	
		-- See if any reactor is unbroken
		local anyReactorIsUnbroken = false
		for reactor in DD.reactors do
			if reactor.Condition > 0 then
				anyReactorIsUnbroken = true
				break
			end
		end
		
		-- See if any non-nukie is alive
		local anyNonNukieAlive = false
		for client in Client.ClientList do
			if (not DD.isClientAntagNonTarget(client)) and (not self.nukiesSet[client]) then
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
				DD.messageClient(nukie, DD.stringLocalize('antagDead'), {preset = 'crit'})
				self.nukies[key] = nil
				self.nukiesSet[nukie] = nil
			end
		end
		
		-- Increase time pressure
		local timeToExplode = 10 * 60 -- in seconds
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
					DD.messageClient(nukie, DD.stringLocalize('antagDead'), {preset = 'crit'})
					self.nukies[key] = nil
					self.nukiesSet[nukie] = nil
				end
			end	
		elseif character.SpeciesName == 'human' then
			if (character.LastAttacker ~= nil) and self.nukiesSet[DD.findClientByCharacter(character.LastAttacker)] then
				self.respawnTickets = self.respawnTickets + 1
				DD.messageAllClients(DD.stringLocalize('nukiesTicketGained', {tickets = self.respawnTickets}), {preset = 'info'})
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
			DD.messageAllClients(DD.stringLocalize('nukiesEndVictory'), {preset = 'crit'})
			DD.roundData.roundEnding = true
			Timer.Wait(function ()
				Game.EndGame()
			end, 10 * 1000)
		else
			DD.messageAllClients(DD.stringLocalize('nukiesEnd'), {preset = 'goodinfo'})
		end
	end
})