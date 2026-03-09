-- sword wielding maniac
DD.eventKnight = DD.class(DD.eventBase, function (self, knight)
	self.knight = knight
end, {
	paramType = {'client'},
	clientKeys = {'knight'},
	public = false,
	
	name = 'knight',
	instanceCap = 1,
	isMainEvent = false,
	cooldown = 60 * 3,
	weight = 2,
	goodness = -2,
	minimunDeadPercentage = 0.01,
	
	onStart = function (self)
		-- pick client to be knight
		if self.knight == nil then
			for client in DD.arrShuffle(Client.ClientList) do
				if DD.isClientRespawnable(client) and client.InGame then
					self.knight = client
					break
				end
			end
		end
		
		-- event requires 5 or more players
		if (self.knight == nil) or ((not self.manuallyTriggered) and (DD.tableSize(Client.ClientList) <= 4)) then
			self.fail('conditions to start could not be met')
			return
		else
			-- Spawn knight
			local job = 'knight'
			local waypoint = DD.findRandomWaypointByJob(job)
			if waypoint == nil then waypoint = DD.findRandomWaypointByJob('clown') end
			local pos = waypoint.WorldPosition
			local character = DD.spawnHuman(self.knight, job, pos)
			character.SetOriginalTeamAndChangeTeam(CharacterTeamType.Team1, true)
			character.UpdateTeam()
		end
	end,
	
	onThink = function (self)
		if (DD.thinkCounter % 30 ~= 0) or (not Game.RoundStarted) then return end
		local timesPerSecond = 2
		
		if self.knight == nil then
			self.fail('"self.knight" is nil at "onThink"')
			return
		end
		
		if not DD.isClientCharacterAlive(self.knight) then
			self.finish()
		end
	end,
	
	onCharacterDeath = function (self, character)
		if self.knight == nil then
			self.fail('"self.knight" is nil at "onCharacterDeath"')
			return
		end
		
		if (self.knight.Character == nil) or (self.knight.Character == character) then
			self.finish()
		end
	end,
	
	onFinish = function (self)
		DD.messageAllClients(DD.stringLocalize('knightEnd'), {preset = 'goodinfo'})
	end,
})