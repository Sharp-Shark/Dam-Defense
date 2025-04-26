-- Picks a player to be a serial killer and keeps giving them targets to kill
DD.eventSerialKiller = DD.class(DD.eventWithStartBase, function (self, killer)
	self.killer = killer
end, {
	paramType = {'client'},
	clientKeys = {'killer'},
	public = false,
	
	name = 'serialKiller',
	isMainEvent = true,
	cooldown = 60 * 4,
	weight = 1,
	goodness = -2,
	minimunAlivePercentage = 1.0,
	
	getShouldFinish = function (self)
		-- guard clause
		if self.killer == nil then
			return true
		end
	
		-- See if anyone is still alive
		local anyoneAlive = false
		for client in Client.ClientList do
			if (not DD.isClientAntagNonTarget(client)) and (client ~= self.killer) then
				anyoneAlive = true
				break
			end
		end
		
		-- End event if the serial killer is dead or if everyone is dead
		if not anyoneAlive then
			self.killerWon = true
			return true
		end
		if (not DD.isClientCharacterAlive(self.killer)) or ((self.killer.Character ~= nil) and self.killer.Character.IsHandcuffed) then
			return true
		end
		-- End event if killsLeftToWin is equal to or lower than 0
		if self.killsLeftToWin <= 0 then
			self.killerWon = true
			return true
		end
		
		return false
	end,
	
	onStart = function (self)
		self.killerWon = false
		self.killsLeftToWin = 0 -- killer automatically wins once this value is equal to or lower than 0
		
		local anyoneAlive = false
		for client in DD.arrShuffle(Client.ClientList) do
			if DD.isClientCharacterAlive(client) and (client.Character.SpeciesName == 'human') then
				if (not DD.isCharacterArrested(client.Character)) and (not DD.isClientAntagExempt(client)) and (self.killer == nil) and DD.eventDirector.isClientBelowEventCap(client) then
					self.killer = client
				else
					anyoneAlive = true
				end
				self.killsLeftToWin = self.killsLeftToWin + 1
			end
		end
		self.killsLeftToWin = math.ceil(self.killsLeftToWin * 0.6)
		
		local nonSecurity = {}
		for client in Client.ClientList do
			if DD.isClientCharacterAlive(client) and (client.Character.SpeciesName == 'human') and (not DD.isCharacterSecurity(client.Character)) then
				table.insert(nonSecurity, client)
			end
		end
		
		if (self.killer == nil) or (not anyoneAlive) or ((#nonSecurity < 3) and not self.manuallyTriggered) then
			self.fail('conditions to start could not be met')
			return
		else
			DD.messageClient(self.killer, DD.stringLocalize('serialKillerMessageSecret', {timer = DD.numberToTime(self.stateStartInitialTimer)}), {preset = 'crit'})
			if self.killer.Character ~= nil then DD.giveAfflictionCharacter(self.killer.Character, 'notificationfx', 999) end
		end
	end,
	
	stateMain = {
		onChange = function (self, state)
			if (self.parent.killer == nil) then
				self.parent.fail('"self.parent.killer" is nil at "stateMain.onChange"')
				return
			end
			
			-- Give affliction
			if DD.isClientCharacterAlive(self.parent.killer) then
				DD.giveAfflictionCharacter(self.parent.killer.Character, 'serialkiller', 999)
				DD.giveAfflictionCharacter(self.parent.killer.Character, 'bloodlust', 1)
				DD.giveAfflictionCharacter(self.parent.killer.Character, 'serialkiller', 999)
			end
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
			DD.messageClient(self.parent.killer, DD.stringLocalize('serialKillerMessageKiller'), {preset = 'crit'})
			for client in Client.ClientList do
				if client ~= self.parent.killer then
					DD.messageClient(client, DD.stringLocalize('serialKillerMessagePublic'), {preset = 'crit'})
				end
			end
			-- Halloween SFX
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
				self.parent.fail('"self.parent.killer" is nil at "stateMain.onThink"')
				return
			end
			
			local timeToExplode = 10 * 60 -- in seconds
			DD.giveAfflictionCharacter(self.parent.killer.Character, 'timepressure', 60/timeToExplode/timesPerSecond)
			
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
			
			if self.parent.getShouldFinish() then
				self.parent.finish()
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
			-- Halloween SFX
			for character in Character.CharacterList do
				DD.giveAfflictionCharacter(character, 'killerfx', 999)
			end
		end
	end,
	
	onChatMessage = function (self, message, sender)
		if string.sub(message, 1, 1) == '/' then return end
		if DD.isClientCharacterAlive(sender) then return end
		DD.messageClient(self.killer, message, {type = 'Dead', sender = sender.Name})
	end,
	
	onFinish = function (self)
		-- This is the end, beautiful friend. This is the end, my only friend. The end of our elaborated plans, the end of everything that stands. The end
		for client in Client.ClientList do
			if client.Character ~= nil then DD.giveAfflictionCharacter(client.Character, 'notificationfx', 999) end
		end
		if self.killerWon then
			DD.messageAllClients(DD.stringLocalize('serialKillerEndVictory'), {preset = 'crit'})
			DD.roundData.roundEnding = true
			Timer.Wait(function ()
				Game.EndGame()
			end, 10 * 1000)
		else
			if not DD.isClientCharacterAlive(self.killer) then
				DD.messageAllClients(DD.stringLocalize('serialKillerEndArrested'), {preset = 'goodinfo'})
				if self.killer ~= nil then DD.messageClient(self.killer, DD.stringLocalize('antagDead'), {preset = 'crit'}) end
			elseif DD.isCharacterArrested(self.killer.Character) then
				DD.messageAllClients(DD.stringLocalize('serialKillerEnd'), {preset = 'goodinfo'})
				if self.killer ~= nil then DD.messageClient(self.killer, DD.stringLocalize('antagArrested'), {preset = 'crit'}) end
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