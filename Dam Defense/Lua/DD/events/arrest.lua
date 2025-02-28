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
			self.fail('"self.target" is nil at "onStart"')
			return
		end
		
		if self.isTargetKnown then
			DD.messageClient(self.target, DD.stringLocalize('arrestMessageTargetKnownTarget', {charge = self.charge}), {preset = 'crit'})
		else
			DD.messageClient(self.target, DD.stringLocalize('arrestMessageTargetUnknownTarget', {charge = self.charge}), {preset = 'crit'})
		end
		for client in Client.ClientList do
			if client ~= self.target then
				local preset = 'info'
				if (client.Character ~= nil) and (client.Character.SpeciesName == 'human') and DD.isCharacterSecurity(client.Character) then preset = 'crit' end
				if self.isTargetKnown then
					DD.messageClient(client, DD.stringLocalize('arrestMessageSecurityKnownTarget', {target = self.target.Name, charge = self.charge}), {preset = preset})
				else
					DD.messageClient(client, DD.stringLocalize('arrestMessageSecurityUnknownTarget', {charge = self.charge}), {preset = preset})
				end
			end
			if client.Character ~= nil then DD.giveAfflictionCharacter(client.Character, 'notificationfx', 999) end
		end
	end,
	
	onThink = function (self)
		if (DD.thinkCounter % 30 ~= 0) or (not Game.RoundStarted) then return end
		
		if (self.target == nil) then
			self.fail('"self.target" is nil at "onThink"')
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
			DD.messageAllClients(DD.stringLocalize('arrestMessageEndArrested', {target = self.target.Name, charge = self.charge}), {preset = 'goodinfo'})
		else
			DD.messageAllClients(DD.stringLocalize('arrestMessageEnd', {target = self.target.Name, charge = self.charge}), {preset = 'info'})
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
		DD.stringLocalize('arrestSillyCharge1'),
		DD.stringLocalize('arrestSillyCharge2'),
		DD.stringLocalize('arrestSillyCharge3'),
		DD.stringLocalize('arrestSillyCharge4'),
		DD.stringLocalize('arrestSillyCharge5'),
		DD.stringLocalize('arrestSillyCharge6'),
		DD.stringLocalize('arrestSillyCharge7'),
		DD.stringLocalize('arrestSillyCharge8'),
		DD.stringLocalize('arrestSillyCharge9'),
		DD.stringLocalize('arrestSillyCharge10'),
		DD.stringLocalize('arrestSillyCharge11'),
		DD.stringLocalize('arrestSillyCharge12'),
		DD.stringLocalize('arrestSillyCharge13'),
		DD.stringLocalize('arrestSillyCharge14'),
		DD.stringLocalize('arrestSillyCharge15'),
		DD.stringLocalize('arrestSillyCharge16'),
		DD.stringLocalize('arrestSillyCharge17'),
		DD.stringLocalize('arrestSillyCharge18'),
		DD.stringLocalize('arrestSillyCharge19'),
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