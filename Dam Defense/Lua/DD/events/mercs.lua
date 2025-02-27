-- Has a non-security player be tasked with killing with another non-security player
DD.eventMERCS = DD.class(DD.eventBase, function (self, mercs)
	self.mercs = mercs
end, {
	paramType = {'client'},
	clientKeys = {'mercs'},
	public = false,
	
	name = 'mercs',
	instanceCap = 1,
	isMainEvent = false,
	cooldown = 60 * 1,
	weight = 1.0,
	goodness = 2.0,
	minimunDeadPercentage  = 0.3,
	
	onStart = function (self)
		if self.mercs == nil then
			for client in DD.arrShuffle(Client.ClientList) do
				if (not DD.isClientCharacterAlive(client)) and client.InGame and DD.lateJoinBlacklistSet[client.AccountId.StringRepresentation] then
					self.mercs = client
					break
				end
			end
		end
		
		self.bompTriggered = false
		
		if self.mercs == nil then
			self.fail('conditions to start could not be met')
			return
		else
			-- Spawn bodyguard
			local job = 'mercs'
			local pos = DD.findRandomWaypointByJob(job).WorldPosition
			local character = DD.spawnHuman(self.mercs, job, pos)
			character.SetOriginalTeamAndChangeTeam(CharacterTeamType.Team1, true)
			character.UpdateTeam()
			-- Messages
			local otherClients = DD.setSubtract(DD.toSet(Client.ClientList), {[self.mercs] = true})
			DD.messageClients(DD.tableKeys(otherClients), 'A Mobile Emergency Rescue and Combat Squadder has been sent to assist security in restoring order to the dam.', {preset = 'crit'})
			-- Mobile Task Force Unit Epsilon-11, designated Nine Tailed Fox has entered the facility. All remaining survivors are advised to stay in the evacuation shelter or any other safe area until the unit has secured has secured the facility. We’ll start escorting personnel out when the SCPs have been recontained.
			for character in Character.CharacterList do
				DD.giveAfflictionCharacter(character, 'announcementfx', 999)
			end
		end
	end,
	
	onThink = function (self)
		if (DD.thinkCounter % 30 ~= 0) or (not Game.RoundStarted) then return end
		local timesPerSecond = 2
		
		if self.mercs == nil then
			self.fail('"self.mercs" is nil at "onThink"')
			return
		end
		
		if not self.bompTriggered then
		end
		
		if not DD.isClientCharacterAlive(self.mercs) then
			self.finish()
		end
	end,
	
	onCharacterDeath = function (self, character)
		if self.mercs == nil then
			self.fail('"self.mercs" is nil at "onThink"')
			return
		end
		
		if (self.mercs.Character == nil) or (self.mercs.Character == character) then
			self.finish()
		end
	end,
	
	onFinish = function (self)
		if DD.isClientCharacterAlive(self.mercs) then
			DD.giveAfflictionCharacter(self.mercs.Character, 'beepingbomb', 5)
		end
	end
})