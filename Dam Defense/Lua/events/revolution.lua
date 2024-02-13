-- Pick some players to be part of a revolution tasked with killing the captain (and also trigger a eventAirdropSeparatist)
DD.eventRevolution = DD.class(DD.eventBase, function (self, rebels)
	self.rebels = rebels
end, {
	paramType = {'clientList'},
	clientKeys = {'rebels'},
	
	name = 'revolution',
	isMainEvent = true,
	cooldown = 60 * 3,
	weight = 2,
	goodness = -1,
	
	onStart = function (self)
		self.rebelsWon = false
		
		-- Pick rebels
		local jobChances = {
			clown = 1,
			laborer = 1,
			mechanic = 1,
			engineer = 0.5,
			medicaldoctor = 0.5,
			researcher = 0.5
		}
		local pickRebels = self.rebels == nil -- if a list of rebels was already given in the constructor then do mess with it
		self.captain = nil
		if pickRebels then self.rebels = {} end
		for client in DD.arrShuffle(Client.ClientList) do
			local chance = 0
			if DD.isClientCharacterAlive(client) and (not client.Character.IsArrested) and (DD.tableSize(self.rebels) < math.ceil(#Client.ClientList / 3)) and DD.eventDirector.isClientBelowEventCap(client) then
				chance = jobChances[client.Character.JobIdentifier] or 0
			end
			if client.Character.HasJob('captain') then
				self.captain = client
			elseif (math.random() < chance) and pickRebels then
				table.insert(self.rebels, client)
			end
		end
		if DD.tableSize(self.rebels) < math.ceil(#Client.ClientList / 3) then
			for client in DD.arrShuffle(Client.ClientList) do
				local chance = 0
				if DD.isClientCharacterAlive(client) and (not client.Character.IsArrested) and (DD.tableSize(self.rebels) < math.ceil(#Client.ClientList / 3)) and DD.eventDirector.isClientBelowEventCap(client) then
					chance = jobChances[client.Character.JobIdentifier] or 0
					if chance ~= 0 then chance = 1 end
				end
				if math.random() < chance then
					table.insert(self.rebels, client)
				end
			end
		end
		
		if (DD.tableSize(self.rebels) <= 0) or (self.captain == nil) then
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
					DD.messageClient(client, 'You are a rebel leader! Your objective is to kill the captain, but do kill anyone who tries to stop you, especially security. Try to enlist non-security personnel to your cause.' .. rebelsList, {preset = 'crit'})
				elseif (client.Character ~= nil) and DD.isCharacterSecurity(client.Character) then
					-- Sec message
					DD.messageClient(client, "There have been rumours of a conspiracy agaisn't the captain, the security team and you. A revolution comes this way, so be prepared to arrest and even kill any rebels.", {preset = 'badinfo'})
				else
					-- Neutral message
					DD.messageClient(client, "There have been rumours of freedom fighters and terrorists. You may ally yourself with the rebels or the captain and his security team. Neutrality does not seem like a viable option...", {preset = 'info'})
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
		
		-- See if any rebel is alive
		local anyRebelIsAlive = false
		for key, rebel in pairs(self.rebels) do
			if DD.isClientCharacterAlive(rebel) and (not rebel.Character.IsArrested) then
				anyRebelIsAlive = true
			else
				if not DD.isClientCharacterAlive(rebel) then
					DD.messageClient(rebel, 'You have died and are not an antagonist anymore!', {preset = 'crit'})
					self.rebels[key] = nil
				end
			end
		end
		
		-- End event if captain is dead or all rebels are dead or arrested
		if not DD.isClientCharacterAlive(self.captain) then
			self.rebelsWon = true
			self.finish()
			return
		end
		if not anyRebelIsAlive then
			self.finish()
		end
	end,
	
	onCharacterDeath = function (self, character)
		local client = DD.findClientByCharacter(character)
		if client == nil then return end
		for key, rebel in pairs(self.rebels) do
			if not DD.isClientCharacterAlive(rebel) then
				DD.messageClient(rebel, 'You have died and are not an antagonist anymore!', {preset = 'crit'})
				self.rebels[key] = nil
			end
		end
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