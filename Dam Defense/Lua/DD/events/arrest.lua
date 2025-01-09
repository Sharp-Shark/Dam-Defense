-- Tasks security with (ideally) arresting a player
DD.eventArrest = DD.class(DD.eventBase, function (self, target, charge, isTargetKnown)
	self.target = target
	self.charge = charge or 'a currently undisclosed crime'
	self.isTargetKnown = isTargetKnown
	if self.isTargetKnown == nil then self.isTargetKnown = false end
end, {
	paramType = {'client', 'string', 'boolean'},
	clientKeys = {'target'},
	
	name = 'arrest',
	isMainEvent = false,
	cooldown = 60 * 2,
	weight = 0,
	goodness = 0,
	
	onStart = function (self)
		if self.target == nil then
			self.fail()
			return
		end
		
		if self.isTargetKnown then
			DD.messageClient(self.target, 'You have been charged with ' .. self.charge .. '! Try to avoid security.', {preset = 'crit'})
		else
			DD.messageClient(self.target, 'Security is after an unknown criminal who was charged with ' .. self.charge .. '. The criminal is you, but they do not know that for now.', {preset = 'crit'})
		end
		for client in Client.ClientList do
			if client ~= self.target then
				local preset = 'info'
				if (client.Character ~= nil) and (client.Character.SpeciesName == 'human') and DD.isCharacterSecurity(client.Character) then preset = 'crit' end
				if self.isTargetKnown then
					DD.messageClient(client, self.target.Name .. ' has been charged with ' .. self.charge .. ' and must be lawfully arrested!', {preset = preset})
				else
					DD.messageClient(client, 'An unknown criminal has been charged with ' .. self.charge .. '! Find out who they are and lawfully arrest them.', {preset = preset})
				end
			end
			if client.Character ~= nil then DD.giveAfflictionCharacter(client.Character, 'notificationfx', 999) end
		end
	end,
	
	onThink = function (self)
		if (DD.thinkCounter % 30 ~= 0) or (not Game.RoundStarted) then return end
		
		if (self.target == nil) then
			self.fail()
			return
		end
		
		if (not DD.isClientCharacterAlive(self.target)) or DD.isCharacterArrested(self.target.Character) then
			self.finish()
		end
	end,
	
	onCharacterDeath = function (self, character)
		if (self.target.Character ~= nil) and (self.target.Character == character) then self.finish() end
	end,
	
	onFinish = function (self)
		if DD.isClientCharacterAlive(self.target) and DD.isCharacterArrested(self.target.Character) then
			DD.giveMoneyToSecurity(5, true)
			DD.messageAllClients('Justice at last! The criminal known as ' .. self.target.Name .. ' who was charged with ' .. self.charge .. ' has been arrested.', {preset = 'goodinfo'})
		else
			DD.messageAllClients('Security failed to arrest ' .. self.target.Name .. ' who was charged with ' .. self.charge .. ' and they are now dead.', {preset = 'info'})
		end
	end
})

-- Tasks security with (ideally) arresting a player for a silly reason
DD.eventArrest1984 = DD.class(DD.eventArrest, function (self)
	for client in DD.arrShuffle(Client.ClientList) do
		if DD.isClientCharacterAlive(client) and (client.Character.SpeciesName == 'human') and (not DD.isCharacterArrested(client.Character)) and (not DD.isCharacterAntagSafe(client.Character)) and DD.eventDirector.isClientBelowEventCap(client) then
			self.target = client
			break
		end
	end
	local sillyCharges = {
		'being a silly goober',
		'promiscuity',
		'indecent display',
		'public urination',
		'just being generally unpleasent',
		'bad vibes',
		'existing',
		'being a real goofball',
		'being real mood killer',
		'liking hitler and kicking puppies',
		'being hella sus',
		'not liking Breaking Bad',
		'being bad to the bone (panana-nana)',
		'blatant homosexuality',
		'blatant heterosexuality',
		'making bad dad jokes',
		'being like, totally super lame bro',
		'cronic uncoolness',
		'skill issue'
	}
	self.charge = sillyCharges[math.random(#sillyCharges)]
	self.isTargetKnown = true
end, {
	name = 'arrest1984',
	isMainEvent = false,
	cooldown = 60 * 2,
	weight = 0.5,
	goodness = -0.5
})