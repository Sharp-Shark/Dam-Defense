-- Affliction gives a few people a certain affliction
DD.eventAffliction = DD.class(DD.eventBase, nil, {
	name = 'affliction',
	isMainEvent = false,
	cooldown = 60 * 2,
	weight = 1,
	goodness = -0.5,
	
	identifier = '',
	minamount = 0,
	maxamount = 0,
	ratio = 0,
	message = '',
	
	onStart = function (self)
		local infected = 0
		for client in Client.ClientList do
			if DD.isClientCharacterAlive(client) and infected < math.ceil(#Client.ClientList * self.ratio) then
				DD.giveAfflictionCharacter(client.Character, self.identifier, self.minamount + math.max(0, self.maxamount - self.minamount) * math.random())
			end
		end
		
		if self.message ~= nil then DD.messageAllClients(self.message, {preset = 'badinfo'}) end
	end
})

-- Flu event
DD.eventFlu = DD.class(DD.eventAffliction, nil, {
	name = 'afflictionFlu',
	isMainEvent = false,
	cooldown = 60 * 2,
	weight = 1,
	goodness = -0.5,
	
	identifier = 'fluhidden',
	minamount = 5,
	maxamount = 50,
	ratio = 1/3,
	message = 'It is suspected there may be a flu outbreak in the region.'
})

-- Husk event
DD.eventHusk = DD.class(DD.eventAffliction, nil, {
	name = 'afflictionHusk',
	isMainEvent = false,
	cooldown = 60 * 3,
	weight = 0.5,
	goodness = -1,
	
	identifier = 'huskinfection',
	minamount = 1,
	maxamount = 1,
	ratio = 1/4,
	message = 'It is suspected there may be a husk outbreak in the region.'
})