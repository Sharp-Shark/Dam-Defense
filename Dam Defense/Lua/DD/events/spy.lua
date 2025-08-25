-- this spy has already breached our defenses
DD.eventSpy = DD.class(DD.eventBase, function (self, spy)
	self.spy = spy
end, {
	paramType = {'client'},
	clientKeys = {'spy'},
	public = false,
	
	name = 'spy',
	instanceCap = 1,
	isMainEvent = false,
	cooldown = 60 * 3,
	weight = 2,
	goodness = -2,
	minimunDeadPercentage = 0.01,
	
	onStart = function (self)
		-- pick client to be spy
		if self.spy == nil then
			for client in DD.arrShuffle(Client.ClientList) do
				if DD.isClientRespawnable(client) and client.InGame then
					self.spy = client
					break
				end
			end
		end
		
		-- event requires 5 or more players
		if (self.spy == nil) or ((not self.manuallyTriggered) and (DD.tableSize(Client.ClientList) <= 4)) then
			self.fail('conditions to start could not be met')
			return
		else
			-- Spawn spy
			local job = 'spy'
			local waypoint = DD.findRandomWaypointByJob(job)
			if waypoint == nil then waypoint = DD.findRandomWaypointByJob('clown') end
			local pos = waypoint.WorldPosition
			local character = DD.spawnHuman(self.spy, job, pos)
			character.SetOriginalTeamAndChangeTeam(CharacterTeamType.Team1, true)
			character.UpdateTeam()
		end
	end,
	
	onThink = function (self)
		if (DD.thinkCounter % 30 ~= 0) or (not Game.RoundStarted) then return end
		local timesPerSecond = 2
		
		if self.spy == nil then
			self.fail('"self.spy" is nil at "onThink"')
			return
		end
		
		if DD.isClientCharacterAlive(self.spy) then
			if DD.isCharacterArrested(self.spy.Character) then
				self.finish()
			end
		else
			self.finish()
		end
	end,
	
	onCharacterDeath = function (self, character)
		if self.spy == nil then
			self.fail('"self.spy" is nil at "onCharacterDeath"')
			return
		end
		
		if (self.spy.Character == nil) or (self.spy.Character == character) then
			self.finish()
		end
	end,
	
	onFinishAlways = function (self)
		if (self.spy ~= nil) and DD.isClientCharacterAlive(self.spy) then
			DD.giveAfflictionCharacter(self.spy.Character, 'beepingbomb', 5)
		end
	end
})