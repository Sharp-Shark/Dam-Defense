-- gang event with a boss and his goons
DD.eventGang = DD.class(DD.eventBase, function (self, boss)
	self.boss = boss
end, {
	paramType = {'client'},
	clientKeys = {'boss', 'goons', 'gangsters'},
	public = true,
	
	name = 'gang',
	isMainEvent = false,
	cooldown = 60 * 4,
	weight = 2,
	goodness = -2,
	minimunDeadPercentage = 0.01,
	
	removeClientFromGang = function (self, client, treason)
		-- remove from gang
		for key, goon in pairs(self.goons) do
			if goon == client then
				self.goons[key] = nil
			end
		end
		self.goonsSet[client] = nil
		for key, gangster in pairs(self.gangsters) do
			if gangster == client then
				self.gangsters[key] = nil
			end
		end
		self.gangstersSet[client] = nil
		
		-- message
		if treason then
			DD.messageClients(self.gangsters, DD.stringLocalize('gangTreasonNotice', {name = client.Name}), {preset = 'goodinfo'})
		end
	end,
	
	addClientToGang = function (self, client)
		-- antag safe jobs and dons cannot join gangs
		if DD.isCharacterAntagSafe(client.Character) or (client.Character.JobIdentifier == 'gangster') then
			return
		end
		-- a client can only be in one gang
		for event in DD.eventDirector.events do
			if (event.name == 'gang') and event.gangstersSet[client] and (event.seed ~= self.seed) then
				event.removeClientFromGang(client, true)
			end
		end
	
		-- message other members of the gang
		DD.messageClients(self.gangsters, DD.stringLocalize('gangRecruitmentNotice', {name = client.Name}), {preset = 'goodinfo'})
		
		-- add to gang
		table.insert(self.goons, client)
		self.goonsSet[client] = true
		table.insert(self.gangsters, client)
		self.gangstersSet[client] = true
		
		-- message recruited client
		DD.messageClient(client, DD.stringLocalize('gangGangsterInfo', {bossName = self.bossName, gangName = self.gangName}), {preset = 'crit'})
		
		-- do gang effect
		Timer.Wait(function ()
			if DD.isClientCharacterAlive(client) then
				DD.giveAfflictionCharacter(client.Character, 'gangfx', 999)
			end
		end, 1000)
		
		-- reset pulmonary emphysema
		local affliction = client.Character.CharacterHealth.GetAffliction('pulmonaryemphysema', true)
		if affliction ~= nil then
			affliction.SetStrength(0)
		end
		
		-- log
		self.logClients({[client] = true})
	end,
	
	buildList = function (self, set, excludeSet, useClientLogName)
		local excludeSet = excludeSet or {}
		local clients = DD.setSubtract(set, excludeSet)
		
		local text = ''
		for client, value in pairs(set) do
			if useClientLogName then
				text = text .. DD.clientLogName(client) .. ', '
			else
				text = text .. client.Name .. ', '
			end
		end
		text = string.sub(text, 1, #text - 2)
		return text
	end,
	
	onStart = function (self)
		local gangCount = 0
		for event in DD.eventDirector.events do
			if event.name == 'gang' then
				gangCount = gangCount + 1
				if gangCount >= 2 then
					self.fail('there cannot be more than 2 gangs at once')
					return
				end
			end
		end
		
		-- pick client to be boss
		if self.boss == nil then
			for client in DD.arrShuffle(Client.ClientList) do
				if DD.isClientRespawnable(client) and client.InGame then
					self.boss = client
					break
				end
			end
		end
		
		-- gang color
		if DD.roundData.gangEventAvailableColors == nil then
			DD.roundData.gangEventAvailableColors = {'cyan', 'yellow', 'magenta'}
		end
		self.gangColor = DD.roundData.gangEventAvailableColors[math.random(#DD.roundData.gangEventAvailableColors)]
		if self.gangColor == nil then
			self.fail('no gang colors available')
			return
		end
		
		-- gang names
		if DD.roundData.gangEventAvailableNames == nil then
			DD.roundData.gangEventAvailableNames = {
				'Benedettos',
				'Blahds',
				'Crepes',
				'Petrovic Mafiya',
				'Bosanska Trupa',
				'Gran Coppolas',
				'Eleganti Mafios',
				'Rojo Muertos',
			}
		end
		self.gangName = DD.roundData.gangEventAvailableNames[math.random(#DD.roundData.gangEventAvailableNames)]
		if self.gangName == nil then
			self.fail('no gang names available')
			return
		end
		
		-- event requires 5 or more players
		if (self.boss == nil) or ((not self.manuallyTriggered) and (DD.tableSize(Client.ClientList) <= 4)) then
			self.fail('conditions to start could not be met')
			return
		else
			-- set goons table (initially empty)
			self.goons = {}
			self.goonsSet = {}
			self.gangsters = {self.boss}
			self.gangstersSet = {[self.boss] = true}
			-- Remove color and name from available list
			for key, color in pairs(DD.roundData.gangEventAvailableColors) do
				if self.gangColor == color then
					table.remove(DD.roundData.gangEventAvailableColors, key)
				end
			end
			for key, name in pairs(DD.roundData.gangEventAvailableNames) do
				if self.gangName == name then
					table.remove(DD.roundData.gangEventAvailableNames, key)
				end
			end
			-- Spawn boss
			local job = 'gangster'
			local waypoint = DD.findRandomWaypointByJob(job)
			if waypoint == nil then waypoint = DD.findRandomWaypointByJob('clown') end
			local pos = waypoint.WorldPosition
			local character = DD.spawnHuman(self.boss, job, pos)
			character.SetOriginalTeamAndChangeTeam(CharacterTeamType.Team1, true)
			character.UpdateTeam()
			Timer.Wait(function ()
				character.GiveTalent(self.gangColor .. 'gangknowledge', true)
				Entity.Spawner.AddItemToSpawnQueue(ItemPrefab.GetItemPrefab(self.gangColor .. 'meth'), character.Inventory, nil, nil, function (spawnedItem) end)
			end, 1000)
			-- Record the name of the boss
			self.bossName = self.boss.Name
		end
	end,
	
	onThink = function (self)
		if (DD.thinkCounter % 30 ~= 0) or (not Game.RoundStarted) then return end
		local timesPerSecond = 2
		
		if self.boss == nil then
			self.fail('"self.boss" is nil at "onThink"')
			return
		end
		
		if not DD.isClientCharacterAlive(self.boss) then
			self.finish()
		end
	end,
	
	onCharacterDeath = function (self, character)
		if self.boss == nil then
			self.fail('"self.boss" is nil at "onCharacterDeath"')
			return
		end
		
		if self.goonsSet[character] then
			for key, goon in pairs(self.goons) do
				if not DD.isClientCharacterAlive(goon) then
					self.goons[key] = nil
					self.goonsSet[goon] = nil
					self.gangsters[key] = nil
					self.gangstersSet[goon] = nil
				end
			end	
		end
		
		if (self.boss.Character == nil) or (self.boss.Character == character) then
			self.finish()
		end
	end,
	
	onChatMessage = function (self, message, sender)
		if (message ~= '/gang') or not self.gangstersSet[sender] then return end
		
		local gangsterList
		gangsterList = self.buildList(self.gangstersSet, nil, true)
		if gangsterList == '' then gangsterList = DD.stringLocalize('empty') end
		-- Message
		DD.messageClient(sender, DD.stringLocalize('commandGang', {gangsterList = gangsterList}), {preset = 'command'})
		
		return true
	end,
	
	onFinish = function (self)
		DD.messageAllClients(DD.stringLocalize('gangEnd', {bossName = self.bossName, gangName = self.gangName}), {preset = 'goodinfo'})
		if self.boss ~= nil then DD.messageClient(self.boss, DD.stringLocalize('antagDead'), {preset = 'crit'}) end
	end,
})