-- Picks a player to be a serial killer and keeps giving them targets to kill
DD.eventSerialKiller = DD.class(DD.eventSecretAntagBase, function (self, killer)
	self.killer = killer
end, {
	paramType = {'client'},
	clientKeys = {'killer'},
	public = false,
	
	name = 'serialKiller',
	isMainEvent = true,
	cooldown = 60 * 5,
	weight = 1,
	goodness = -0.5,
	minimunAlivePercentage = 1.0,
	
	onStart = function (self)
		self.killerWon = false
		self.killsLeftToWin = 0 -- killer automatically wins once this value is equal to or lower than 0
		self.timePressurePauseTimer = 0
		
		local anyoneAlive = false
		for client in DD.arrShuffle(Client.ClientList) do
			if DD.isClientCharacterAlive(client) and (client.Character.SpeciesName == 'human') and (not DD.isCharacterArrested(client.Character)) and (not DD.isCharacterAntagSafe(client.Character)) and (self.killer == nil) and DD.eventDirector.isClientBelowEventCap(client) then
				self.killer = client
			elseif DD.isClientCharacterAlive(client) and (client.Character.SpeciesName == 'human') then
				anyoneAlive = true
				self.killsLeftToWin = self.killsLeftToWin + 1
			end
		end
		self.killsLeftToWin = math.ceil(self.killsLeftToWin * 0.8)
		
		local nonSecurity = {}
		for client in Client.ClientList do
			if DD.isClientCharacterAlive(client) and (client.Character.SpeciesName == 'human') and (not DD.isCharacterSecurity(client.Character)) then
				table.insert(nonSecurity, client)
			end
		end
		
		if (self.killer == nil) or (not anyoneAlive) or (#nonSecurity < 3) then
			self.fail()
			return
		else
			local message = 'You are going to turn into a Serial Killer within {time}. Make sure when you do turn, you are somewhere secluded, where no one will see it.'
			DD.messageClient(self.killer, DD.stringReplace(message, {time = DD.numberToTime(self.eventActualStartTimer)}), {preset = 'crit'})
		end
	end,
	
	stateMain = {
		onChange = function (self, state)
			if (self.parent.killer == nil) then
				self.parent.fail()
				return
			end
		
			self.parent.murderCooldown = 60
			-- Give affliction
			DD.giveAfflictionCharacter(self.parent.killer.Character, 'bloodlust', 1)
			-- Give time pressure immunity
			DD.giveAfflictionCharacter(self.parent.killer.Character, 'timepressureimmunity', 60 * 3) -- 3 minutes of time pressure immunity
			-- Remove item at headslot
			if self.parent.killer.Character.Inventory.GetItemAt(DD.invSlots.head) ~= nil then
				self.parent.killer.Character.Inventory.GetItemAt(DD.invSlots.head).drop()
			end
			-- Put mask at headslot
			Timer.Wait(function ()
				Entity.Spawner.AddItemToSpawnQueue(ItemPrefab.GetItemPrefab('creepymask'), self.parent.killer.Character.Inventory, nil, nil, function (spawnedItem)
					self.parent.mask = spawnedItem
					Timer.Wait(function ()
						self.parent.killer.Character.Inventory.TryPutItem(spawnedItem, DD.invSlots.head, true, true, self.parent.killer.Character, true, true)
					end, 1)
				end)
			end, 1)
			-- Message
			DD.messageClient(self.parent.killer, 'You are a serial killer! Your mask grants you unnatural resilience and power. You must kill your target ', {preset = 'crit'})
			for client in Client.ClientList do
				if client ~= self.parent.killer then
					DD.messageClient(client, 'A serial killer is roaming the area, however it is unknown who they are. Be careful!', {preset = 'crit'})
				end
			end
			-- 
			for character in Character.CharacterList do
				DD.giveAfflictionCharacter(character, 'killerfx', 999)
			end
			-- Make event public
			self.parent.public = true
		end,
		onThink = function (self)
			-- Is called every 1/6 of a second instead of every 1/2 a second so affliction gets updated faster
			if (DD.thinkCounter % 10 ~= 0) or (not Game.RoundStarted) then return end
			local timesPerSecond = 6
		
			if (self.parent.killer == nil) then
				self.parent.fail()
				return
			end
			
			-- give serial killer "flag" affliction
			if DD.isClientCharacterAlive(self.parent.killer) and (self.parent.killer.Character.CharacterHealth.GetAffliction('serialkiller', true) == nil) then
				DD.giveAfflictionCharacter(self.parent.killer.Character, 'serialkiller', 999)
			end
			
			local timeToExplode = 5 * 60 -- in seconds
			if self.parent.timePressurePauseTimer > 0 then
				self.parent.timePressurePauseTimer = self.parent.timePressurePauseTimer - 1/timesPerSecond
			else
				DD.giveAfflictionCharacter(self.parent.killer.Character, 'timepressure', 60/timeToExplode/timesPerSecond)
			end
			if (self.parent.murder == nil) or (self.parent.murder.finished) then
				-- if last murder resulted in a victory for the murderer, reset time pressure
				if (self.parent.murder ~= nil) and self.parent.murder.murdererWon and (self.parent.killer.Character.CharacterHealth.GetAffliction('timepressure', true) ~= nil) then
					self.parent.killer.Character.CharacterHealth.GetAffliction('timepressure', true).SetStrength(0)
				end
				-- when murderCooldown reaches 0, start a new murder event
				if self.parent.murderCooldown <= 0 then
					local victim = nil
					for client in DD.arrShuffle(Client.ClientList) do
						if DD.isClientCharacterAlive(client) and (client ~= self.parent.killer) and (client.Character.SpeciesName == 'human') then
							victim = client
							break
						end
					end
					self.parent.murder = DD.eventMurder.new(self.parent.killer, victim)
					self.parent.murder.start()
					self.parent.murderCooldown = 30
				else
					self.parent.murderCooldown = self.parent.murderCooldown - (1 / timesPerSecond)
				end
			end
			
			-- bloodlust when creepy mask is being worn
			if DD.isClientCharacterAlive(self.parent.killer) and (self.parent.killer.Character.Inventory.GetItemAt(2) ~= nil) and (self.parent.mask.ID == self.parent.killer.Character.Inventory.GetItemAt(2).ID) then
				if self.parent.killer.Character.CharacterHealth.GetAffliction('bloodlust', true) == nil then
					DD.giveAfflictionCharacter(self.parent.killer.Character, 'bloodlust', 1)
				end
				if self.parent.killer.Character.CharacterHealth.GetAffliction('bloodlust', true) ~= nil then
					self.parent.killer.Character.CharacterHealth.GetAffliction('bloodlust', true).SetStrength(1)
				end
			else
				if DD.isClientCharacterAlive(self.parent.killer) then
					if self.parent.killer.Character.CharacterHealth.GetAffliction('bloodlust', true) ~= nil then
						self.parent.killer.Character.CharacterHealth.GetAffliction('bloodlust', true).SetStrength(0)
					end
				end
			end
			
			-- See if anyone is still alive
			local anyoneAlive = false
			for client in Client.ClientList do
				if DD.isClientCharacterAlive(client) and (client.Character.SpeciesName == 'human') and (client ~= self.parent.killer) then
					anyoneAlive = true
					break
				end
			end
			
			-- End event if the serial killer is dead or if everyone is dead
			if not anyoneAlive then
				self.parent.killerWon = true
				self.parent.finish()
				return
			end
			if (not DD.isClientCharacterAlive(self.parent.killer)) or ((self.parent.killer.Character ~= nil) and DD.isCharacterArrested(self.parent.killer.Character)) then
				self.parent.finish()
				return
			end
			-- End event if killsLeftToWin is equal to or lower than 0
			if self.parent.killsLeftToWin <= 0 then
				self.parent.killerWon = true
				self.parent.finish()
				return
			end
		end,
	},
	
	onCharacterDeath = function (self, character)
		if (self.killer.Character ~= nil) and (self.killer.Character == character) then
			self.finish()
			return
		end
		if (character.LastAttacker == self.killer.Character) and (character.SpeciesName == 'human') then
			self.killsLeftToWin = self.killsLeftToWin - 1
			self.timePressurePauseTimer = 60 * 2
		end
	end,
	
	onChatMessage = function (self, message, sender)
		if (not DD.isClientCharacterAlive(sender)) and (string.sub(message, 1, 1) ~= '/') then
			DD.messageClient(self.killer, message, {type = 'Dead', sender = sender.Name})
		end
	end,
	
	onFinish = function (self)
		-- This is the end, beautiful friend. This is the end, my only friend. The end of our elaborated plans, the end of everything that stands. The end
		if self.killerWon then
			DD.messageAllClients('Serial killer has won this round! Round ending in 10 seconds.', {preset = 'crit'})
			DD.roundData.roundEnding = true
			Timer.Wait(function ()
				Game.EndGame()
			end, 10 * 1000)
		else
			if not DD.isClientCharacterAlive(self.killer) then
				DD.messageAllClients('The serial killer has been eliminated.', {preset = 'goodinfo'})
				DD.messageClient(self.killer, 'You have died and are not an antagonist anymore!', {preset = 'crit'})
			elseif DD.isCharacterArrested(self.killer.Character) then
				DD.messageAllClients('The serial killer has been arrested.', {preset = 'goodinfo'})
				DD.messageClient(self.killer, 'You been arrested and are not an antagonist anymore!', {preset = 'crit'})
			end
		end
	end,
	
	onFinishAlways = function (self)
		if (self.killer ~= nil) and DD.isClientCharacterAlive(self.killer) and (not self.killerWon) then
			if self.killer.Character.CharacterHealth.GetAffliction('serialkiller', true) ~= nil then
				self.killer.Character.CharacterHealth.GetAffliction('serialkiller', true).SetStrength(0)
			end
			if self.killer.Character.CharacterHealth.GetAffliction('bloodlust', true) ~= nil then
				self.killer.Character.CharacterHealth.GetAffliction('bloodlust', true).SetStrength(0)
			end
			if self.killer.Character.CharacterHealth.GetAffliction('timepressure', true) ~= nil then
				self.killer.Character.CharacterHealth.GetAffliction('timepressure', true).SetStrength(0)
			end
		end
	end
})