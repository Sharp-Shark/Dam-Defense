-- Merasmus the Wizard has come for your souls!
DD.eventWizard = DD.class(DD.eventBase, function (self, wizard)
	self.wizard = wizard
end, {
	paramType = {'client'},
	clientKeys = {'wizard'},
	public = false,
	
	name = 'wizard',
	instanceCap = 1,
	isMainEvent = false,
	cooldown = 60 * 3,
	weight = 1.5,
	goodness = -1,
	
	onStart = function (self)
		self.wizardWon = false
		
		-- pick client to be wizard
		local ignorePlayerCount = false
		if self.wizard ~= nil then
			ignorePlayerCount = true
		else
			for client in DD.arrShuffle(Client.ClientList) do
				if DD.isClientRespawnable(client) and client.InGame then
					self.wizard = client
					break
				end
			end
		end
		
		-- event requires 5 or more players
		if (self.wizard == nil) or ((not ignorePlayerCount) and (DD.tableSize(Client.ClientList) <= 4)) then
			self.fail('conditions to start could not be met')
			return
		else
			-- Spawn wizard
			local job = 'wizard'
			local waypoint = DD.findRandomWaypointByJob(job)
			if waypoint == nil then waypoint = DD.findRandomWaypointByJob('clown') end
			local pos = waypoint.WorldPosition
			local character = DD.spawnHuman(self.wizard, job, pos)
			character.SetOriginalTeamAndChangeTeam(CharacterTeamType.Team1, true)
			character.UpdateTeam()
		end
	end,
	
	onThink = function (self)
		if (DD.thinkCounter % 30 ~= 0) or (not Game.RoundStarted) then return end
		local timesPerSecond = 2
		
		if self.wizard == nil then
			self.fail('"self.wizard" is nil at "onThink"')
			return
		end
		
		-- see if anyone else is alive
		local anyoneAlive = false
		for client in Client.ClientList do
			if DD.isClientCharacterAlive(client) and (client.Character.SpeciesName == 'human') and (client ~= self.wizard) then
				anyoneAlive = true
				break
			end
		end
		
		if not DD.isClientCharacterAlive(self.wizard) then
			self.finish()
		elseif not anyoneAlive then
			self.wizardWon = true
			self.finish()
		end
	end,
	
	onCharacterDeath = function (self, character)
		if self.wizard == nil then
			self.fail('"self.wizard" is nil at "onCharacterDeath"')
			return
		end
		
		if (self.wizard.Character == nil) or (self.wizard.Character == character) then
			self.finish()
		end
	end,
	
	onFinish = function (self)
		if self.wizardWon then
			DD.messageAllClients(DD.stringLocalize('wizardEndVictory'), {preset = 'crit'})
			DD.roundData.roundEnding = true
			Timer.Wait(function ()
				Game.EndGame()
			end, 10 * 1000)
		else
			DD.messageAllClients(DD.stringLocalize('wizardEnd'), {preset = 'goodinfo'})
			if self.wizard ~= nil then DD.messageClient(self.wizard, DD.stringLocalize('antagDead'), {preset = 'crit'}) end
		end
	end,
})