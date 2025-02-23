-- Ghost role event
DD.eventGhostRole = DD.class(DD.eventBase, function (self, eventClass)
	if self.eventClass == nil then self.eventClass = eventClass end
end, {
	paramType = {'event'},
	clientKeys = {'volunteers'},
	
	name = 'ghostRole',
	isMainEvent = true,
	cooldown = 60 * 1,
	weight = 1,
	goodness = 0,
	
	informSpectators = function (self, clients, text)
		local clients = clients or Client.ClientList
		local tbl = {seed = self.seed, eventName = self.eventClass.tbl.name, timer = DD.numberToTime(self.timer)}
		local text = text or 'Type in /join {eventName} into chat to join the "{eventName}" event! You have {timer} to join before it starts.'
		text = DD.stringReplace(text, tbl)
		for client in clients do
			if not DD.isClientCharacterAlive(client) then
				DD.messageClient(client, text, {preset = 'ghostRole'})
			end
		end
	end,
	
	onStart = function (self)
		self.timer = Game.ServerSettings.RespawnInterval - 30 -- timer will be 30s shorter than the respawn timer
		self.timerStarted = false
		
		for client in Client.ClientList do
			if DD.isClientRespawnable(client) then
				self.timerStarted = true
				break
			end
		end
		
		self.volunteers = {}
		
		self.informSpectators()
	end,
	
	onThink = function (self)
		if (DD.thinkCounter % 30 ~= 0) or (not Game.RoundStarted) then return end
		
		if self.timerStarted then
			-- if there is nobody dead reset timer
			local anyoneDead = false
			for client in Client.ClientList do
				if DD.isClientRespawnable(client) then
					anyoneDead = true
					break
				end
			end
			if not anyoneDead then
				self.volunteers = {}
				self.timer = Game.ServerSettings.RespawnInterval - 30
				self.timerStarted = false
				return
			end
			
			if self.timer == 60 then
				self.informSpectators()
			end
			if self.timer <= 0 then
				if (not self.eventClass.tbl.isMainEvent) or (DD.eventDirector.mainEvent == nil) then
					self.finish()
				end
			else
				self.timer = self.timer - 0.5
			end
		end
	end,
	
	onCharacterDeath = function (self, character)
		local client = DD.findClientByCharacter(character)
		if client == nil then return end
		
		self.timerStarted = true
		self.informSpectators({client})
	end,
	
	onChatMessage = function (self, message, sender)
		if ((message ~= '/join ' .. self.eventClass.tbl.name) and (message ~= '/exit ' .. self.eventClass.tbl.name)) or DD.isClientCharacterAlive(sender) then return end
		if message == '/join ' .. self.eventClass.tbl.name then
			if DD.tableHas(self.volunteers, sender) then
				DD.messageClient(sender, DD.stringReplace('You have already volunteered for that event. Do /exit {eventName} to undo.', {eventName = self.eventClass.tbl.name, seed = self.seed}), {preset = 'ghostRole'})
			elseif #DD.eventDirector.getClientEvents(sender) > 0 then
				DD.messageClient(sender, 'You are already part of another event and cannot join this one.', {preset = 'ghostRole'})
			else
				table.insert(self.volunteers, sender)
				DD.messageClient(sender, DD.stringReplace('You have joined the "{eventName}" event! Do /exit {eventName} to undo.', {eventName = self.eventClass.tbl.name, seed = self.seed}), {preset = 'ghostRole'})
			end
		else
			if DD.tableHas(self.volunteers, sender) then
				for key, volunteer in pairs(self.volunteers) do
					if volunteer == sender then table.remove(self.volunteers, key) end
				end
				DD.messageClient(sender, DD.stringReplace('You have exited the "{eventName}" event! Do /join {eventName} to undo.', {eventName = self.eventClass.tbl.name, seed = self.seed}), {preset = 'ghostRole'})
			else
				DD.messageClient(sender, 'You have not volunteered for that event.', {preset = 'ghostRole'})
			end
		end
		return true
	end,
	
	onFinish = function (self)
		for key, volunteer in pairs(self.volunteers) do
			if DD.isClientCharacterAlive(volunteer) or (DD.eventDirector.getClientEvents(sender) > 1) then table.remove(self.volunteers, key) end
		end
		
		if DD.tableSize(self.volunteers) == 0 then
			self.informSpectators(nil, 'The "{eventName}" event countdown has finished but no one joined it, so it has been cancelled.')
			self.fail()
			return
		end
		
		if (not self.eventClass.tbl.isMainEvent) or (DD.eventDirector.mainEvent == nil) then
			local event = self.eventClass.new(self.volunteers)
			event.start()
			
			if not event.failed then
				DD.eventDirector.goodness = DD.eventDirector.goodness + event.goodness / 2
				DD.eventDirector.cooldown = event.cooldown
				if event.isMainEvent then
					DD.eventDirector.mainEventCooldown = event.cooldown
					DD.eventDirector.mainEvent = event
				end
			end
		end
	end
})