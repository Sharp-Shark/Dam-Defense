-- Merasmus the Wizard has come for your souls!
DD.eventWizard = DD.class(DD.eventBase, function (self, wizard)
	self.wizard = wizard
end, {
	paramType = {'client'},
	clientKeys = {'wizard'},
	public = true,
	
	name = 'wizard',
	instanceCap = 1,
	isMainEvent = false,
	cooldown = 60 * 3,
	weight = 2,
	goodness = -3,
	minimunDeadPercentage = 0.01,
	minimunTimeElapsed = 10 * 60,
	
	onStart = function (self)
		-- pick client to be wizard
		if self.wizard == nil then
			for client in DD.arrShuffle(Client.ClientList) do
				if DD.isClientRespawnable(client) and client.InGame then
					self.wizard = client
					break
				end
			end
		end
		
		-- event requires 5 or more players
		if (self.wizard == nil) or ((not self.manuallyTriggered) and (DD.tableSize(Client.ClientList) <= 4)) then
			self.fail('conditions to start could not be met')
			return
		else
			local month = os.date('*t', os.time()).month
			local jolly = (month == 1) or (month == 12) -- january or december
			
			-- Spawn wizard
			local job = 'wizard'
			local waypoint = DD.findRandomWaypointByJob(job)
			if waypoint == nil then waypoint = DD.findRandomWaypointByJob('clown') end
			local pos = waypoint.WorldPosition
			local subclass = jolly and 1 or 0 -- wizard is replace with santa claus during december
			local character = DD.spawnHuman(self.wizard, job, pos, nil, subclass)
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
		
		if not DD.isClientCharacterAlive(self.wizard) then
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
		DD.messageAllClients(DD.stringLocalize('wizardEnd'), {preset = 'goodinfo'})
	end,
})