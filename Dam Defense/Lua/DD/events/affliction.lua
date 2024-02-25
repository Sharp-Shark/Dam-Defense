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
	message = 'It is suspected there may be an outbreak in the region. However, it is not yet known what the disease is.',
	
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
		
		if self.message ~= nil then DD.messageAllClients(self.message, {preset = 'badinfo'}) end
	end
})

-- Flu event
DD.eventAfflictionFlu = DD.class(DD.eventAffliction, nil, {
	name = 'afflictionFlu',
	isMainEvent = false,
	cooldown = 60 * 2,
	weight = 0.5,
	goodness = -0.5,
	
	identifier = 'fluhidden',
	minamount = 5,
	maxamount = 50,
	ratio = 1/4
})

-- TB event
DD.eventAfflictionTB = DD.class(DD.eventAffliction, nil, {
	name = 'afflictionTB',
	isMainEvent = false,
	cooldown = 60 * 2,
	weight = 0.25,
	goodness = -1,
	
	identifier = 'tbhidden',
	minamount = 5,
	maxamount = 50,
	ratio = 1/4
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