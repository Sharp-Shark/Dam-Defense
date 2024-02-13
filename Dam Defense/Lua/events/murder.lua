-- Has a non-security player be tasked with killing with another non-security player
DD.eventMurder = DD.class(DD.eventBase, function (self, murderer, victim)
	self.murderer = murderer
	self.victim = victim
end, {
	paramType = {'client', 'client'},
	clientKeys = {'murderer', 'victim'},
	
	name = 'murder',
	isMainEvent = false,
	cooldown = 60 * 3,
	weight = 1,
	goodness = -1,
	
	onStart = function (self)
		self.murdererWon = false
		self.murdererDied = false
		self.murdererArrested = false
		self.victimDied = false
		
		-- Pick murderer (can't be security)
		if self.murderer == nil then
			for client in DD.arrShuffle(Client.ClientList) do
				if DD.isClientCharacterAlive(client) and (not DD.isCharacterSecurity(client.Character)) and (client ~= self.victim) and DD.eventDirector.isClientBelowEventCap(client) then
					self.murderer = client
					break
				end
			end
		end
		
		-- Pick victim (can't be security) (also can't be the murderer cuz otherwise suicide???)
		if self.victim == nil then
			for client in DD.arrShuffle(Client.ClientList) do
				if DD.isClientCharacterAlive(client) and (not DD.isCharacterSecurity(client.Character)) and (client ~= self.murderer) and DD.eventDirector.isClientBelowEventCap(client) then
					self.victim = client
					break
				end
			end
		end
		
		-- If couldn't find a suitable murder and/or victim cancel event
		if (self.murderer == nil) or (self.victim == nil) then
			self.fail()
			return
		else
			DD.messageClient(self.murderer, 'You hear voices in your head... aggressive yet seductive voices telling you to murder ' .. self.victim.Name .. '.', {preset = 'crit'})
			DD.messageClient(self.victim, 'You hear voices in your head... calm yet worried voices warning someone wants to murder you.', {preset = 'crit'})
		end
	end,
	
	onThink = function (self)
		if (DD.thinkCounter % 30 ~= 0) or (not Game.RoundStarted) then return end
		
		if (self.murderer == nil) or (self.victim == nil) then
			self.fail()
			return
		end
		
		if not DD.isClientCharacterAlive(self.murderer) then
			self.murdererDied = true
		else
			if self.murderer.Character.IsArrested then
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
			DD.messageAllClients('The murderer has succeeded and ' .. self.victim.Name .. ' is now dead! They must be brought to justice!', {preset = 'badinfo'})
			DD.messageClient(self.murderer, 'You hear voices in your head... joyful voices thanking you for killing ' .. self.victim.Name .. '. Well done.', {preset = 'goodinfo'})
			-- Start event for security to arrest murderer
			local event = DD.eventArrest.new(self.murderer, 'manslaughter', false)
			event.start()
		elseif self.murdererDied then
			DD.messageAllClients(self.murderer.Name .. ' has failed to murder ' .. self.victim.Name ..' and is now dead! Life goes on...', {preset = 'info'})
			DD.messageClient(self.murderer, 'You have died and are not an antagonist anymore!', {preset = 'crit'})
		elseif self.murdererArrested then
			DD.messageAllClients(self.murderer.Name .. ' has failed to murder ' .. self.victim.Name ..' and has been lawfully arrested! Life goes on...', {preset = 'goodinfo'})
			DD.messageClient(self.murderer, 'You hear voices in your head... aggressive yet disappointed voices berrating you for your failure. You do not need to murder ' .. self.victim.Name .. ' anymore.', {preset = 'crit'})
		elseif self.victimDied then
			DD.messageClient(self.murderer, 'You hear voices in your head... aggressive yet disappointed voices berrating you for your failure. Although ' .. self.victim.Name .. ' died, it was not by your hand.', {preset = 'info'})
		end
	end
})