-- Affliction gives a few people a certain affliction
DD.eventAffliction = DD.class(DD.eventBase, nil, {
	name = 'affliction',
	isMainEvent = false,
	cooldown = 0,
	weight = 0,
	goodness = 0,
	
	identifier = '',
	minamount = 0,
	maxamount = 0,
	ratio = 0,
	message = DD.stringLocalize('afflictionMessage'),
	
	onStart = function (self)
		local infected = 0
		for client in DD.arrShuffle(Client.ClientList) do
			if DD.isClientCharacterAlive(client) and
			(client.Character.SpeciesName == 'human') and
			(infected < math.ceil(#Client.ClientList * self.ratio)) and
			DD.isCharacterUsingHullOxygen(client.Character) then
				DD.giveAfflictionCharacter(client.Character, self.identifier, self.minamount + math.max(0, self.maxamount - self.minamount) * math.random())
				infected = infected + 1
			end
		end
		
		if self.message ~= nil then
			DD.messageAllClients(self.message, {preset = 'badinfo'})
			for client in Client.ClientList do
				if client.Character ~= nil then DD.giveAfflictionCharacter(client.Character, 'notificationfx', 999) end
			end
		end
	end
})

-- Flu event
DD.eventAfflictionFlu = DD.class(DD.eventAffliction, nil, {
	name = 'afflictionFlu',
	isMainEvent = false,
	cooldown = 60 * 1.5,
	weight = 0.4,
	goodness = -0.5,
	
	identifier = 'fluinfection',
	minamount = 1,
	maxamount = 10,
	ratio = 1/5
})

-- TB event
DD.eventAfflictionTB = DD.class(DD.eventAffliction, nil, {
	name = 'afflictionTB',
	isMainEvent = false,
	cooldown = 60 * 1.5,
	weight = 0.3,
	goodness = -1.5,
	
	identifier = 'tbinfection',
	minamount = 1,
	maxamount = 10,
	ratio = 1/5
})

-- Husk event
--[[
DD.eventAfflictionHusk = DD.class(DD.eventAffliction, nil, {
	name = 'afflictionHusk',
	isMainEvent = false,
	cooldown = 60 * 3,
	weight = 0.25,
	goodness = -1.5,
	
	identifier = 'huskinfection',
	minamount = 1,
	maxamount = 1,
	ratio = 1/4
})
--]]