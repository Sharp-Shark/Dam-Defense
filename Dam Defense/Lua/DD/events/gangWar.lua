-- Main event where 2 gangs fight. Although it is a main event, it can't possibly cause the round to end
DD.eventGangWar = DD.class(DD.eventWithStartBase, function (self, gang1, gang2)
	self.gang1 = gang1
	self.gang2 = gang2
	if type(self.gang1) == 'table' then
		self.gang1Set = DD.toSet(self.gang1)
	end
	if type(self.gang2) == 'table' then
		self.gang2Set = DD.toSet(self.gang2)
	end
end, {
	paramType = {'clientList', 'clientList'},
	clientKeys = {'gang1', 'gang2'},
	public = false,
	
	name = 'gangWar',
	isMainEvent = true,
	cooldown = 60 * 5,
	weight = 1.5,
	goodness = -0.5,
	minimunAlivePercentage = 1.0,
	
	-- set this to false unless testing the event
	debugMode = false,
	
	getShouldFinish = function (self)
		-- see if any gangster is not arrested
		local anyGangsterNotArrested = false
		local gang1Alive = false
		local gang2Alive = false
		for client in self.gang1 do
			if DD.isClientCharacterAlive(client) and (not DD.isCharacterArrested(client.Character)) then
				anyGangsterNotArrested = true
			end
			if DD.isClientCharacterAlive(client) then
				gang1Alive = true
			end
		end
		for client in self.gang2 do
			if DD.isClientCharacterAlive(client) and (not DD.isCharacterArrested(client.Character)) then
				anyGangsterNotArrested = true
			end
			if DD.isClientCharacterAlive(client) then
				gang2Alive = true
			end
		end
		
		-- end event
		if ((not gang1Alive) and (not gang2live)) and not self.debugMode then
			return true
		end
		if (not anyGangsterNotArrested) and not self.debugMode then
			self.winnerGang = 'security'
			return true
		end
		if (not gang1Alive) and not self.debugMode then
			self.winnerGang = 'gang2'
			return true
		end
		if (not gang2Alive) and not self.debugMode then
			self.winnerGang = 'gang1'
			return true
		end
		
		return false
	end,
	
	addClientToGang = function(self, client, gang)
		if self.gang1Set[client] or self.gang2Set[client] then return end
	
		DD.messageClients(gang, DD.stringLocalize('gangWarRecruitmentNotice', {name = client.Name}), {preset = 'goodinfo'})
		table.insert(gang, client)
		self.gang1Set = DD.toSet(self.gang1)
		self.gang2Set = DD.toSet(self.gang2)
		
		-- afflictions
		DD.giveAfflictionCharacter(client.Character, 'gangfx', 999)
		DD.giveAfflictionCharacter(client.Character, 'timepressureimmunity', 60 * 3) -- 3 minutes of time pressure immunity
		-- give talents
		client.character.GiveTalent('gangknowledge', true)
		if self.gang1Set[client] then
			client.Character.GiveTalent(self.gang1Color .. 'gangknowledge', true)
		else
			client.Character.GiveTalent(self.gang2Color .. 'gangknowledge', true)
		end
		-- custom salary for gang member
		DD.roundData.characterSalaryTimer[client.Character] = DD.jobSalaryTimer.securityofficer
		DD.roundData.salaryTimer[client] = DD.roundData.characterSalaryTimer[client.Character]
		-- message
		local gangName
		local rivalGangName
		if self.gang1Set[client] then
			gangName = self.gang1Name
			rivalGangName = self.gang2Name
		else
			gangName = self.gang2Name
			rivalGangName = self.gang1Name
		end
		DD.messageClient(client, DD.stringLocalize('gangWarGangsterInfo', {gangName = gangName, rivalGangName = rivalGangName}), {preset = 'crit'})
		
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
	
	doxGangster = function (self, client)
		if not self.knownGangstersSet[client] then
			DD.messageAllClients(DD.stringLocalize('gangWarDoxx', {name = DD.clientLogName(client)}), {preset = 'command'})
			table.insert(self.knownGangsters, client)
			self.knownGangstersSet[client] = true
			return
		end
	end,
	
	rewardSecurityForArrests = function (self, multiplier)
		local arrestedGangsters = 0
		for client in self.gang1 do
			if DD.isClientCharacterAlive(client) and DD.isCharacterArrested(client.Character) then
				arrestedGangsters = arrestedGangsters + 1
			end
		end
		for client in self.gang2 do
			if DD.isClientCharacterAlive(client) and DD.isCharacterArrested(client.Character) then
				arrestedGangsters = arrestedGangsters + 1
			end
		end
		
		if arrestedGangsters <= 0 then
			return
		end
		
		for client in Client.ClientList do
			if DD.isClientCharacterAlive(client) and DD.isCharacterSecurity(client.Character) then
				DD.giveMoneyToClient(client, arrestedGangsters * multiplier, true)
			end
		end
	end,
	
	onStart = function (self)
		self.winnerGang = nil
	
		-- gang names
		local gangNames = {
			pair = {
				{'Glass Jaws', 'Benedettos'},
				{'Powder Gangers', 'Tunnel Snakes'},
				{"Builder's League", 'Reliable Demos'},
				{'Blahds', 'Crepes'},
				{'Tea Musketeers', 'Yankee Eagles'},
				{'North Side', 'South Side'},
			},
			ego = {
				'Sons of Peter',
				'Ballast Bears',
				'Shark Shooters',
				'Evil Clouds',
				'Mellon Slicers',
				'Squatting Sonks',
				'Crab Bells',
			},
			free = {
				'Petrovic Mafiya',
				'Bosanska Trupa',
				'Gran Coppolas',
				'Eleganti Mafios',
				'Rojo Muertos',
				'Hombres Libres',
				'Pepsi Poppers',
				'Heavy Hitters',
				'Honking Clowns',
				'Freak Raptors',
				'Glue Sniffers',
				'Chair Knights',
				'Flaming Flares',
			},
		}
		local gangNamesClass = DD.tableKeys(gangNames)[math.random(#DD.tableKeys(gangNames))]
		gangNames = gangNames[gangNamesClass]
		gangNames = DD.arrShuffle(gangNames)
		if gangNamesClass == 'pair' then
			self.gang1Name = gangNames[1][1]
			self.gang2Name = gangNames[1][2]
		else
			self.gang1Name = gangNames[1]
			self.gang2Name = gangNames[2]
		end
		
		-- gang colors
		if self.gang2Name == nil then
			self.gang2Name = gangNames[2][1]
		end
		local gangColors = {
			'cyan',
			'yellow',
			'magenta'
		}
		gangColors = DD.arrShuffle(gangColors)
		self.gang1Color = gangColors[1]
		self.gang2Color = gangColors[2]
		
		-- gang members
		if self.gang1 == nil then
			self.gang1Set = {}
			self.gang1 = {}
		end
		if self.gang2 == nil then
			self.gang2Set = {}
			self.gang2 = {}
		end
		for client in DD.arrShuffle(Client.ClientList) do
			if DD.tableSize(self.gang1) + DD.tableSize(self.gang2) >= math.ceil(#Client.ClientList / 3) then
				break
			end
			if DD.isClientCharacterAlive(client) and (client.Character.SpeciesName == 'human') and (not DD.isCharacterArrested(client.Character)) and (not DD.isCharacterAntagSafe(client.Character)) then
				-- do not add client to a gang if he's already in one
				if not (self.gang1Set[client] or self.gang2Set[client]) then
					if DD.tableSize(self.gang1) <= DD.tableSize(self.gang2) then
						table.insert(self.gang1, client)
						self.gang1Set[client] = true
					else
						table.insert(self.gang2, client)
						self.gang2Set[client] = true
					end
				end
			end
		end
		
		-- Hei, Al Capone, vê se te emenda! Já sabem do teu furo, nego, no imposto de renda.
		self.knownGangsters = {}
		self.knownGangstersSet = {}
		self.doxTimer = 60 * 8
		self.clientDoxTimerOffset = {}
		-- Give gangsters a timer offset
		local amount
		amount = 0
		for client in self.gang1 do
			self.clientDoxTimerOffset[client] = self.doxTimer / #self.gang1 * amount / 2
			amount = amount + 1
		end
		amount = 0
		for client in self.gang2 do
			self.clientDoxTimerOffset[client] = self.doxTimer / #self.gang2 * amount / 2
			amount = amount + 1
		end
		
		-- set of living non-gangsters
		local aliveSet = {}
		for client in Client.ClientList do
			if DD.isClientCharacterAlive(client) and (client.Character.SpeciesName == 'human') then
				aliveSet[client] = true
			end
		end
		local nonGangSet = DD.setSubtract(DD.setSubtract(aliveSet, self.gang1Set), self.gang2Set)
		
		-- event requires 2 gangsters and 2 non-gangsters
		if ((DD.tableSize(self.gang1) + DD.tableSize(self.gang2) < 2) or (DD.tableSize(nonGangSet) < 2)) and not self.debugMode then
			self.fail()
			return
		else
			-- give affliction and do client messages
			for client in Client.ClientList do
				if self.gang1Set[client] or self.gang2Set[client] then
					-- afflictions
					DD.giveAfflictionCharacter(client.Character, 'gangfx', 999)
					DD.giveAfflictionCharacter(client.Character, 'timepressureimmunity', 60 * 3) -- 3 minutes of time pressure immunity
					-- give talents
					client.character.GiveTalent('gangknowledge', true)
					if self.gang1Set[client] then
						client.Character.GiveTalent(self.gang1Color .. 'gangknowledge', true)
					else
						client.Character.GiveTalent(self.gang2Color .. 'gangknowledge', true)
					end
					-- custom salary for gang member
					DD.roundData.characterSalaryTimer[client.Character] = DD.jobSalaryTimer.securityofficer
					DD.roundData.salaryTimer[client] = DD.roundData.characterSalaryTimer[client.Character]
					-- message
					local gangName
					local rivalGangName
					if self.gang1Set[client] then
						gangName = self.gang1Name
						rivalGangName = self.gang2Name
					else
						gangName = self.gang2Name
						rivalGangName = self.gang1Name
					end
					DD.messageClient(client, DD.stringLocalize('gangWarGangsterInfo', {gangName = gangName, rivalGangName = rivalGangName, timer = self.stateStartInitialTimer}), {preset = 'crit'})
				end
			end
			-- spawn airdrops for gangs
			local event = DD.eventAirdropSeparatist.new()
			event.start()
		end
	end,
	
	stateStartInitialTimer = 60 * 3, -- in seconds
	
	stateMain = {
		onChange = function (self, state)
			-- give affliction and do client messages
			for client in Client.ClientList do
				if self.parent.gang1Set[client] or self.parent.gang2Set[client] then
					-- message for gangsters
					DD.messageClient(client, DD.stringLocalize('gangWarGangsterReveal'), {preset = 'crit'})
				elseif (client.Character ~= nil) and DD.isCharacterSecurity(client.Character) then
					-- message for security
					DD.messageClient(client, DD.stringLocalize('gangWarSecurityInfo'), {preset = 'crit'})
				else
					-- message for commoners
					DD.messageClient(client, DD.stringLocalize('gangWarCommonerInfo'), {preset = 'crit'})
				end
				if client.Character ~= nil then DD.giveAfflictionCharacter(client.Character, 'notificationfx', 999) end
			end
			-- Make event public
			self.parent.public = true
		end,
		onThink = function (self)
			if (DD.thinkCounter % 30 ~= 0) or (not Game.RoundStarted) then return end
			local timesPerSecond = 2
			
			-- check for dead gangsters
			for key, client in pairs(self.parent.gang1) do
				if (client.Character == nil) or client.Character.IsDead then
					DD.messageClient(client, 'You have died and are not an antagonist anymore!', {preset = 'crit'})
					self.parent.gang1[key] = nil
					self.parent.gang1Set[client] = nil
					if client.Character ~= nil then
						DD.roundData.characterSalaryTimer[client.Character] = nil
					end
					DD.giveMoneyToClients(self.parent.gang2, 5, true)
				end
			end
			for key, client in pairs(self.parent.gang2) do
				if (client.Character == nil) or client.Character.IsDead then
					DD.messageClient(client, 'You have died and are not an antagonist anymore!', {preset = 'crit'})
					self.parent.gang2[key] = nil
					self.parent.gang2Set[client] = nil
					if client.Character ~= nil then
						DD.roundData.characterSalaryTimer[client.Character] = nil
					end
					DD.giveMoneyToClients(self.parent.gang1, 5, true)
				end
			end
			
			-- dox gangsters
			if self.parent.doxTimer > 0 then
				self.parent.doxTimer = self.parent.doxTimer - 1 / timesPerSecond
			end
			for client in self.parent.gang1 do
				local offset = 0
				if self.parent.clientDoxTimerOffset[client] ~= nil then offset = self.parent.clientDoxTimerOffset[client] end
				if self.parent.doxTimer - offset <= 0 then
					self.parent.doxGangster(client)
				end
			end
			for client in self.parent.gang2 do
				local offset = 0
				if self.parent.clientDoxTimerOffset[client] ~= nil then offset = self.parent.clientDoxTimerOffset[client] end
				if self.parent.doxTimer - offset <= 0 then
					self.parent.doxGangster(client)
				end
			end
			
			-- Increase time pressure
			local timeToExplode = 12 * 60 -- in seconds
			for client in self.parent.gang1 do
				DD.giveAfflictionCharacter(client.Character, 'timepressure', 60/timeToExplode/timesPerSecond)
			end
			for client in self.parent.gang2 do
				DD.giveAfflictionCharacter(client.Character, 'timepressure', 60/timeToExplode/timesPerSecond)
			end
			
			if self.parent.getShouldFinish() then
				self.parent.finish()
			end
		end,
	},
	
	onCharacterDeath = function (self, character)
		local client = DD.findClientByCharacter(character)
		if client == nil then return end
		if self.gang1Set[client] then
			for key, client in pairs(self.gang1) do
				if not DD.isClientCharacterAlive(client) then
					DD.messageClient(client, 'You have died and are not an antagonist anymore!', {preset = 'crit'})
					self.gang1[key] = nil
					self.gang1Set[client] = nil
					DD.roundData.characterSalaryTimer[client.Character] = nil
					DD.giveMoneyToClients(self.gang2, 5, true)
				end
			end
		end
		if self.gang2Set[client] then
			for key, client in pairs(self.gang2) do
				if not DD.isClientCharacterAlive(client) then
					DD.messageClient(client, 'You have died and are not an antagonist anymore!', {preset = 'crit'})
					self.gang2[key] = nil
					self.gang2Set[client] = nil
					DD.roundData.characterSalaryTimer[client.Character] = nil
					DD.giveMoneyToClients(self.gang1, 5, true)
				end
			end
		end
	end,
	
	onChatMessage = function (self, message, sender)
		if message ~= '/gang' then return end
		
		local message = ''
		if self.gang1Set[sender] or self.gang2Set[sender] then
			-- Build  list
			local list
			if self.gang1Set[sender] then
				list = self.buildList(self.gang1Set, nil, true)
			elseif self.gang2Set[sender] then
				list = self.buildList(self.gang2Set, nil, true)
			end
			message = 'Your fellow gang members are: ' .. list .. '. '
		end
		-- Build  list
		local list
		list = self.buildList(self.knownGangstersSet, nil, true)
		if list == '' then list = 'empty' end
		message = message .. 'Public list of gangsters is: ' .. list .. '. '
		DD.messageClient(sender, message, {preset = 'command'})
		
		return true
	end,
	
	onFinish = function (self)
		-- This is the end, beautiful friend. This is the end, my only friend. The end of our elaborated plans, the end of everything that stands. The end
		for client in Client.ClientList do
			if client.Character ~= nil then DD.giveAfflictionCharacter(client.Character, 'notificationfx', 999) end
		end
		self.rewardSecurityForArrests(5)
		if self.winnerGang == 'gang1' then
			DD.messageAllClients(DD.stringLocalize('gangWarEndGang', {gangName = self.gang1Name, rivalGangName = self.gang2Name}), {preset = 'goodinfo'})
		elseif self.winnerGang == 'gang2' then
			DD.messageAllClients(DD.stringLocalize('gangWarEndGang', {gangName = self.gang2Name, rivalGangName = self.gang1Name}), {preset = 'goodinfo'})
		elseif self.winnerGang == 'security' then
			for client in Client.ClientList do
				DD.giveMoneyToClient(client, 10, true)
			end
			DD.messageAllClients(DD.stringLocalize('gangWarEndSecurity'), {preset = 'goodinfo'})
		else
			DD.messageAllClients(DD.stringLocalize('gangWarEndNeutral'), {preset = 'goodinfo'})
		end
	end,
	
	onFinishAlways = function (self)
		if self.gang1 == nil then self.gang1 = {} end
		if self.gang2 == nil then self.gang2 = {} end
		for client in self.gang1 do
			if client.Character ~= nil then
				if client.Character.CharacterHealth.GetAffliction('timepressure', true) ~= nil then
					client.Character.CharacterHealth.GetAffliction('timepressure', true).SetStrength(0)
				end
				if self.winnerGang ~= 'gang1' then
					DD.roundData.characterSalaryTimer[client.Character] = nil
				end
			end
		end
		for client in self.gang2 do
			if client.Character ~= nil then
				if client.Character.CharacterHealth.GetAffliction('timepressure', true) ~= nil then
					client.Character.CharacterHealth.GetAffliction('timepressure', true).SetStrength(0)
				end
				if self.winnerGang ~= 'gang2' then
					DD.roundData.characterSalaryTimer[client.Character] = nil
				end
			end
		end
	end
})