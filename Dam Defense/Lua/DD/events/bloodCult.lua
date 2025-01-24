-- Enlighten a few initial players whose objective is to convert all players into cultists like them, or kill them
DD.eventBloodCult = DD.class(DD.eventWithStartBase, function (self, cultists)
	self.cultists = cultists
	if type(self.cultists) == 'table' then
		self.cultistsSet = DD.toSet(self.cultists)
	end
end, {
	paramType = {'clientList'},
	clientKeys = {'cultists'},
	public = false,
	
	name = 'bloodCult',
	isMainEvent = true,
	cooldown = 60 * 6,
	weight = 1.5,
	goodness = -1.5,
	minimunAlivePercentage = 1.0,
	
	getShouldFinish = function (self)
		self.updateCultistList()
		
		local aliveSet = {}
		for client in Client.ClientList do
			if DD.isClientCharacterAlive(client) and (client.Character.SpeciesName == 'human') then
				aliveSet[client] = true
			end
		end
		local nonCultistsSet = DD.setSubtract(aliveSet, self.cultistsSet)
		
		if DD.tableSize(nonCultistsSet) <= 0 then
			self.cultistsWon = true
			return true
		end
		if DD.tableSize(self.cultistsSet) <= 0 then
			return true
		end
		
		return false
	end,
	
	buildCultistList = function (self, excludeSet, useClientLogName)
		local excludeSet = excludeSet or {}
		local clients = DD.setSubtract(self.cultistsSet, excludeSet)
		
		local text = ''
		for client, value in pairs(clients) do
			if useClientLogName then
				text = text .. DD.clientLogName(client) .. ', '
			else
				text = text .. client.Name .. ', '
			end
		end
		text = string.sub(text, 1, #text - 2)
		return text
	end,
	
	cultistTitles = {},
	bloodWhisper = function (self, message, sender)
		if self.cultistTitles[sender] == nil then
			local titles = {
				'Cultist',
				'Enlightened',
				'Worshipper',
				'Believer',
				'Faithful',
				'Holy',
				'Devout',
				'Righteous',
				'Loyal',
				'Stalwart',
				'Staunch',
				'Fanatic',
				'Sinless',
				'Fearless',
				'Zealous',
				'Pious'
			}
			self.cultistTitles[sender] = ', the ' .. titles[math.random(#titles)]
		end
		local title = self.cultistTitles[sender]
		for client in Client.ClientList do
			if self.cultistsSet[client] then
				DD.messageClient(client, message, {sender = sender.Name .. title, sendMain = false, sendAnother = true, color = Color(255, 55, 55)})
			end
		end
	end,
	
	updateCultistList = function (self)
		self.cultists = {}
		for client in Client.ClientList do
			if DD.isClientCharacterAlive(client) and (client.Character.SpeciesName == 'human') and (client.Character.CharacterHealth.GetAfflictionStrengthByIdentifier('enlightened') > 99) then
				table.insert(self.cultists, client)
			end
		end
		for client in self.cultists do
			if not self.cultistsSet[client] then
				self.logClients({[client] = true})
			end
		end
		self.cultistsSet = DD.toSet(self.cultists)
		return self.cultists
	end,
	
	onStart = function (self)
		self.cultistsWon = false
		
		-- Pick cultists
		if self.cultists == nil then
			self.cultistsSet = {}
			self.cultists = {}
			for client in DD.arrShuffle(Client.ClientList) do
				if DD.isClientCharacterAlive(client) and (client.Character.SpeciesName == 'human') and (not DD.isCharacterArrested(client.Character)) and (not DD.isCharacterAntagSafe(client.Character)) then
					table.insert(self.cultists, client)
					self.cultistsSet[client] = true
				end
				if DD.tableSize(self.cultists) >= math.ceil(#Client.ClientList / 4) then
					break
				end
			end
		end
		
		local aliveSet = {}
		for client in Client.ClientList do
			if DD.isClientCharacterAlive(client) and (client.Character.SpeciesName == 'human') then
				aliveSet[client] = true
			end
		end
		local nonCultistsSet = DD.setSubtract(aliveSet, self.cultistsSet)
		
		-- Event requires 2 (or more) cultists and 3 (or more) non-cultist
		if (DD.tableSize(self.cultists) <= 1) or (DD.tableSize(nonCultistsSet) <= 2) then
			self.fail()
			return
		else
			-- Give affliction and do client messages
			for client in Client.ClientList do
				if self.cultistsSet[client] then
					DD.giveAfflictionCharacter(client.Character, 'enlightened', 999)
					DD.giveAfflictionCharacter(client.Character, 'timepressureimmunity', 60 * 3) -- 3 minutes of time pressure immunity
					-- No "DD.messageClient" here since whenever the "enlightened" affliction is gained, a luahook already sends a message
				end
			end
			-- Spawn airdrops for cultists
			local event = DD.eventAirdropCultist.new()
			event.start()
		end
	end,
	
	stateStartInitialTimer = 60 * 1, -- in seconds
	
	stateMain = {
		onChange = function (self, state)
			-- Give affliction and do client messages
			for client in Client.ClientList do
				if self.parent.cultistsSet[client] then
					DD.messageClient(client, 'Nexpharma intelligence has discovered the existance of your blood cult and now everyone is aware of your conspiracy, exert caution! They do not know who the individual cultists are at the moment though.', {preset = 'crit'})
				elseif (client.Character ~= nil) and DD.isCharacterAntagSafe(client.Character) then
					DD.messageClient(client, 'Intel reports a blood cult chapter has started in this region. Identify and neutralize all of them before they convert or kill everyone. Any mentions of "Tchernobog" should be met with suspicion.', {preset = 'crit'})
				else
					DD.messageClient(client, 'There have been rumours of cultists in the area. If you were not worried about hooded figures in the sewers saying strange chants before, you should be now.', {preset = 'crit'})
				end
				if client.Character ~= nil then DD.giveAfflictionCharacter(client.Character, 'notificationfx', 999) end
			end
			-- Make event public
			self.parent.public = true
		end,
		onThink = function (self)
			if (DD.thinkCounter % 30 ~= 0) or (not Game.RoundStarted) then return end
			
			if self.parent.getShouldFinish() then
				self.parent.finish()
			end
		end,
	},
	
	onCharacterDeath = function (self, character)
		local client = DD.findClientByCharacter(character)
		if client == nil then return end
		if self.cultistsSet[client] then
			for key, cultist in pairs(self.cultists) do
				if not DD.isClientCharacterAlive(cultist) then
					DD.messageClient(cultist, 'You have died and are not an antagonist anymore!', {preset = 'crit'})
					self.cultists[key] = nil
					self.cultistsSet[cultist] = nil
				end
			end	
		end
	end,
	
	onChatMessage = function (self, message, sender)
		if (string.sub(message, 1, 8) ~= '/whisper') and (message ~= '/cultists') then return end
		if not self.cultistsSet[sender] then return end
		
		if message == '/cultists' then
			-- Build cultist list
			local cultistList = self.buildCultistList(nil, true)
			local message = ''
			message = 'The cultists are: ' .. cultistList .. '.'
			DD.messageClient(sender, message, {preset = 'command'})
		else
			self.bloodWhisper(string.sub(message, 10), sender)
		end
		
		return true
	end,
	
	onFinish = function (self)
		-- This is the end, beautiful friend. This is the end, my only friend. The end of our elaborated plans, the end of everything that stands. The end
		for character in Character.CharacterList do
			if character.SpeciesName == 'humanUndead' then
				DD.giveAfflictionCharacter(character, 'timepressure', 999)
			end
		end
		for client in Client.ClientList do
			if client.Character ~= nil then DD.giveAfflictionCharacter(client.Character, 'notificationfx', 999) end
		end
		if self.cultistsWon then
			DD.messageAllClients('The blood cult has won this round, long live Tchernobog! Round ending in 10 seconds.', {preset = 'crit'})
			DD.roundData.roundEnding = true
			Timer.Wait(function ()
				Game.EndGame()
			end, 10 * 1000)
		else
			DD.messageAllClients('The local blood cult chapter has been eliminated.', {preset = 'goodinfo'})
		end
	end
})