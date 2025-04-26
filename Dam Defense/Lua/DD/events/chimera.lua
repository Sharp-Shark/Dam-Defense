-- spawns a dead player as a husk chimera
DD.eventChimera = DD.class(DD.eventBase, function (self, chimera)
	self.chimera = chimera
end, {
	paramType = {'client'},
	clientKeys = {'chimera'},
	public = true,
	
	name = 'chimera',
	instanceCap = 1,
	isMainEvent = false,
	cooldown = 60 * 3,
	weight = 2,
	goodness = -4,
	minimunDeadPercentage = 0.05,
	minimunTimeElapsed = 5 * 60,
	
	onStart = function (self)
		-- pick client to be chimera
		if self.chimera == nil then
			for client in DD.arrShuffle(Client.ClientList) do
				if DD.isClientRespawnable(client) and client.InGame then
					self.chimera = client
					break
				end
			end
		end
		
		-- event requires 5 or more players
		if (self.chimera == nil) or ((not self.manuallyTriggered) and (DD.tableSize(Client.ClientList) <= 4)) then
			self.fail('conditions to start could not be met')
			return
		else
			-- Spawn chimera
			local location = DD.getLocation(function (item) return item.HasTag('dd_wetsewer') end)
			local locationName = tostring(location.CurrentHull.RoomName)
			if TextManager.Get(locationName) ~= nil then locationName = tostring(TextManager.Get(locationName)) end
			
			Entity.Spawner.AddCharacterToSpawnQueue('Husk_chimera', location.WorldPosition, function (character)
				self.chimeraCharacter = character
				self.chimera.SetClientCharacter(character)
				DD.chatMessageFunctions.jobinfo('', self.chimera, true)
			end)
			
			DD.messageAllClients(DD.stringLocalize('fishMessage', {fishCount = 1, fishName = 'husk chimera', locationName = locationName}), {preset = 'badinfo'})
			for client in Client.ClientList do
				if client.Character ~= nil then DD.giveAfflictionCharacter(client.Character, 'notificationfx', 999) end
			end
		end
	end,
	
	onThink = function (self)
		if (DD.thinkCounter % 30 ~= 0) or (not Game.RoundStarted) then return end
		local timesPerSecond = 2
		
		if (self.chimera ~= nil) and (self.chimera.Character ~= self.chimeraCharacter) then
			local client = DD.findClientByCharacter(self.chimeraCharacter)
			if client ~= nil then self.chimera = client end
		end
		
		if self.chimeraCharacter == nil then
			self.fail('"self.chimeraCharacter" is nil at "onThink"')
			return
		end
		
		if self.chimeraCharacter.IsDead then
			self.finish()
		end
	end,
	
	onCharacterDeath = function (self, character)
		if self.chimeraCharacter == nil then
			self.fail('"self.chimeraCharacter" is nil at "onCharacterDeath"')
			return
		end
		
		if self.chimeraCharacter == character then
			self.finish()
		end
	end,
	
	onFinish = function (self)
		DD.messageAllClients(DD.stringLocalize('chimeraEnd'), {preset = 'goodinfo'})
	end,
	
	onFinishAlways = function (self)
		if self.chimeraCharacter ~= nil then
			self.chimeraCharacter.Kill(CauseOfDeathType.Disconnected, nil, true, true)
		end
	end,
})