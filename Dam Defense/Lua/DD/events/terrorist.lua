-- terrorist suicide
DD.eventTerrorist = DD.class(DD.eventBase, function (self, terrorist)
	self.terrorist = terrorist
end, {
	paramType = {'client'},
	clientKeys = {'terrorist'},
	public = false,
	
	name = 'terrorist',
	isMainEvent = false,
	cooldown = 60 * 2,
	weight = 2,
	goodness = -2,
	minimunDeadPercentage = 0.01,
	minimunTimeElapsed = 12 * 60,
	
	onStart = function (self)
		if (#DD.eventDirector.getEventInstances('deathSquad') > 0) and not self.manuallyTriggered then
			self.fail('terrorist event cannot start if there is a deathSquad event')
			return
		end
		
		-- pick client to be terrorist
		if self.terrorist == nil then
			for client in DD.arrShuffle(Client.ClientList) do
				if DD.isClientRespawnable(client) and client.InGame then
					self.terrorist = client
					break
				end
			end
		end
		
		-- event requires 5 or more players
		if (self.terrorist == nil) or ((not self.manuallyTriggered) and (DD.tableSize(Client.ClientList) <= 4)) then
			self.fail('conditions to start could not be met')
			return
		else
			-- Spawn terrorist
			local job = 'jet'
			local waypoint = DD.findRandomWaypointByJob('clown')
			local pos = waypoint.WorldPosition
			local subclass = 2
			local character = DD.spawnHuman(self.terrorist, job, pos, nil, subclass)
			character.SetOriginalTeamAndChangeTeam(CharacterTeamType.Team2, true)
			character.UpdateTeam()
			-- Antag
			DD.giveAfflictionCharacter(character, 'antag', 99)
			-- Make terrorist wanted
			local event = DD.eventArrest.new(self.terrorist, 'terrorism', false)
			event.isTargetKnown = true
			event.start()
		end
	end,
	
	onThink = function (self)
		if (DD.thinkCounter % 30 ~= 0) or (not Game.RoundStarted) then return end
		local timesPerSecond = 2
		
		if self.terrorist == nil then
			self.fail('"self.terrorist" is nil at "onThink"')
			return
		end
		
		if DD.isClientCharacterAlive(self.terrorist) then
			if DD.isCharacterArrested(self.terrorist.Character) then
				self.finish()
				return
			end
		else
			self.finish()
			return
		end
		
		-- Increase time pressure
		local timeToExplode = 5 * 60 -- in seconds
		DD.giveAfflictionCharacter(self.terrorist.Character, 'timepressure', 60/timeToExplode/timesPerSecond)
	end,
	
	onCharacterDeath = function (self, character)
		if self.terrorist == nil then
			self.fail('"self.terrorist" is nil at "onCharacterDeath"')
			return
		end
		
		if (self.terrorist.Character == nil) or (self.terrorist.Character == character) then
			self.finish()
		end
	end,
	
	onFinish = function (self)
	end,
	
	onFinishAlways = function (self)
		if (self.terrorist ~= nil) and DD.isClientCharacterAlive(self.terrorist) then
			DD.giveAfflictionCharacter(self.terrorist.Character, 'beepingbomb', 5)
		end
	end
})