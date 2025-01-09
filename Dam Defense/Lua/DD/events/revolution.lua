-- Pick some players to be part of a revolution tasked with killing all of security (and also trigger an eventAirdropSeparatist)
DD.eventRevolution = DD.class(DD.eventWithStartBase, function (self, rebels)
	self.rebels = rebels
end, {
	paramType = {'clientList'},
	clientKeys = {'rebels', 'security'},
	public = false,
	
	name = 'revolution',
	isMainEvent = true,
	cooldown = 60 * 6,
	weight = 2,
	goodness = -1,
	minimunAlivePercentage = 1.0,
	
	buildRebelList = function (self, excludeSet, useClientLogName)
		local excludeSet = excludeSet or {}
		local clients = DD.setSubtract(self.rebelsSet, excludeSet)
		
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
	
	rewardSecurityForArrests = function (self, multiplier)
		local arrestedRebels = 0
		for client in self.rebels do
			if DD.isClientCharacterAlive(client) and DD.isCharacterArrested(client.Character) then
				arrestedRebels = arrestedRebels + 1
			end
		end
		
		if arrestedRebels <= 0 then
			return
		end
		
		for client in Client.ClientList do
			if DD.isClientCharacterAlive(client) and DD.isCharacterSecurity(client.Character) then
				DD.giveMoneyToClient(client, arrestedRebels * multiplier, true)
			end
		end
	end,
	
	onStart = function (self)
		self.rebelsWon = false
		self.rebelsDoxTimer = 60 * 8
		self.rebelsDoxHappened = false
		
		-- Pick rebels
		local jobChances = {
			clown = 1,
			mechanic = 1,
			janitor = 0.5,
			engineer = 0.5,
			medicaldoctor = 0.5
		}
		local pickRebels = self.rebels == nil -- if a list of rebels was already given in the constructor then do not mess with it
		self.security = {}
		if pickRebels then self.rebels = {} end
		self.rebelsSet = DD.toSet(self.rebels)
		for client in DD.arrShuffle(Client.ClientList) do
			local chance = -1
			if DD.isClientCharacterAlive(client) and (client.Character.SpeciesName == 'human') and (not DD.isCharacterArrested(client.Character)) and (DD.tableSize(self.rebels) < math.ceil(#Client.ClientList / 3)) and DD.eventDirector.isClientBelowEventCap(client) then
				chance = jobChances[tostring(client.Character.JobIdentifier)] or -1
			end
			if DD.isClientCharacterAlive(client) and DD.isCharacterAntagSafe(client.Character) then
				chance = -1
			end
			if DD.isClientCharacterAlive(client) and (client.Character.SpeciesName == 'human') and DD.isCharacterSecurity(client.Character) then
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
				if DD.isClientCharacterAlive(client) and (client.Character.SpeciesName == 'human') and (not DD.isCharacterArrested(client.Character)) and DD.eventDirector.isClientBelowEventCap(client) then
					chance = jobChances[tostring(client.Character.JobIdentifier)] or -1
					if chance ~= -1 then chance = 1 end
				end
				if DD.isClientCharacterAlive(client) and DD.isCharacterAntagSafe(client.Character) then
					chance = -1
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
		
		-- Event requires 2 (or more) rebel leaders and (1 or more) security personnel
		if (DD.tableSize(self.rebels) <= 1) or (DD.tableSize(self.security) <= 0) then
			self.fail()
			return
		else
			-- Message
			local rebelsSet = DD.toSet(self.rebels)
			for client in Client.ClientList do
				if rebelsSet[client] then
				    -- Give rebel leader talent	
					client.Character.GiveTalent('rebelknowledge', true)
					-- Build rebel list
					local rebelList = self.buildRebelList({[client] = true})
					if DD.tableSize(self.rebels) > 1 then
						rebelList = ' Your comrades are: ' .. rebelList .. '.'
					else
						rebelList = ''
					end
					-- Rebel message
					DD.messageClient(client, 'You are a rebel leader! Your objective is to kill the captain and security. You have ' .. DD.numberToTime(self.stateStartInitialTimer) ..' until people become aware of the revolution, so start preparing now. Try to enlist non-security personnel to your cause.' .. rebelList .. ' Do /rebels to get info pertinent to this event.', {preset = 'crit'})
					if client.Character ~= nil then DD.giveAfflictionCharacter(client.Character, 'notificationfx', 999) end
				end
			end
			-- Spawn airdrops for rebels
			local event = DD.eventAirdropSeparatist.new()
			event.start()
		end
	end,
	
	stateStartInitialTimer = 60 * 2, -- in seconds
	
	stateMain = {
		onChange = function (self, state)
			local rebelsSet = DD.toSet(self.parent.rebels)
			for client in Client.ClientList do
				if rebelsSet[client] then
					DD.messageClient(client, 'Everyone, including security, has heard rumours about your conspiracy and are now aware of the revolution. The cat is out of the bag, so be careful! They do not know who the rebels are yet, but the list of rebels will be public in ' .. DD.numberToTime(self.parent.rebelsDoxTimer) ..'. Do /rebels to get info pertinent to this event.', {preset = 'crit'})
				elseif (client.Character ~= nil) and DD.isCharacterAntagSafe(client.Character) then
					-- Sec message
					DD.messageClient(client, "There have been rumours of a conspiracy agaisnt the captain and security. A revolution comes this way, so be prepared to arrest and even kill any rebels. List of rebels will be pubic in " .. DD.numberToTime(self.parent.rebelsDoxTimer) .. '. Do /rebels to get info pertinent to this event.', {preset = 'crit'})
				else
					-- Neutral message
					DD.messageClient(client, "There have been rumours of a revolution. You should ally yourself with the rebels or security. Has security ever treated you well though? List of rebels will be pubic in " .. DD.numberToTime(self.parent.rebelsDoxTimer) .. '. Do /rebels to get info pertinent to this event.', {preset = 'crit'})
				end
				if client.Character ~= nil then DD.giveAfflictionCharacter(client.Character, 'notificationfx', 999) end
			end
			-- Make event public
			self.parent.public = true
		end,
		onThink = function (self)
			if (DD.thinkCounter % 30 ~= 0) or (not Game.RoundStarted) then return end
			local timesPerSecond = 2
			
			-- See if security is still alivd
			local anySecurityIsAlive = false
			self.parent.security = {}
			for client in Client.ClientList do
				if DD.isClientCharacterAlive(client) and DD.isCharacterSecurity(client.Character) and (client.Character.SpeciesName == 'human') then
					table.insert(self.parent.security, client)
					anySecurityIsAlive = true
				end
			end
			
			-- See if any rebel is alive
			local anyRebelIsAlive = false
			for key, rebel in pairs(self.parent.rebels) do
				if DD.isClientCharacterAlive(rebel) and (not DD.isCharacterArrested(rebel.Character)) and (rebel.Character.SpeciesName == 'human') then
					anyRebelIsAlive = true
				else
					if (not DD.isClientCharacterAlive(rebel)) or (rebel.Character.SpeciesName ~= 'human') then
						DD.messageClient(rebel, 'You have died and are not an antagonist anymore!', {preset = 'crit'})
						self.parent.rebels[key] = nil
						self.parent.rebelsSet[rebel] = nil
					end
				end
			end
			
			-- Increase time pressure
			local timeToExplode = 15 * 60 -- in seconds
			for client in self.parent.rebels do
				DD.giveAfflictionCharacter(client.Character, 'timepressure', 60/timeToExplode/timesPerSecond)
			end
			
			-- End event if all of security is dead or if all rebel leaders are dead/arrested
			if not anySecurityIsAlive then
				self.parent.rebelsWon = true
				self.parent.finish()
				return
			end
			if not anyRebelIsAlive then
				self.parent.finish()
				return
			end
			if anySecurityIsAlive and anyRebelIsAlive and not self.parent.rebelsDoxHappened then
				if self.parent.rebelsDoxTimer > 0 then
					self.parent.rebelsDoxTimer = self.parent.rebelsDoxTimer - 0.5
				else
					self.parent.rebelsDoxHappened = true
					-- Build rebel list
					local rebelList = self.parent.buildRebelList()
					
					local message = ''
					message = 'The Nexascanner (TM) has finished its "rebel search algorithm" and found the rebel leaders to be: ' .. rebelList .. '. Do /rebels to get a list of rebel leaders.'
					DD.messageAllClients(message, {preset = 'crit'})
				end
			end
		end,
	},
	
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
			local rebelList = self.buildRebelList(nil, true)
			local message = ''
			message = 'The rebel leaders are: ' .. rebelList .. '.'
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
		for client in Client.ClientList do
			if client.Character ~= nil then DD.giveAfflictionCharacter(client.Character, 'notificationfx', 999) end
		end
		if self.rebelsWon then
			DD.messageAllClients('Rebels have won this round! Round ending in 10 seconds.', {preset = 'crit'})
			DD.roundData.roundEnding = true
			Timer.Wait(function ()
				Game.EndGame()
			end, 10 * 1000)
		else
			self.rewardSecurityForArrests(5)
			DD.messageAllClients('All rebels have been eliminated or arrested.', {preset = 'goodinfo'})
		end
	end,
	
	onFinishAlways = function (self)
		if self.rebels == nil then self.rebels = {} end
		for client in self.rebels do
			if client.Character ~= nil then
				if client.Character.CharacterHealth.GetAffliction('timepressure', true) ~= nil then
					client.Character.CharacterHealth.GetAffliction('timepressure', true).SetStrength(0)
				end
			end
		end
	end
})