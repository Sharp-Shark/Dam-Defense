-- Main event where 2 gangs fight. Although it is a main event, it can't possibly cause the round to end
DD.eventGangWar = DD.class(DD.eventBase, function (self, gang1, gang2)
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
	clientKeys = {'eventGangWar'},
	
	name = 'eventGangWar',
	isMainEvent = true,
	cooldown = 60 * 6,
	weight = 1.5,
	goodness = -0.5,
	
	-- set this to false unless testing the event
	debugMode = false,
	
	buildList = function (self, set, excludeSet)
		local excludeSet = excludeSet or {}
		local clients = DD.setSubtract(set, excludeSet)
		
		local text = ''
		for client, value in pairs(set) do
			text = text .. client.Name .. ', '
		end
		text = string.sub(text, 1, #text - 2)
		return text
	end,
	
	doxGangster = function (self, gang)
		for client in DD.arrShuffle(gang) do
			if not self.knownGangstersSet[client] then
				DD.messageAllClients(DD.stringLocalize('gangWarDoxx', {name = client.Name}), {preset = 'command'})
				table.insert(self.knownGangsters, client)
				self.knownGangstersSet[client] = true
				return
			end
		end
	end,
	
	rewardSecurityForArrests = function (self, timesPerSecond)
		if self.rewardSecurityTimer == nil then
			self.rewardSecurityTimer = 60
			return
		elseif self.rewardSecurityTimer > 0 then
			self.rewardSecurityTimer = self.rewardSecurityTimer - 1 / timesPerSecond
			return
		else
			self.rewardSecurityTimer = 60
		end
	
		local arrestedGangsters = 0
		for client in self.gang1 do
			if (client.Character ~= nil) and (not client.Character.IsDead) and client.Character.IsHandcuffed then
				arrestedGangsters = arrestedGangsters + 1
			end
		end
		for client in self.gang2 do
			if (client.Character ~= nil) and (not client.Character.IsDead) and client.Character.IsHandcuffed then
				arrestedGangsters = arrestedGangsters + 1
			end
		end
		
		for client in Client.ClientList do
			if DD.isClientCharacterAlive(client) and DD.isCharacterSecurity(client.Character) then
				DD.giveMoneyToClient(client, arrestedGangsters, true)
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
			if DD.isClientCharacterAlive(client) and (client.Character.SpeciesName == 'human') and (not client.Character.IsHandcuffed) and (not DD.isCharacterAntagSafe(client.Character)) then
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
		local doxTimer = 60 * 8
		self.gang1DoxInitialTimer = doxTimer / DD.tableSize(self.gang1)
		self.gang1DoxTimer = self.gang1DoxInitialTimer
		self.gang2DoxInitialTimer = doxTimer / DD.tableSize(self.gang2)
		self.gang2DoxTimer = self.gang2DoxInitialTimer
		
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
					DD.messageClient(client, DD.stringLocalize('gangWarGangsterInfo', {gangName = gangName, rivalGangName = rivalGangName}), {preset = 'crit'})
				elseif (client.Character ~= nil) and DD.isCharacterSecurity(client.Character) then
					-- message for security
					DD.messageClient(client, DD.stringLocalize('gangWarSecurityInfo'), {preset = 'crit'})
				else
					-- message for commoners
					DD.messageClient(client, DD.stringLocalize('gangWarCommonerInfo'), {preset = 'crit'})
				end
			end
			-- spawn airdrops for gangs
			local event = DD.eventAirdropSeparatist.new()
			event.start()
		end
	end,
	
	onThink = function (self)
		if (DD.thinkCounter % 30 ~= 0) or (not Game.RoundStarted) then return end
		local timesPerSecond = 2
		
		-- check for dead gangsters
		for key, client in pairs(self.gang1) do
			if (client.Character == nil) or client.Character.IsDead then
				DD.messageClient(client, 'You have died and are not an antagonist anymore!', {preset = 'crit'})
				self.gang1[key] = nil
				self.gang1Set[client] = nil
				DD.roundData.characterSalaryTimer[client.Character] = nil
				DD.giveMoneyToClients(self.gang2, 5, true)
			end
		end
		for key, client in pairs(self.gang2) do
			if (client.Character == nil) or client.Character.IsDead then
				DD.messageClient(client, 'You have died and are not an antagonist anymore!', {preset = 'crit'})
				self.gang2[key] = nil
				self.gang2Set[client] = nil
				DD.roundData.characterSalaryTimer[client.Character] = nil
				DD.giveMoneyToClients(self.gang1, 5, true)
			end
		end
		
		-- dox gangsters
		if self.gang1DoxTimer > 0 then
			self.gang1DoxTimer = self.gang1DoxTimer - 1 / timesPerSecond
		else
			self.gang1DoxTimer = self.gang1DoxInitialTimer
			self.doxGangster(self.gang1)
		end
		if self.gang2DoxTimer > 0 then
			self.gang2DoxTimer = self.gang2DoxTimer - 1 / timesPerSecond
		else
			self.gang2DoxTimer = self.gang2DoxInitialTimer
			self.doxGangster(self.gang2)
		end
		
		-- reward security
		self.rewardSecurityForArrests(timesPerSecond)
		
		-- Increase time pressure
		local timeToExplode = 12 * 60 -- in seconds
		for client in self.gang1 do
			DD.giveAfflictionCharacter(client.Character, 'timepressure', 60/timeToExplode/timesPerSecond)
		end
		for client in self.gang2 do
			DD.giveAfflictionCharacter(client.Character, 'timepressure', 60/timeToExplode/timesPerSecond)
		end
		
		-- end event
		if (DD.tableSize(self.gang1) + DD.tableSize(self.gang2) <= 0) and not self.debugMode then
			self.finish()
			return
		end
		if (DD.tableSize(self.gang1) <= 0) and not self.debugMode then
			self.winnerGang = 'gang2'
			self.finish()
			return
		end
		if (DD.tableSize(self.gang2) <= 0) and not self.debugMode then
			self.winnerGang = 'gang1'
			self.finish()
			return
		end
	end,
	
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
				list = self.buildList(self.gang1Set)
			elseif self.gang2Set[sender] then
				list = self.buildList(self.gang2Set)
			end
			message = 'Your fellow gang members are: ' .. list .. '. '
		end
		-- Build  list
		local list
		list = self.buildList(self.knownGangstersSet)
		if list == '' then list = 'empty' end
		message = message .. 'Public list of gangsters is: ' .. list .. '. '
		DD.messageClient(sender, message, {preset = 'command'})
		
		return true
	end,
	
	onFinish = function (self)
		-- This is the end, beautiful friend. This is the end, my only friend. The end of our elaborated plans, the end of everything that stands. The end
		if self.winnerGang == 'gang1' then
			DD.messageAllClients(DD.stringLocalize('gangWarEndGang', {gangName = self.gang1Name, rivalGangName = self.gang2Name}), {preset = 'goodinfo'})
		elseif self.winnerGang == 'gang2' then
			DD.messageAllClients(DD.stringLocalize('gangWarEndGang', {gangName = self.gang2Name, rivalGangName = self.gang1Name}), {preset = 'goodinfo'})
		else
			DD.messageAllClients(DD.stringLocalize('gangWarEndNeutral'), {preset = 'goodinfo'})
		end
	end,
	
	onFinishAlways = function (self)
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