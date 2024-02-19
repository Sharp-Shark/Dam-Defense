-- Pick some players to be part of a revolution tasked with killing all of security (and also trigger an eventAirdropSeparatist)
DD.eventRevolution = DD.class(DD.eventBase, function (self, rebels)
	self.rebels = rebels
end, {
	paramType = {'clientList'},
	clientKeys = {'rebels', 'security'},
	
	name = 'revolution',
	isMainEvent = true,
	cooldown = 60 * 3,
	weight = 2,
	goodness = -1,
	
	onStart = function (self)
		self.rebelsWon = false
		self.rebelsDoxTimer = 60 * 10
		self.rebelsDoxHappened = false
		
		-- Pick rebels
		local jobChances = {
			clown = 1,
			laborer = 1,
			mechanic = 1,
			engineer = 0.5,
			medicaldoctor = 0.5,
			researcher = 0.5
		}
		local pickRebels = self.rebels == nil -- if a list of rebels was already given in the constructor then do not mess with it
		self.security = {}
		if pickRebels then self.rebels = {} end
		self.rebelsSet = DD.toSet(self.rebels)
		for client in DD.arrShuffle(Client.ClientList) do
			local chance = -1
			if DD.isClientCharacterAlive(client) and (not client.Character.IsArrested) and (DD.tableSize(self.rebels) < math.ceil(#Client.ClientList / 3)) and DD.eventDirector.isClientBelowEventCap(client) then
				chance = jobChances[tostring(client.Character.JobIdentifier)] or -1
			end
			if DD.isClientCharacterAlive(client) and DD.isCharacterSecurity(client.Character) then
				table.insert(self.security, client)
			elseif (math.random() < chance) and pickRebels then
				table.insert(self.rebels, client)
				self.rebelsSet[client] = true
			end
		end
		-- Incase the rebel cap still hasn't been met ignore RNG and make anyone (who isn't security) into a rebel leader until cap is reached
		if DD.tableSize(self.rebels) < math.ceil(#Client.ClientList / 3) then
			for client in DD.arrShuffle(Client.ClientList) do
				local chance = -1
				if DD.isClientCharacterAlive(client) and (not client.Character.IsArrested) and DD.eventDirector.isClientBelowEventCap(client) then
					chance = jobChances[tostring(client.Character.JobIdentifier)] or -1
					if chance ~= -1 then chance = 1 end
				end
				if self.rebelsSet[rebel] then chance = -1 end -- avoid adding a player to the rebel list twice
				if (0 < chance) and pickRebels then
					table.insert(self.rebels, client)
					self.rebelsSet[client] = true
				end
				if not (DD.tableSize(self.rebels) < math.ceil(#Client.ClientList / 3)) then
					break
				end
			end
		end
		
		if (DD.tableSize(self.rebels) <= 0) or (DD.tableSize(self.security) <= 0) then
			self.fail()
			return
		else
			-- Message
			local rebelsSet = DD.toSet(self.rebels)
			for client in Client.ClientList do
				if rebelsSet[client] then
					-- Build rebel list
					local rebelsList = ''
					for rebel in self.rebels do
						if rebel ~= client then
							rebelsList = rebelsList .. rebel.Name .. ', '
						end
					end
					rebelsList = string.sub(rebelsList, 1, #rebelsList - 2)
					if DD.tableSize(self.rebels) > 1 then rebelsList = ' Your comrades are: ' .. rebelsList .. '.' end 
					-- Rebel message
					DD.messageClient(client, 'You are a rebel leader! Your objective is to kill the captain and security. Try to enlist non-security personnel to your cause.' .. rebelsList .. ' List of rebels will be public in ' .. DD.numberToTime(self.rebelsDoxTimer) ..'. Do /rebels to get info pertinent to this event.', {preset = 'crit'})
				elseif (client.Character ~= nil) and DD.isCharacterSecurity(client.Character) then
					-- Sec message
					DD.messageClient(client, "There have been rumours of a conspiracy agaisn't the captain and security. A revolution comes this way, so be prepared to arrest and even kill any rebels. List of rebels will be pubic in " .. DD.numberToTime(self.rebelsDoxTimer) .. '. Do /rebels to get info pertinent to this event.', {preset = 'crit'})
				else
					-- Neutral message
					DD.messageClient(client, "There have been rumours of a revolution. You should ally yourself with the rebels or security. Has security ever treated you well though? List of rebels will be pubic in " .. DD.numberToTime(self.rebelsDoxTimer) .. '. Do /rebels to get info pertinent to this event.', {preset = 'crit'})
				end
			end
			-- Spawn airdrops for security and rebels
			local event = DD.eventAirdropSecurity.new()
			event.start()
			local event = DD.eventAirdropSeparatist.new()
			event.start()
		end
	end,
	
	onThink = function (self)
		if (DD.thinkCounter % 30 ~= 0) or (not Game.RoundStarted) then return end
		
		-- See if security is still alivd
		local anySecurityIsAlive = false
		self.security = {}
		for client in Client.ClientList do
			if DD.isClientCharacterAlive(client) and DD.isCharacterSecurity(client.Character) then
				table.insert(self.security, client)
				anySecurityIsAlive = true
			end
		end
		
		-- See if any rebel is alive
		local anyRebelIsAlive = false
		for key, rebel in pairs(self.rebels) do
			if DD.isClientCharacterAlive(rebel) and (not rebel.Character.IsArrested) then
				anyRebelIsAlive = true
			else
				if not DD.isClientCharacterAlive(rebel) then
					DD.messageClient(rebel, 'You have died and are not an antagonist anymore!', {preset = 'crit'})
					self.rebels[key] = nil
					self.rebelsSet[rebel] = nil
				end
			end
		end
		
		-- End event if all of security is dead or if all rebel leaders are dead/arrested
		if not anySecurityIsAlive then
			self.rebelsWon = true
			self.finish()
			return
		end
		if not anyRebelIsAlive then
			self.finish()
			return
		end
		if anySecurityIsAlive and anyRebelIsAlive and not self.rebelsDoxHappened then
			if self.rebelsDoxTimer > 0 then
				self.rebelsDoxTimer = self.rebelsDoxTimer - 0.5
			else
				self.rebelsDoxHappened = true
				-- Build rebel list
				local rebelsList = ''
				for rebel in self.rebels do
					if rebel ~= client then
						rebelsList = rebelsList .. rebel.Name .. ', '
					end
				end
				rebelsList = string.sub(rebelsList, 1, #rebelsList - 2)
				
				local message = ''
				message = 'The Nexascanner (TM) has finished its "rebel search algorithm" and found the rebel leaders to be: ' .. rebelsList .. '. Do /rebels to get a list of rebel leaders.'
				DD.messageAllClients(message, {preset = 'crit'})
			end
		end
	end,
	
	onCharacterDeath = function (self, character)
		local client = DD.findClientByCharacter(character)
		if client == nil then return end
		for key, rebel in pairs(self.rebels) do
			if not DD.isClientCharacterAlive(rebel) then
				DD.messageClient(rebel, 'You have died and are not an antagonist anymore!', {preset = 'crit'})
				self.rebels[key] = nil
				self.rebelsSet[rebel] = nil
			end
		end
	end,
	
	onChatMessage = function (self, message, sender)
		if message ~= '/rebels' then return end
		
		if self.rebelsSet[sender] or self.rebelsDoxHappened then
			-- Build rebel list
			local rebelsList = ''
			for rebel in self.rebels do
				if rebel ~= client then
					rebelsList = rebelsList .. rebel.Name .. ', '
				end
			end
			rebelsList = string.sub(rebelsList, 1, #rebelsList - 2)
			
			local message = ''
			message = 'The rebel leaders are: ' .. rebelsList .. '.'
			if not self.rebelsDoxHappened then message = message .. ' The list of rebel leaders will be public in ' .. DD.numberToTime(self.rebelsDoxTimer) .. '.' end
			DD.messageClient(sender, message, {preset = 'command'})
		else
			local message = ''
			message = 'The list of rebel leaders will be public in ' .. DD.numberToTime(self.rebelsDoxTimer) .. '.'
			DD.messageClient(sender, message, {preset = 'command'})
		end
		
		return true
	end,
	
	onFinish = function (self)
		-- This is the end, beautiful friend. This is the end, my only friend. The end of our elaborated plans, the end of everything that stands. The end
		if self.rebelsWon then
			DD.messageAllClients('Rebels have won this round! Round ending in 10 seconds.', {preset = 'crit'})
			DD.roundData.roundEnding = true
			Timer.Wait(function ()
				Game.EndGame()
			end, 10 * 1000)
		else
			DD.messageAllClients('All rebels have been eliminated or arrested.', {preset = 'goodinfo'})
		end
	end
})