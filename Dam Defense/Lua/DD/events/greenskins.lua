-- Spawn in a few silly masked little goobers in the sewers
DD.eventGreenskins = DD.class(DD.eventBase, function (self, greenskins)
	self.greenskins = greenskins
	if type(self.greenskins) == 'table' then
		self.greenskinsSet = DD.toSet(self.greenskins)
	end
end, {
	paramType = {'clientList'},
	clientKeys = {'greenskins'},
	public = false,
	
	name = 'greenskins',
	isMainEvent = true,
	cooldown = 60 * 2,
	weight = 0.5,
	goodness = -1.5,
	minimunDeadPercentage  = 0.5,
	
	updateGreenskinList = function (self)
		self.greenskins = {}
		for client in Client.ClientList do
			if DD.isClientCharacterAlive(client) and ((client.Character.SpeciesName == 'humanGoblin') or (client.Character.SpeciesName == 'humanTroll')) then
				table.insert(self.greenskins, client)
			end
		end
		self.greenskinsSet = DD.toSet(self.greenskins)
		return self.greenskins
	end,
	
	onStart = function (self)
		-- Pick greenskins
		if self.greenskins == nil then
			self.greenskinsSet = {}
			self.greenskins = {}
			for client in DD.arrShuffle(Client.ClientList) do
				if (not DD.isClientCharacterAlive(client)) and DD.eventDirector.isClientBelowEventCap(client) then
					table.insert(self.greenskins, client)
					self.greenskinsSet[client] = true
				end
			end
		end
		
		if DD.tableSize(self.greenskins) <= 0 then
			self.fail()
			return
		else
			-- Spawn greenskins and do client messages
			for client in Client.ClientList do
				if self.greenskinsSet[client] then
					-- Is Troll
					local conversionTrollPercentage = 20
					local isTroll = math.random(100) <= conversionTrollPercentage
					local speciesName = 'humanGoblin'
					if isTroll then speciesName = 'humanTroll' end
					
					local greenskinInfo = DD.stringLocalize('greenskinInfo')
					
					local job = 'greenskinjob'
					local pos = DD.getLocation(function (item) return item.HasTag('dd_wetsewer') end).WorldPosition
					local character = DD.spawnHuman(client, job, pos, nil, nil, speciesName)
					character.SetOriginalTeamAndChangeTeam(CharacterTeamType.Team1, true)
					character.UpdateTeam()
					DD.messageClient(client, greenskinInfo, {preset = 'crit'})
				end
			end
		end
	end,
	
	onThink = function (self)
		if (DD.thinkCounter % 30 ~= 0) or (not Game.RoundStarted) then return end
		local timesPerSecond = 2
		
		-- See if any greenskin is alive
		self.updateGreenskinList()
		
		-- Increase time pressure
		local timeToExplode = 8 * 60 + 20 -- in seconds
		for client in self.greenskins do
			DD.giveAfflictionCharacter(client.Character, 'timepressure', 60/timeToExplode/timesPerSecond)
		end
		
		-- End event if all reactors are broken or all nukies are dead
		if DD.tableSize(self.greenskins) <= 0 then
			self.finish()
		end
	end,
	
	onFinish = function (self)
		for client in Client.ClientList do
			if client.Character ~= nil then DD.giveAfflictionCharacter(client.Character, 'notificationfx', 999) end
		end
		for item in Item.ItemList do
			if (item.Prefab.Identifier == 'goblinmask') or (item.Prefab.Identifier == 'goblincrate') or (item.Prefab.Identifier == 'midazolam') then
				Entity.Spawner.AddItemToRemoveQueue(item)
			end
		end
		if DD.tableSize(self.greenskins) <= 0 then
			DD.messageAllClients(DD.stringLocalize('greenskinsEventEndDefeat'), {preset = 'goodinfo'})
		end
	end
})