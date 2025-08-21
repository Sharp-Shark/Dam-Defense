-- Has a non-security player be tasked with killing with another non-security player
DD.eventMurder = DD.class(DD.eventBase, function (self, murderer, victim)
	self.murderer = murderer
	self.victim = victim
end, {
	paramType = {'client', 'client'},
	clientKeys = {'murderer', 'victim'},
	public = false,
	
	name = 'murder',
	isMainEvent = false,
	cooldown = 60 * 3,
	weight = 0.5,
	goodness = -1,
	
	onStart = function (self)
		self.murdererWon = false
		self.murdererDied = false
		self.murdererArrested = false
		self.victimDied = false
		
		-- Pick murderer (can't be security)
		if self.murderer == nil then
			for client in DD.arrShuffle(Client.ClientList) do
				if DD.isClientCharacterAlive(client) and (client.Character.SpeciesName == 'human') and (not DD.isClientAntagExempt(client)) and (client ~= self.victim) and DD.eventDirector.isClientBelowEventCap(client) then
					self.murderer = client
					break
				end
			end
		end
		
		-- Pick victim (can't be security) (also can't be the murderer cuz otherwise suicide???)
		if self.victim == nil then
			for client in DD.arrShuffle(Client.ClientList) do
				if DD.isClientCharacterAlive(client) and (client.Character.SpeciesName == 'human') and (not DD.isCharacterSecurity(client.Character)) and (client ~= self.murderer) and DD.eventDirector.isClientBelowEventCap(client) then
					self.victim = client
					break
				end
			end
		end
		
		-- If couldn't find a suitable murder and/or victim cancel event
		if (self.murderer == nil) or (self.victim == nil) then
			self.fail('conditions to start could not be met')
			return
		else
			DD.messageClient(self.murderer, DD.stringLocalize('murderMessageMurderer' ,{victimName = self.victim.Name}), {preset = 'crit'})
			DD.messageClient(self.victim, DD.stringLocalize('murderMessageVictim'), {preset = 'crit'})
			if self.murderer.Character ~= nil then DD.giveAfflictionCharacter(self.murderer.Character, 'notificationfx', 999) end
			if self.victim.Character ~= nil then DD.giveAfflictionCharacter(self.victim.Character, 'notificationfx', 999) end
		end
	end,
	
	onThink = function (self)
		if (DD.thinkCounter % 30 ~= 0) or (not Game.RoundStarted) then return end
		
		if (self.murderer == nil) or (self.victim == nil) then
			self.fail('"self.murderer" or "self.victim" is nil at "onThink"')
			return
		end
		
		if not DD.isClientCharacterAlive(self.murderer) then
			self.murdererDied = true
		else
			if DD.isCharacterArrested(self.murderer.Character) then
				self.murdererArrested = true
			end
		end
		
		if not DD.isClientCharacterAlive(self.victim) then
			self.victimDied = true
			if (self.victim.Character ~= nil) and (not self.murdererDied) and (self.victim.Character.LastAttacker == self.murderer.Character) then
				self.murdererWon = true
			end
		end
	
		if self.murdererWon or self.murdererDied or self.murdererArrested or self.victimDied then
			self.finish()
		end
	end,
	
	onCharacterDeath = function (self, character)
		if (self.murderer.Character ~= nil) and (self.murderer.Character == character) then
			self.murdererDied = true
		end
		if (self.victim.Character ~= nil) and (self.victim.Character == character) then
			self.victimDied = true
			if (not self.murdererDied) and (self.victim.Character.LastAttacker == self.murderer.Character) then
				self.murdererWon = true
			end
		end
		
		if self.murdererDied or self.victimDied then self.finish() end
	end,
	
	onFinish = function (self)
		if self.murdererWon then
			DD.giveMoneyToClient(self.murderer, 5, true)
			DD.messageAllClients(DD.stringLocalize('murderEndMurdererVictory', {victimName = self.victim.Name}), {preset = 'badinfo'})
			DD.messageClient(self.murderer, DD.stringLocalize('murderMessageMurdererVictory', {victimName = self.victim.Name}), {preset = 'goodinfo'})
			-- Start event for security to arrest murderer
			local event = DD.eventArrest.new(self.murderer, 'manslaughter', false)
			event.start()
		elseif self.murdererDied then
			DD.messageAllClients(DD.stringLocalize('murderEndMurdererDead', {murdererName = self.murderer.Name, victimName = self.victim.Name}), {preset = 'info'})
			DD.messageClient(self.murderer, DD.stringLocalize('murderMessageMurdererDead', {victimName = self.victim.Name}), {preset = 'crit'})
		elseif self.murdererArrested then
			DD.giveMoneyToSecurity(5, true)
			DD.messageAllClients(DD.stringLocalize('murderEndMurdererArrested', {murdererName = self.murderer.Name, victimName = self.victim.Name}), {preset = 'goodinfo'})
			DD.messageClient(self.murderer, DD.stringLocalize('murderMessageMurdererArrested', {victimName = self.victim.Name}), {preset = 'crit'})
		elseif self.victimDied then
			DD.messageClient(self.murderer, DD.stringLocalize('murderMessageMurdererUnrelatedDeath', {victimName = self.victim.Name}), {preset = 'info'})
		end
	end
})