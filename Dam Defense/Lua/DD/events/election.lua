-- Election
DD.eventElection = DD.class(DD.eventBase, nil, {
	name = 'election',
	isMainEvent = false,
	cooldown = 60 * 3,
	weight = 1,
	goodness = -1,
	
	-- set this to false unless testing the event
	debugMode = false,
	
	onStart = function (self)
	
		local captainIsAlive = false
		local anySecurityIsAlive = false
		for client in Client.ClientList do
			if DD.isClientCharacterAlive(client) and DD.isCharacterSecurity(client.Character) and (client.Character.SpeciesName == 'human') then
				if client.Character.JobIdentifier == 'captain' then
					captainIsAlive = true
					self.captain = client
				else
					anySecurityIsAlive = true
				end
			end
		end
		
		if ((not captainIsAlive) or (not anySecurityIsAlive) or (DD.eventDirector.mainEvent ~= nil)) and (not self.debugMode) then
			self.fail('conditions to start could not be met')
			return
		end
		
		self.timer = 60 * 2
		
		self.yesVotes = 0
		self.noVotes = 0
		
		for item in Item.ItemList do
			if item.Prefab.Identifier == 'ballotbox' then
				item.Condition = 100
				item.NonInteractable = false
				local nonInteractable = item.SerializableProperties[Identifier("NonInteractable")]
				Networking.CreateEntityEvent(item, Item.ChangePropertyEventData(nonInteractable, item))
				DD.setLightState(item, true)
			end
		end
		
		DD.messageAllClients(DD.stringLocalize('electionStart', {timer = DD.numberToTime(self.timer)}), {preset = 'crit'})
		for client in Client.ClientList do
			if client.Character ~= nil then DD.giveAfflictionCharacter(client.Character, 'notificationfx', 999) end
		end
		
		-- /election command will only be usable after DD.thinkCounter is greater than this value
		DD.electionCommandUsableAfter = DD.thinkCounter + self.cooldown * 60
	end,
	
	onThink = function (self)
		if (DD.thinkCounter % 30 ~= 0) or (not Game.RoundStarted) then return end
		local timesPerSecond = 2
		
		if ((self.captain == nil) or (not DD.isClientCharacterAlive(self.captain))) and (not self.debugMode) then
			for client in Client.ClientList do
				if client.Character ~= nil then DD.giveAfflictionCharacter(client.Character, 'notificationfx', 999) end
			end
			DD.messageAllClients(DD.stringLocalize('electionEndFail'), {preset = 'crit'})
			self.fail('captain is dead')
		end
		
		if self.timer <= 0 then
			self.finish()
		else
			self.timer = self.timer - 1 / timesPerSecond
		end
	end,
	
	onFinish = function (self)
		local result = self.yesVotes - self.noVotes
		
		for client in Client.ClientList do
			if client.Character ~= nil then DD.giveAfflictionCharacter(client.Character, 'notificationfx', 999) end
		end
		
		if (self.captain == nil) or (not DD.isClientCharacterAlive(self.captain)) then
			DD.messageAllClients(DD.stringLocalize('electionEndFail'), {preset = 'crit'})
			return
		end
		
		if result > 0 then
			local replacement
			for client in DD.arrShuffle(Client.ClientList) do
				if DD.isClientCharacterAlive(client) and DD.isCharacterSecurity(client.Character) and (client.Character.SpeciesName == 'human') and (client.Character.JobIdentifier ~= 'captain') then
					replacement = client
					break
				end
			end
			if replacement == nil then
				DD.messageAllClients(DD.stringLocalize('electionEndYesFail'), {preset = 'crit'})
			else
				-- kill captain and replacement
				DD.giveAfflictionCharacter(self.captain.Character, 'beepingbomb', 5)
				self.captain.AssignedJob = JobVariant(JobPrefab.Get('mechanic'), math.random(JobPrefab.Get('mechanic').Variants) - 1)
				DD.clientJob[self.captain] = 'mechanic'
				DD.giveAfflictionCharacter(replacement.Character, 'beepingbomb', 5)
				replacement.AssignedJob = JobVariant(JobPrefab.Get('captain'), math.random(JobPrefab.Get('captain').Variants) - 1)
				DD.clientJob[replacement] = 'captain'
				-- respawn captain once he dies
				local seed = tostring(math.floor(math.random() * 10^8))
				DD.characterDeathFunctions['respawnAsLaborer' .. seed] = function (character)
					local client = self.captain
					Timer.Wait(function ()
						if client ~= DD.findClientByCharacter(character) then return end
						local seed = seed
						
						-- get job and job variant
						local job = 'mechanic'
						local variant
						for jobVariant in client.JobPreferences do
							if tostring(jobVariant.Prefab.Identifier) == job then
								variant = jobVariant.Variant
							end
						end
						if variant == nil then variant = math.random(JobPrefab.Get(job).Variants) - 1 end
						
						local pos = DD.findRandomWaypointByJob(job).WorldPosition
						local character = DD.spawnHuman(client, job, pos)
						character.SetOriginalTeamAndChangeTeam(CharacterTeamType.Team1, true)
						character.UpdateTeam()
					
						DD.characterDeathFunctions['respawnAsLaborer' .. seed] = nil
					end, 100)
				end
				-- respawn replacement once he dies
				local seed = tostring(math.floor(math.random() * 10^8))
				DD.characterDeathFunctions['respawnAsCaptain' .. seed] = function (character)
					local client = replacement
					Timer.Wait(function ()
						if client ~= DD.findClientByCharacter(character) then return end
						local seed = seed
						
						-- get job and job variant
						local job = 'captain'
						local variant
						for jobVariant in client.JobPreferences do
							if tostring(jobVariant.Prefab.Identifier) == job then
								variant = jobVariant.Variant
							end
						end
						if variant == nil then variant = math.random(JobPrefab.Get(job).Variants) - 1 end
						
						local pos = DD.findRandomWaypointByJob(job).WorldPosition
						local character = DD.spawnHuman(client, job, pos)
						character.SetOriginalTeamAndChangeTeam(CharacterTeamType.Team1, true)
						character.UpdateTeam()
					
						DD.characterDeathFunctions['respawnAsCaptain' .. seed] = nil
					end, 100)
				end
				-- message
				DD.messageAllClients(DD.stringLocalize('electionEndYes', {name = replacement.Name}), {preset = 'crit'})
			end
		else
			DD.messageAllClients(DD.stringLocalize('electionEndNo'), {preset = 'crit'})
		end
	end,
	
	onFinishAlways = function (self)
		for item in Item.ItemList do
			if item.Prefab.Identifier == 'ballotbox' then
				item.Condition = 0
				item.NonInteractable = true
				local nonInteractable = item.SerializableProperties[Identifier("NonInteractable")]
				Networking.CreateEntityEvent(item, Item.ChangePropertyEventData(nonInteractable, item))
				DD.setLightState(item, false)
			end
		end
	end
})