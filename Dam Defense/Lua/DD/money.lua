if CLIENT then return end

-- Calculates the interval necessary for an amount of money to be acquired given a period of time
-- If money = 30 and period = 60 then interval = 2
local getJobSalaryTimer = function (money, period)
	local period = period or (60 * 5)
	return period / money
end
DD.jobSalaryTimer = {
	captain = getJobSalaryTimer(10),
	diver = getJobSalaryTimer(7),
	securityofficer = getJobSalaryTimer(7),
	researcher = getJobSalaryTimer(7),
	medicaldoctor = getJobSalaryTimer(5),
	engineer = getJobSalaryTimer(5),
	mechanic = getJobSalaryTimer(2),
	clown = getJobSalaryTimer(2),
	-- removed jobs
	foreman = getJobSalaryTimer(7),
	assistant = getJobSalaryTimer(2)
}

-- Event for giving people money on "/withdraw" command
DD.eventWithdraw = DD.class(DD.eventBase, function (self, client, amount)
	self.client = client
	self.amount = amount
end, {
	name = 'withdraw',
	isMainEvent = false,
	cooldown = 0,
	weight = 0,
	goodness = 0,
	
	onStart = function (self)
		if self.client == nil then
			for client in DD.arrShuffle(Client.ClientList) do
				if DD.isClientCharacterAlive(client) and (not client.Character.IsArrested) and DD.eventDirector.isClientBelowEventCap(client) then
					self.client = client
					break
				end
			end
		end
		if self.amount == nil then
			self.amount = math.ceil(math.random() * 120)
		end
		if (self.client == nil) or (self.amount == nil) then
			self.fail()
			return
		end
	
		local inventory = self.client.Character.Inventory
		
		-- Spawn crate at airdrop pos and fill it with items
		Entity.Spawner.AddItemToSpawnQueue(ItemPrefab.GetItemPrefab('moneycase'), inventory, nil, nil, function (spawnedItem)
			for n = 1, self.amount do
				Entity.Spawner.AddItemToSpawnQueue(ItemPrefab.GetItemPrefab('money'), spawnedItem.OwnInventory, nil, nil, function () return end)
			end
			self.item = spawnedItem
		end, true, nil, nil)
		
		-- Timer until crate deletes itself (to avoid cluttering the map with crates)
		self.timer = 40
		
		-- Warn airdrop has been spawned
		local message = 'A Nexcase (TM) with {amount} Nexcredits (TM) has been teleported to you by Nexmail (TM). It will be teleported back in {seconds} seconds along with anything left inside!'
		DD.messageClient(self.client, DD.stringReplace(message, {amount = self.amount, seconds = self.timer}), {preset = 'command'})
	end,
	
	onThink = function (self)
		if (DD.thinkCounter % 30 ~= 0) or (not Game.RoundStarted) then return end
		
		if self.timer <= 0 then
			self.finish()
		else
			self.timer = self.timer - 0.5
		end
	end,
	
	onFinishAlways = function (self)
		if self.item ~= nil then
			Entity.Spawner.AddEntityToRemoveQueue(self.item)
		end
	end
})

DD.giveMoneyToClient = function (client, amount, announce)
	if DD.roundData.bank[client] ~= nil then
		DD.roundData.bank[client] = DD.roundData.bank[client] + amount
	else
		DD.roundData.bank[client] = amount
	end
	if announce then
		local message = 'You have received {amount} Nexcredits (TM).'
		DD.messageClient(client, DD.stringReplace(message, {amount = amount}), {preset = 'command'})
	end
end

DD.giveMoneyToClients = function (clients, amount, announce)
	for client in clients do
		DD.giveMoneyToClient(client, amount, announce)
	end
end

DD.giveMoneyToSecurity = function (amount, announce)
	for client in Client.ClientList do
		if DD.isClientCharacterAlive(client) and DD.isCharacterSecurity(client.Character) then
			DD.giveMoneyToClient(client, amount, announce)
		end
	end
end

DD.updateMoney = function ()
	for client in Client.ClientList do
		if DD.isClientCharacterAlive(client) and (client.Character.SpeciesName == 'human') then
			local character = client.Character
			local jobIdentifier = tostring(character.JobIdentifier)
			if (DD.roundData.withdrawCooldown[client] ~= nil) and (DD.roundData.withdrawCooldown[client] > 0) then
				DD.roundData.withdrawCooldown[client] = DD.roundData.withdrawCooldown[client] - 0.5
			end
			if DD.roundData.salaryTimer[client] ~= nil then
				if DD.roundData.salaryTimer[client] <= 0 then
					DD.giveMoneyToClient(client, 1)
					DD.roundData.salaryTimer[client] = DD.jobSalaryTimer[jobIdentifier]
				else
					DD.roundData.salaryTimer[client] = DD.roundData.salaryTimer[client] - 0.5
				end
			else
				DD.giveMoneyToClient(client, 0)
				DD.roundData.salaryTimer[client] = DD.jobSalaryTimer[jobIdentifier]
			end
		end
	end
end

DD.thinkFunctions.money = function ()
	if (DD.thinkCounter % 30 ~= 0) or (not Game.RoundStarted) or (DD.roundData.roundEnding) then return end
	
	DD.updateMoney()
end

DD.roundStartFunctions.money = function ()
	DD.roundData.bank = {}
	DD.roundData.salaryTimer = {}
	DD.roundData.withdrawCooldown = {}
end

DD.characterDeathFunctions.deleteSalaryTimerOnDeath = function (character)
	client = DD.findClientByCharacter(character)
	if client == nil then return end
	
	DD.roundData.salaryTimer[client] = nil
end

DD.chatMessageFunctions.tellCredits = function (message, sender)
	if message ~= '/credits' then return end
	if (DD.roundData.bank[sender] == nil) or (DD.roundData.salaryTimer[sender] == nil) then
		local message = 'You have no Nexaccount (TM).'
		DD.messageClient(sender, DD.stringReplace(message, {}), {preset = 'command'})
		return true
	end
	
	local amount = DD.roundData.bank[sender]
	local message = 'You have {amount} Nexcredits (TM) in your Nexaccount (TM). Your next reward will be in {timer}.'
	
	DD.messageClient(sender, DD.stringReplace(message, {amount = amount, timer = DD.numberToTime(DD.roundData.salaryTimer[sender])}), {preset = 'command'})
	
	return true
end

DD.chatMessageFunctions.withdrawMoney = function (message, sender)
	if string.sub(message, 1, 9) ~= '/withdraw' then return end
	if DD.roundData.bank[sender] == nil then
		local message = 'You have no Nexaccount (TM).'
		DD.messageClient(sender, DD.stringReplace(message, {}), {preset = 'command'})
		return true
	end
	if not DD.isClientCharacterAlive(sender) then
		local message = 'You have to be alive to withdraw.'
		DD.messageClient(sender, DD.stringReplace(message, {}), {preset = 'command'})
		return true
	end
	if sender.Character.SpeciesName ~= 'human' then
		local message = 'Error! Non-human lifeform detected.'
		DD.messageClient(sender, DD.stringReplace(message, {}), {preset = 'command'})
		return true
	end
	if (DD.roundData.withdrawCooldown[sender] ~= nil) and (DD.roundData.withdrawCooldown[sender] > 0) then
		local message = 'You have to wait {timer} before you can withdraw again.'
		DD.messageClient(sender, DD.stringReplace(message, {timer = DD.numberToTime(DD.roundData.withdrawCooldown[sender])}), {preset = 'command'})
		return true
	end

	local args = DD.stringSplit(message, ' ') table.remove(args, 1)
	
	local maxAmount = math.min(120, DD.roundData.bank[sender])
	local amount = math.max(0, math.min(maxAmount, tonumber(args[1]) or 999999))
	
	if (amount == nil) or (amount <= 1) then
		local message = 'You have tried to withdraw an invalid amount and thusly failed.'
		DD.messageClient(sender, DD.stringReplace(message, {}), {preset = 'command'})
		return true
	end
	
	DD.roundData.withdrawCooldown[sender] = 30
	
	DD.roundData.bank[sender] = DD.roundData.bank[sender] - amount
	
	local event = DD.eventWithdraw.new(sender, amount)
	event.start()
	
	return true
end