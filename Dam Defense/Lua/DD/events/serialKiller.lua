-- Picks a player to be a serial killer and keeps giving them targets to kill
DD.eventSerialKiller = DD.class(DD.eventBase, function (self, killer)
	self.killer = killer
end, {
	paramType = {'client'},
	clientKeys = {'killer'},
	
	name = 'serialKiller',
	isMainEvent = true,
	cooldown = 60 * 5,
	weight = 1,
	goodness = -0.5,
	
	onStart = function (self)
		self.killerWon = false
		self.timePressurePauseTimer = 0
		self.eventActualStartTimer = 60 * 1
		
		local anyoneAlive = false
		for client in DD.arrShuffle(Client.ClientList) do
			if DD.isClientCharacterAlive(client) and (client.Character.SpeciesName == 'human') and (not client.Character.IsArrested) and (not DD.isCharacterAntagSafe(client.Character)) and (self.killer == nil) and DD.eventDirector.isClientBelowEventCap(client) then
				self.killer = client
			elseif DD.isClientCharacterAlive(client) then
				anyoneAlive = true
			end
		end
		
		local nonSecurity = {}
		for client in Client.ClientList do
			if DD.isClientCharacterAlive(client) and (client.Character.SpeciesName == 'human') and (not DD.isCharacterSecurity(client.Character)) then
				table.insert(nonSecurity, client)
			end
		end
		
		if (self.killer == nil) or (not anyoneAlive) or (#nonSecurity < 2) then
			self.fail()
			return
		else
			local message = 'You are going to turn into a Serial Killer within {time}. Make sure when you do turn, you are somewhere secluded, where no one will see it.'
			DD.messageClient(self.killer, DD.stringReplace(message, {time = DD.numberToTime(self.eventActualStartTimer)}), {preset = 'crit'})
		end
	end,
	
	onThink = function (self)
		-- Is called every 1/6 of a second instead of every 1/2 a second so affliction gets updated faster
		if (DD.thinkCounter % 10 ~= 0) or (not Game.RoundStarted) then return end
		local timesPerSecond = 6
	
		if (self.killer == nil) then
			self.fail()
			return
		end
		
		if self.eventActualStartTimer > 0 then
			self.eventActualStartTimer = self.eventActualStartTimer - 1/timesPerSecond
			if not (self.eventActualStartTimer > 0) then
				self.murderCooldown = 15
				-- Give affliction
				DD.giveAfflictionCharacter(self.killer.Character, 'bloodlust', 1)
				-- Give time pressure immunity for 3 minutes
				DD.giveAfflictionCharacter(self.killer.Character, 'timepressureimmunity', 60 * 3)
				-- Remove item at headslot
				if self.killer.Character.Inventory.GetItemAt(DD.invSlots.head) ~= nil then
					self.killer.Character.Inventory.GetItemAt(DD.invSlots.head).drop()
				end
				-- Put mask at headslot
				Entity.Spawner.AddItemToSpawnQueue(ItemPrefab.GetItemPrefab('clownmask'), self.killer.Character.Inventory, nil, nil, function (spawnedItem)
					self.mask = spawnedItem
					Timer.Wait(function ()
						self.killer.Character.Inventory.TryPutItem(spawnedItem, DD.invSlots.head, true, true, self.killer.Character, true, true)
					end, 1)
				end)
				-- Message
				DD.messageClient(self.killer, 'You are a serial killer! Your mask grants you unnatural resilience and power, but it also makes you insane... only try to kill the person you have been tasked with killing!', {preset = 'crit'})
				for client in Client.ClientList do
					if client ~= self.killer then
						DD.messageClient(client, 'A serial killer is roaming the area, however it is unknown who they are. Be careful!', {preset = 'crit'})
					end
				end
			end
			return
		end
		
		local timeToExplode = 5 * 60 -- in seconds
		if self.timePressurePauseTimer > 0 then
			self.timePressurePauseTimer = self.timePressurePauseTimer - 1/timesPerSecond
		else
			DD.giveAfflictionCharacter(self.killer.character, 'timepressure', 60/timeToExplode/timesPerSecond)
		end
		if (self.murder == nil) or (self.murder.finished) then
			if (self.murder ~= nil) and self.murder.murdererWon and (self.killer.Character.CharacterHealth.GetAffliction('timepressure', true) ~= nil) then
				self.killer.Character.CharacterHealth.GetAffliction('timepressure', true).SetStrength(0)
			end
			if self.murderCooldown <= 0 then
				local victim = nil
				for client in DD.arrShuffle(Client.ClientList) do
					if DD.isClientCharacterAlive(client) and (client ~= self.killer) and (client.Character.SpeciesName == 'human') then
						victim = client
						break
					end
				end
				self.murder = DD.eventMurder.new(self.killer, victim)
				self.murder.start()
				self.murderCooldown = 30
			else
				self.murderCooldown = self.murderCooldown - (1 / timesPerSecond)
			end
		end
		
		if DD.isClientCharacterAlive(self.killer) and (self.killer.Character.Inventory.GetItemAt(2) ~= nil) and (self.mask.ID == self.killer.Character.Inventory.GetItemAt(2).ID) then
			if self.killer.Character.CharacterHealth.GetAffliction('bloodlust', true) == nil then
				DD.giveAfflictionCharacter(self.killer.Character, 'bloodlust', 1)
			end
			if self.killer.Character.CharacterHealth.GetAffliction('bloodlust', true) ~= nil then
				self.killer.Character.CharacterHealth.GetAffliction('bloodlust', true).SetStrength(1)
			end
		else
			if DD.isClientCharacterAlive(self.killer) then
				if self.killer.Character.CharacterHealth.GetAffliction('bloodlust', true) ~= nil then
					self.killer.Character.CharacterHealth.GetAffliction('bloodlust', true).SetStrength(0)
				end
			end
		end
		
		-- See if anyone is still alive
		local anyoneAlive = false
		for client in Client.ClientList do
			if DD.isClientCharacterAlive(client) and (client ~= self.killer) then
				anyoneAlive = true
				break
			end
		end
		
		-- End event if the serial killer is dead or if everyone is dead
		if not anyoneAlive then
			self.killerWon = true
			self.finish()
			return
		end
		if (not DD.isClientCharacterAlive(self.killer)) or ((self.killer.Character ~= nil) and self.killer.Character.IsArrested) then
			self.finish()
		end
	end,
	
	onCharacterDeath = function (self, character)
		if (self.killer.Character ~= nil) and (self.killer.Character == character) then
			self.finish()
			return
		end
		if (character.LastAttacker == self.killer.Character) and (character.SpeciesName == 'human') then
			self.timePressurePauseTimer = 60 * 3
		end
	end,
	
	onFinish = function (self)
		-- This is the end, beautiful friend. This is the end, my only friend. The end of our elaborated plans, the end of everything that stands. The end
		if DD.isClientCharacterAlive(self.killer) then
			if self.killer.Character.CharacterHealth.GetAffliction('bloodlust', true) ~= nil then
				self.killer.Character.CharacterHealth.GetAffliction('bloodlust', true).SetStrength(0)
			end
		end
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
			elseif self.killer.Character.IsArrested then
				DD.messageAllClients('The serial killer has been arrested.', {preset = 'goodinfo'})
				DD.messageClient(self.killer, 'You been arrested and are not an antagonist anymore!', {preset = 'crit'})
				self.killer.Character.CharacterHealth.GetAffliction('timepressure', true).SetStrength(0)
			end
		end
	end
})