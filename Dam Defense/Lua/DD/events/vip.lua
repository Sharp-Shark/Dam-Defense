-- Has a non-security player be tasked with killing with another non-security player
DD.eventVIP = DD.class(DD.eventBase, function (self, vip, guard)
	self.vip = vip
	self.guard = guard
end, {
	paramType = {'client', 'client'},
	clientKeys = {'vip', 'guard'},
	
	name = 'vip',
	instanceCap = 1,
	isMainEvent = false,
	cooldown = 60 * 3,
	weight = 2,
	goodness = 1,
	minimunDeadPercentage = 0.01,
	
	onStart = function (self)
		if self.vip == nil then
			for client in DD.arrShuffle(Client.ClientList) do
				if DD.isClientCharacterAlive(client) and (client.Character.SpeciesName == 'human') and (not DD.isCharacterSecurity(client.Character)) and DD.eventDirector.isClientBelowEventCap(client) then
					self.vip = client
					break
				end
			end
		end
		
		if self.guard == nil then
			for client in DD.arrShuffle(Client.ClientList) do
				if DD.isClientRespawnable(client) and client.InGame then
					self.guard = client
					break
				end
			end
		end
		
		-- event requires 5 or more players
		if (self.vip == nil) or (self.guard == nil) or ((not self.manuallyTriggered) and (DD.tableSize(Client.ClientList) <= 4)) then
			self.fail('conditions to start could not be met')
			return
		else
			-- Bounty
			self.bounty = 30
			-- Spawn bodyguard
			local team = CharacterTeamType.Team1
			local job = 'bodyguard'
			local pos = self.vip.Character.WorldPosition
			local subclass = 0
			if self.vip.Character.JobIdentifier == 'jet' then
				job = 'jet'
				subclass = 1
				team = CharacterTeamType.Team2
				for event in DD.eventDirector.getEventInstances('nukies') do
					table.insert(event.nukies, self.guard)
					event.nukiesSet[self.guard] = true
				end
			elseif  self.vip.Character.JobIdentifier == 'mercsevil' then
				job = 'mercsevil'
				team = CharacterTeamType.Team2
				for event in DD.eventDirector.getEventInstances('deathSquad') do
					table.insert(event.nukies, self.guard)
					event.nukiesSet[self.guard] = true
				end
			end
			local character = DD.spawnHuman(self.guard, job, pos, nil, subclass)
			character.SetOriginalTeamAndChangeTeam(team, true)
			character.UpdateTeam()
			-- Remove item at innerclothing
			if self.vip.Character.Inventory.GetItemAt(DD.invSlots.innerclothing) ~= nil then
				self.vip.Character.Inventory.GetItemAt(DD.invSlots.innerclothing).drop()
			end
			-- Get identifier
			local vipOutfitIdentifiers = {'vipclothes1', 'vipclothes2', 'vipclothes3'}
			local vipOutfitIdentifier = vipOutfitIdentifiers[math.random(#vipOutfitIdentifiers)]
			-- Put vip outfit at headslot
			Timer.Wait(function ()
				Entity.Spawner.AddItemToSpawnQueue(ItemPrefab.GetItemPrefab(vipOutfitIdentifier), self.vip.Character.Inventory, nil, nil, function (spawnedItem)
					self.vipOutfit = spawnedItem
					Timer.Wait(function ()
						self.vip.Character.Inventory.TryPutItem(spawnedItem, DD.invSlots.innerclothing, true, true, self.vip.Character, true, true)
					end, 1)
				end)
				-- give VIP a headset if he lacks one
				if self.vip.Character.Inventory.GetItemAt(DD.invSlots.headset) == nil then
					Entity.Spawner.AddItemToSpawnQueue(ItemPrefab.GetItemPrefab('headset'), self.vip.Character.Inventory, nil, nil, function (spawnedItem)
						Timer.Wait(function ()
							self.vip.Character.Inventory.TryPutItem(spawnedItem, DD.invSlots.headset, true, true, self.vip.Character, true, true)
						end, 1)
					end)
				end
			end, 1)
			-- Custom salary for VIP
			DD.roundData.characterSalaryTimer[self.vip.Character] = DD.jobSalaryTimer.captain
			DD.roundData.salaryTimer[self.vip] = DD.roundData.characterSalaryTimer[self.vip.Character]
			-- Messages
			DD.messageClient(self.vip, DD.stringLocalize('vipMessageBoss', {guardName = self.guard.Name}), {preset = 'crit'})
			DD.messageClient(self.guard, DD.stringLocalize('vipMessageBodyguard', {vipName = self.vip.Name}), {preset = 'crit'})
			local otherClients = DD.setSubtract(DD.toSet(Client.ClientList), {[self.vip] = true, [self.guard] = true})
			DD.messageClients(DD.tableKeys(otherClients), DD.stringLocalize('vipMessagePublic', {vipName = self.vip.Name, bounty = self.bounty}), {preset = 'crit'})
			for client in Client.ClientList do
				if client.Character ~= nil then DD.giveAfflictionCharacter(client.Character, 'notificationfx', 999) end
			end
		end
	end,
	
	onThink = function (self)
		if (DD.thinkCounter % 30 ~= 0) or (not Game.RoundStarted) then return end
		local timesPerSecond = 2
		
		if self.vip == nil then
			self.fail('"self.vip" is nil at "onThink"')
			return
		end
		
		if not DD.isClientCharacterAlive(self.vip) then
			self.finish()
		end
	end,
	
	onCharacterDeath = function (self, character)
		if self.vip == nil then
			self.fail('"self.vip" is nil at "onCharacterDeath"')
			return
		end
		
		if (self.guard ~= nil) and (self.guard.Character ~= nil) and (character == self.guard.Character) then
			DD.messageClient(self.guard, DD.stringLocalize('bodyguardDead'), {preset = 'crit'})
			DD.roundData.characterSalaryTimer[self.guard.Character] = nil
			self.guard = nil
		end
		
		if (self.vip.Character == nil) or (self.vip.Character == character) then
			self.finish()
		end
	end,
	
	onFinish = function (self)
		for client in Client.ClientList do
			if client.Character ~= nil then DD.giveAfflictionCharacter(client.Character, 'notificationfx', 999) end
		end
		local rewarded = false
		if (self.vip.Character ~= nil) and (self.vip.Character.LastAttacker ~= nil) and not DD.isCharacterAntagSafe(self.vip.Character.LastAttacker) then
			local murderer = DD.findClientByCharacter(self.vip.Character.LastAttacker)
			if (murderer ~= nil) and (murderer ~= self.vip) and (murderer ~= self.guard) then
				DD.giveMoneyToClient(murderer, self.bounty, true)
				rewarded = true
				-- Start event for security to arrest murderer
				local event = DD.eventArrest.new(murderer, 'manslaughter', false)
				event.start()
			end
		end
		if rewarded then
			DD.messageAllClients(DD.stringLocalize('vipEnd'), {preset = 'crit'})
		else
			DD.messageAllClients(DD.stringLocalize('vipEndNoReward'), {preset = 'crit'})
		end
		if (self.guard ~= nil) and DD.isClientCharacterAlive(self.guard) then
			DD.giveAfflictionCharacter(self.guard.Character, 'beepingbomb', 5)
		end
	end,
	
	onFinishAlways = function (self)
		if self.vipOutfit ~= nil then
			Entity.Spawner.AddItemToRemoveQueue(self.vipOutfit)
		end
		if (self.vip ~= nil) and (self.vip.Character ~= nil) then
			DD.roundData.characterSalaryTimer[self.vip.Character] = nil
		end
		if (self.guard ~= nil) and (self.guard.Character ~= nil) then
			DD.roundData.characterSalaryTimer[self.guard.Character] = nil
		end
	end
})