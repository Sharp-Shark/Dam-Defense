-- Has a non-security player be tasked with killing with another non-security player
DD.eventVIP = DD.class(DD.eventBase, function (self, vip, guard)
	self.vip = vip
	self.guard = guard
end, {
	paramType = {'client', 'client'},
	clientKeys = {'vip', 'guard'},
	public = false,
	
	name = 'vip',
	instanceCap = 1,
	isMainEvent = false,
	cooldown = 60 * 3,
	weight = 1.5,
	goodness = 0.5,
	
	onStart = function (self)
		local ignorePlayerCount = false
		if (self.vip ~= nil) or (self.guard ~= nil) then
			ignorePlayerCount = true
		end
	
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
				if (not DD.isClientCharacterAlive(client)) and client.InGame then
					self.guard = client
					break
				end
			end
		end
		
		-- event requires 6 or more players
		if (self.vip == nil) or (self.guard == nil) or ((not ignorePlayerCount) and (DD.tableSize(Client.ClientList) <= 5)) then
			self.fail()
			return
		else
			-- Bounty
			self.bounty = 30
			-- Spawn bodyguard
			local job = 'bodyguard'
			local pos = self.vip.Character.WorldPosition
			local character = DD.spawnHuman(self.guard, job, pos)
			character.SetOriginalTeamAndChangeTeam(CharacterTeamType.Team1, true)
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
			DD.messageClient(self.vip, 'You are now a VIP. A body guard, ' .. self.guard.Name ..', has been assigned to keep you safe from hostiles. Your pay grade has been raised.', {preset = 'crit'})
			DD.messageClient(self.guard, 'You have been tasked with keeping VIP ' .. self.vip.Name .. ' alive at all costs. Failure will result in immediate termination. Your pay grade has been raised.', {preset = 'crit'})
			local otherClients = DD.setSubtract(DD.toSet(Client.ClientList), {[self.vip] = true, [self.guard] = true})
			DD.messageClients(DD.tableKeys(otherClients), 'A VIP is in town! Any non-medical and non-security personnel who kills ' .. self.vip.name .. ' will be rewarded with ' .. self.bounty ..' nexcredits.', {preset = 'crit'})
		end
	end,
	
	onThink = function (self)
		if (DD.thinkCounter % 30 ~= 0) or (not Game.RoundStarted) then return end
		local timesPerSecond = 2
		
		if self.vip == nil then
			self.fail()
			return
		end
		
		if not DD.isClientCharacterAlive(self.vip) then
			self.finish()
		end
	end,
	
	onCharacterDeath = function (self, character)
		if self.vip == nil then
			self.fail()
			return
		end
		
		if (self.guard ~= nil) and (self.guard.Character ~= nil) and (character == self.guard.Character) then
			DD.messageClient(self.guard, 'You have died and are not a body guard anymore!', {preset = 'crit'})
			DD.roundData.characterSalaryTimer[self.guard.Character] = nil
			self.guard = nil
		end
		
		if (self.vip.Character == nil) or (self.vip.Character == character) then
			self.finish()
		end
	end,
	
	onFinish = function (self)
		local rewarded = false
		if (self.vip.Character ~= nil) and (self.vip.Character.LastAttacker ~= nil) and not DD.isCharacterAntagSafe(self.vip.Character.LastAttacker) then
			local murderer = DD.findClientByCharacter(self.vip.Character.LastAttacker)
			if (murderer ~= self.vip) and (murderer ~= self.guard) then
				DD.giveMoneyToClient(murderer, self.bounty, true)
				rewarded = true
			end
		end
		if rewarded then
			DD.messageAllClients('The VIP is dead! An anonymous person has been rewarded for their death.', {preset = 'crit'})
		else
			DD.messageAllClients('The VIP is dead! No one has been rewarded for their death.', {preset = 'crit'})
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